//
//  BasicCameraViewController.m
//  FriendlyPicBasic
//
//  Created by Carmelo I. Uria on 2/27/13.
//  Copyright (c) 2013 Carmelo I. Uria. All rights reserved.
//

#import "BasicCameraViewController.h"

@interface BasicCameraViewController ()

@end

@implementation BasicCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL) animated
{
    [super viewDidAppear:animated];
    [[self adBannerView] sizeThatFits:self.view.bounds.size];
    [[self view] addSubview:[self adBannerView]];
    
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation) toInterfaceOrientation duration:(NSTimeInterval) duration
{
}

#pragma mark -
#pragma mark - iAd Banner View Delegate

- (void) bannerViewDidLoadAd:(ADBannerView *) banner
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

- (void) bannerView:(ADBannerView *) banner didFailToReceiveAdWithError:(NSError *) error
{
    NSLog(@"ADBannerView did recieve error:  %@", error);
    [banner setHidden:YES];
}

@end
