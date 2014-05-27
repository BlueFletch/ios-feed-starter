//
//  BFUser.h
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFUser : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSDate *lastActionDate;
@property (nonatomic, strong) NSDate *createdDate;

@end
