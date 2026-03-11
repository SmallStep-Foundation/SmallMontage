//
//  SmallMontageTests.m — SmallMontage unit tests
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "SSTestMacros.h"
#import "../App/SMAppDelegate.h"

static void testSMAppDelegateMenuBuild(void)
{
    CREATE_AUTORELEASE_POOL(pool);
    SMAppDelegate *d = [[SMAppDelegate alloc] init];
    [d buildMenu];
    SS_TEST_ASSERT(YES, "SMAppDelegate buildMenu did not crash");
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [d release];
#endif
    RELEASE(pool);
}

int main(int argc, char **argv) {
    (void)argc;(void)argv;
    CREATE_AUTORELEASE_POOL(pool);
    [NSApplication sharedApplication];
    testSMAppDelegateMenuBuild();
    SS_TEST_SUMMARY();
    RELEASE(pool);
    return SS_TEST_RETURN();
}
