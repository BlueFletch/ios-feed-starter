//
//  BFAppDelegate.h
//  feed
//
//  Created by Blake Byrnes on 5/19/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAPush.h"

@interface BFAppDelegate : UIResponder <UIApplicationDelegate,UAPushNotificationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
