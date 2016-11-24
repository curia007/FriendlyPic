//
//  OptionsViewController.m
//  FriendlyPic
//
//  Created by Carmelo I. Uria on 8/29/12.
//  Copyright (c) 2012 Carmelo Uria Corporation. All rights reserved.
//

#import "OptionsViewController.h"

#import "CameraViewController.h"

NSString * const OptionKey = @"OptionKey";

NSString * const BluePenOption = @"bluePenOption";
NSString * const GreenPenOption = @"greenPenOption";
NSString * const YellowPenOption = @"yellowPenOption";
NSString * const RedPenOption = @"redPenOption";

NSString * const FacebookOption = @"facebookOption";
NSString * const TwitterOption = @"twitterOption";
NSString * const SaveOption = @"saveOption";
NSString * const MailOption = @"mailOption";

typedef void (^CompletionBlock)(void);

@interface OptionsViewController ()

@property (strong, nonatomic) SKProductsRequest *productRequest;
@property (strong, nonatomic) NSSet *productIdentifiers;

- (void) dismissOptionsViewControllerAnimated:(BOOL)flag completion:(CompletionBlock) completionBlock;

@end

@implementation OptionsViewController

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

    // TODO:  Add productIdentifer
    _productIdentifiers = [NSSet setWithObject:@""];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) blueLineSelected:(id)sender
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [userInfo setObject:BluePenOption  forKey:OptionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CameraOptionsNotification object:nil userInfo:userInfo];
    
    [self dismissOptionsViewControllerAnimated:YES completion:^{
#ifdef DEBUG
        NSLog(@"OptionsViewController dismissed");
#endif

    }];
}

- (IBAction) greenLineSelected:(id)sender
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [userInfo setObject:GreenPenOption  forKey:OptionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CameraOptionsNotification object:nil userInfo:userInfo];
    
    [self dismissOptionsViewControllerAnimated:YES completion:^{
#ifdef DEBUG
        NSLog(@"OptionsViewController dismissed");
#endif
        
    }];

}

- (IBAction) yellowLineSelected:(id)sender
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [userInfo setObject:YellowPenOption  forKey:OptionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CameraOptionsNotification object:nil userInfo:userInfo];
    
    [self dismissOptionsViewControllerAnimated:YES completion:^{
#ifdef DEBUG
        NSLog(@"OptionsViewController dismissed");
#endif
        
    }];

}

- (IBAction) redLineSelected:(id)sender
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [userInfo setObject:RedPenOption  forKey:OptionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CameraOptionsNotification object:nil userInfo:userInfo];
    
    [self dismissOptionsViewControllerAnimated:YES completion:^{
#ifdef DEBUG
        NSLog(@"OptionsViewController dismissed");
#endif
        
    }];

}

- (IBAction) facebookSelected:(id) sender
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [userInfo setObject:FacebookOption  forKey:OptionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CameraOptionsNotification object:nil userInfo:userInfo];
    
    [self dismissOptionsViewControllerAnimated:YES completion:^{
#ifdef DEBUG
        NSLog(@"OptionsViewController dismissed");
#endif
        
    }];

}

- (IBAction) twitterSelected:(id) sender
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [userInfo setObject:TwitterOption  forKey:OptionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CameraOptionsNotification object:nil userInfo:userInfo];
    
    [self dismissOptionsViewControllerAnimated:YES completion:^{
#ifdef DEBUG
        NSLog(@"OptionsViewController dismissed");
#endif
        
    }];

}

- (IBAction) saveAction:(id) sender
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [userInfo setObject:SaveOption  forKey:OptionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CameraOptionsNotification object:nil userInfo:userInfo];
    
    [self dismissOptionsViewControllerAnimated:YES completion:^{
#ifdef DEBUG
        NSLog(@"OptionsViewController dismissed");
#endif
        
    }];
}

- (IBAction) purchaseAction:(id) sender
{
//    _productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[self productIdentifiers]];
//    [[self productRequest] setDelegate:self];
//    [[self productRequest] start];
//  https://itunes.apple.com/us/app/friendlypic/id595819103?mt=8
    NSURL *proURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/friendlypic/id595819103?mt=8"];
    [[UIApplication sharedApplication] openURL:proURL];
}

- (IBAction) mailAction:(id) sender
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [userInfo setObject:MailOption  forKey:OptionKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CameraOptionsNotification object:nil userInfo:userInfo];
    
    [self dismissOptionsViewControllerAnimated:YES completion:^{
#ifdef DEBUG
        NSLog(@"OptionsViewController dismissed");
#endif
        
    }];
    

}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) orientation
{
    [[[self view] layer] setShouldRasterize:YES];
}

- (void) didRotateToInterfaceOrientation:(UIInterfaceOrientation) orientation
{
    [[[self view] layer] setShouldRasterize:NO];
}

- (void) dismissOptionsViewControllerAnimated:(BOOL)flag completion:(CompletionBlock) completionBlock
{
    [self dismissViewControllerAnimated:flag completion:completionBlock];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate Methods

- (void) productsRequest:(SKProductsRequest *) request didReceiveResponse:(SKProductsResponse *) response
{
    if ([[response products] count] > 0)
    {
        SKProduct *product = [[response products] lastObject];
        
#ifdef DEBUG
        NSLog(@"Buying %@...", [product productIdentifier]);
#endif
        
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];

    }

}

#pragma mark -
#pragma mark SKPaymentTransactionObserver Methods

- (void) paymentQueue:(SKPaymentQueue *) queue updatedTransactions:(NSArray *) transactions
{
    NSLog(@"Updated Transactions...");
    
}

- (void) paymentQueue:(SKPaymentQueue *) queue updatedDownloads:(NSArray *) downloads
{
    NSLog(@"Updated Downloads...");
}

@end

