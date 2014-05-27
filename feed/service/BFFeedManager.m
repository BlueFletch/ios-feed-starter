//
//  BFFeedManager.m
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFFeedManager.h"
#import <RestKit/RestKit.h>
#import "BFPost.h"
#import "BFMappingProvider.h"
#import "BFUserManager.h"

@implementation BFFeedManager

NSString * const BFFeedStarted = @"BFFeedStarted";
NSString * const BFFeedFailed = @"BFFeedFailed";
NSString * const BFFeedEnded = @"BFFeedEnded";

static BFFeedManager *sharedManager = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [super sharedManager];
    });
    
    return sharedManager;
}

-(void)getFeed:(void (^)(NSArray * feed))success failure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure {
    [[NSNotificationCenter defaultCenter] postNotificationName:BFFeedStarted object:nil];
    
    [self getObjectsAtPath:@"feed" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BFFeedEnded object:nil];
        
        //read post ids
        for (BFPost *post in [mappingResult array]) {
            for(BFComment *comment in post.comments) {
                comment.parentPostId = post.postId;
            }
        }
        success([mappingResult array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BFFeedEnded object:nil];
        if (failure) failure(operation, error);
    }];
}

- (void) createPost:(NSString *)postText success:(void (^)(BFPost *post))success failure:(void (^)(RKObjectRequestOperation * operation, NSError *error))failure;{
    
    [self postObject:nil path:@"post" parameters:@{@"username":BFUserManager.username, @"postText":postText} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success([mappingResult firstObject]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) failure(operation, error);
    }];
}
- (void) createComment:(NSString *)commentText forPostId:(NSString *)postId success:(void (^)(BFComment *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure {
    
    [self postObject:nil
                path:@"comment"
          parameters:@{
                       @"username":BFUserManager.username,
                       @"commentText":commentText,
                       @"postId": postId
                    }
             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                success([mappingResult firstObject]);
             }
             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                if (failure) failure(operation, error);
             }
     ];
}

- (void) setupResponseDescriptors {
    [super setupResponseDescriptors];
    
    RKResponseDescriptor *feedDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:[BFMappingProvider postMapping]
                             method:RKRequestMethodGET pathPattern:@"feed" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *postDescriptor =
        [RKResponseDescriptor responseDescriptorWithMapping:[BFMappingProvider postMapping]
                             method:RKRequestMethodPOST pathPattern:@"post" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    RKResponseDescriptor *postCommentDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:[BFMappingProvider commentMapping]
                                                 method:RKRequestMethodPOST pathPattern:@"comment" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // Error JSON looks like {"errors": "Some Error Has Occurred"}
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    // The entire value at the source key path containing the errors maps to the message
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError);
    // Any response in the 4xx status code range with an "errors" key path uses this mapping
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"errors" statusCodes:statusCodes];

    [self addResponseDescriptorsFromArray:@[ postDescriptor, feedDescriptor, postCommentDescriptor, errorDescriptor ]];

    
    
    
}


@end
