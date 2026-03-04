//
//  SMEngine.h
//  SmallMontage
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SMProject;

@interface SMEngine : NSObject {
    void *_engineRef;
}

- (void)buildFromProject:(SMProject *)project;
- (BOOL)startPreview;
- (void)stopPreview;
- (BOOL)isPreviewRunning;
- (BOOL)exportToPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
