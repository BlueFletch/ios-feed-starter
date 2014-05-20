//
//  BFUserManager.m
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFUserManager.h"
#import <RestKit/RestKit.h>
#import "BFMappingProvider.h"


@implementation BFUserManager

static BFUserManager *sharedManager = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super sharedManager];
    });
    
    return sharedManager;
}

- (void) authenticateWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(BFUser *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure {
    [self postObject:nil path:@"login" parameters:@{@"username":username, @"password": password} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            BFUser *currentUser = (BFUser *)[mappingResult.array firstObject];
            success(currentUser);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionFailure" object:operation];
            if (failure) {
            failure(operation, error);
        }
    }];
}

#pragma mark - Setup Helpers

- (void) setupResponseDescriptors {
    [super setupResponseDescriptors];
    
    RKResponseDescriptor *authenticatedUserResponseDescriptors =
        [RKResponseDescriptor responseDescriptorWithMapping:[BFMappingProvider userMapping]
                                                     method:RKRequestMethodPOST pathPattern:@"login" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [self addResponseDescriptor:authenticatedUserResponseDescriptors];
}


@end
