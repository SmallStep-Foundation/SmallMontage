//
//  SMTimelineView.h
//  SmallMontage
//
//  Timeline view: multiple tracks (video/audio), clips as blocks, time ruler, playhead.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SMProject;
@class SMClip;

@protocol SMTimelineViewDelegate <NSObject>
@optional
- (void)timelineViewDidChange:(NSView *)view;
@end

@interface SMTimelineView : NSView {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    SMProject *_project;
    id _delegate;
    double _framesPerPixel;
    NSInteger _playheadPosition;
    NSInteger _selectedTrackIndex;
    NSInteger _selectedClipIndex;
#endif
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, retain) SMProject *project;
@property (nonatomic, assign) id<SMTimelineViewDelegate> delegate;
#else
@property (nonatomic, strong) SMProject *project;
@property (nonatomic, weak) id<SMTimelineViewDelegate> delegate;
#endif

/// Frames per pixel (zoom). Larger = more zoomed in.
@property (nonatomic, assign) double framesPerPixel;

/// Current playhead position in frames.
@property (nonatomic, assign) NSInteger playheadPosition;

/// Selected clip (track index, clip index); -1 if none.
@property (nonatomic, assign) NSInteger selectedTrackIndex;
@property (nonatomic, assign) NSInteger selectedClipIndex;

- (void)reloadData;

- (CGFloat)contentWidth;
- (CGFloat)contentHeight;

@end

NS_ASSUME_NONNULL_END
