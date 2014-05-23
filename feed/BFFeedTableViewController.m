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
#import "BButton.h"
#import "BFFeedManager.h"
#import "BFAddPostViewController.h"

@interface BFFeedTableViewController ()
@property (weak, nonatomic) IBOutlet BButton *addPostButton;
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
    
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    [self.addPostButton setType:BButtonTypeDanger];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BFFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    BFPost *post = self.feed[indexPath.row];
    cell.feedText.text = post.postText;
    
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height + 1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
- (void) refresh {
    [[BFFeedManager sharedManager] getFeed:^(NSArray * feed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.feed = [NSMutableArray arrayWithArray:feed];
            [self.tableView reloadData];
            if (self.refreshControl.isRefreshing)
                [self.refreshControl endRefreshing];

        });
    } failure:^(RKObjectRequestOperation * operation, NSError * error) {
        
    }];
}

- (IBAction)unwindSegue:(UIStoryboardSegue *)segue {
    //read saved post out of "Add Post" controller
    BFAddPostViewController *ctrl = segue.sourceViewController;
    [self.feed insertObject:ctrl.savedPost atIndex:0];
    [self.tableView reloadData];
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
