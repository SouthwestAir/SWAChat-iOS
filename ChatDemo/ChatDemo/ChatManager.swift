//
//  ChatManager.swift
//  ChatDemo
//

import Foundation

class ChatManager {
    static let shared = ChatManager()
    
    var avatar: String?
    var username: String?
    
    func createUser(avatar: String?, username: String?, completion: @escaping ()->()) {
        self.avatar = avatar ?? MockUsernameGenerator.shared.generateAvatar()
        self.username = username ?? MockUsernameGenerator.shared.generateUsername()
        
        SWAMessagingManager.shared.anonymousLoginAndLoad { (authResult, error) in
            if error != nil {
                fatalError("Firebase error occurred logging in as anon user")
            }
            
            SWAMessagingManager.shared.appInitializer { (messagingApp, error) in
                // Add the logged in user's id. This messaging session belongs to this user.
                if let userId = username {
                    messagingApp?.channelUserParticipantId = userId
                    
                    messagingApp?.createChannel(channelId: avatar ?? userId, userId: userId)
                    messagingApp?.createChannel(channelId: "Main", userId: "Main")
                    
                    messagingApp?.loadAllChannels() {
                        completion()
                    }
                }
                
            }
            
        }
    }
}
