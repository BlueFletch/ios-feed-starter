//
//  BFAddCommentViewController.h
//  feed
//
//  Created by Blake Byrnes on 5/26/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFTextView+Category.h"
#import "BButton.h"
#import "BFComment.h"

//declare the delegate
@interface BFAddCommentViewController : UIViewController


@property (weak, nonatomic) IBOutlet BFTextView_Category *textInput;
@property (weak, nonatomic) IBOutlet BButton *addButton;

@property (strong) NSString* replyToPostId;
- (IBAction)onPosted:(id)sender;

@end