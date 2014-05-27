//
//  BFFeedReplyTableViewCell.m
//  feed
//
//  Created by Blake Byrnes on 5/26/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFFeedReplyTableViewCell.h"

@implementation BFFeedReplyTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self.replyButton addAwesomeIcon:FAReply beforeTitle:true];
    [self.replyButton setType:BButtonTypePrimary];
    
    [self.editButton setType:BButtonTypeGray];
    [self.editButton addAwesomeIcon:FAEdit beforeTitle:true];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
