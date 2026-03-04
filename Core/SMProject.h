//
//  SMProject.h
//  SmallMontage
//
//  Document model: multiple tracks (video and audio), serialization.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SMTrack;

@interface SMProject : NSObject {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    double _frameRate;
    NSInteger _width;
    NSInteger _height;
    NSMutableArray *_tracks;
    BOOL _dirty;
#endif
}

/// Project frame rate (frames per second). Default 25.
@property (nonatomic, assign) double frameRate;

/// Video width for export. Default 1920.
@property (nonatomic, assign) NSInteger width;

/// Video height for export. Default 1080.
@property (nonatomic, assign) NSInteger height;

/// All tracks (video first, then audio). Order matters for composition.
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, retain) NSMutableArray *tracks;
#else
@property (nonatomic, strong) NSMutableArray<SMTrack *> *tracks;
#endif

/// Whether the project has unsaved changes.
@property (nonatomic, assign) BOOL dirty;

- (instancetype)init;

- (SMTrack *)addVideoTrackWithName:(NSString *)name;
- (SMTrack *)addAudioTrackWithName:(NSString *)name;

/// Total length of the project in frames (max of all track lengths).
- (NSInteger)length;

- (BOOL)writeToFile:(NSString *)path error:(NSError **)outError;
- (instancetype)initWithContentsOfFile:(NSString *)path error:(NSError **)outError;

@end

NS_ASSUME_NONNULL_END
