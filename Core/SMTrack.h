//
//  SMTrack.h
//  SmallMontage
//
//  A single track (video or audio) containing an ordered list of clips.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SMTrackType) {
    SMTrackTypeVideo = 0,
    SMTrackTypeAudio = 1
};

@class SMClip;

@interface SMTrack : NSObject {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    SMTrackType _trackType;
    NSString *_name;
    NSMutableArray *_clips;
#endif
}

@property (nonatomic, assign) SMTrackType trackType;
@property (nonatomic, copy) NSString *name;
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, retain) NSMutableArray *clips;
#else
@property (nonatomic, strong) NSMutableArray<SMClip *> *clips;
#endif

- (instancetype)initWithType:(SMTrackType)type name:(NSString *)name;

/// Total length of track in frames (end of last clip).
- (NSInteger)length;

@end

NS_ASSUME_NONNULL_END
