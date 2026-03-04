//
//  SMTimelineView.m
//  SmallMontage
//

#import "SMTimelineView.h"
#import "SMProject.h"
#import "SMTrack.h"
#import "SMClip.h"

static const CGFloat kTrackHeight = 48.0;
static const CGFloat kRulerHeight = 24.0;
static const CGFloat kLeftLabelWidth = 100.0;
static const double kDefaultFramesPerPixel = 0.5;

@implementation SMTimelineView

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize project = _project;
@synthesize delegate = _delegate;
@synthesize framesPerPixel = _framesPerPixel;
@synthesize playheadPosition = _playheadPosition;
@synthesize selectedTrackIndex = _selectedTrackIndex;
@synthesize selectedClipIndex = _selectedClipIndex;
#endif

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _project = nil;
        _framesPerPixel = kDefaultFramesPerPixel;
        _playheadPosition = 0;
        _selectedTrackIndex = -1;
        _selectedClipIndex = -1;
    }
    return self;
}

- (void)setProject:(SMProject *)project {
    _project = project;
    [self updateFrameSize];
    [self setNeedsDisplay:YES];
}

- (void)reloadData {
    [self updateFrameSize];
    [self setNeedsDisplay:YES];
}

- (void)updateFrameSize {
    CGFloat w = [self contentWidth];
    CGFloat h = [self contentHeight];
    [self setFrameSize:NSMakeSize(w, h)];
}

- (CGFloat)pixelsPerFrame {
    return 1.0 / (CGFloat)_framesPerPixel;
}

- (NSInteger)totalFrames {
    return _project ? [_project length] : 0;
}

- (CGFloat)contentWidth {
    NSInteger frames = [self totalFrames];
    if (frames <= 0) frames = (NSInteger)(25 * 60 * 10);
    return (CGFloat)frames * [self pixelsPerFrame];
}

- (NSInteger)trackCount {
    return _project ? (NSInteger)[_project.tracks count] : 0;
}

- (CGFloat)contentHeight {
    return kRulerHeight + (CGFloat)[self trackCount] * kTrackHeight;
}

