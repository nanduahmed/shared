//
//  NewUserVerification.swift
//  HumOS
//
//  Created by Deepesh.Sunku on 9/1/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation

class NewUserVerification: BasicModel {
    
    init (data:NSDictionary, response:NSURLResponse) {
        super.init()
        self.success = true
        self.errorStr = nil
        self.httpResponse = response
        if let status = data["status"] as? String where status == "SUCCESS"{
            self.success = true
        } else if (data["user"] != nil) {
            self.success = true
        } else {
            self.success = false
            self.errorStr = "Error. Please try again."
        }
    }
    
    convenience init(error:String) {
        self.init(error:error)
    }
    
    
}