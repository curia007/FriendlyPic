//
//  TweeterService.m
//  FriendlyPic
//
//  Created by Carmelo I. Uria on 9/8/12.
//  Copyright (c) 2012 Carmelo Uria Corporation. All rights reserved.
//

#import "TwitterService.h"

@interface TwitterService ()


@end

@implementation TwitterService

- (void) sendCustomTweet:(id)sender
{
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] > 0)
            {
                // Grab the initial Twitter account to tweet from.
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                
                // Create a request, which in this example, posts a tweet to the user's timeline.
                // This example uses version 1 of the Twitter API.
                // This may need to be changed to whichever version is currently appropriate.
                SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"http://api.twitter.com/1./statuses/update.json"] parameters:[NSDictionary dictionaryWithObject:@"Hello. This is a tweet." forKey:@"status"]];
                
                // Set the account used to post the tweet.
                [postRequest setAccount:twitterAccount];
                
                // Perform the request created above and create a handler block to handle the response.
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    if (error == nil)
                    {
                        NSLog(@"no error");
                    }
                    else
                    {
                        NSLog(@"error : %@", error);
                    }
                }];
            }
        }
        else
        {
            if (error != nil)
            {
                NSLog(@"Account Store Error : %@", error);
            }
        }
    }];
}

- (NSArray *) retrieveImages
{
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:1];
    
    return images;
}

- (void) performUploadWithImage:(UIImage *) image name:(NSString *) name
{
    NSURL *url = [NSURL URLWithString:@"https://upload.twitter.com/1/statuses/update_with_media.json"];
    
    // Create an account store object.
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];

            //  Create a POST request for the target endpoint
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:nil];
            
            //  self.accounts is an array of all available accounts;
            //  we use the first one for simplicity
            [request setAccount:[accountsArray objectAtIndex:0]];
                        
            //  Obtain NSData from the UIImage
            NSData *imageData = UIImagePNGRepresentation(image);
            
            //  Add the data of the image with the
            //  correct parameter name, "media[]"
            [request addMultipartData:imageData withName:@"media[]" type:@"multipart/form-data" filename:name];
            
            //  Add the data of the status as parameter "status"
            //[request addMultiPartData:[status dataUsingEncoding:NSUTF8StringEncoding]
            //                 withName:@"status"
            //                     type:@"multipart/form-data"];
            
            //  Perform the request.
            //    Note that -[performRequestWithHandler] may be called on any thread,
            //    so you should explicitly dispatch any UI operations to the main thread
            [request performRequestWithHandler:
             ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 NSDictionary *dict =
                 (NSDictionary *)[NSJSONSerialization
                                  JSONObjectWithData:responseData options:0 error:nil];
                 
                 // Log the result
                 NSLog(@"%@", dict);
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     // perform an action that updates the UI...
                 });
             }];

            
            
            
            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] > 0)
            {
            }
        }
    }];
    
}

@end
