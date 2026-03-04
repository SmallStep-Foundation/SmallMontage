//
//  SMEngineBridge.h
//  SmallMontage
//
//  C API for MLT engine: build tractor from track/clip data, preview, export.
//  Used by SMEngine (Obj-C).
//

#ifndef SMEngineBridge_h
#define SMEngineBridge_h

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct SMClipDesc {
    char *path;
    int in_point;
    int out_point;
    int timeline_start;
} SMClipDesc;

typedef struct SMTrackDesc {
    int is_video;  /* 1 = video, 0 = audio */
    int num_clips;
    SMClipDesc *clips;
} SMTrackDesc;

typedef void* SMEngineRef;

SMEngineRef SMEngineCreate(double frame_rate, int width, int height);
int SMEngineBuild(SMEngineRef engine, int num_tracks, SMTrackDesc *track_descs);
int SMEngineStartPreview(SMEngineRef engine);
void SMEngineStopPreview(SMEngineRef engine);
int SMEngineIsPreviewRunning(SMEngineRef engine);
int SMEngineExport(SMEngineRef engine, const char *output_path);
void SMEngineDestroy(SMEngineRef engine);

#ifdef __cplusplus
}
#endif

#endif /* SMEngineBridge_h */
