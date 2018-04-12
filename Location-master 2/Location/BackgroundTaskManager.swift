//  Converted with Swiftify v1.0.6190 - https://objectivec2swift.com/
//
//  BackgroundTaskManager.h
//
//  Created by Puru Shukla on 20/02/13.
//  Copyright (c) 2013 Puru Shukla. All rights reserved.
//
import Foundation
import UIKit

class BackgroundTaskManager: NSObject {
//    class func shared() -> Self {
//        var sharedBGTaskManager = BackgroundTaskManager()
////        var onceToken: dispatch_once_t
////        dispatch_once(onceToken, {() -> Void in
////            sharedBGTaskManager = BackgroundTaskManager()
////        })
//        return sharedBGTaskManager as! Self
//    }
    static var shared = BackgroundTaskManager()

    func beginNewBackgroundTask() -> UIBackgroundTaskIdentifier {
        var application = UIApplication.shared
        var bgTaskId = UIBackgroundTaskInvalid
        if application.responds(to: #selector(self.beginBackgroundTaskWithExpirationHandler)) {
            bgTaskId = application.beginBackgroundTask(withExpirationHandler: {() -> Void in
                print("background task \(UInt(bgTaskId)) expired")
                self.bgTaskIdList.remove(at: self.bgTaskIdList.index(of: (bgTaskId))!)
                application.endBackgroundTask(bgTaskId)
                bgTaskId = UIBackgroundTaskInvalid
            })
            if self.masterTaskId == UIBackgroundTaskInvalid {
                self.masterTaskId = bgTaskId
                print("started master task \(UInt(self.masterTaskId))")
            }
            else {
                //add this id to our list
                print("started background task \(UInt(bgTaskId))")
                self.bgTaskIdList.append((bgTaskId))
                self.endBackgroundTasks()
            }
        }
        return bgTaskId
    }

    func endAllBackgroundTasks() {
        self.drainBGTaskList(true)
    }


    override init() {
        super.init()
        
        self.bgTaskIdList = [Any]()
        self.masterTaskId = UIBackgroundTaskInvalid
    
    }

    func endBackgroundTasks() {
        self.drainBGTaskList(false)
    }

    func drainBGTaskList(_ all: Bool) {
            //mark end of each of our background task
        var application = UIApplication.shared
        if application.responds(to: #selector(self.endBackgroundTasks)) {
            var count = self.bgTaskIdList.count
            for i in (all ? 0 : 1)..<count {
                var bgTaskId = CInt(self.bgTaskIdList[0])
                print("ending background task with id -\(UInt(bgTaskId))")
                application.endBackgroundTask(bgTaskId)
                self.bgTaskIdList.remove(at: 0)
            }
            if self.bgTaskIdList.count > 0 {
                print("kept background task id \(self.bgTaskIdList[0])")
            }
            if all {
                print("no more background tasks running")
                application.endBackgroundTask(self.masterTaskId)
                self.masterTaskId = UIBackgroundTaskInvalid
            }
            else {
                print("kept master background task id \(UInt(self.masterTaskId))")
            }
        }
    }

    var bgTaskIdList = [Any]()
    var masterTaskId = UIBackgroundTaskIdentifier()
}
//
//  BackgroundTaskManager.m
//
//  Created by Puru Shukla on 20/02/13.
//  Copyright (c) 2013 Puru Shukla. All rights reserved.
//
