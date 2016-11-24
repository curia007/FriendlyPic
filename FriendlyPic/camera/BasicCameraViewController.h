//
//  BasicCameraViewController.h
//  FriendlyPicBasic
//
//  Created by Carmelo I. Uria on 2/27/13.
//  Copyright (c) 2013 Carmelo I. Uria. All rights reserved.
//

#import "CameraViewController.h"

#import <StoreKit/StoreKit.h>
#import <iAd/iAd.h>

@interface BasicCameraViewController : CameraViewController <ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet ADBannerView *adBannerView;

@end
