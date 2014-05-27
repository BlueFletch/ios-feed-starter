//
//  BFFeedTableViewController.h
//  feed
//
//  Created by Blake Byrnes on 5/20/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BButton.h"
#import "BFTextView+Category.h"

@interface BFFeedTableViewController : UITableViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *profileConfig;

@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet BFTextView_Category *postText;
@property (weak, nonatomic) IBOutlet BButton *addButton;
@property (strong) NSMutableArray *feed;

@property NSIndexPath *controlRowIndexPath;
@property NSIndexPath *tappedIndexPath;

- (IBAction)onAdd:(id)sender;
- (void) loadFeed:(NSArray *)feed;
@end
