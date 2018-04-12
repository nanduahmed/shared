//
//  ConnectedUsers.swift
//  HumOS
//
//  Created by Nandu Ahmed on 8/31/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation

class ConnectedUsersModel: BasicModel {
    
    var connectedUsersList:[ConnectedUsersInfo]?
    
    init(list:[ConnectedUsersInfo]?) {
        super.init()
        if (list != nil) {
            self.connectedUsersList = list
        } else {
            self.success = false
            self.connectedUsersList = nil
        }
    }
    
    
    static func createSearchJSON(searchUserIds:[ConnectedUser]) -> String {
        var retString:String?
        var userIdsArr = [String]()
        for userID in searchUserIds {
            userIdsArr.append(userID.userId)
        }
        let intDict = ["$tv.id":["type":"in","value": userIdsArr]]
        let d = ["filter":intDict, "filter_type":"and", "full_document":"true", "page":1, "per_page":500]
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(d, options: NSJSONWritingOptions.PrettyPrinted)
            retString = String(data: jsonData, encoding: NSUTF8StringEncoding)
            print(retString?.trimNewLines().trim())
        } catch let error as NSError {
            print(error.description)
        }
        
        return (retString?.trimNewLines().trim())!
    }
    
    convenience init(error:String) {
        self.init(list:nil)
        self.errorStr = error
    }
}
