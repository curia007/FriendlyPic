//
//  OptionsTableViewController.m
//  FriendlyPicBasic
//
//  Created by Carmelo I. Uria on 10/11/13.
//  Copyright (c) 2013 Carmelo I. Uria. All rights reserved.
//

#import "OptionsTableViewController.h"
#import "OptionTableViewCell.h"
#import "CameraViewController.h"

#define APP_STORE_OPTION_ROW 1
#define MAIL_OPTION_ROW 2
#define BLUE_CRAYON_OPTION_ROW 3
#define GREEN_CRAYON_OPTION_ROW 4
#define RED_CRAYON_OPTION_ROW 5
#define YELLOW_CRAYON_OPTION_ROW 6

typedef void (^CompletionBlock)(void);

@interface OptionsTableViewController ()

@property (strong, nonatomic) SKProductsRequest *productRequest;
@property (strong, nonatomic) NSSet *productIdentifiers;

- (void) dismissOptionsViewControllerAnimated:(BOOL)flag completion:(CompletionBlock) completionBlock;

- (void) blueLineSelected:(id)sender;
- (void) greenLineSelected:(id)sender;
- (void) yellowLineSelected:(id)sender;
- (void) redLineSelected:(id)sender;
- (void) facebookSelected:(id) sender;
- (void) twitterSelected:(id) sender;
- (void) saveAction:(id) sender;
- (void) purchaseAction:(id) sender;
- (void) mailAction:(id) sender;

@end

@implementation OptionsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[self tableView] setRowHeight:100.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissOptionsViewControllerAnimated:(BOOL)flag completion:(CompletionBlock) completionBlock
{
    [self dismissViewControllerAnimated:flag completion:completionBlock];
}

- (void) blueLineSelected:(id)sender
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

- (void) greenLineSelected:(id)sender
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

- (void) yellowLineSelected:(id)sender
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

- (void) redLineSelected:(id)sender
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

- (void) facebookSelected:(id) sender
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

- (void) twitterSelected:(id) sender
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

- (void) saveAction:(id) sender
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

- (void) purchaseAction:(id) sender
{
    //    _productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[self productIdentifiers]];
    //    [[self productRequest] setDelegate:self];
    //    [[self productRequest] start];
    //  https://itunes.apple.com/us/app/friendlypic/id595819103?mt=8
    NSURL *proURL = [NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/friendlypic/id595819103?mt=8"];
    [[UIApplication sharedApplication] openURL:proURL];
}

- (void) mailAction:(id) sender
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

#pragma mark -
#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (OptionTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OptionCellIdentifier";
    OptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if ([indexPath row] == APP_STORE_OPTION_ROW)
    {
        [[cell optionImageView] setImage:[UIImage imageNamed:@"App-Store-Icon"]];
    }
    if ([indexPath row] == MAIL_OPTION_ROW)
    {
        [[cell optionImageView] setImage:[UIImage imageNamed:@"mail"]];
    }
    if ([indexPath row] == BLUE_CRAYON_OPTION_ROW)
    {
        [[cell optionImageView] setImage:[UIImage imageNamed:@"blue_marker-pen-512"]];
    }
    if ([indexPath row] == GREEN_CRAYON_OPTION_ROW)
    {
        [[cell optionImageView] setImage:[UIImage imageNamed:@"green_marker-pen-512"]];
    }
    if ([indexPath row] == RED_CRAYON_OPTION_ROW)
    {
        [[cell optionImageView] setImage:[UIImage imageNamed:@"red_marker-pen-512"]];
    }
    if ([indexPath row] == YELLOW_CRAYON_OPTION_ROW)
    {
        [[cell optionImageView] setImage:[UIImage imageNamed:@"yellow_marker-pen-512"]];
    }
 
    return cell;
}

#pragma mark 
#pragma mark UITableViewDelegate
- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
    if ([indexPath row] == APP_STORE_OPTION_ROW)
    {
        [self purchaseAction:nil];
    }
    if ([indexPath row] == MAIL_OPTION_ROW)
    {
        [self mailAction:nil];
    }
    if ([indexPath row] == BLUE_CRAYON_OPTION_ROW)
    {
        [self blueLineSelected:nil];
    }
    if ([indexPath row] == GREEN_CRAYON_OPTION_ROW)
    {
        [self greenLineSelected:nil];
    }
    if ([indexPath row] == RED_CRAYON_OPTION_ROW)
    {
        [self redLineSelected:nil];
    }
    if ([indexPath row] == YELLOW_CRAYON_OPTION_ROW)
    {
        [self yellowLineSelected:nil];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

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
