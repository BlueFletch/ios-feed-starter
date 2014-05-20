//
//  BFFeedManager.h
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFObjectManager.h"
#import "BFPost.h"
#import "BFUser.h"
#import "BFComment.h"


@interface BFFeedManager : BFObjectManager

- (void) getFeed:(void (^)(NSArray *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;

- (void) createPost:(BFPost *)post success:(void (^)(BFPost *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;

@end
