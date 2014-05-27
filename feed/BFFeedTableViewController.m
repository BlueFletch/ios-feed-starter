//
//  BFFeedTableViewController.m
//  feed
//
//  Created by Blake Byrnes on 5/20/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFFeedTableViewController.h"
#import "BFFeedTableViewCell.h"
#import "BFFeedReplyTableViewCell.h"
#import "BFAddCommentViewController.h"
#import "BFPost.h"
#import <AFNetworking/AFNetworking.h>
#import "BFObjectManager.h"
#import "BButton.h"
#import "BFFeedManager.h"
#import "BFUserManager.h"
#import "UIView+Borders.h"
#import "NSDate+Helper.h"
#import "UIButton+AFNetworking.h"
#import "CRToast.h"
#import "WYPopoverController.h"
#import "WYStoryboardPopoverSegue.h"

@interface BFFeedTableViewController () <WYPopoverControllerDelegate> {
    WYPopoverController* addCommentPopoverController;
    BFFeedTableViewCell *commentSizingCell;
    BFFeedTableViewCell *postSizingCell;
}
- (IBAction)refreshTable:(id)sender;

@end

@implementation BFFeedTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%@'s feed", BFUserManager.user.username];
    //hide back button since we don't really need it
    self.navigationController.navigationBarHidden = false;
    self.navigationItem.hidesBackButton = true;
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive | UIScrollViewKeyboardDismissModeOnDrag;
    
    self.postText.placeholder = @"Add a new entry to the feed";
    [self.addButton setType:BButtonTypeDanger];
    //add a border (through a helper category on uiview)
    [self.tableHeaderView addBottomBorderWithHeight:1.0 andColor:[UIColor colorWithWhite:0.800 alpha:1.000]];
    
    self.profileConfig.clipsToBounds = YES;
    //make sure image doesn't skew to fit in here
    self.profileConfig.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileConfig.layer.cornerRadius = 4;//half of the width
    self.profileConfig.layer.borderColor=[UIColor colorWithWhite:0.800 alpha:1.000].CGColor;
    self.profileConfig.layer.borderWidth= 1.0f;
    [self setProfileImageToButton];
    
    
    //listen for comments added
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(commentAdded:) name:@"commentAdded" object:nil];
    [center addObserver:self selector:@selector(commentCanceled) name:@"commentCanceled" object:nil];
    [center addObserver:self selector:@selector(refreshTable:) name:@"newContentAvailable" object:nil];
    
}

- (void) setProfileImageToButton {
    
    //add profile image in top left corner
    NSURL *imageUrl = [NSURL URLWithString:BFUserManager.user.imageUrl relativeToURL:[NSURL URLWithString:BFObjectManager.baseURL]];
    [self.profileConfig setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"Profile"] forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadFeed:(NSArray *)feed {
    self.feed = [[NSMutableArray alloc] init];
    for (BFPost* post in feed) {
        [self.feed addObject:post];
        for (BFComment* comment in post.comments) {
            [self.feed addObject:comment];
        }
    }
}
- (void) viewDidAppear:(BOOL)animated {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        [self showHintForProfile];
    });
}

- (void) showHintForProfile {
    
    NSDictionary *options = @{
                              kCRToastTextKey : @"Change your profile image in the top left corner!",
                              kCRToastBackgroundColorKey : [UIColor colorWithRed:0.400 green:0.600 blue:0.800 alpha:1.000],
                              };
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                }];
}

