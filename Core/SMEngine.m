//
//  SMEngine.m
//  SmallMontage
//

#import "SMEngine.h"
#import "SMProject.h"
#import "SMTrack.h"
#import "SMClip.h"
#import "SMEngineBridge.h"
#import <stdlib.h>
#import <string.h>

@implementation SMEngine

- (instancetype)init {
    self = [super init];
    if (self) {
        _engineRef = SMEngineCreate(25.0, 1920, 1080);
    }
    return self;
}

- (void)buildFromProject:(SMProject *)project {
    if (!project) return;
    NSArray *tracks = project.tracks;
    if (![tracks count]) return;

    if (_engineRef) {
        SMEngineDestroy(_engineRef);
        _engineRef = NULL;
    }
    _engineRef = SMEngineCreate(project.frameRate, (int)project.width, (int)project.height);
    if (!_engineRef) return;

    NSInteger n = [tracks count];
    SMTrackDesc *descs = (SMTrackDesc *)malloc((size_t)n * sizeof(SMTrackDesc));
    if (!descs) return;
    memset(descs, 0, (size_t)n * sizeof(SMTrackDesc));

    NSInteger t;
    for (t = 0; t < n; t++) {
        SMTrack *track = [tracks objectAtIndex:(NSUInteger)t];
        descs[t].is_video = (track.trackType == SMTrackTypeVideo) ? 1 : 0;
        descs[t].num_clips = (int)[track.clips count];
        if (descs[t].num_clips > 0) {
            descs[t].clips = (SMClipDesc *)calloc((size_t)descs[t].num_clips, sizeof(SMClipDesc));
            if (descs[t].clips) {
                NSInteger c;
                for (c = 0; c < descs[t].num_clips; c++) {
                    SMClip *clip = [track.clips objectAtIndex:(NSUInteger)c];
                    descs[t].clips[c].path = clip.sourcePath ? strdup([clip.sourcePath UTF8String]) : NULL;
                    descs[t].clips[c].in_point = (int)clip.inPoint;
                    descs[t].clips[c].out_point = (int)clip.outPoint;
                    descs[t].clips[c].timeline_start = (int)clip.timelineStart;
                }
            }
        }
    }

    SMEngineBuild(_engineRef, (int)n, descs);

    for (t = 0; t < n; t++) {
        if (descs[t].clips) {
            int c;
            for (c = 0; c < descs[t].num_clips; c++)
                free(descs[t].clips[c].path);
            free(descs[t].clips);
        }
    }
    free(descs);
}

- (BOOL)startPreview {
    if (!_engineRef) return NO;
    return SMEngineStartPreview(_engineRef) == 0;
}

- (void)stopPreview {
    if (_engineRef)
        SMEngineStopPreview(_engineRef);
}

- (BOOL)isPreviewRunning {
    return _engineRef && SMEngineIsPreviewRunning(_engineRef);
}

- (BOOL)exportToPath:(NSString *)path {
    if (!_engineRef || !path || [path length] == 0) return NO;
    return SMEngineExport(_engineRef, [path UTF8String]) == 0;
}

- (void)dealloc {
    if (_engineRef) {
        SMEngineDestroy(_engineRef);
        _engineRef = NULL;
    }
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
