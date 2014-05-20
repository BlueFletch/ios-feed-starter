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
- (void) authenticateWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(BFUser *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;

@end
