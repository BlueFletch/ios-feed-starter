//
//  BFUserManager.h
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFObjectManager.h"
#import "BFUser.h"

@interface BFUserManager : BFObjectManager

extern NSString * const BFLoginStarted;
extern NSString * const BFLoginEnded;
extern NSString * const BFLoginFailed;

+ (NSString *) username;
+ (BFUser *) user;

- (void) authenticateWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(BFUser * user))success failure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure;
- (void) authenticateIfAvailable:(void (^)(BFUser * user))success failure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure;
- (void) setProfileImage:(UIImage *) image onSuccess:(void (^)(BFUser * user))success onFailure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure;
@end
