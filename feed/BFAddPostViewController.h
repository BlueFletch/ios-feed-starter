//
//  BFAddPostViewController.h
//  feed
//
//  Created by Blake Byrnes on 5/23/14.
//  Copyright (c) 2014 bluefletch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFPost.h"

@interface BFAddPostViewController : UIViewController
@property (weak, atomic) BFPost *savedPost;

@end
