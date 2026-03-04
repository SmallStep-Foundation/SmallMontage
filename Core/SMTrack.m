//
//  SMTrack.m
//  SmallMontage
//

#import "SMTrack.h"
#import "SMClip.h"

@implementation SMTrack

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize trackType = _trackType;
@synthesize name = _name;
@synthesize clips = _clips;
#endif

- (instancetype)initWithType:(SMTrackType)type name:(NSString *)name {
    self = [super init];
    if (self) {
        _trackType = type;
        _name = [name copy];
        _clips = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSInteger)length {
    NSInteger end = 0;
    for (SMClip *clip in _clips) {
        NSInteger clipEnd = [clip timelineEnd];
        if (clipEnd > end) end = clipEnd;
    }
    return end + 1;
}

@end
