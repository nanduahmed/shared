//
//  NewUser.swift
//  HumOS
//
//  Created by Deepesh.Sunku on 8/31/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation


class NewUser : BasicModel {
    
    var documentId: String?
    var vaultId: String?
    var email: String?
    var phone: String?
    var displayName: String?
    var firstName: String?
    var lastName: String?
    var password: String?
    
    init (data:NSDictionary, response:NSURLResponse) {
        super.init()
        self.success = true
        self.errorStr = nil
        self.httpResponse = response
        
        if (data["message"] != nil) {
            self.success = false
            self.errorStr = data["message"] as? String
        } else if let docId = data["document_id"],
           let vId = data["vault_id"] {
            self.documentId = docId as? String
            self.vaultId = vId as? String
        } else if data["Status"] as! String == "EXIST" {
            self.success = false
            self.errorStr = data["message"] as? String
        } else {
            self.success = false
            self.errorStr = "Error creating user. Please trying again."
        }
    }
    
    convenience init(error:String) {
        self.init(error:error)
    }
}