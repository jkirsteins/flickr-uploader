//
//  MDAppDelegate.m
//  shopapp
//
//  Created by Jānis Kiršteins on 18.04.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDAppDelegate.h"
#import "NSObject+SBJson.h"
#import "IIViewDeckController.h"
#import "MDViewController.h"

static DDPClient *ddpClient;

@implementation MDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // --- DDP
    ddpClient = [[DDPClient alloc] initWithHostnameAndPortAndUrl:@"10.10.10.42" andPort:3000 andUrl:@"websocket"];
    ddpClient.delegate = (id)self;
    [ddpClient connect];
    
    
    // IIViewDeckController
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    MDViewController *centerController = (MDViewController*)[mainStoryboard instantiateInitialViewController];
    UIViewController *leftViewController = (MDViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"LeftMenuViewController"];
    
    IIViewDeckController* deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController
        leftViewController:leftViewController];
    deckController.rightSize = 100;
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];
    return YES;
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark DDPClientDelegate

- (void)onOpen: (NSDictionary*)message_dictionary
{
    NSLog(@"Opened");
}

- (void)onConnect: (NSDictionary*)message_dictionary
{
    NSLog(@"Connected");
}

- (void)onData: (NSDictionary*)message_dictionary
{
    NSLog(@"Data");
}

static int itemCount = 0;
- (void)onAdded: (NSDictionary*)message_dictionary
{
    itemCount++;
    NSLog(@"Total item count: %d", itemCount);
}

- (void)onResult: (NSDictionary*)message_dictionary
{
    NSLog(@"Result");
}

- (void)onNoSub: (NSDictionary*)message_dictionary
{
    NSLog(@"NoSub");
}

- (void)onError: (NSDictionary*)message_dictionary
{
    NSLog(@"Error");
}

@end
