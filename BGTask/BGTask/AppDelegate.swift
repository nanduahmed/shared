//
//  AppDelegate.swift
//  BGTask
//
//  Created by Nandu Ahmed on 10/25/16.
//  Copyright © 2016 Nizaam. All rights reserved.
//

import UIKit
//import Mix
import Mixpanel
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var bgTask:UIBackgroundTaskIdentifier?
    var timer:Timer?
    static var counter = 1
    var date = Date.init()
    
    var locationTracker:LocationTracker?
    var locationManager:CLLocationManager?

    var locationUpdateTimer:Timer?
    var coords = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Mixpanel.initialize(token:"b3669aff8abca4cbbfb0e891d840d01c")
        Mixpanel.mainInstance().track(event: "Launch")
        
//        self.locationTracker = LocationTracker()

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
            application.registerForRemoteNotifications()
        }
        
        application.registerForRemoteNotifications()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        self.configureLocation()


        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Print Device Token "+deviceTokenString)
        let val = "Print Device Token "+deviceTokenString
        Mixpanel.mainInstance().track(event: "DeviceToken", properties: ["token":val])
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("i am not available in simulator \(error)")
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        
        self.getLocationAndSend()
        self.getData()
        self.locationManager?.startUpdatingLocation()
        completionHandler(.newData);

        
    }
    
    func getLocationAndSend()  {
        self.locationUpdateTimer = Timer.scheduledTimer(timeInterval: 10.0,
                                                        target: self,
                                                        selector: #selector(AppDelegate.getData),
                                                        userInfo: nil,
                                                        repeats: true)
        
    }
    
    
    func getData()  {
//        self.locationTracker?.startLocationTracking()
//        self.locationTracker?.updateLocationToServer()
        let n = NetworkHandler()
        n.getCallToServer(params: ["":""]) { (data) -> (Void) in
            print("After Call Lat \(self.coords.latitude) After Call Lon \(self.coords.longitude)" )
        }

       
        
    }
    
    func configureLocation()  {
        locationManager = CLLocationManager()

        locationManager?.delegate = self
        locationManager?.distanceFilter = kCLLocationAccuracyBestForNavigation;
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        let bgTaskIdentifier = "locationToProvider"
//        self.bgTask = application.beginBackgroundTask(withName: bgTaskIdentifier) {
//            
//            application.endBackgroundTask(self.bgTask!)
//            self.bgTask = UIBackgroundTaskInvalid
//        }
//        
//        self.timer = Timer.scheduledTimer(timeInterval: 20,
//                                          target: self,
//                                          selector: #selector (self.doStuffInBG) ,
//                                          userInfo: nil,
//                                          repeats: true)
        
    }
    
    func doStuffInBG()  {
        let d = Date.init()
        let val = d.timeIntervalSince(self.date)
        print("FBG:This is NthTime \(AppDelegate.counter)  Time : \(val)")
        AppDelegate.counter+=1
        
//        Mixpanel.mainInstance().track(event: "BGTask ## ",
//                                      properties: ["Item" : "FBG:This is NthTime \(AppDelegate.counter)  Time : \(val)"])
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Mixpanel.mainInstance().track(event: "BGTask ## Teminate",
                                      properties: ["Item" : "Terminate"])
    }


}

extension AppDelegate : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("::lat \(String(describing: locations.last?.coordinate.latitude)) , ::long \(String(describing: locations.last?.coordinate.latitude))" )
        self.coords = (locations.last?.coordinate)!
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

}