- (void)drawRect:(NSRect)dirtyRect {
    (void)dirtyRect;
    NSRect bounds = [self bounds];
    [[NSColor windowBackgroundColor] setFill];
    NSRectFill(bounds);

    if (!_project) return;

    CGFloat ppf = [self pixelsPerFrame];
    NSInteger nTracks = [self trackCount];
    CGFloat totalH = kRulerHeight + (CGFloat)nTracks * kTrackHeight;

    /* Ruler */
    NSRect rulerRect = NSMakeRect(kLeftLabelWidth, totalH - kRulerHeight, bounds.size.width - kLeftLabelWidth, kRulerHeight);
    [[NSColor controlBackgroundColor] setFill];
    NSRectFill(rulerRect);
    [[NSColor gridColor] setStroke];
    NSFrameRect(rulerRect);
    NSInteger len = [self totalFrames];
    double fps = _project.frameRate;
    NSInteger f;
    for (f = 0; f <= len; f += (NSInteger)(fps * 5)) {
        CGFloat x = kLeftLabelWidth + (CGFloat)f * ppf;
        if (x > bounds.size.width) break;
        NSString *label = [NSString stringWithFormat:@"%ld", (long)((double)f / fps)];
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont systemFontOfSize:10], NSFontAttributeName,
            [NSColor labelColor], NSForegroundColorAttributeName, nil];
        [label drawAtPoint:NSMakePoint(x + 2, totalH - kRulerHeight + 4) withAttributes:attrs];
    }

    /* Tracks */
    NSInteger t;
    for (t = 0; t < nTracks; t++) {
        CGFloat y = totalH - kRulerHeight - (CGFloat)(t + 1) * kTrackHeight;
        NSRect trackRect = NSMakeRect(0, y, bounds.size.width, kTrackHeight);
        BOOL isVideo = ([[_project.tracks objectAtIndex:(NSUInteger)t] trackType] == SMTrackTypeVideo);
        [[NSColor colorWithCalibratedWhite:isVideo ? 0.92 : 0.96 alpha:1.0] setFill];
        NSRectFill(trackRect);
        [[NSColor gridColor] setStroke];
        NSFrameRect(trackRect);

        /* Track label */
        NSRect labelRect = NSMakeRect(4, y + 4, kLeftLabelWidth - 8, kTrackHeight - 8);
        NSString *name = [[_project.tracks objectAtIndex:(NSUInteger)t] name];
        if (![name length]) name = (isVideo ? @"Video" : @"Audio");
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSFont systemFontOfSize:11], NSFontAttributeName,
            [NSColor labelColor], NSForegroundColorAttributeName, nil];
        [name drawInRect:labelRect withAttributes:attrs];

        /* Clips */
        SMTrack *track = [_project.tracks objectAtIndex:(NSUInteger)t];
        NSInteger c;
        for (c = 0; c < (NSInteger)[track.clips count]; c++) {
            SMClip *clip = [track.clips objectAtIndex:(NSUInteger)c];
            CGFloat x = kLeftLabelWidth + (CGFloat)clip.timelineStart * ppf;
            CGFloat w = (CGFloat)[clip length] * ppf;
            if (w < 2) w = 2;
            NSRect clipRect = NSMakeRect(x, y + 2, w, kTrackHeight - 4);
            BOOL sel = (_selectedTrackIndex == t && _selectedClipIndex == c);
            if (sel)
                [[NSColor selectedControlColor] setFill];
            else {
                NSColor *accent = [NSColor colorWithCalibratedRed:0.0 green:0.48 blue:1.0 alpha:1.0];
                if (accent) [accent setFill];
                else [[NSColor blueColor] setFill];
            }
            NSRectFill(clipRect);
            [[NSColor darkGrayColor] setStroke];
            NSFrameRect(clipRect);
            NSString *clipName = [clip.sourcePath lastPathComponent];
            if ([clipName length] > 0)
                [clipName drawInRect:NSInsetRect(clipRect, 4, 0) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSFont systemFontOfSize:10], NSFontAttributeName,
                    [NSColor whiteColor], NSForegroundColorAttributeName, nil]];
        }
    }

    /* Playhead */
    CGFloat px = kLeftLabelWidth + (CGFloat)_playheadPosition * ppf;
    if (px >= kLeftLabelWidth && px < bounds.size.width) {
        [[NSColor redColor] setStroke];
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(px, 0)];
        [line lineToPoint:NSMakePoint(px, totalH)];
        [line setLineWidth:2];
        [line stroke];
    }
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint loc = [self convertPoint:[event locationInWindow] fromView:nil];
    CGFloat ppf = [self pixelsPerFrame];
    NSInteger nTracks = [self trackCount];
    CGFloat totalH = kRulerHeight + (CGFloat)nTracks * kTrackHeight;

    if (loc.x < kLeftLabelWidth) return;
    if (loc.y > totalH - kRulerHeight) return;

    NSInteger trackIdx = (NSInteger)((totalH - kRulerHeight - loc.y) / kTrackHeight);
    if (trackIdx < 0 || trackIdx >= nTracks) {
        _selectedTrackIndex = -1;
        _selectedClipIndex = -1;
        [self setNeedsDisplay:YES];
        return;
    }
    NSInteger frame = (NSInteger)((loc.x - kLeftLabelWidth) / ppf);
    SMTrack *track = [_project.tracks objectAtIndex:(NSUInteger)trackIdx];
    NSInteger found = -1;
    NSInteger c;
    for (c = 0; c < (NSInteger)[track.clips count]; c++) {
        SMClip *clip = [track.clips objectAtIndex:(NSUInteger)c];
        if (frame >= clip.timelineStart && frame <= [clip timelineEnd]) {
            found = c;
            break;
        }
    }
    _selectedTrackIndex = trackIdx;
    _selectedClipIndex = found;
    [self setNeedsDisplay:YES];
}

@end
