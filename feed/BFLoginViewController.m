//
//  BFLoginController.m
//  feed
//
//  Created by Blake Byrnes on 5/20/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFLoginViewController.h"
#import "BFFeedTableViewController.h"
#import "BButton.h"
#import "BFFeedManager.h"
#import "BFUserManager.h"

@interface BFLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet BButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@property (strong, nonatomic) NSArray *feed;
@property BOOL isAuthenticated;

@end

@implementation BFLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //hide top bar
    self.navigationController.navigationBarHidden = true;
    
    //setup flat button
    [self.loginButton setType:BButtonTypePrimary];
    [self.loginButton addAwesomeIcon:FALock beforeTitle:NO];
    
    
    
    [self.userName becomeFirstResponder];
    self.errorMessage.alpha = 0;
    self.password.delegate = self;
    self.userName.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginClicked {
    NSString *username = self.userName.text;
    NSString *pwd = self.password.text;
    [[BFUserManager sharedManager] authenticateWithUsername:username password:pwd success:^(BFUser *user) {
        self.isAuthenticated = true;
        [self loadFeed];
        
        NSLog(@"Authenticated successfully");
    } failure:^(RKObjectRequestOperation *operation, NSError *error)  {
        
        NSLog(@"Failed to authenticate");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self flashErrorMessage];
        });
        
    }];
}

//show error label and fade out after 5 seconds
- (void) flashErrorMessage {
    [UIView animateWithDuration:1.5 animations:^{
        self.errorMessage.alpha =1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.errorMessage.alpha = 0;
        });
    }];
}

- (void) loadFeed {
    [[BFFeedManager sharedManager] getFeed:^(NSArray * feed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.feed = feed;
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
        });
    } failure:^(RKObjectRequestOperation * operation, NSError * error) {
        
    }];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"loginSegue"])
    {
        // Get reference to the destination view controller
        BFFeedTableViewController *vc = [segue destinationViewController];
        
        vc.feed = self.feed;
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"loginSegue"])
    {
        return self.isAuthenticated;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (0 == [textField.text length]) {
        return NO;
    }
  
    [textField resignFirstResponder];
    if (textField == self.userName) {
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        [self loginClicked];
    }
    return YES;
}
@end

