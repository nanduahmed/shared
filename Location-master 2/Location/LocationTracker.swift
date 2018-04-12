//  Converted with Swiftify v1.0.6190 - https://objectivec2swift.com/
//
//  LocationTracker.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//
import Foundation
import CoreLocation
import UIKit


class LocationTracker: NSObject, CLLocationManagerDelegate {
    var myLastLocation = CLLocationCoordinate2D()
    var myLastLocationAccuracy = CLLocationAccuracy()
    var shareModel: LocationShareModel!
    var myLocation = CLLocationCoordinate2D()
    var myLocationAccuracy = CLLocationAccuracy()

    class func sharedLocationManager() -> CLLocationManager {
        var locationManager: CLLocationManager?
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.async {
            if locationManager == nil {
                self.locationManager = CLLocationManager()
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                self.locationManager.allowsBackgroundLocationUpdates = true
                self.locationManager.pausesLocationUpdatesAutomatically = false
            }
        }
        return locationManager
    }

    func startLocationTracking() {
        print("startLocationTracking")
        if CLLocationManager.locationServicesEnabled() == false {
            print("locationServicesEnabled false")
            var servicesDisabledAlert = UIAlertView(title: "Location Services Disabled", message: "You currently have all location services for this device disabled", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "")
            servicesDisabledAlert.show()
        }
        else {
            var authorizationStatus = CLLocationManager.authorizationStatus()
            if authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted {
                print("authorizationStatus failed")
            }
            else {
                print("authorizationStatus authorized")
                var locationManager = LocationTracker.sharedLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager.distanceFilter = kCLDistanceFilterNone
                if IS_OS_8_OR_LATER {
                    locationManager.requestAlwaysAuthorization()
                }
                locationManager.startUpdatingLocation()
            }
        }
    }

    func stopLocationTracking() {
        print("stopLocationTracking")
        if self.shareModel.timer {
            self.shareModel.timer.invalidate()
            self.shareModel.timer = nil
        }
        var locationManager = LocationTracker.sharedLocationManager()
        locationManager.stopUpdatingLocation()
    }

    func updateLocationToServer() {
        print("updateLocationToServer")
            // Find the best location from the array based on accuracy
        var myBestLocation = [AnyHashable: Any]()
        for i in 0..<self.shareModel.myLocationArray.count {
            var currentLocation = self.shareModel.myLocationArray[i]
            if i == 0 {
                myBestLocation = currentLocation
            }
            else {
                if (currentLocation[ACCURACY] as! String).floatValue <= (myBestLocation[ACCURACY] as! String).floatValue {
                    myBestLocation = currentLocation
                }
            }
        }
        print("My Best location:\(myBestLocation)")
        //If the array is 0, get the last location
        //Sometimes due to network issue or unknown reason, you could not get the location during that  period, the best you can do is sending the last known location to the server
        if self.shareModel.myLocationArray.count == 0 {
            print("Unable to get location, use the last known location")
            self.myLocation = self.myLastLocation
            self.myLocationAccuracy = self.myLastLocationAccuracy
        }
        else {
            var theBestLocation: CLLocationCoordinate2D
            theBestLocation.latitude = (myBestLocation[LATITUDE] as! String).floatValue
            theBestLocation.longitude = (myBestLocation[LONGITUDE] as! String).floatValue
            self.myLocation = theBestLocation
            self.myLocationAccuracy = (myBestLocation[ACCURACY] as! String).floatValue
        }
        print("Send to Server: Latitude(\(self.myLocation.latitude)) Longitude(\(self.myLocation.longitude)) Accuracy(\(self.myLocationAccuracy))")
        //TODO: Your code to send the self.myLocation and self.myLocationAccuracy to your server
        //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
        self.shareModel.myLocationArray.removeAll()
        self.shareModel.myLocationArray = nil
        self.shareModel.myLocationArray = [Any]()
    }


