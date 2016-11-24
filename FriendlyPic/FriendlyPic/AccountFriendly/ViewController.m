//
//  ViewController.m
//  AccountFriendly
//
//  Created by Carmelo I. Uria on 10/15/12.
//  Copyright (c) 2012 Carmelo Uria Corporation. All rights reserved.
//

#import "ViewController.h"

#import "ServiceAccessor.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    ServiceAccessor *accessor = [[ServiceAccessor alloc] init];
    NSArray *images = [accessor retrieveFacebookPhotos];
    
    NSLog(@"images : %@", images);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
