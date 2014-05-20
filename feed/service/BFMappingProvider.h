//
//  BFMappingProvider.h
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "RKObjectMapping.h"

@interface BFMappingProvider : NSObject
+ (RKObjectMapping *) userMapping;
+ (RKObjectMapping *) postMapping;
+ (RKObjectMapping *) commentMapping;

@end