    override init() {
        if self == super.init() {
            //Get the share model and also initialize myLocationArray
            self.shareModel = LocationShareModel.sharedModel()
            self.shareModel.myLocationArray = [Any]()
            NotificationCenter.default.addObserver(self, selector: #selector(self.applicationEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        }
    }

    func applicationEnterBackground() {
        var locationManager = LocationTracker.sharedLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        if IS_OS_8_OR_LATER {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
        //Use the BackgroundTaskManager to manage all the background Task
        self.shareModel.bgTask = BackgroundTaskManager.shared()
        self.shareModel.bgTask.beginNewBackgroundTask()
    }

    func restartLocationUpdates() {
        print("restartLocationUpdates")
        if self.shareModel.timer {
            self.shareModel.timer.invalidate()
            self.shareModel.timer = nil
        }
        var locationManager = LocationTracker.sharedLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        if IS_OS_8_OR_LATER {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
// MARK: - CLLocationManagerDelegate Methods

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [Any]) {
        print("locationManager didUpdateLocations")
        for i in 0..<locations.count {
            var newLocation = locations[i]
            var theLocation = newLocation.coordinate
            var theAccuracy = newLocation.horizontalAccuracy
            var locationAge = -newLocation.timestamp.timeIntervalSinceNow
            if locationAge > 30.0 {

            }
            //Select only valid location and also location with good accuracy
            if newLocation != nil && theAccuracy > 0 && theAccuracy < 2000 && (!(theLocation.latitude == 0.0 && theLocation.longitude == 0.0)) {
                self.myLastLocation = theLocation
                self.myLastLocationAccuracy = theAccuracy
                var dict = [AnyHashable: Any]()
                dict["latitude"] = Int(theLocation.latitude)
                dict["longitude"] = Int(theLocation.longitude)
                dict["theAccuracy"] = Int(theAccuracy)
                //Add the vallid location with good accuracy into an array
                //Every 1 minute, I will select the best location based on accuracy and send to server
                self.shareModel.myLocationArray.append(dict)
            }
        }
        //If the timer still valid, return it (Will not run the code below)
        if self.shareModel.timer {
            return
        }
        self.shareModel.bgTask = BackgroundTaskManager.shared()
        self.shareModel.bgTask.beginNewBackgroundTask()
        //Restart the locationMaanger after 1 minute
        self.shareModel.timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.restartLocationUpdates), userInfo: nil, repeats: false)
        //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
        //The location manager will only operate for 10 seconds to save battery
        if self.shareModel.delay10Seconds {
            self.shareModel.delay10Seconds.invalidate()
            self.shareModel.delay10Seconds = nil
        }
        self.shareModel.delay10Seconds = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.stopLocationDelayBy10Seconds), userInfo: nil, repeats: false)
    }
    //Stop the locationManager

    func stopLocationDelayBy10Seconds() {
        var locationManager = LocationTracker.sharedLocationManager()
        locationManager.stopUpdatingLocation()
        print("locationManager stop Updating after 10 seconds")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error?) {
        // NSLog(@"locationManager error:%@",error);
        switch error!.code {
            case kCLErrorNetwork:
            // general, network-related error
                                var alert = UIAlertView(title: "Network Error", message: "Please check your network connection.", delegate: self, cancelButtonTitle: "Ok", otherButtonTitles: "")
                alert.show()

            case kCLErrorDenied:
                                var alert = UIAlertView(title: "Enable Location Service", message: "You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services", delegate: self, cancelButtonTitle: "Ok", otherButtonTitles: "")
                alert.show()

            default:
                break
        }

    }
    //Send the location to Server
}
//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location All rights reserved.
//
let LATITUDE = //  Converted with Swiftify v1.0.6190 - https://objectivec2swift.com/
"latitude"
let LONGITUDE = //  Converted with Swiftify v1.0.6190 - https://objectivec2swift.com/
"longitude"
let ACCURACY = //  Converted with Swiftify v1.0.6190 - https://objectivec2swift.com/
"theAccuracy"
let IS_OS_8_OR_LATER = //  Converted with Swiftify v1.0.6190 - https://objectivec2swift.com/
(CFloat(UIDevice.current.systemVersion) >= 8.0)
