//
//  AppDelegate.h
//  TipTacToeObjc
//
//  Created by Jose Aponte on 10/22/16.
//  Copyright © 2016 jappsku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCManager.h"

#define kServiceType @"triqui"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MCManager *mcManager;


@end