#pragma mark - Image Picker Stuff


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"replyPopoverSegue"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
        
		BFAddCommentViewController* addCommentController = [[navigationController viewControllers] objectAtIndex:0];
        addCommentController.preferredContentSize = CGSizeMake(self.view.frame.size.width - 8, 150);
		//addCommentController.delegate = self;
        
        WYStoryboardPopoverSegue* popoverSegue = (WYStoryboardPopoverSegue*)segue;
        
        addCommentPopoverController = [popoverSegue popoverControllerWithSender:sender
                                                          permittedArrowDirections:WYPopoverArrowDirectionAny
                                                                          animated:YES];
        

        id prev = self.feed[self.controlRowIndexPath.row - 1];
        if ([prev isKindOfClass:[BFPost class]]) {
            addCommentController.replyToPostId = [((BFPost*)prev) postId];
        } else {
            addCommentController.replyToPostId = [((BFComment*)prev) parentPostId];
        }
        
        addCommentPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(4, 4, 4, 4);
        
        addCommentPopoverController.delegate = self;
	} else {
        UIImagePickerController *controller = [[segue destinationViewController] init];
#if TARGET_IPHONE_SIMULATOR
        // Only executes on the Simulator
        [controller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
#else
        // Only executes on an iPhone or iPod touch device
        [controller setSourceType:UIImagePickerControllerSourceTypeCamera];
#endif
        controller.delegate = self;
    }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    [[BFUserManager sharedManager] setProfileImage:image onSuccess:^(BFUser *user) {
        [self setProfileImageToButton];
        [self refreshTable:nil];
        [self showMessage:@"Your profile picture has been saved" subMessage:nil asError:false];
    } onFailure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self showMessage:@"Error saving new profile picture" subMessage:[error description] asError:true];
    }];
}
-(void)showMessage:(NSString *)message subMessage:(NSString *)submessage asError:(BOOL)isError {
    NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:@{
                              kCRToastTextKey : message,
                              kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                              kCRToastBackgroundColorKey : isError ? [UIColor redColor] : [UIColor colorWithRed:0.200 green:0.600 blue:0.000 alpha:1.000]
                              }];
    if (submessage) {
        options[kCRToastSubtitleTextKey]= submessage;
    }
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.controlRowIndexPath){
        return self.feed.count + 1;
    }

    // Return the number of rows in the section.
    return self.feed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.controlRowIndexPath && [indexPath isEqual:self.controlRowIndexPath]) {
        BFFeedReplyTableViewCell *replyCell= [tableView dequeueReusableCellWithIdentifier:@"replyCell" forIndexPath:indexPath];
        
        id entry = self.feed[indexPath.row-1];
        BFUser *replyToPostUser = [entry isKindOfClass:[BFPost class]] ? ((BFPost *) entry).postUser : ((BFComment *) entry).commentUser;
        
        BOOL enableEdit = [replyToPostUser.userId isEqualToString:BFUserManager.user.userId];
        replyCell.editButton.hidden = !enableEdit;
        return replyCell;
    }
    //update the indexpath if needed... because we may have an "inserted" row into the model
    indexPath = [self modelIndexPathforIndexPath:indexPath];

    id entry = self.feed[indexPath.row];
    BFFeedTableViewCell *cell = nil;
    BFUser *postUser;
    NSDate *date;
    if ([entry isKindOfClass:[BFPost class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell" forIndexPath:indexPath];
        BFPost *post = entry;
        cell.feedText.text = post.postText;
        
        date = post.createdDate;
        postUser = post.postUser;
        
        cell.backgroundColor = post.isNewPost ? [UIColor colorWithRed:0.655 green:0.793 blue:0.999 alpha:1.000] : [UIColor whiteColor];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
        BFComment *comment = entry;
        cell.feedText.text = comment.commentText;
        
        date = comment.createdDate;
        postUser = comment.commentUser;
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.dateLabel.text = [NSDate stringForDisplayFromDate:date];
    cell.nameLabel.text = postUser.username;
    [cell.profileImage setImageWithURL:[NSURL URLWithString:postUser.imageUrl relativeToURL:[NSURL URLWithString:BFObjectManager.baseURL]]];
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //for control row
    if([indexPath isEqual:self.controlRowIndexPath]){
        return 45; //height for control cell
    }
    //update the indexpath if needed... because we may have an "inserted" row into the model
    indexPath = [self modelIndexPathforIndexPath:indexPath];

    BFFeedTableViewCell *cell =nil;
    id entry = self.feed[indexPath.row];
    if ([entry isKindOfClass:[BFPost class]]) {
        if (!postSizingCell)
            postSizingCell = [tableView dequeueReusableCellWithIdentifier:@"feedCell"];
        cell = postSizingCell;
        BFPost *post = entry;
        cell.feedText.text = post.postText;
    } else {
        if (!commentSizingCell)
            commentSizingCell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        cell = commentSizingCell;
        
        BFComment *comment = entry;
        cell.feedText.text = comment.commentText;
    }
    
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height + 1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark Handle Reply Row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //if user tapped the same row twice let's start getting rid of the control cell
    if([indexPath isEqual:self.tappedIndexPath]){
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    //update the indexpath if needed... I explain this below
    indexPath = [self modelIndexPathforIndexPath:indexPath];
    
    //pointer to delete the control cell
    NSIndexPath *indexPathToDelete = self.controlRowIndexPath;
    
    //if in fact I tapped the same row twice lets clear our tapping trackers
    if([indexPath isEqual:self.tappedIndexPath]){
        self.tappedIndexPath = nil;
        self.controlRowIndexPath = nil;
    }
    //otherwise let's update them appropriately
    else{
        self.tappedIndexPath = indexPath; //the row the user just tapped.
        //Now I set the location of where I need to add the dummy cell
        self.controlRowIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1   inSection:indexPath.section];
    }
    
    //all logic is done, lets start updating the table
    [tableView beginUpdates];
    
    //lets delete the control cell, either the user tapped the same row twice or tapped another row
    if(indexPathToDelete){
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathToDelete]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
    //lets add the new control cell in the right place
    if(self.controlRowIndexPath){
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:self.controlRowIndexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
    
    //and we are done...
    [tableView endUpdates];  
}

- (NSIndexPath *)modelIndexPathforIndexPath:(NSIndexPath *)indexPath
{
    NSInteger whereIsTheControlRow = self.controlRowIndexPath.row;
    if(self.controlRowIndexPath != nil && indexPath.row > whereIsTheControlRow)
        return [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
    return indexPath;
}

#pragma mark IBActions


- (IBAction)refreshTable:(id)sender {
    [[BFFeedManager sharedManager] getFeed:^(NSArray * feed) {
        [self loadFeed:feed];
        self.controlRowIndexPath = nil;
        self.tappedIndexPath = nil;
        [self.tableView reloadData];
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
    } failure:^(RKObjectRequestOperation * operation, NSError * error) {
        
    }];
}
- (IBAction)onAdd:(id)sender {
    //TODO: post new comment
    NSString *text = self.postText.text;
    if (!text || [text isEqualToString:@""]) {
        [self showMessage:@"Your post is empty" subMessage:nil asError:true];
        return;
    }
    [[BFFeedManager sharedManager] createPost:text success:^(BFPost * saved) {
        self.postText.text = @"";
        [self.feed insertObject:saved atIndex:0];
        [self.tableView reloadData];
        [self showMessage:@"Your message has been posted" subMessage:nil asError:false];
        
    } failure:^(RKObjectRequestOperation * op, NSError * err) {
        [self showMessage:@"Your message couldn't be posted" subMessage:[err description] asError:true];
        NSLog(@"Error saving post %@", [err description]);
    }];
    
}

-(void)commentCanceled {
    [addCommentPopoverController dismissPopoverAnimated:true];
    addCommentPopoverController.delegate = nil;
    addCommentPopoverController = nil;
}
- (void)commentAdded:(NSNotification *) notification{
    [addCommentPopoverController dismissPopoverAnimated:true];
    
    //refresh after add
    //TODO: insert into proper location
    [self refreshTable:nil];
}

#pragma mark - WYPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)aPopoverController
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)aPopoverController
{
    if (aPopoverController == addCommentPopoverController)
    {
        //release
        addCommentPopoverController.delegate = nil;
        addCommentPopoverController = nil;
    }
}



@end
