//
//  HumOSObjectModelFactory.swift
//  HumOS
//
//  Created by Nandu Ahmed on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation

enum HumOSObjectType {
    case LoginObj
    case CreatePatientObj
    case DownloadMessageObj
    case ConnectedUsersObj
    case CreateSignVerificationCode
    case ValidateVerificationCode
    case RegisterUser
    case CreateMessage

}

typealias HumOSObjectCompletion = (BasicModel) -> Void

class HumOSObjectModelFactory  {
    
    var objectStore:[String:AnyObject] = [:]
    var loginObject:HumOSUserSession?
    var accessToken:String?
    
    static let sharedManager = HumOSObjectModelFactory()
    
    func getObjectOfType(objType:HumOSObjectType, parameters:[String:AnyObject], completion:HumOSObjectCompletion) -> Void {
        
        switch objType {
        case .LoginObj:
            if (loginObject?.success) != nil {
                completion(loginObject!)
            } else {
                NetworkInterface.fetchJSON(.Login, headers: parameters["headers"] as? NSDictionary, payload: parameters["payload"] as? NSDictionary, requestCompletionHander: { (success, data, response, error) -> (Void) in
                    var humOSUser:HumOSUserSession? = nil
                    
                    if (success == true && data != nil) {
                        humOSUser = HumOSUserSession.init(data: data!, response: response!)
                        print("********   Access Token = \(humOSUser?.user?.accessToken) *******")
                        self.loginObject = humOSUser
                        self.accessToken = humOSUser?.user?.accessToken
                        
                    } else {
                        humOSUser = HumOSUserSession.init(error: "Unable to Login")
                    }
                    completion(humOSUser!)
                })
            }
            break
            
        case .CreatePatientObj:
            NetworkInterface.fetchJSON(.CreatePatient, headers: parameters["urlParams"] as? NSDictionary, requestCompletionHander: { (success, data, response, error) -> (Void) in
                var humOSNewUser:NewUser? = nil
                
                if (success == true && data != nil) {
                    humOSNewUser = NewUser.init(data: data!, response: response!)
                    if let urlParams = parameters["urlParams"],let email = urlParams["email"] as? String, let phone = urlParams["phone"] as? String {
                        humOSNewUser?.email = email
                        humOSNewUser?.phone = phone
                    }
                } else {
                    humOSNewUser = NewUser.init(error: "Unable to create user")
                    
                }
                completion(humOSNewUser!)
            })
            break
            
        case .ConnectedUsersObj:
            if (loginObject?.connectedUsersInfo.count > 0) {
                let connectedUsersObj = ConnectedUsersModel.init(list: loginObject?.connectedUsersInfo)
                completion(connectedUsersObj)
                return
            }
            if (loginObject?.success) != nil {
                if let connectedUsers = loginObject?.user?.attributes.connectedUsers {
                    let srchStr = ConnectedUsersModel.createSearchJSON(connectedUsers)
                    let headers = ["search_option":srchStr.toBase64()]
                    NetworkInterface.fetchJSON(HumOSRequestType.ConnectedUsersDetails, headers: headers, payload: nil, requestCompletionHander: { (success, data, response, error) -> (Void) in
                        self.addConnectedUsersToHumOSObject(data!)
                        let connectedUsersObj = ConnectedUsersModel.init(list: self.loginObject?.connectedUsersInfo)
                        completion(connectedUsersObj)
                    })
                } else {
                    let connectedUsersObj = ConnectedUsersModel.init(error: "No Users")
                    completion(connectedUsersObj)
                }
            } else {
                let connectedUsersObj = ConnectedUsersModel.init(error: "No Login Object")
                completion(connectedUsersObj)
            }
            break
            
        case .DownloadMessageObj:
            let otherUserId = parameters["to_uid"]
            NetworkInterface.fetchJSON(HumOSRequestType.DownloadMessage, headers: ["access_token":self.accessToken!,"to_uid":otherUserId!]) { (success, data, response, error) -> (Void) in
                print(data)
                if (success == true && data != nil) {
                    let detailMsg = DetailMessageModel.init(withData: data!)
                    completion(detailMsg)
                } else {
                    let detailMsg = DetailMessageModel.init(error:"Cannot Get Message List")
                    completion(detailMsg)
                }
            }
            break
            
        case .CreateSignVerificationCode:
            NetworkInterface.fetchJSON(.CreateSignUpVerificationCode, headers: nil, payload:parameters["payload"] as? NSDictionary, requestCompletionHander: { (success, data, response, error) -> (Void) in
                var humOSNewUser:NewUserVerification? = nil
                
                if (success == true && data != nil) {
                    humOSNewUser = NewUserVerification.init(data: data!, response: response!)
                    
                } else {
                    humOSNewUser = NewUserVerification.init(error: "Unable to create verification code")
                    
                }
                completion(humOSNewUser!)
            })
            break
        
        case .ValidateVerificationCode:
            NetworkInterface.fetchJSON(.ValidateVerificationCode, headers: nil, payload:parameters["payload"] as? NSDictionary, requestCompletionHander: { (success, data, response, error) -> (Void) in
                var humOSNewUser:NewUserVerification? = nil
                
                if (success == true && data != nil) {
                    humOSNewUser = NewUserVerification.init(data: data!, response: response!)
                    
                } else {
                    humOSNewUser = NewUserVerification.init(error: "Unable to validate verification code. Please try again.")
                    
                }
                completion(humOSNewUser!)
            })
            break
            
        case .RegisterUser:
            NetworkInterface.fetchJSON(.RegisterUser, headers: nil, payload:parameters["payload"] as? NSDictionary, requestCompletionHander: { (success, data, response, error) -> (Void) in
                var humOSNewUser:NewUserVerification? = nil
                
                if (success == true && data != nil) {
                    humOSNewUser = NewUserVerification.init(data: data!, response: response!)
                    
                } else {
                    humOSNewUser = NewUserVerification.init(error: "Unable to register. Please try again later.")
                    
                }
                completion(humOSNewUser!)
            })
            break
        case .CreateMessage:
            NetworkInterface.fetchJSON(.NewMessage, headers: nil, payload:parameters, requestCompletionHander: { (success, data, response, error) -> (Void) in
                var humOSNewUser:NewMessage? = nil
                
                if (success == true && data != nil) {
                    humOSNewUser = NewMessage.init(data: data!, response: response!)
                    
                } else {
                    humOSNewUser = NewMessage.init(error: "Unable to send message. Please try again later.")
                    
                }
                completion(humOSNewUser!)
            })
            break

        default:
            break
            
        }
    }
    
    func addConnectedUsersToHumOSObject(data:NSDictionary) -> Bool  {
        if  (data["result"] == nil ) {
            return false
        }
        
        if let attrArray = data["data"]?["documents"] {
            print(attrArray)
            let attArr = attrArray as? [NSDictionary]
            for encodedObj:NSDictionary in attArr!   {
                if let encodedStr:String = encodedObj["attributes"] as? String{
                    let trimmed = encodedStr.trimNewLines()
                    let val = trimmed.convertEncodedToJSON() as? NSDictionary
                    let conn:ConnectedUsersInfo = ConnectedUsersInfo.init(fromDictionary: val!)
                    if let userId = encodedObj["user_id"] {
                        conn.userId = userId as! String
                    }
                    print("CONNECTED USER DETAIL *** \(conn)")
                    loginObject?.connectedUsersInfo.append(conn)
                }
            }
        }
        
        return true
    }
}
