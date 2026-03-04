//
//  SMMainWindow.m
//  SmallMontage
//

#import "SMMainWindow.h"
#import "SMProject.h"
#import "SMTrack.h"
#import "SMClip.h"
#import "SMEngine.h"
#import "SMTimelineView.h"
#import "SSWindowStyle.h"
#import "SSFileDialog.h"
#import <AppKit/AppKit.h>

static const CGFloat kToolbarHeight = 40.0;
static const CGFloat kMargin = 8.0;

@interface SMMainWindow () <SMTimelineViewDelegate>
#if defined(GNUSTEP) && !__has_feature(objc_arc)
@property (nonatomic, retain) NSView *toolStrip;
@property (nonatomic, retain) NSScrollView *scrollView;
@property (nonatomic, retain) SMTimelineView *timelineView;
@property (nonatomic, retain) SMProject *project;
@property (nonatomic, retain) SMEngine *engine;
@property (nonatomic, copy) NSString *documentPath;
#else
@property (nonatomic, strong) NSView *toolStrip;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) SMTimelineView *timelineView;
@property (nonatomic, strong) SMProject *project;
@property (nonatomic, strong) SMEngine *engine;
@property (nonatomic, copy) NSString *documentPath;
#endif
@end

@implementation SMMainWindow

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize toolStrip = _toolStrip;
@synthesize scrollView = _scrollView;
@synthesize timelineView = _timelineView;
@synthesize project = _project;
@synthesize engine = _engine;
@synthesize documentPath = _documentPath;
#endif

- (instancetype)init {
    NSUInteger style = [SSWindowStyle standardWindowMask];
    NSRect frame = NSMakeRect(100, 100, 900, 560);
    self = [super initWithContentRect:frame
                            styleMask:style
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setTitle:@"Untitled - SmallMontage"];
        [self setReleasedWhenClosed:NO];
        _documentPath = nil;
        _project = [[SMProject alloc] init];
        _engine = [[SMEngine alloc] init];
        [self buildContent];
    }
    return self;
}

#if defined(GNUSTEP) && !__has_feature(objc_arc)
- (void)dealloc {
    [_toolStrip release];
    [_scrollView release];
    [_timelineView release];
    [_project release];
    [_engine release];
    [_documentPath release];
    [super dealloc];
}
#endif

