//  Converted with Swiftify v1.0.6190 - https://objectivec2swift.com/
//
//  LocationShareModel.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//
import Foundation
import CoreLocation
class LocationShareModel: NSObject {
    var timer: Timer!
    var delay10Seconds: Timer!
    var bgTask: BackgroundTaskManager!
    var myLocationArray = [Any]()

//    class func sharedModel() -> Any {
//        var sharedMyModel: Any? = nil
//        var onceToken: dispatch_once_t
//        dispatch_once(onceToken, {() -> Void in
//            sharedMyModel = self.init()
//        })
//        return sharedMyModel
//    }
    var sharedModel = LocationShareModel()

    //Class method to make sure the share model is synch across the app

    override init() {
        super.init()


    
    }
}
//
//  LocationShareModel.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//
