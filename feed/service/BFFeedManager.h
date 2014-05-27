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

extern NSString * const BFFeedStarted;
extern NSString * const BFFeedEnded;
extern NSString * const BFFeedFailed;

- (void) getFeed:(void (^)(NSArray * feed))success failure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure;
- (void) createPost:(NSString *)postText success:(void (^)(BFPost *post))success failure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure;
- (void) createComment:(NSString *)commentText forPostId:(NSString *)postId success:(void (^)(BFComment *post))success failure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure;

@end
