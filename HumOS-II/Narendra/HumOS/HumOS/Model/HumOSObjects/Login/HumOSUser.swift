//
//  HumOSUser.swift
//  HumOS
//
//  Created by Nandu Ahmed on 8/30/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation
import UIKit


class HumOSUserSession : BasicModel {
    
    static let kAccessToken = "access_token"
    static let kSearchOptions = "search_option"
    static let kSuccessCode = "hum-0001"
    static let kStatusCode = "humos_code"
    
    override init() {
        super.init()
    }
    
    init (data:NSDictionary, response:NSURLResponse) {
        super.init()
        if data["status"] as? String == "success" {
            self.success = true
            self.errorStr = nil
            self.httpResponse = response
            self.isLoginValid = true
            self.createHumOSUser(fromDictionary: data)
        } else {
            self.isLoginValid = false
            if let errorMsgFromServer = data["response"] {
                self.errorStr = errorMsgFromServer as? String
            } else {
                self.errorStr = "Server Error- Received Failure"
            }
        }
    }
    
    convenience init(error:String) {
        self.init()
        self.errorStr = error
        self.isLoginValid = false
    }
    
    var connectedUsersInfo : [ConnectedUsersInfo]!
    var user : User?
    
    func createHumOSUser(fromDictionary dictionary: NSDictionary){
        if let responseData = dictionary["response"] as? NSDictionary {
            connectedUsersInfo = [ConnectedUsersInfo]()
            if let connectedUsersInfoArray = responseData["connected_users_info"] as? [NSDictionary]{
                for dic in connectedUsersInfoArray{
                    let value = ConnectedUsersInfo(fromDictionary: dic)
                    value.userTheamColor = UIColor.randomColor() as String
                    connectedUsersInfo.append(value)
                }
            }
            if let userData = responseData["user"] as? NSDictionary{
                user = User(fromDictionary: userData)
            }
        }
        
    }
}

    class ConnectedUsersInfo{
        
        var connectedProvidersSikkaId : [String]!
        var connectedUsers : [ConnectedUser]!
        var displayName : String!
        var email : String!
        var firstName : String!
        var gender : String!
        var invitedUsers : [AnyObject]!
        var lastName : String!
        var phone : String!
        var profileBlobId : String!
        var type : String!
        var userId : String!
        var userTheamColor : String!
        var fullName : String! {
            get {
                if firstName != nil && lastName != nil {
                    return ((firstName).trim() + " " + (lastName).trim()).trim()
                } else {
                    return firstName ?? lastName ?? ""
                }
            }
        }
        
        /**
         * Instantiate the instance using the passed dictionary values to set the properties values
         */
        convenience init(fromDictionary dictionary: NSDictionary){
            self.init()
            connectedProvidersSikkaId = dictionary["connected_providers_sikka_id"] as? [String]
            connectedUsers = [ConnectedUser]()
            if let connectedUsersArray = dictionary["connected_users"] as? [NSDictionary]{
                for dic in connectedUsersArray{
                    let value = ConnectedUser(fromDictionary: dic)
                    connectedUsers.append(value)
                }
            }
            displayName = dictionary["display_name"] as? String
            email = dictionary["email"] as? String
            firstName = dictionary["first_name"] as? String
            gender = dictionary["gender"] as? String
            invitedUsers = dictionary["invited_users"] as? [AnyObject]
            lastName = dictionary["last_name"] as? String
            phone = dictionary["phone"] as? String
            profileBlobId = dictionary["profileBlobId"] as? String
            type = dictionary["type"] as? String
            userId = dictionary["user_id"] as? String
            
        }
        
    }
    
    
    class User {
        var accessKey : String!
        var accessToken : String?
        var attributes : Attribute!
        var groupIds : [String]!
        var id : String!
        var status : String!
        var userId : String!
        var username : String!
        
        init(fromDictionary dictionary: NSDictionary){
            accessKey = dictionary["access_key"] as? String
            accessToken = dictionary[HumOSUserSession.kAccessToken] as? String
            if let attributesData = dictionary["attributes"] as? NSDictionary{
                attributes = Attribute(fromDictionary: attributesData)
            }
            groupIds = dictionary["group_ids"] as? [String]
            id = dictionary["id"] as? String
            status = dictionary["status"] as? String
            userId = dictionary["user_id"] as? String
            username = dictionary["username"] as? String
        }
    }
    
    
    class Attribute{
        
        var connectedProvidersSikkaId : [String]!
        var connectedUsers : [ConnectedUser]!
        var email : String!
        var firstName : String!
        var languages : [AnyObject]!
        var lastName : String!
        var medicalLicence : String!
        var phone : String!
        var practiceName : String!
        var profileSource : String!
        var sikkaIdNo : String!
        var specialties : [AnyObject]!
        var type : String!
        var fullName : String! {
            get {
                if firstName != nil && lastName != nil {
                    return ((firstName).trim() + " " + (lastName).trim()).trim()
                } else {
                    return firstName ?? lastName ?? ""
                }
            }
        }
        init(fromDictionary dictionary: NSDictionary){
            connectedProvidersSikkaId = dictionary["connected_providers_sikka_id"] as? [String]
            connectedUsers = [ConnectedUser]()
            if let connectedUsersArray = dictionary["connected_users"] as? [NSDictionary]{
                for dic in connectedUsersArray{
                    let value = ConnectedUser(fromDictionary: dic)
                    connectedUsers.append(value)
                }
            }
            email = dictionary["email"] as? String
            firstName = dictionary["first_name"] as? String
            languages = dictionary["languages"] as? [AnyObject]
            lastName = dictionary["last_name"] as? String
            medicalLicence = dictionary["medical_licence"] as? String
            phone = dictionary["phone"] as? String
            practiceName = dictionary["practice_name"] as? String
            profileSource = dictionary["profileSource"] as? String
            sikkaIdNo = dictionary["sikka_id_no"] as? String
            specialties = dictionary["specialties"] as? [AnyObject]
            type = dictionary["type"] as? String
        }
    }
    
    class ConnectedUser{
        
        var userId : String!
        var vaultId : String!
        
        init(fromDictionary dictionary: NSDictionary){
            userId = dictionary["user_id"] as? String
            vaultId = dictionary["vault_id"] as? String
        }
        
}

