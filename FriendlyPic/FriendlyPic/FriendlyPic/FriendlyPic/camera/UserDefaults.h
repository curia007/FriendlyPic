#import <Foundation/Foundation.h>

@interface UserDefaults : NSObject

+ (BOOL) usingFrontCamera;
+ (void) setUsingFrontCamera:(BOOL) isUsingFrontCamera;

@end
