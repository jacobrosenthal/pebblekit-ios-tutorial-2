//
//  AppDelegate.h
//  PebbleKit-iOS-Tutorial-2
//
//  Created by Chris Lewis on 1/13/15.
//  Copyright (c) 2015 Pebble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PebbleKit/PebbleKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (weak, nonatomic) PBPebbleCentral *central;
@property (weak, nonatomic) PBWatch *watch;

@property (strong, nonatomic) UIWindow *window;

- (void) connectPebble;

@end

