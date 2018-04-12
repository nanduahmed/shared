//
//  BackgroundTaskManager.swift
//  LocationSwing
//
//  Created by Mazhar Biliciler on 14/07/14.
//  Copyright (c) 2014 Mazhar Biliciler. All rights reserved.
//

import Foundation
import UIKit


class BackgroundTaskManager : NSObject {
    
    var bgTaskIdList : NSMutableArray?
    var masterTaskId : UIBackgroundTaskIdentifier?
    
    override init() {
        super.init()
        if self != nil {
            self.bgTaskIdList = NSMutableArray()
            self.masterTaskId = UIBackgroundTaskInvalid
        }
    }
    
    static let sharedBackgroundTaskManager = BackgroundTaskManager()
    
//    class func sharedBackgroundTaskManager() -> BackgroundTaskManager? {
//        struct Static {
//            static var sharedBGTaskManager : BackgroundTaskManager?
//            static var onceToken : dispatch_once_t = 0
//        }
//        dispatch_once(&Static.onceToken) {
//            Static.sharedBGTaskManager = BackgroundTaskManager()
//        }
//        return Static.sharedBGTaskManager
//    }
    
    func beginNewBackgroundTask() -> UIBackgroundTaskIdentifier? {
        var application : UIApplication = UIApplication.shared
        
        var bgTaskId : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
        
//        if application.respondsToSelector("beginBackgroundTaskWithExpirationHandler") {
//        if application.responds(to: Selector("beginBackgroundTaskWithExpirationHandler") {
            print("RESPONDS TO SELECTOR")
            bgTaskId = application.beginBackgroundTask(expirationHandler: {
                print("background task \(bgTaskId as Int) expired\n")
            })
//        }
        
        if self.masterTaskId == UIBackgroundTaskInvalid {
            self.masterTaskId = bgTaskId
            print("started master task \(self.masterTaskId)\n")
        } else {
            // add this ID to our list
            print("started background task \(bgTaskId as Int)\n")
            self.bgTaskIdList!.add(bgTaskId)
            //self.endBackgr
        }
        return bgTaskId
    }
    
    func endBackgroundTask(){
        self.drainBGTaskList(all: false)
    }
    
    func endAllBackgroundTasks() {
        self.drainBGTaskList(all: true)
    }
    
    func drainBGTaskList(all:Bool) {
        //mark end of each of our background task
        var application: UIApplication = UIApplication.shared
        
        
        let endBackgroundTask : Selector = "endBackgroundTask"
        
//        if application.respondsToSelector(endBackgroundTask) {
            var count: Int = self.bgTaskIdList!.count
            var j = (all==true ? 0:1)
//            for (var i = j; i<count; i += 1) {
        for i in j..<count {
                var bgTaskId : UIBackgroundTaskIdentifier = self.bgTaskIdList!.object(at: 0) as! Int
                print("ending background task with id \(bgTaskId as Int)\n")
                application.endBackgroundTask(bgTaskId)
                self.bgTaskIdList!.removeObject(at: 0)
            }
            if self.bgTaskIdList!.count > 0 {
                print("kept background task id \(self.bgTaskIdList!.object(at: 0))\n")
            }
            if all == true {
                print("no more background tasks running\n")
                application.endBackgroundTask(self.masterTaskId!)
                self.masterTaskId = UIBackgroundTaskInvalid
            } else {
                print("kept master background task id \(self.masterTaskId)\n")
            }
//        }
    }

}


