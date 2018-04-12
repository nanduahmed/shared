//
//  NewMessage.swift
//  HumOS
//
//  Created by Narendra Kumar on 9/6/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation


class NewMessage: BasicModel {
    
    var documentId : String?
    var document : Document?
    init (data:NSDictionary?, response:NSURLResponse?) {
        super.init()
        
        if (data != nil && response != nil) {
            self.success = false
            self.errorStr = "Error. Please try again."
            return
        }
        

        self.success = true
        self.errorStr = nil
        self.httpResponse = response
        if let status = data!["humos_code"] as? String where status == "hum-0004", let responseDoc  = data!["response"] as? Dictionary<String,String>, let documentId = responseDoc["document_id"]{
            self.success = true
            self.documentId = documentId
            self.document = Document(document: data!["document"] as? NSDictionary)
        } else {
            self.success = false
            self.errorStr = "Error. Please try again."
        }
    }
    
    convenience init(error:String) {
        self.init(data:nil , response: nil)
        self.errorStr = error
    }
    
    class Document {
        var channel : String?
        var fromId : String?
        var text : String?
        var timestamp : Int?
        var type : String?
        init(document: NSDictionary?){
            channel = document?["channel"] as? String ?? ""
            fromId = document?["fromId"] as? String ?? ""
            text = document?["text"] as? String ?? ""
            timestamp = document?["timestamp"] as? Int ?? 0
            text = document?["type"] as? String
        }
    }
    
    
}