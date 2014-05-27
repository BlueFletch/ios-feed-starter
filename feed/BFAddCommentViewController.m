//
//  BFAddCommentViewController.m
//  feed
//
//  Created by Blake Byrnes on 5/26/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFAddCommentViewController.h"
#import "BFPost.h"
#import "BFFeedManager.h"
#import "CRToast.h"

@interface BFAddCommentViewController ()
@end

@implementation BFAddCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.textInput becomeFirstResponder];
}
-(void)viewWillDisappear:(BOOL)animated {
    [self.textInput resignFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.addButton setType:BButtonTypeDanger];
    
    self.textInput.placeholder = @"Add a comment";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onPosted:(id)sender {
    if (self.replyToPostId) {
        NSString *text = self.textInput.text;
        if (!text || [text isEqualToString:@""]) {
            
            [CRToastManager showNotificationWithOptions:@{
                                      kCRToastTextKey : @"Your comment is empty",
                                      kCRToastBackgroundColorKey : [UIColor redColor],
                                    }
                                        completionBlock:nil];
            return;
        }
        
        [[BFFeedManager sharedManager] createComment:text forPostId:self.replyToPostId success:^(BFComment *comment) {
            //self ref doesn't matter because block will go out of scope with view
            id data = @{
                        @"postId":self.replyToPostId,
                        @"comment":comment
                    };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"commentAdded" object:nil userInfo:data];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [CRToastManager showNotificationWithOptions:@{
                                                          kCRToastTextKey : @"Error saving comment",
                                                          kCRToastSubtitleTextKey : [error description],
                                                          kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                                                          kCRToastBackgroundColorKey : [UIColor redColor],
                                                          }
                                        completionBlock:nil];
        }];
    }
}
@end
