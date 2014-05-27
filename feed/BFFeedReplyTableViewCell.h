//
//  BFFeedReplyTableViewCell.h
//  feed
//
//  Created by Blake Byrnes on 5/26/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BButton.h"

@interface BFFeedReplyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet BButton *editButton;
@property (weak, nonatomic) IBOutlet BButton *replyButton;

@end
