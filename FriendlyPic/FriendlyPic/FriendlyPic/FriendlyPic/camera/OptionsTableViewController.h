//
//  OptionsTableViewController.h
//  FriendlyPicBasic
//
//  Created by Carmelo I. Uria on 10/11/13.
//  Copyright (c) 2013 Carmelo I. Uria. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface OptionsTableViewController : UITableViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end
