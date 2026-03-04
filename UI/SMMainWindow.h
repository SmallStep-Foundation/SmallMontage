//
//  SMMainWindow.h
//  SmallMontage
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SMProject;
@class SMEngine;
@class SMTimelineView;

@interface SMMainWindow : NSWindow {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    NSView *_toolStrip;
    NSScrollView *_scrollView;
    SMTimelineView *_timelineView;
    SMProject *_project;
    SMEngine *_engine;
    NSString *_documentPath;
#endif
}

- (void)newDocument;
- (void)openDocument;
- (void)saveDocument;
- (void)saveDocumentAs;
- (void)exportDocument;

@end

NS_ASSUME_NONNULL_END
