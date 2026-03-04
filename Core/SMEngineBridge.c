//
//  SMEngineBridge.c
//  SmallMontage
//
//  C bridge to MLT for building tractor/multitrack from track/clip data,
//  preview (SDL2 consumer), and export (avformat).
//

#include "SMEngineBridge.h"
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#ifdef HAVE_MLT
#include <framework/mlt.h>

static int clip_compare_timeline(const void *a, const void *b) {
    const SMClipDesc *ca = (const SMClipDesc *)a;
    const SMClipDesc *cb = (const SMClipDesc *)b;
    return (ca->timeline_start > cb->timeline_start) - (ca->timeline_start < cb->timeline_start);
}

typedef struct SMEngineInternal {
    mlt_profile profile;
    mlt_tractor tractor;
    mlt_consumer consumer;
    pthread_t consumer_thread;
    int consumer_running;
} SMEngineInternal;

static mlt_playlist build_playlist(mlt_profile profile, SMTrackDesc *track) {
    mlt_playlist pl = mlt_playlist_new(profile);
    if (!pl) return NULL;

    /* Sort clips by timeline start */
    SMClipDesc *sorted = (SMClipDesc *)malloc((size_t)track->num_clips * sizeof(SMClipDesc));
    if (!sorted) { mlt_playlist_close(pl); return NULL; }
    memcpy(sorted, track->clips, (size_t)track->num_clips * sizeof(SMClipDesc));
    qsort(sorted, (size_t)track->num_clips, sizeof(SMClipDesc), clip_compare_timeline);

    mlt_position last_end = 0;
    for (int i = 0; i < track->num_clips; i++) {
        SMClipDesc *c = &sorted[i];
        if (c->path && c->timeline_start > last_end) {
            mlt_playlist_blank(pl, c->timeline_start - last_end);
        }
        if (c->path) {
            mlt_producer prod = mlt_factory_producer(profile, "loader", c->path);
            if (prod) {
                mlt_playlist_append_io(pl, prod, (mlt_position)c->in_point, (mlt_position)c->out_point);
                mlt_producer_close(prod);
            }
        }
        last_end = c->timeline_start + (c->out_point - c->in_point + 1);
    }
    free(sorted);
    return pl;
}

static void *consumer_thread_fn(void *arg) {
    SMEngineInternal *e = (SMEngineInternal *)arg;
    if (e->consumer)
        mlt_consumer_run(e->consumer);
    e->consumer_running = 0;
    return NULL;
}

SMEngineRef SMEngineCreate(double frame_rate, int width, int height) {
    if (!mlt_factory_init(NULL))
        return NULL;
    SMEngineInternal *e = (SMEngineInternal *)calloc(1, sizeof(SMEngineInternal));
    if (!e) { mlt_factory_close(); return NULL; }
    e->profile = mlt_profile_init(NULL);
    if (!e->profile) { free(e); mlt_factory_close(); return NULL; }
    mlt_profile_set_frame_rate(e->profile, frame_rate, 1);
    mlt_profile_set_width(e->profile, width);
    mlt_profile_set_height(e->profile, height);
    e->tractor = NULL;
    e->consumer = NULL;
    e->consumer_running = 0;
    return (SMEngineRef)e;
}

int SMEngineBuild(SMEngineRef engine, int num_tracks, SMTrackDesc *track_descs) {
    SMEngineInternal *e = (SMEngineInternal *)engine;
    if (!e || !e->profile || num_tracks <= 0 || !track_descs)
        return -1;
    if (e->tractor) {
        mlt_tractor_close(e->tractor);
        e->tractor = NULL;
    }
    mlt_tractor tractor = mlt_tractor_new();
    if (!tractor) return -1;
    mlt_multitrack multitrack = mlt_tractor_multitrack(tractor);
    if (!multitrack) { mlt_tractor_close(tractor); return -1; }

    for (int t = 0; t < num_tracks; t++) {
        mlt_playlist pl = build_playlist(e->profile, &track_descs[t]);
        if (!pl) {
            mlt_tractor_close(tractor);
            return -1;
        }
        mlt_producer track_prod = mlt_playlist_producer(pl);
        mlt_multitrack_connect(multitrack, track_prod, t);
        mlt_producer_close(track_prod);
        mlt_playlist_close(pl);
    }
    e->tractor = tractor;
    return 0;
}

