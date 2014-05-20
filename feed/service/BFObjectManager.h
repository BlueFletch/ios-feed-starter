//
//  BFObjectManager.h
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "RKObjectManager.h"

@interface BFObjectManager : RKObjectManager
+(NSString*)baseURL;
+ (instancetype) sharedManager;

- (void) setupRequestDescriptors;
- (void) setupResponseDescriptors;
@end
