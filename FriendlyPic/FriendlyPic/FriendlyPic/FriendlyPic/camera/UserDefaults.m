#import "UserDefaults.h"

static NSString* USING_FRONT_CAMERA_DEFAULTS_KEY = @"usingFrontCamera";

@implementation UserDefaults

+ (void) initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults: @{
		USING_FRONT_CAMERA_DEFAULTS_KEY : [NSNumber numberWithBool:YES],
	 }];
}

+ (BOOL) usingFrontCamera
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:USING_FRONT_CAMERA_DEFAULTS_KEY];
}

+ (void) setUsingFrontCamera:(BOOL) isUsingFrontCamera
{
    [[NSUserDefaults standardUserDefaults] setBool:isUsingFrontCamera forKey:USING_FRONT_CAMERA_DEFAULTS_KEY];
}

@end