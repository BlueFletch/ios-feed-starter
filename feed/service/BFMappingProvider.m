//
//  BFMappingProvider.m
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFMappingProvider.h"
#import "BFUser.h"
#import "BFPost.h"
#import "BFComment.h"
#import <RestKit/RestKit.h>

@implementation BFMappingProvider

+ (RKObjectMapping *) userMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[BFUser class]];
    [mapping addAttributeMappingsFromDictionary:@{@"_id":@"userId"}];
    [mapping addAttributeMappingsFromArray:@[@"imageUrl", @"username", @"lastActionDate", @"createdDate"]];
    return mapping;
}
+ (RKObjectMapping *) postMapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[BFPost class]];
    
    [mapping addAttributeMappingsFromDictionary:@{@"_id":@"postId",
                                                  @"newPostForUser":@"isNewPost"}];
    [mapping addAttributeMappingsFromArray:@[@"postText"]];

    /* TODO: fill-in*/
    
    
    
    /* First key is JSON Key, second is in Objective C Key */
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"comments" toKeyPath:@"comments" withMapping:[self commentMapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"postUser" toKeyPath:@"postUser" withMapping:[self userMapping]]];
    return mapping;
}
+ (RKObjectMapping *) commentMapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[BFComment class]];
    /* TODO: fill-in*/

    return mapping;
}
@end
