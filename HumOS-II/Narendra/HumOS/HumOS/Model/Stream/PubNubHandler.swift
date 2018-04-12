//
//  PubNubHandler.swift
//  HumOS
//
//  Created by Narendra Kumar on 9/6/16.
//  Copyright © 2016 Sikka Software. All rights reserved.
//

import Foundation

import PubNub

protocol PubNubDelagate {
    func didReceiveMessage(message: AnyObject)
}

struct PubNubConfig {
    
    static let PUBLISH_KEY = "pub-c-d16cdec2-9bd2-4520-986f-7fa640a87d44"
    static let SUBSCRIBE_KEY = "sub-c-a2e8863c-82ed-11e5-92ab-0619f8945a4f"
    static let CIPHER_KEY = "6239B3672219C40D2EA3463556FECC9594B42110DEF922207522202744D6D519"
    
}

class PubNubHandler: NSObject, PNObjectEventListener {
    static var sharedManager = PubNubHandler()
    var client: PubNub?
    var delegate : PubNubDelagate?
    func setupConfig(authKey : String) {
        let configuration = PNConfiguration(publishKey: PubNubConfig.PUBLISH_KEY, subscribeKey: PubNubConfig.SUBSCRIBE_KEY)
        configuration.authKey=authKey
        configuration.uuid=authKey
        configuration.cipherKey=PubNubConfig.CIPHER_KEY
        configuration.restoreSubscription = true
        client = PubNub.clientWithConfiguration(configuration)
        client?.addListener(self)
        client?.subscribeToChannels([authKey], withPresence: true)
        
    }
    
    func client(client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        
    }
    
    // Handle new message from one of channels on which client has been subscribed.
    func client(client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
        
        if let channelName : String = message.data.message!["channel"] as? String {
            // if isOnChannel(channelName){
            self.delegate?.didReceiveMessage(message.data.message!)
            // }
        }
    }
    
    
    // Warning :: Root view must be Tabbar and ChatView should be in 2nd index of tabbar
    func isOnChannel(channel : String) -> Bool {
//        let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        if let tabbarVC : UITabBarController = appDelegate.window?.rootViewController as? UITabBarController, let navigationController : UINavigationController = tabbarVC.viewControllers![2] as? UINavigationController {
//            if (navigationController.topViewController!.isKindOfClass(ChatDetailViewController)){
//                if let chatDetailVC : ChatDetailViewController = navigationController.topViewController as? ChatDetailViewController,
//                    let activeChannel : String = chatDetailVC.getChannelName() where channel == activeChannel{
//                    return true
//                }
//            }
//
//        }
        return false
    }
    
    func client(client: PubNub, didReceiveStatus status: PNStatus) {
        print(status)
    }
    
    
    func publishMessageOnChannel(message : AnyObject!, channel : String!) {
        client?.publish(message, toChannel: channel, withCompletion: { (status) in
            print(status)
        })
    }
    
}
