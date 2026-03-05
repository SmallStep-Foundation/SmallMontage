//
//  SMAppDelegate.m
//  SmallMontage
//

#import "SMAppDelegate.h"
#import "SMMainWindow.h"
#import "SSAppDelegate.h"
#import "SSHostApplication.h"
#import "SSMainMenu.h"
#import "SSAboutPanel.h"

@interface SMAppDelegate (Private)
- (void)buildMenu;
@end

@implementation SMAppDelegate

- (void)applicationWillFinishLaunching {
    [self buildMenu];
}

- (void)applicationDidFinishLaunching {
    _mainWindow = [[SMMainWindow alloc] init];
    [_mainWindow makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender {
    (void)sender;
    return YES;
}

- (void)buildMenu {
#if !TARGET_OS_IPHONE
    SSMainMenu *menu = [[SSMainMenu alloc] init];
    [menu setAppName:@"SmallMontage"];
    [menu setAboutAppName:@"SmallMontage"];
    [menu setAboutVersion:@"1.0"];
    [menu setAboutTarget:self];
    NSArray *items = [NSArray arrayWithObjects:
        [SSMainMenuItem itemWithTitle:@"New" action:@selector(newDocument:) keyEquivalent:@"n" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Open…" action:@selector(openDocument:) keyEquivalent:@"o" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Save" action:@selector(saveDocument:) keyEquivalent:@"s" modifierMask:NSCommandKeyMask target:self],
        [SSMainMenuItem itemWithTitle:@"Save As…" action:@selector(saveDocumentAs:) keyEquivalent:@"" modifierMask:0 target:self],
        [SSMainMenuItem itemWithTitle:@"Export…" action:@selector(exportDocument:) keyEquivalent:@"e" modifierMask:NSCommandKeyMask target:self],
        nil];
    [menu buildMenuWithItems:items quitTitle:@"Quit SmallMontage" quitKeyEquivalent:@"q"];
    [menu install];
#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [menu release];
#endif
#endif
}

- (void)newDocument:(id)sender {
    (void)sender;
    [_mainWindow newDocument];
}

- (void)openDocument:(id)sender {
    (void)sender;
    [_mainWindow openDocument];
}

- (void)saveDocument:(id)sender {
    (void)sender;
    [_mainWindow saveDocument];
}

- (void)saveDocumentAs:(id)sender {
    (void)sender;
    [_mainWindow saveDocumentAs];
}

- (void)exportDocument:(id)sender {
    (void)sender;
    [_mainWindow exportDocument];
}

- (void)showAbout:(id)sender {
    (void)sender;
    [SSAboutPanel showWithAppName:@"SmallMontage" version:@"1.0"];
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_mainWindow release];
    [super dealloc];
}
#endif

@end
