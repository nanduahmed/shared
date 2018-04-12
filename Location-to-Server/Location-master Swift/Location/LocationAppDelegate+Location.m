
//
//  LocationAppDelegate+Location.m
//  Location
//
//  Created by Nandu Ahmed on 12/22/16.
//  Copyright © 2016 Location. All rights reserved.
//

#import "LocationAppDelegate+Location.h"

@implementation LocationAppDelegate (Location)


- (void)publishLocation {
    NSString *targetChannel = @"location_channel";
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh-mm-ss"];
    NSString *resultString = [dateFormatter stringFromDate: date];
    
    NSDictionary *data = @{@"message":@"location message",
                           @"username":@"iPad",
                           @"Time":resultString};
    [self.client publish: data
               toChannel: targetChannel withCompletion:^(PNPublishStatus *publishStatus) {
                   
                   // Check whether request successfully completed or not.
                   if (!publishStatus.isError) {
                       
                       // Message successfully published to specified channel.
                   }
                   else {
                       
                       /**
                        Handle message publish error. Check 'category' property to find out
                        possible reason because of which request did fail.
                        Review 'errorData' property (which has PNErrorData data type) of status
                        object to get additional information about issue.
                        
                        Request can be resent using: [publishStatus retry];
                        */
                   }
               }];
}

// Handle new message from one of channels on which client has been subscribed.
- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
    // Handle new message stored in message.data.message
    if (![message.data.channel isEqualToString:message.data.subscription]) {
        
        // Message has been received on channel group stored in message.data.subscription.
    }
    else {
        
        // Message has been received on channel stored in message.data.channel.
    }
    
    NSLog(@"Received message: %@ on channel %@ at %@", message.data.message,
          message.data.channel, message.data.timetoken);
}


// New presence event handling.
- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
    if (![event.data.channel isEqualToString:event.data.subscription]) {
        
        // Presence event has been received on channel group stored in event.data.subscription.
    }
    else {
        
        // Presence event has been received on channel stored in event.data.channel.
    }
    
    if (![event.data.presenceEvent isEqualToString:@"state-change"]) {
        
        NSLog(@"%@ \"%@'ed\"\nat: %@ on %@ (Occupancy: %@)", event.data.presence.uuid,
              event.data.presenceEvent, event.data.presence.timetoken, event.data.channel,
              event.data.presence.occupancy);
    }
    else {
        
        NSLog(@"%@ changed state at: %@ on %@ to: %@", event.data.presence.uuid,
              event.data.presence.timetoken, event.data.channel, event.data.presence.state);
    }
}

// Handle subscription status change.
- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    if (status.operation == PNSubscribeOperation) {
        
        // Check whether received information about successful subscription or restore.
        if (status.category == PNConnectedCategory || status.category == PNReconnectedCategory) {
            
            // Status object for those categories can be casted to `PNSubscribeStatus` for use below.
            PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
            if (subscribeStatus.category == PNConnectedCategory) {
                
                // This is expected for a subscribe, this means there is no error or issue whatsoever.
                
                // Select last object from list of channels and send message to it.
                NSString *targetChannel = [client channels].lastObject;
                [self.client publish: @"Hello from the PubNub Objective-C SDK"
                           toChannel: targetChannel withCompletion:^(PNPublishStatus *publishStatus) {
                               
                               // Check whether request successfully completed or not.
                               if (!publishStatus.isError) {
                                   
                                   // Message successfully published to specified channel.
                               }
                               else {
                                   
                                   /**
                                    Handle message publish error. Check 'category' property to find out
                                    possible reason because of which request did fail.
                                    Review 'errorData' property (which has PNErrorData data type) of status
                                    object to get additional information about issue.
                                    
                                    Request can be resent using: [publishStatus retry];
                                    */
                               }
                           }];
            }
            else {
                
                /**
                 This usually occurs if subscribe temporarily fails but reconnects. This means there was
                 an error but there is no longer any issue.
                 */
            }
        }
        else if (status.category == PNUnexpectedDisconnectCategory) {
            
            /**
             This is usually an issue with the internet connection, this is an error, handle
             appropriately retry will be called automatically.
             */
        }
        // Looks like some kind of issues happened while client tried to subscribe or disconnected from
        // network.
        else {
            
            PNErrorStatus *errorStatus = (PNErrorStatus *)status;
            if (errorStatus.category == PNAccessDeniedCategory) {
                
                /**
                 This means that PAM does allow this client to subscribe to this channel and channel group
                 configuration. This is another explicit error.
                 */
            }
            else {
                
                /**
                 More errors can be directly specified by creating explicit cases for other error categories
                 of `PNStatusCategory` such as: `PNDecryptionErrorCategory`,
                 `PNMalformedFilterExpressionCategory`, `PNMalformedResponseCategory`, `PNTimeoutCategory`
                 or `PNNetworkIssuesCategory`
                 */
            }
        }
    }
}

@end
