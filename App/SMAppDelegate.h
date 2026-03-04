//
//  SMAppDelegate.h
//  SmallMontage
//
//  App lifecycle and menu; creates the main editor window.
//

#import <Foundation/Foundation.h>
#if !TARGET_OS_IPHONE
#import <AppKit/AppKit.h>
#endif
#import "SSAppDelegate.h"

@class SMMainWindow;

@interface SMAppDelegate : NSObject <SSAppDelegate>
{
    SMMainWindow *_mainWindow;
}
@end
