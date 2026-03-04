//
//  SMProject.m
//  SmallMontage
//

#import "SMProject.h"
#import "SMTrack.h"
#import "SMClip.h"

@implementation SMProject

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize frameRate = _frameRate;
@synthesize width = _width;
@synthesize height = _height;
@synthesize tracks = _tracks;
@synthesize dirty = _dirty;
#endif

- (instancetype)init {
    self = [super init];
    if (self) {
        _frameRate = 25.0;
        _width = 1920;
        _height = 1080;
        _tracks = [[NSMutableArray alloc] init];
        _dirty = NO;
    }
    return self;
}

- (SMTrack *)addVideoTrackWithName:(NSString *)name {
    SMTrack *t = [[SMTrack alloc] initWithType:SMTrackTypeVideo name:name];
    [_tracks addObject:t];
    _dirty = YES;
    return t;
}

- (SMTrack *)addAudioTrackWithName:(NSString *)name {
    SMTrack *t = [[SMTrack alloc] initWithType:SMTrackTypeAudio name:name];
    [_tracks addObject:t];
    _dirty = YES;
    return t;
}

- (NSInteger)length {
    NSInteger maxLen = 0;
    for (SMTrack *t in _tracks) {
        NSInteger len = [t length];
        if (len > maxLen) maxLen = len;
    }
    return maxLen;
}

- (BOOL)writeToFile:(NSString *)path error:(NSError **)outError {
    NSMutableDictionary *root = [NSMutableDictionary dictionary];
    [root setObject:[NSNumber numberWithDouble:_frameRate] forKey:@"frameRate"];
    [root setObject:[NSNumber numberWithInteger:_width] forKey:@"width"];
    [root setObject:[NSNumber numberWithInteger:_height] forKey:@"height"];
    NSMutableArray *tracksArr = [NSMutableArray array];
    for (SMTrack *track in _tracks) {
        NSMutableDictionary *td = [NSMutableDictionary dictionary];
        [td setObject:(track.trackType == SMTrackTypeVideo) ? @"video" : @"audio" forKey:@"type"];
        [td setObject:track.name ?: @"" forKey:@"name"];
        NSMutableArray *clipsArr = [NSMutableArray array];
        for (SMClip *clip in track.clips) {
            [clipsArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                clip.sourcePath ?: @"", @"sourcePath",
                [NSNumber numberWithInteger:clip.inPoint], @"inPoint",
                [NSNumber numberWithInteger:clip.outPoint], @"outPoint",
                [NSNumber numberWithInteger:clip.timelineStart], @"timelineStart",
                nil]];
        }
        [td setObject:clipsArr forKey:@"clips"];
        [tracksArr addObject:td];
    }
    [root setObject:tracksArr forKey:@"tracks"];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:root format:NSPropertyListXMLFormat_v1_0 options:0 error:outError];
    if (!data) return NO;
    return [data writeToFile:path options:NSDataWritingAtomic error:outError];
}

- (instancetype)initWithContentsOfFile:(NSString *)path error:(NSError **)outError {
    self = [self init];
    if (!self) return nil;
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        if (outError) *outError = [NSError errorWithDomain:NSPOSIXErrorDomain code:0 userInfo:nil];
        return nil;
    }
    id plist = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:outError];
    if (![plist isKindOfClass:[NSDictionary class]]) return nil;
    NSDictionary *root = (NSDictionary *)plist;
    _frameRate = [[root objectForKey:@"frameRate"] doubleValue];
    if (_frameRate <= 0) _frameRate = 25.0;
    _width = [[root objectForKey:@"width"] integerValue];
    if (_width <= 0) _width = 1920;
    _height = [[root objectForKey:@"height"] integerValue];
    if (_height <= 0) _height = 1080;
    NSArray *tracksArr = [root objectForKey:@"tracks"];
    if ([tracksArr isKindOfClass:[NSArray class]]) {
        for (id tObj in tracksArr) {
            if (![tObj isKindOfClass:[NSDictionary class]]) continue;
            NSDictionary *td = (NSDictionary *)tObj;
            NSString *typeStr = [td objectForKey:@"type"];
            NSString *name = [td objectForKey:@"name"];
            if (![name isKindOfClass:[NSString class]]) name = @"Track";
            SMTrackType type = ([typeStr isEqualToString:@"audio"]) ? SMTrackTypeAudio : SMTrackTypeVideo;
            SMTrack *track = [[SMTrack alloc] initWithType:type name:name];
            NSArray *clipsArr = [td objectForKey:@"clips"];
            if ([clipsArr isKindOfClass:[NSArray class]]) {
                for (id cObj in clipsArr) {
                    if (![cObj isKindOfClass:[NSDictionary class]]) continue;
                    NSDictionary *cd = (NSDictionary *)cObj;
                    SMClip *clip = [[SMClip alloc] init];
                    clip.sourcePath = [[cd objectForKey:@"sourcePath"] description];
                    clip.inPoint = [[cd objectForKey:@"inPoint"] integerValue];
                    clip.outPoint = [[cd objectForKey:@"outPoint"] integerValue];
                    clip.timelineStart = [[cd objectForKey:@"timelineStart"] integerValue];
                    [track.clips addObject:clip];
                }
            }
            [_tracks addObject:track];
        }
    }
    _dirty = NO;
    return self;
}

@end
