//
//  MKSKNonRenewSubscriptionProduct.h
//  PainTracker
//
//  Created by Wendy Kutschke on 6/22/14.
//  Copyright (c) 2014 Chronic Stimulation, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKStoreKitConfigs.h"

@interface MKSKNonRenewSubscriptionProduct : NSObject

@property (nonatomic, copy) void (^onReceiptVerificationSucceeded)(void);
@property (nonatomic, copy) void (^onReceiptVerificationFailed)(NSError* error);

@property (nonatomic, strong) NSData *receipt;
@property (nonatomic, assign) NSInteger subscriptionMonths;
@property (nonatomic, strong) NSDate *currentExpiryDate;

@property (nonatomic, strong) NSString *productId;
@property (nonatomic, strong) NSURLConnection *theConnection;
@property (nonatomic, strong) NSMutableData *dataFromConnection;

- (void) verifyReceiptOnComplete:(void (^)(void)) completionBlock
                         onError:(void (^)(NSError*)) errorBlock;

-(id) initWithProductId:(NSString*) aProductId receiptData:(NSData*) aReceipt;

@end