int SMEngineStartPreview(SMEngineRef engine) {
    SMEngineInternal *e = (SMEngineInternal *)engine;
    if (!e || !e->tractor) return -1;
    if (e->consumer_running) return 0;
    mlt_consumer consumer = mlt_factory_consumer(e->profile, "sdl2", NULL);
    if (!consumer) return -1;
    mlt_consumer_connect(consumer, mlt_tractor_service(e->tractor));
    mlt_consumer_start(consumer);
    e->consumer = consumer;
    e->consumer_running = 1;
    pthread_create(&e->consumer_thread, NULL, consumer_thread_fn, e);
    return 0;
}

void SMEngineStopPreview(SMEngineRef engine) {
    SMEngineInternal *e = (SMEngineInternal *)engine;
    if (!e || !e->consumer) return;
    mlt_consumer_stop(e->consumer);
    while (e->consumer_running)
        pthread_yield();
    pthread_join(e->consumer_thread, NULL);
    mlt_consumer_close(e->consumer);
    e->consumer = NULL;
}

int SMEngineIsPreviewRunning(SMEngineRef engine) {
    SMEngineInternal *e = (SMEngineInternal *)engine;
    return e && e->consumer_running;
}

int SMEngineExport(SMEngineRef engine, const char *output_path) {
    SMEngineInternal *e = (SMEngineInternal *)engine;
    if (!e || !e->tractor || !output_path) return -1;
    mlt_consumer consumer = mlt_factory_consumer(e->profile, "avformat", output_path);
    if (!consumer) return -1;
    mlt_properties props = mlt_consumer_properties(consumer);
    mlt_properties_set(props, "target", output_path);
    mlt_properties_set(props, "muxer", "mp4");
    mlt_properties_set(props, "vcodec", "libx264");
    mlt_properties_set(props, "acodec", "aac");
    mlt_properties_set(props, "real_time", "0");
    mlt_consumer_connect(consumer, mlt_tractor_service(e->tractor));
    mlt_consumer_start(consumer);
    mlt_consumer_run(consumer);
    mlt_consumer_stop(consumer);
    mlt_consumer_close(consumer);
    return 0;
}

void SMEngineDestroy(SMEngineRef engine) {
    SMEngineInternal *e = (SMEngineInternal *)engine;
    if (!e) return;
    SMEngineStopPreview(engine);
    if (e->tractor)
        mlt_tractor_close(e->tractor);
    if (e->profile)
        mlt_profile_close(e->profile);
    free(e);
    mlt_factory_close();
}

#else
/* Stub implementation when MLT is not available */

SMEngineRef SMEngineCreate(double frame_rate, int width, int height) {
    (void)frame_rate;
    (void)width;
    (void)height;
    return NULL;
}

int SMEngineBuild(SMEngineRef engine, int num_tracks, SMTrackDesc *track_descs) {
    (void)engine;
    (void)num_tracks;
    (void)track_descs;
    return -1;
}

int SMEngineStartPreview(SMEngineRef engine) {
    (void)engine;
    return -1;
}

void SMEngineStopPreview(SMEngineRef engine) {
    (void)engine;
}

int SMEngineIsPreviewRunning(SMEngineRef engine) {
    (void)engine;
    return 0;
}

int SMEngineExport(SMEngineRef engine, const char *output_path) {
    (void)engine;
    (void)output_path;
    return -1;
}

void SMEngineDestroy(SMEngineRef engine) {
    (void)engine;
}

#endif
