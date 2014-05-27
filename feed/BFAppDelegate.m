//
//  BFAppDelegate.m
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import "BFAppDelegate.h"
#import <RestKit/RestKit.h>
#import "BButton.h"
#import "CRToast.h"
#import "UAConfig.h"
#import "UAirship.h"
#import "UAPush.h"

@implementation BFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    //let AFNetworking manage the activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [CRToastManager setDefaultOptions:@{
                                        kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                        kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                        kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeSpring),
                                        kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                        kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                                        }];
    
    UAConfig *config = [UAConfig defaultConfig];
    config.developmentAppSecret = @"_t63_4GmRPmmHQLMg5spsg";
    config.developmentAppKey = @"WiSuM8BWRTCYvV01RYOYUw";
    config.inProduction = false;
    
    [UAirship takeOff:config];
    
    [UAPush setDefaultPushEnabledValue:NO];
    [UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert);

    [UAPush shared].pushNotificationDelegate = self;

    [[BButton appearance]setStyle:BButtonStyleBootstrapV3];
    return YES;
}
- (void) receivedForegroundNotification:(NSDictionary *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newContentAvailable" object:self];
}
- (void) launchedFromNotification:(NSDictionary *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newContentAvailable" object:self];
}
- (void)displayNotificationAlert:(NSString *)alertMessage {
    //don't show
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UAPush shared] resetBadge];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
