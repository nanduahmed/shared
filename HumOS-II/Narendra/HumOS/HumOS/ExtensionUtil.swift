//
//  ExtensionUtil.swift
//  HumOS
//
//  Created by Narendra Kumar on 9/6/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation

extension NSDate{
    static func currentTimeStamp()-> Int{
        return Int(NSDate().timeIntervalSince1970*1000)
    }
}