- (void)buildContent {
    NSView *content = [self contentView];
    NSRect contentBounds = [content bounds];
    CGFloat stripY = contentBounds.size.height - kToolbarHeight - kMargin;

    _toolStrip = [[NSView alloc] initWithFrame:NSMakeRect(0, stripY, contentBounds.size.width, kToolbarHeight)];
    [_toolStrip setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [content addSubview:_toolStrip];

    CGFloat x = kMargin;
    NSButton *addVideo = [[NSButton alloc] initWithFrame:NSMakeRect(x, 6, 100, 28)];
    [addVideo setTitle:@"Add Video Track"];
    [addVideo setButtonType:NSMomentaryPushInButton];
    [addVideo setBezelStyle:NSRoundedBezelStyle];
    [addVideo setTarget:self];
    [addVideo setAction:@selector(addVideoTrack:)];
    [_toolStrip addSubview:addVideo];
    x += 108;

    NSButton *addAudio = [[NSButton alloc] initWithFrame:NSMakeRect(x, 6, 100, 28)];
    [addAudio setTitle:@"Add Audio Track"];
    [addAudio setButtonType:NSMomentaryPushInButton];
    [addAudio setBezelStyle:NSRoundedBezelStyle];
    [addAudio setTarget:self];
    [addAudio setAction:@selector(addAudioTrack:)];
    [_toolStrip addSubview:addAudio];
    x += 108;

    NSButton *importBtn = [[NSButton alloc] initWithFrame:NSMakeRect(x, 6, 90, 28)];
    [importBtn setTitle:@"Import…"];
    [importBtn setButtonType:NSMomentaryPushInButton];
    [importBtn setBezelStyle:NSRoundedBezelStyle];
    [importBtn setTarget:self];
    [importBtn setAction:@selector(importMedia:)];
    [_toolStrip addSubview:importBtn];
    x += 98;

    NSButton *playBtn = [[NSButton alloc] initWithFrame:NSMakeRect(x, 6, 50, 28)];
    [playBtn setTitle:@"Play"];
    [playBtn setButtonType:NSMomentaryPushInButton];
    [playBtn setBezelStyle:NSRoundedBezelStyle];
    [playBtn setTarget:self];
    [playBtn setAction:@selector(play:)];
    [_toolStrip addSubview:playBtn];
    x += 58;

    NSButton *stopBtn = [[NSButton alloc] initWithFrame:NSMakeRect(x, 6, 50, 28)];
    [stopBtn setTitle:@"Stop"];
    [stopBtn setButtonType:NSMomentaryPushInButton];
    [stopBtn setBezelStyle:NSRoundedBezelStyle];
    [stopBtn setTarget:self];
    [stopBtn setAction:@selector(stop:)];
    [_toolStrip addSubview:stopBtn];
    x += 58;

    NSButton *exportBtn = [[NSButton alloc] initWithFrame:NSMakeRect(x, 6, 70, 28)];
    [exportBtn setTitle:@"Export…"];
    [exportBtn setButtonType:NSMomentaryPushInButton];
    [exportBtn setBezelStyle:NSRoundedBezelStyle];
    [exportBtn setTarget:self];
    [exportBtn setAction:@selector(exportDocument)];
    [_toolStrip addSubview:exportBtn];

    NSRect scrollFrame = NSMakeRect(0, 0, contentBounds.size.width, stripY);
    _scrollView = [[NSScrollView alloc] initWithFrame:scrollFrame];
    [_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [_scrollView setHasVerticalScroller:YES];
    [_scrollView setHasHorizontalScroller:YES];
    [_scrollView setBorderType:NSBezelBorder];
    [_scrollView setAutohidesScrollers:YES];

    _timelineView = [[SMTimelineView alloc] initWithFrame:NSZeroRect];
    [_timelineView setProject:_project];
    [_timelineView setDelegate:self];
    [_scrollView setDocumentView:_timelineView];
    [content addSubview:_scrollView];

#if defined(GNUSTEP) && !__has_feature(objc_arc)
    [addVideo release];
    [addAudio release];
    [importBtn release];
    [playBtn release];
    [stopBtn release];
    [exportBtn release];
#endif
}

- (void)timelineViewDidChange:(NSView *)view {
    (void)view;
    [self updateTitle];
}

- (void)updateTitle {
    NSString *name = _documentPath ? [_documentPath lastPathComponent] : @"Untitled";
    if ([_project dirty]) name = [name stringByAppendingString:@" *"];
    [self setTitle:[NSString stringWithFormat:@"%@ - SmallMontage", name]];
}

- (void)addVideoTrack:(id)sender {
    (void)sender;
    NSInteger n = 0;
    for (SMTrack *t in _project.tracks)
        if (t.trackType == SMTrackTypeVideo) n++;
    NSString *name = [NSString stringWithFormat:@"Video %ld", (long)(n + 1)];
    [_project addVideoTrackWithName:name];
    [_timelineView reloadData];
    [self updateTitle];
}

- (void)addAudioTrack:(id)sender {
    (void)sender;
    NSInteger n = 0;
    for (SMTrack *t in _project.tracks)
        if (t.trackType == SMTrackTypeAudio) n++;
    NSString *name = [NSString stringWithFormat:@"Audio %ld", (long)(n + 1)];
    [_project addAudioTrackWithName:name];
    [_timelineView reloadData];
    [self updateTitle];
}

- (void)importMedia:(id)sender {
    (void)sender;
    SSFileDialog *dialog = [SSFileDialog openDialog];
    [dialog setAllowedFileTypes:[NSArray arrayWithObjects:@"mp4", @"mov", @"avi", @"mkv", @"webm", @"mp3", @"wav", @"m4a", @"ogg", nil]];
    [dialog setAllowsMultipleSelection:YES];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    if ([_project.tracks count] == 0) {
        [_project addVideoTrackWithName:@"Video 1"];
        [_project addAudioTrackWithName:@"Audio 1"];
    }
    SMTrack *videoTrack = nil;
    SMTrack *audioTrack = nil;
    for (SMTrack *t in _project.tracks) {
        if (t.trackType == SMTrackTypeVideo && !videoTrack) videoTrack = t;
        if (t.trackType == SMTrackTypeAudio && !audioTrack) audioTrack = t;
    }
    NSInteger pos = [_project length];
    for (NSURL *url in urls) {
        NSString *path = [url path];
        if (!path.length) continue;
        NSString *ext = [[path pathExtension] lowercaseString];
        NSArray *videoExts = [NSArray arrayWithObjects:@"mp4", @"mov", @"avi", @"mkv", @"webm", nil];
        BOOL isVideo = [videoExts containsObject:ext];
        SMTrack *track = isVideo ? videoTrack : audioTrack;
        if (!track) track = isVideo ? [_project.tracks objectAtIndex:0] : [_project.tracks lastObject];
        SMClip *clip = [[SMClip alloc] init];
        clip.sourcePath = path;
        clip.inPoint = 0;
        clip.outPoint = 10000;
        clip.timelineStart = (NSInteger)pos;
        [track.clips addObject:clip];
        pos += [clip length];
    }
    [_timelineView reloadData];
    [self updateTitle];
}

- (void)play:(id)sender {
    (void)sender;
    if ([_engine isPreviewRunning]) return;
    [_engine buildFromProject:_project];
    [_engine startPreview];
}

- (void)stop:(id)sender {
    (void)sender;
    [_engine stopPreview];
}

- (void)newDocument {
    _project = [[SMProject alloc] init];
    _documentPath = nil;
    [_timelineView setProject:_project];
    [_timelineView reloadData];
    [self setTitle:@"Untitled - SmallMontage"];
}

- (void)openDocument {
    SSFileDialog *dialog = [SSFileDialog openDialog];
    [dialog setAllowedFileTypes:[NSArray arrayWithObject:@"smallmontage"]];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    NSString *path = [[urls objectAtIndex:0] path];
    if (!path.length) return;
    NSError *err = nil;
    SMProject *doc = [[SMProject alloc] initWithContentsOfFile:path error:&err];
    if (doc) {
        _project = doc;
        _documentPath = path;
        [_timelineView setProject:_project];
        [_timelineView reloadData];
        [self updateTitle];
    }
}

- (void)saveDocument {
    if ([_documentPath length] > 0) {
        NSError *err = nil;
        if ([_project writeToFile:_documentPath error:&err]) {
            [_project setDirty:NO];
            [self updateTitle];
        }
        return;
    }
    [self saveDocumentAs];
}

- (void)saveDocumentAs {
    SSFileDialog *dialog = [SSFileDialog saveDialog];
    [dialog setAllowedFileTypes:[NSArray arrayWithObject:@"smallmontage"]];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    NSString *path = [[urls objectAtIndex:0] path];
    if (!path.length) return;
    if (![[path pathExtension] length])
        path = [path stringByAppendingPathExtension:@"smallmontage"];
    NSError *err = nil;
    if ([_project writeToFile:path error:&err]) {
        _documentPath = path;
        [_project setDirty:NO];
        [self updateTitle];
    }
}

- (void)exportDocument {
    SSFileDialog *dialog = [SSFileDialog saveDialog];
    [dialog setAllowedFileTypes:[NSArray arrayWithObject:@"mp4"]];
    NSArray *urls = [dialog showModal];
    if (!urls || [urls count] == 0) return;
    NSString *path = [[urls objectAtIndex:0] path];
    if (!path.length) return;
    if (![[path pathExtension] length])
        path = [path stringByAppendingPathExtension:@"mp4"];
    [_engine buildFromProject:_project];
    if ([_engine exportToPath:path]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Export complete"];
        [alert setInformativeText:[NSString stringWithFormat:@"Exported to %@", path]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Export failed"];
        [alert setInformativeText:@"Check that MLT and ffmpeg are installed and the project has content."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
}

@end
