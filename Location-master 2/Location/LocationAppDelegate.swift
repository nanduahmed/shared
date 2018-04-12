//  Converted with Swiftify v1.0.6190 - https://objectivec2swift.com/
//
//  LocationAppDelegate.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//
import UIKit
@UIApplicationMain
class LocationAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow!
    var locationTracker: LocationTracker!
    var locationUpdateTimer: Timer!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        var alert: UIAlertView?
        //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
        if UIApplication.shared.backgroundRefreshStatus == .denied {
            alert = UIAlertView(title: "", message: "The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "")
            alert!.show()
        }
        else if UIApplication.shared.backgroundRefreshStatus == .restricted {
            alert = UIAlertView(title: "", message: "The functions of this app are limited because the Background App Refresh is disable.", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "")
            alert!.show()
        }
        else {
            self.locationTracker = LocationTracker()
            self.locationTracker.startLocationTracking()
                //Send the best location to server every 60 seconds
                //You may adjust the time interval depends on the need of your app.
            var time = 60.0
            self.locationUpdateTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(self.updateLocation), userInfo: nil, repeats: true)
        }

        return true
    }

    func updateLocation() {
        print("updateLocation")
        self.locationTracker.updateLocationToServer()
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
//
//  LocationAppDelegate.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//