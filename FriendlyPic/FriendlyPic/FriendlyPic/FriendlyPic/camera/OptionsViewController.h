//
//  OptionsViewController.h
//  FriendlyPic
//
//  Created by Carmelo I. Uria on 8/29/12.
//  Copyright (c) 2012 Carmelo Uria Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

void displayErrorOnMainQueue(NSError *error, NSString *message);

@interface OptionsViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (weak, nonatomic) IBOutlet UIButton *blueButton;
@property (weak, nonatomic) IBOutlet UIButton *yellowButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *greenButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

- (IBAction) blueLineSelected:(id) sender;
- (IBAction) greenLineSelected:(id) sender;
- (IBAction) yellowLineSelected:(id) sender;
- (IBAction) redLineSelected:(id) sender;

- (IBAction) facebookSelected:(id) sender;
- (IBAction) twitterSelected:(id) sender;
- (IBAction) saveAction:(id) sender;
- (IBAction) purchaseAction:(id) sender;
- (IBAction) mailAction:(id)sender;

@end
