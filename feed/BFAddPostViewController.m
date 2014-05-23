//
//  BFAddPostViewController.m
//  feed
//
//  Created by Blake Byrnes on 5/23/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFAddPostViewController.h"
#import "BButton.h"
#import "BFPost.h"
#import "BFFeedManager.h"

@interface BFAddPostViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textInput;
@property (weak, nonatomic) IBOutlet BButton *addButton;
- (IBAction)onAdd:(id)sender;

@end

@implementation BFAddPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.addButton setType:BButtonTypeDanger];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)onAdd:(id)sender {
    //TODO: post new comment
    NSString *text = self.textInput.text;
    [[BFFeedManager sharedManager] createPost:text success:^(BFPost * saved) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.savedPost = saved;
            [self performSegueWithIdentifier:@"backToFeed" sender:self];
        });
        
    } failure:^(RKObjectRequestOperation * op, NSError * err) {
        NSLog(@"Error saving post %@", [err description]);
    }];
    
}
@end
