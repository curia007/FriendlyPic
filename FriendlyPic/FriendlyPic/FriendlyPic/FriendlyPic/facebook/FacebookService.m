//
//  FacebookPostageService.m
//  FriendlyPic
//
//  Created by Carmelo I. Uria on 9/8/12.
//  Copyright (c) 2012 Carmelo Uria Corporation. All rights reserved.
//

#import "FacebookService.h"

#import "NSData+Base64.h"

NSString *const FBSessionStateChangedNotification = @"com.example.Login:FBSessionStateChangedNotification";

@implementation FacebookService

- (void) performUploadWithData:(UIImage *) image name:(NSString *) name;
{
    NSAssert(image != nil, @"image cannot be nil");
    
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            @"publish_actions",
                            @"publish_stream",
                            @"manage_pages",
                            @"user_photos",
                            @"photo_upload",
                            nil];

    NSMutableDictionary *optionsDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [optionsDictionary setObject:@"518955411452899" forKey:ACFacebookAppIdKey];
    [optionsDictionary setObject:permissions forKey:ACFacebookPermissionsKey];
    [optionsDictionary setObject:ACFacebookAudienceEveryone forKey:ACFacebookAudienceKey];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [accountStore requestAccessToAccountsWithType:accountType options:optionsDictionary completion:^(BOOL granted, NSError *error) {
        if (granted == YES)
        {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            NSLog(@"accounts : %@", accounts);
            
            ACAccount *account = [accounts lastObject];
            
            NSString *urlString = @"https://graph.facebook.com/me/photos";
            SLRequestMethod requestMethod = SLRequestMethodPOST;
            NSURL *url = [NSURL URLWithString:urlString];
            
            
            NSData *rawData = UIImageJPEGRepresentation(image, 1.0);
            
            // write to URL
            NSString *filename = [NSString stringWithFormat:@"%@.jpeg", name];
            NSArray *documentDictionaries = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *documentDictionary = [documentDictionaries objectAtIndex:0];
            NSString *documentDictionaryFilename = [documentDictionary stringByAppendingPathComponent:filename];
            BOOL isFileCreated = [rawData writeToFile:documentDictionaryFilename options:NSDataWritingAtomic error:&error];
            
            if (isFileCreated == NO)
            {
                NSLog(@"file not create, possible error : %@", error);
                error = nil;
            }
            
            NSURL *documentURL = [NSURL fileURLWithPath:documentDictionaryFilename];
            NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithObject:documentDictionaryFilename forKey:@"picture"];
            
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:requestMethod URL:url parameters:requestParameters];
            
            request.account = account;
            [request addMultipartData:rawData withName:documentDictionaryFilename type:@"Content-Type: image/jpeg" filename:documentDictionaryFilename];
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (error != nil)
                {
                    NSLog(@"Error : %@", error);
                }
                else
                {
                    NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                    NSLog(@"documentURL : %@", [documentURL absoluteString]);
                    NSLog(@"document filename = %@", documentDictionaryFilename);
                    NSLog(@"response : %@", response);
                }
            }];
        }
        else
        {
            if (error != nil)
            {
                NSLog(@"Error : %@", error);
            }
            else
            {
                NSLog(@"Appears to be an configuration issue");
            }
        }
    }];
    
}

- (void) retrieveImagesWithCompletion:(FacebookImageCompletion) completion
{
    
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            @"manage_pages",
                            @"user_photos",
                            nil];
    
    NSMutableDictionary *optionsDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [optionsDictionary setObject:@"518955411452899" forKey:ACFacebookAppIdKey];
    [optionsDictionary setObject:permissions forKey:ACFacebookPermissionsKey];
    [optionsDictionary setObject:ACFacebookAudienceEveryone forKey:ACFacebookAudienceKey];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    [accountStore requestAccessToAccountsWithType:accountType options:optionsDictionary completion:^(BOOL granted, NSError *error) {
        if (granted == YES)
        {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            NSLog(@"accounts : %@", accounts);
            
            ACAccount *account = [accounts lastObject];

            // retrieve user albums
            NSString *urlString = @"https://graph.facebook.com/me/albums";
            SLRequestMethod requestMethod = SLRequestMethodGET;
            NSURL *url = [NSURL URLWithString:urlString];

            NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithObject:@"id, name" forKey:@"fields"];

            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:requestMethod URL:url parameters:requestParameters];
            
            request.account = account;

            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                
                NSError *jsonError = nil;
                
                if (error != nil)
                {
                    NSLog(@"Error : %@", error);
                }
                else
                {
                    
                    NSDictionary *objects = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];

#ifdef DEBUG
                    NSLog(@"objects : %@", objects);
#endif                    
                    NSDictionary *data = [objects objectForKey:@"data"];
                    for (NSDictionary *object in data)
                    {
                        NSString *album = [object objectForKey:@"id"];
                        NSLog(@"object : %@", album);
                        
                        // retrieve user albums
                        NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@", album];
                        SLRequestMethod requestMethod = SLRequestMethodGET;
                        NSURL *url = [NSURL URLWithString:urlString];
                        
                        NSMutableDictionary *requestParameters = nil;
                        //NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithObject:@"id, name" forKey:@"fields"];
                        
                        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:requestMethod URL:url parameters:requestParameters];
                        
                        request.account = account;
                        
                        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                            
                            if (error != nil)
                            {
                                NSLog(@"error = %@", error);
                            }
                            else
                            {
                                NSError *jsonError = nil;
                                
                                NSDictionary *objects = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];
                                NSLog(@"objects = %@", objects);
                                
                                // retrieve image link
                                NSString *link = [objects objectForKey:@"link"];
                                NSLog(@"link = %@", link);
                                
                                completion(link, error);
                               
                            }
                        }];
                        
                    }
                }
            }];
        }
        
    }];
    
    // test
    NSLog(@"test");
}

@end
