//
//  SMClip.m
//  SmallMontage
//

#import "SMClip.h"

@implementation SMClip

#if defined(GNUSTEP) && !__has_feature(objc_arc)
@synthesize sourcePath = _sourcePath;
@synthesize inPoint = _inPoint;
@synthesize outPoint = _outPoint;
@synthesize timelineStart = _timelineStart;
#endif

- (NSInteger)length {
    if (_outPoint < _inPoint) return 0;
    return _outPoint - _inPoint + 1;
}

- (NSInteger)timelineEnd {
    return _timelineStart + [self length] - 1;
}

@end
