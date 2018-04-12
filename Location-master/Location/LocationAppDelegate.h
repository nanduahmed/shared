//
//  LocationAppDelegate.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTracker.h"
#import <PubNub/PubNub.h>


@interface LocationAppDelegate : UIResponder <UIApplicationDelegate, PNObjectEventListener>

@property (strong, nonatomic) UIWindow *window;
@property LocationTracker * locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;
@property (nonatomic, strong) PubNub *client;


@end
