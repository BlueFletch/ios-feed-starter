//
//  BFObjectManager.m
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFObjectManager.h"
#import <RestKit/RestKit.h>

@implementation BFObjectManager

//static NSString * const _baseUrl = @"http://feed.bluefletch.com/";

static NSString * const _baseUrl = @"https://bfapp-bfsharing.rhcloud.com/";

+ (NSString *) baseURL {
    return _baseUrl;
}

+ (instancetype)sharedManager {
    
    BFObjectManager *sharedManager  = [self managerWithBaseURL:[NSURL URLWithString:self.baseURL]];
    sharedManager.requestSerializationMIMEType = RKMIMETypeJSON;
    /*
     THIS CLASS IS MAIN POINT FOR CUSTOMIZATION:
     - setup HTTP headers that should exist on all HTTP Requests
     - override methods in this class to change default behavior for all HTTP Requests
     - define methods that should be available across all object managers
     */
    
    [sharedManager setupRequestDescriptors];
    [sharedManager setupResponseDescriptors];
    
    
    
    return sharedManager;
}

- (void) setupRequestDescriptors {
}

- (void) setupResponseDescriptors {
}
@end
