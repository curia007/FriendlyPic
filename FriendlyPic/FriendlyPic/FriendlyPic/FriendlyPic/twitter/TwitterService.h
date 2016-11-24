//
//  TweeterService.h
//  FriendlyPic
//
//  Created by Carmelo I. Uria on 9/8/12.
//  Copyright (c) 2012 Carmelo Uria Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterService : NSObject

- (void) sendCustomTweet:(id)sender;
- (void) performUploadWithImage:(UIImage *) image name:(NSString *) name;

- (NSArray *) retrieveImages;

@end
