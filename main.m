//
//  main.m
//  SmallMontage
//
//  Non-linear video editor with multiple video and audio tracks.
//  Uses SmallStepLib for app lifecycle, menus, and file dialogs; MLT for playback/export.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SMAppDelegate.h"
#import "SSAppDelegate.h"
#import "SSHostApplication.h"

int main(int argc, const char *argv[]) {
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#endif
    id<SSAppDelegate> delegate = [[SMAppDelegate alloc] init];
    [SSHostApplication runWithDelegate:delegate];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [delegate release];
    [pool release];
#endif
    return 0;
}
