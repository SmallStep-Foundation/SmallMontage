//
//  SMClip.h
//  SmallMontage
//
//  A single clip on a track: source file, in/out points, position on timeline.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMClip : NSObject {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    NSString *_sourcePath;
    NSInteger _inPoint;
    NSInteger _outPoint;
    NSInteger _timelineStart;
#endif
}

/// Path to the source media file.
@property (nonatomic, copy) NSString *sourcePath;

/// In point in source (frame index, 0-based).
@property (nonatomic, assign) NSInteger inPoint;

/// Out point in source (frame index, inclusive).
@property (nonatomic, assign) NSInteger outPoint;

/// Start position on the timeline (frame index).
@property (nonatomic, assign) NSInteger timelineStart;

/// Length on timeline in frames (derived: outPoint - inPoint + 1).
- (NSInteger)length;

/// End position on timeline (timelineStart + length - 1).
- (NSInteger)timelineEnd;

@end

NS_ASSUME_NONNULL_END
