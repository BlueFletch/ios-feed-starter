//
//  BFFeedTableViewController.m
//  feed
//
//  Created by Blake Byrnes on 5/20/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFFeedTableViewController.h"
#import "BFFeedTableViewCell.h"
#import "BFPost.h"
#import <AFNetworking/AFNetworking.h>
#import "BFObjectManager.h"
#import "UAPush.h"

@interface BFFeedTableViewController ()
@property (readwrite, nonatomic) BFFeedTableViewCell *metricsCell;

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
    
    self.title = @"BF Feed";
    self.navigationController.navigationBarHidden = false;
    self.navigationItem.hidesBackButton = true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated {
    [[UAPush shared] resetBadge];//zero badge
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.feed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BFFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
- (void)configureCell:(BFFeedTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //protection against overflow
    BFPost *post = self.feed[indexPath.row];
    cell.feedText.text = post.postText;
    [cell.profileImage setImageWithURL:[NSURL URLWithString:post.postUser.imageUrl relativeToURL:[NSURL URLWithString:BFObjectManager.baseURL]]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (!self.metricsCell) {
        self.metricsCell = [self.tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    }
    // We need to adjust the metrics cell's frame to handle table width changes (e.g. rotations).
    CGRect theFrame = self.metricsCell.frame;
    theFrame.size.width = self.tableView.bounds.size.width;
    self.metricsCell.frame = theFrame;
    
    // Set up the metrics cell using real populated content.
    [self configureCell:self.metricsCell atIndexPath:indexPath];
    
    // Force a layout.
    //Layout and Autolayout update UIView
    [ self.metricsCell setNeedsUpdateConstraints];
    [ self.metricsCell updateConstraintsIfNeeded];
    [ self.metricsCell.contentView setNeedsLayout];
    [ self.metricsCell.contentView layoutIfNeeded];
    
    // Get the layout size - we ignore the width - in the fact the width _could_ conceivably be zero.
    // Note: Using content view is intentional.
    CGSize theSize = [self.metricsCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return (theSize.height + 1);
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
