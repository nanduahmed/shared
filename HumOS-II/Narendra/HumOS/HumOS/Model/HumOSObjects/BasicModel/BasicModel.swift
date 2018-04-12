//
//  BasicModel.swift
//  HumOS
//
//  Created by Nandu Ahmed on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation

class BasicModel {
    var success:Bool! = false
    var errorStr:String?
    var createdAt:NSDate = NSDate.init()
    var httpResponse:NSURLResponse?
    var isLoginValid = false
    
    convenience init(error:String) {
        self.init()
        self.errorStr = error
    }
}
