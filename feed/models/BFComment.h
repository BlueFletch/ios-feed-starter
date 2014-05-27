//
//  BFComment.h
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFUser.h"

@interface BFComment : NSObject

@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic, strong) BFUser *commentUser;
@property (nonatomic, strong) NSDate *createdDate;

@property (nonatomic, strong) NSString *parentPostId;

@end
