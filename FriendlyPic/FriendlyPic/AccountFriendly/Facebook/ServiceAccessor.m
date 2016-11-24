//
//  ServiceAccessor.m
//  FriendlyPic
//
//  Created by Carmelo I. Uria on 10/15/12.
//  Copyright (c) 2012 Carmelo Uria Corporation. All rights reserved.
//

#import "ServiceAccessor.h"

#import "FacebookService.h"
#import "TwitterService.h"

@implementation ServiceAccessor


- (void) testFacebook
{
    FacebookService *service = [[FacebookService alloc] init];
    
    UIImage *image = [UIImage imageNamed:@"YOLT.jpg"];
    
    [service performImageUpload:image];
}

- (void) testTwitter
{
    TwitterService *service = [[TwitterService alloc] init];

    UIImage *image = [UIImage imageNamed:@"YOLT.jpg"];
    
    [service performImageUpload:image];
}

- (NSArray *) retrieveFacebookPhotos
{
    FacebookService *service = [[FacebookService alloc] init];
    
    [service retrieveImagesWithCompletion:^(NSString *link, NSError *error)
    {
        if (link != nil)
        {
            NSLog(@"retrieved link = %@", link);
        }
    }];
    
    return nil;
}

- (NSArray *) retrieveTwitterPhotos
{
    TwitterService *service = [[TwitterService alloc] init];
    NSArray *images = [service retrieveImages];
    
    NSLog(@"image count = %i, images : %@", [images count], images);
    
    return images;
}

@end
