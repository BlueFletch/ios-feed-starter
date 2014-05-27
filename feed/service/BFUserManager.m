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
#import "SSKeychain.h"

@implementation BFUserManager

NSString * const BFLoginStarted = @"BFLoginStarted";
NSString * const BFLoginFailed = @"BFLoginFailed";
NSString * const BFLoginEnded = @"BFLoginEnded";

static BFUser *user;
static BFUserManager *sharedManager = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super sharedManager];
    });
    
    return sharedManager;
}
+ (NSString *)username {
    return user.username;
}
+ (BFUser *) user {
    return user;
}

- (void) storeCredentialsWithUsername:(NSString *)username andPassword:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setValue:username forKeyPath:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SSKeychain setPassword:password forService:@"feed" account:username];
}


- (void) authenticateIfAvailable:(void (^)(BFUser * user))success failure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure {
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if (!username) failure(NULL, NULL);
    
    NSString *password = [SSKeychain passwordForService:@"feed" account:username];
    
    if (username && password) {
        [self authenticateWithUsername:username password:password success:success failure:failure];
    }
}

- (void) authenticateWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(BFUser * user))success failure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure  {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BFLoginStarted object:nil];
    
    [self postObject:nil path:@"login" parameters:@{@"username":username, @"password": password} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BFLoginEnded object:operation];
        
        if (success) {
            BFUser *currentUser = (BFUser *)[mappingResult.array firstObject];
            user = currentUser;
            [self storeCredentialsWithUsername:username andPassword:password];
            success(currentUser);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BFLoginFailed object:operation];
        [[NSNotificationCenter defaultCenter] postNotificationName:BFLoginEnded object:operation];
        
        if (failure) {
            failure(operation, error);
        }
    }];
}
- (void) setProfileImage:(UIImage *) image onSuccess:(void (^)(BFUser * user))success onFailure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure  {
    NSString *path = [NSString stringWithFormat:@"user/%@/profilepic", BFUserManager.username];
    NSMutableURLRequest *request =
        [[RKObjectManager sharedManager]
                multipartFormRequestWithObject:nil
                                        method:RKRequestMethodPUT
                                          path:path
                                    parameters:nil
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         //4008392
                         [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.2)
                                                     name:@"imageFile"
                                                 fileName:@"image.jpg"
                                                 mimeType:@"image/jpeg"];
                         
                     }];
    
    
    
    RKObjectRequestOperation *operation =
        [[RKObjectManager sharedManager]
            objectRequestOperationWithRequest:request
         success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
             BFUser *_user =[mappingResult firstObject];
             user = _user;
             if (success) success(user);
         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
             if (failure) failure(operation,error);
         }];

    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
}

#pragma mark - Setup Helpers

- (void) setupResponseDescriptors {
    [super setupResponseDescriptors];
    
    RKResponseDescriptor *authenticatedUserResponseDescriptors =
        [RKResponseDescriptor responseDescriptorWithMapping:[BFMappingProvider userMapping]
                                                     method:RKRequestMethodPOST pathPattern:@"login" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    RKResponseDescriptor *profilePicResponse =
        [RKResponseDescriptor responseDescriptorWithMapping:[BFMappingProvider userMapping]
                                                 method:RKRequestMethodPUT pathPattern:@"user/:username/profilepic" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [self addResponseDescriptorsFromArray:@[authenticatedUserResponseDescriptors, profilePicResponse]];
}


@end
