//
//  ViewController.swift
//  BGTask
//
//  Created by Nandu Ahmed on 10/25/16.
//  Copyright © 2016 Nizaam. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController , CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager?
    var locationTracker:LocationTracker?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        locationManager = CLLocationManager()
////        locationManager?.delegate = self as! CLLocationManagerDelegate
//        locationManager?.requestWhenInUseAuthorization()
//        
//        locationManager?.delegate = self
//        locationManager?.distanceFilter = kCLLocationAccuracyBestForNavigation;
//        locationManager?.desiredAccuracy = kCLLocationAccuracyBest;
        
        
//        let n = NetworkHandler()
//        n.getCallToServer(params: ["":""]) { (data) -> (Void) in
//            print(data)
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var onHit: UIButton!

    @IBAction func onHitPress(_ sender: Any) {
        let n = NetworkHandler()
        n.getCallToServer(params: ["":""]) { (data) -> (Void) in
            print(data)
        }
    }
    
    @IBAction func startLocation(_ sender: Any) {
//        self.locationTracker = LocationTracker()
//        self.locationTracker?.startLocationTracking()
        let appdel = UIApplication.shared.delegate as! AppDelegate
        self.locationManager = appdel.locationManager
        self.locationManager?.startUpdatingLocation()
        self.locationManager?.allowsBackgroundLocationUpdates = true
        let lat = 37.7
        let lon = -122.4
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?center=40.765819,-73.975866&zoom=14&views=traffic")! as URL)
        } else {
            NSLog("Can't use Google Maps");
        }
    }
    
    @IBAction func stopLocation(_ sender: Any) {
//        self.locationTracker?.stopLocationTracking()
        self.locationManager?.stopUpdatingLocation()
    }
    
    @IBAction func restartLocation(_ sender: Any) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("lat \(String(describing: locations.last?.coordinate.latitude)) , long \(String(describing: locations.last?.coordinate.latitude))" )
        let n = NetworkHandler()
        n.getCallToServer(params: ["":""]) { (data) -> (Void) in
            print(data)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

