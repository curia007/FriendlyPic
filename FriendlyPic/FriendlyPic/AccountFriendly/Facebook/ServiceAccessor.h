//
//  FacebookAccessor.h
//  FriendlyPic
//
//  Created by Carmelo I. Uria on 10/15/12.
//  Copyright (c) 2012 Carmelo Uria Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceAccessor : NSObject

- (void) testFacebook;
- (void) testTwitter;

- (NSArray *) retrieveFacebookPhotos;
- (NSArray *) retrieveTwitterPhotos;

@end
