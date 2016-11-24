//
//  FacebookPostageService.h
//  FriendlyPic
//
//  Created by Carmelo I. Uria on 9/8/12.
//  Copyright (c) 2012 Carmelo Uria Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

// Completion block for performRequestWithHandler.
typedef void(^FacebookImageCompletion)(NSString *imageURLString, NSError *error);

@interface FacebookService : NSObject

- (void) performUploadWithData:(UIImage *) image name:(NSString *) name;
- (void) retrieveImagesWithCompletion:(FacebookImageCompletion) completion;

@end
