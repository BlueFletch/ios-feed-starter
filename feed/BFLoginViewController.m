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
#import "SVProgressHUD.h"
#import "CRToast.h"
#import "UAPush.h"

//this is a macro.  It let's you simplify code that you are reusing a lot.
//If you have a bunch of these, they can go into a helper file
#define dispatch_main($block) ([NSThread isMainThread] ? $block() : dispatch_sync(dispatch_get_main_queue(), $block))


@interface BFLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet BButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *password;

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
    
    //register for backend notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startLogin) name:BFLoginStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDownload) name:BFFeedStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endHUD) name:BFLoginFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endHUD) name:BFFeedEnded object:nil];
    
    
    //login if credentials already set
    [[BFUserManager sharedManager] authenticateIfAvailable:^(BFUser *user) {
        self.isAuthenticated = true;
        [self loadFeed];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        //keep going
    }];
    
    
    [self.userName becomeFirstResponder];
    self.password.delegate = self;
    self.userName.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startLogin {
    dispatch_main(^{
        [UIView animateWithDuration:0.5f animations:^{
            self.userName.alpha = 0;
            self.password.alpha = 0;
            self.loginButton.alpha = 0;
        }];
        [SVProgressHUD showWithStatus:@"Logging In"];
    });
}
- (void) startDownload {
    dispatch_main(^{
        [SVProgressHUD showWithStatus:@"Loading Feed"];
    });
}
- (void) endHUD {
    dispatch_main(^{
        [SVProgressHUD dismiss];
        [UIView animateWithDuration:1.0 animations:^{
            self.userName.alpha = 1;
            self.password.alpha = 1;
            self.loginButton.alpha = 1;
        }];
    });
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
        [CRToastManager showNotificationWithOptions:@{
                          kCRToastTextKey : @"Error logging in",
                          kCRToastBackgroundColorKey : [UIColor redColor],
                    }
        completionBlock:nil];
        
    }];
}


- (void) loadFeed {
    //this will happen after logged in
    [UAPush shared].alias = BFUserManager.username;
    [[UAPush shared] setTags:@[@"BFUsers"]];
    [[UAPush shared] setPushEnabled:YES];
    
    [[BFFeedManager sharedManager] getFeed:^(NSArray * feed) {
        self.feed = feed;
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
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
        
        [vc loadFeed:self.feed];
    }
}


-(BOOL)shouldAutorotate {
    return false;
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

