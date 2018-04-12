//
//  DetailMessageModel.swift
//  HumOS
//
//  Created by Nandu Ahmed on 9/2/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import UIKit

enum SendFromType {
    case me
    case other
}

enum MessageType: String {
    case text = "text"
    case image = "image"
    case video = "video"
}

class DetailMessageModel: BasicModel {
    
//    var response:[String,AnyObject]
    var messages:[Message] = [Message]()
    
    init(withData:NSDictionary?) {
        super.init()
        if let ecryptedMessages:[NSDictionary] = withData?["response"]?["documents"] as? [NSDictionary]{
            for msg:NSDictionary  in ecryptedMessages  {
                let d:String = (msg["document"] as? String)!
                let enc:String = d.fromBase64()
                print(enc)
                if let json = d.convertEncodedToJSON() as? NSDictionary {
                    let msg:Message = Message.init(data:json)
                    messages.append(msg)
                }
            }
            messages = messages.reverse()
        }
    }
    
    convenience init(error:String) {
        self.init(withData:nil)
        self.errorStr = error
    }
}

struct Message {
    let sendFrom:SendFromType?
    let messageType:MessageType?
    var text:String?
    let timeStamp:Int?
    let sendFromID:String?
    let channel:String?
    let myUserId = HumOSObjectModelFactory.sharedManager.loginObject?.user?.userId
    
    init(data:NSDictionary)  {
        if let fromId = data["fromId"] where fromId as? String != myUserId {
            self.sendFrom = .other
            self.sendFromID = fromId as? String
        } else {
            self.sendFrom = .me
            self.sendFromID = myUserId!
        }
        
        if let type  = data["type"] as? String {
            switch type {
            case "text":
                self.messageType = .text
                break
            case "image":
                self.messageType = .image
                break
            case "video":
                self.messageType = .video
                break
            default:
                self.messageType = .text
            }
        } else {
            self.messageType = .text
        }
        
        if let txt = data["text"] as? String {
            self.text = txt
        } else {
            self.text = ""
        }
        if let ts = data["timestamp"] as? Int {
            self.timeStamp = ts
        } else {
            self.timeStamp = 0
        }
        if let chnl = data["channel"] as? String {
            self.channel = chnl
        } else {
            self.channel = ""
        }
    }
    
    init(msg:String) {
        self.text = msg
        self.sendFrom = .me
        self.messageType = .text
        self.timeStamp = NSDate.currentTimeStamp()
        self.sendFromID = myUserId
        self.channel = ""
    }
    
    func JSON(accessToken: String, sendername: String, toUID: String)-> Dictionary<String, AnyObject>{
        
        var json : [String: AnyObject] = [:]
        json["access_token"] = accessToken
        json["sender_name"] = sendername
        json["type"] = messageType?.rawValue
        json["to_uid"] = toUID
        json["timestamp"] = timeStamp
        
        if let messageType = messageType {
            switch messageType {
            case MessageType.text:
                json["text"] = text
                break
            default:
                break
            }
        }
        return json

    }
    
    func getPubNubMessage()-> Dictionary<String, AnyObject> {
        var message : Dictionary <String, AnyObject> = [:]
        if let messageType = messageType {
            message["type"] = messageType.rawValue
        }
        message["fromId"] = myUserId
        message["channel"] = channel
        message["timestamp"] = timeStamp
        
        return message
    }
    
}
