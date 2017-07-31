//
//  MKSKNonRenewSubscriptionProduct.m
//  PainTracker
//
//  Created by Wendy Kutschke on 6/22/14.
//  Copyright (c) 2014 Chronic Stimulation, LLC. All rights reserved.
//

#import "MKSKNonRenewSubscriptionProduct.h"
#import "NSData+MKBase64.h"

static void (^onReviewRequestVerificationSucceeded)(void);
static void (^onReviewRequestVerificationFailed)(void);
static NSURLConnection *sConnection;
static NSMutableData *sDataFromConnection;

@implementation MKSKNonRenewSubscriptionProduct

-(id) initWithProductId:(NSString*) aProductId receiptData:(NSData*) aReceipt
{
    if((self = [super init]))
    {
        self.productId = aProductId;
        self.receipt = aReceipt;
    }
    return self;
}

- (void) verifyReceiptOnComplete:(void (^)(void)) completionBlock
                         onError:(void (^)(NSError*)) errorBlock
{
    self.onReceiptVerificationSucceeded = completionBlock;
    self.onReceiptVerificationFailed = errorBlock;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", OWN_SERVER, @"verifyProduct.php"]];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:60];
	
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	NSString *receiptDataString = [self.receipt base64EncodedString];
    
	NSString *postData = [NSString stringWithFormat:@"receiptdata=%@", receiptDataString];
	
	NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
	[theRequest setValue:length forHTTPHeaderField:@"Content-Length"];
	
	[theRequest setHTTPBody:[postData dataUsingEncoding:NSASCIIStringEncoding]];
	
    self.theConnection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
    [self.theConnection start];
}


#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    self.dataFromConnection = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
	[self.dataFromConnection appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:self.dataFromConnection
                                                     encoding:NSASCIIStringEncoding];
    responseString = [responseString stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.dataFromConnection = nil;
	if([responseString isEqualToString:@"YES"])
	{
        if(self.onReceiptVerificationSucceeded)
        {
            self.onReceiptVerificationSucceeded();
            self.onReceiptVerificationSucceeded = nil;
        }
	}
    else
    {
        if(self.onReceiptVerificationFailed)
        {
            self.onReceiptVerificationFailed(nil);
            self.onReceiptVerificationFailed = nil;
        }
    }
	
    
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    
    self.dataFromConnection = nil;
    if(self.onReceiptVerificationFailed)
    {
        self.onReceiptVerificationFailed(nil);
        self.onReceiptVerificationFailed = nil;
    }
}

@end
