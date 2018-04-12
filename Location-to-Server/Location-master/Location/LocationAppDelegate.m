//
//  LocationAppDelegate.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import "LocationAppDelegate.h"
#import "Mixpanel/Mixpanel.h"

@implementation LocationAppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
     UIAlertView * alert;
    
     Mixpanel *mixpanel = [Mixpanel sharedInstanceWithToken:@"b3669aff8abca4cbbfb0e891d840d01c"];
    
    [mixpanel identify:@"nandu-ahmed"];
    
    NSString *pubKey = @"pub-c-7e624616-094f-4169-983a-1d42b97191c1";
    NSString *subsKey = @"sub-c-df45b208-c3fb-11e6-b045-02ee2ddab7fe";
    
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:pubKey subscribeKey:subsKey];
    self.client = [PubNub clientWithConfiguration:configuration];
    [self.client addListener:self];
    
    [self.client subscribeToChannels: @[@"location_channel"] withPresence:YES];

    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    }else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted){
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disable."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else{
        
        self.locationTracker = [[LocationTracker alloc]init];
        [self.locationTracker startLocationTracking];
        
        //Send the best location to server every 60 seconds
        //You may adjust the time interval depends on the need of your app.
        NSTimeInterval time = 60.0;
        self.locationUpdateTimer =
        [NSTimer scheduledTimerWithTimeInterval:time
                                         target:self
                                       selector:@selector(updateLocation)
                                       userInfo:nil
                                        repeats:YES];
    }
    
    return YES;
}

-(void)updateLocation {
    NSLog(@"updateLocation");
    
    [self.locationTracker updateLocationToServer];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
