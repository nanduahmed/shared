//
//  String.swift
//  HumOS
//
//  Created by Nandu Ahmed on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation

extension String
{
    func trim() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func trimNewLines() -> String {
        return self.stringByReplacingOccurrencesOfString("\n", withString: "")
    }
    
    func fromBase64() -> String
    {
        if let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0)) {
            return String(data: data, encoding: NSUTF8StringEncoding)!
        } else {
            return ""
        }
    }
    
    func toBase64() -> String
    {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
    
    func convertEncodedToJSON() -> AnyObject {
        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0))
        if (data != nil) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
            } catch let err as NSError {
                print(err)
            }
        }
        let st = ["err":"bad data"]
        return st
    }

}
