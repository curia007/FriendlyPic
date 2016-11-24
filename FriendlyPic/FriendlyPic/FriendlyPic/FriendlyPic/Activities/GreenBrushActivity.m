//
//  FacebookActivity.m
//  FriendlyPic
//
//  Created by Carmelo I. Uria on 3/19/13.
//  Copyright (c) 2013 Carmelo Uria Corporation. All rights reserved.
//

#import "GreenBrushActivity.h"

@implementation GreenBrushActivity

- (NSString *) activityType
{
    return @"Green";
}

- (NSString *) activityTitle
{
    return @"Green Brush";
}

- (UIImage *) activityImage
{
    return [UIImage imageNamed:@"green_marker-pen-50"];
}

- (void)performActivity
{
    
}

- (BOOL) canPerformWithActivityItems:(NSArray *) activityItems
{
    return YES;
}

- (void) prepareWithActivityItems:(NSArray *) activityItems
{
    
}


@end
