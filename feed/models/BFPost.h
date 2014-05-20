//
//  BFPost.h
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFUser.h"
@interface BFPost : NSObject

@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSString *postText;
@property (nonatomic, strong) BFUser *postUser;

@property (nonatomic, strong) NSArray *comments;

@property (nonatomic) BOOL isNewPost;

@end
