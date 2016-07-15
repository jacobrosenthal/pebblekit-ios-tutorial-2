//
//  AppDelegate.m
//  PebbleKit-iOS-Tutorial-2
//
//  Created by Chris Lewis on 1/13/15.
//  Copyright (c) 2015 Pebble. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <PBPebbleCentralDelegate>

@end

@implementation AppDelegate

// AppMessage keys
typedef NS_ENUM(NSUInteger, AppMessageKey) {
    KeyButtonUp = 0,
    KeyButtonDown,
    KeyButtonSelect
};


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // First, create an action
    UIMutableUserNotificationAction *acceptAction = [self createAction];

    // Second, create a category and tie those actions to it (only the one action for now)
    UIMutableUserNotificationCategory *inviteCategory = [self createCategory:@[acceptAction]];

    // Third, register those settings with our new notification category
    [self registerSettings:inviteCategory];

    // Set the delegate to receive PebbleKit events
    self.central = [PBPebbleCentral defaultCentral];
    self.central.delegate = self;

    // Register UUID
    self.central.appUUID = [[NSUUID alloc] initWithUUIDString:@"3783cff2-5a14-477d-baee-b77bd423d079"];

    [self connectPebble];
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    UIApplication* app = [UIApplication sharedApplication];

    // Create a new notification.
    UILocalNotification* alarm = [[UILocalNotification alloc] init];
    if (alarm)
    {
        alarm.fireDate = [[NSDate date] dateByAddingTimeInterval:1];
        alarm.timeZone = [NSTimeZone defaultTimeZone];
        alarm.repeatInterval = 0;
        alarm.alertBody =@"Remote app killed, Watch Button will not work. Tap here to re-activate uploads." ;

        [app scheduleLocalNotification:alarm];
    }

}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {

    // Get the notifications types that have been allowed, do whatever with them
    UIUserNotificationType allowedTypes = [notificationSettings types];

    NSLog(@"Registered for notification types: %lu", (unsigned long)allowedTypes);

    // You can get this setting anywhere in your app by using this:
    // UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {

    if ([identifier isEqualToString:@"RECONNECT_IDENTIFIER"]) {
        // handle it
        [self connectPebble];
    }

    // Call this when you're finished
    completionHandler();
}

#pragma PEBBLECENTRAL

- (void)pebbleCentral:(PBPebbleCentral *)central watchDidConnect:(PBWatch *)watch isNew:(BOOL)isNew {

    //kill our watch disconnected or app killed notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    if (self.watch) {
        return;
    }
    self.watch = watch;
    NSLog(@"watchDidConnect");

    // Keep a weak reference to self to prevent it staying around forever
    __weak typeof(self) welf = self;

    // need to send arbitrary data to watch before it can send to us
    NSNumber *arbitraryNumber = [NSNumber numberWithUint8:42];
    NSDictionary *update = @{ @(0):arbitraryNumber };
    [self.watch appMessagesPushUpdate:update onSent:^(PBWatch *watch,
                                                      NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Successfully sent message.");
        } else {
            NSLog(@"Error sending message: %@", error);
        }
    }];

    // Sign up for AppMessage
    [self.watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
        NSLog(@"appMessagesAddReceiveUpdateHandler %@ %@", watch, update);
        __strong typeof(welf) sself = welf;
        if (!sself) {
            // self has been destroyed
            return NO;
        }

        // Process incoming messages
        if (update[@(KeyButtonUp)]) {
            NSLog(@"up");
            [self notify:@"up"];
        }

        if (update[@(KeyButtonDown)]) {
            NSLog(@"down");
            [self notify:@"down"];
        }

        if (update[@(KeyButtonSelect)]) {
            NSLog(@"select");
            [self notify:@"select"];
        }

        // Get the size of the main view and update the current page offset
//        CGSize windowSize = CGSizeMake(sself.view.frame.size.width, sself.view.frame.size.height);
//        [sself.scrollView setContentOffset:CGPointMake(sself.currentPage * windowSize.width, 0) animated:YES];

        return YES;
    }];
}


- (void)pebbleCentral:(PBPebbleCentral *)central watchDidDisconnect:(PBWatch *)watch {
    NSLog(@"watchDidDisconnect");

    // Only remove reference if it was the current active watch
    if (self.watch == watch) {
        self.watch = nil;
//        self.outputLabel.text = @"Watch disconnected";
    }


    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Hey! Remote disconnected";
    notification.category = @"RECONNECT_CATEGORY";

    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma NOTIFICATIONS

- (UIMutableUserNotificationAction *)createAction {
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    acceptAction.identifier = @"RECONNECT_IDENTIFIER";
    acceptAction.title = @"Accept";

    // Given seconds, not minutes, to run in the background
    acceptAction.activationMode = UIUserNotificationActivationModeBackground;

    // If YES the actions is red
    acceptAction.destructive = NO;

    // If YES requires passcode, but does not unlock the device
    acceptAction.authenticationRequired = NO;

    return acceptAction;
}

- (UIMutableUserNotificationCategory *)createCategory:(NSArray *)actions {
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    inviteCategory.identifier = @"RECONNECT_CATEGORY";

    // You can define up to 4 actions in the 'default' context
    // On the lock screen, only the first two will be shown
    // If you want to specify which two actions get used on the lockscreen, use UIUserNotificationActionContextMinimal
    [inviteCategory setActions:actions forContext:UIUserNotificationActionContextDefault];

    // These would get set on the lock screen specifically
    // [inviteCategory setActions:@[declineAction, acceptAction] forContext:UIUserNotificationActionContextMinimal];

    return inviteCategory;
}

- (void)registerSettings:(UIMutableUserNotificationCategory *)category {
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);

    NSSet *categories = [NSSet setWithObjects:category, nil];
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];

    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

#pragma PEBBLE HELPERS

- (void)notify:(NSString *)body{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = body;

    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];

    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)connectPebble{
    if(self.watch.isConnected)
        return;

    // Begin connection
    [self.central run];
}

@end
