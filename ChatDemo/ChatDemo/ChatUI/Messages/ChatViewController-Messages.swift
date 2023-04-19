//
//  ChatViewController-Messages.swift
//  ChatDemo
//

import UIKit

// MARK: - MESSAGES

extension ChatViewController {
    func setupMessages() {
        SWAMessagingManager.shared.messagingMessagesDelegate = self
        
        messagesTableView.register(UINib(nibName: "ChatLeftGrayBubbleCell", bundle: nil), forCellReuseIdentifier: "ChatLeftGrayBubbleCell")
        messagesTableView.register(UINib(nibName: "ChatLeftRequestBubbleCell", bundle: nil), forCellReuseIdentifier: "ChatLeftRequestBubbleCell")
        messagesTableView.register(UINib(nibName: "ChatRightBlueBubbleCell", bundle: nil), forCellReuseIdentifier: "ChatRightBlueBubbleCell")
        messagesTableView.register(UINib(nibName: "ChatRightRequestBubbleCell", bundle: nil), forCellReuseIdentifier: "ChatRightRequestBubbleCell")

    }
}

// MARK: - Messaging Messages Delegate

extension ChatViewController: SWAMessagingMessagesDelegate {
    
    func reloadCurrentChatMessages(_ channel: SWAMessagingChannel) {
        if channel == currentChatRoom {
            messagesTableView.reloadData()
        }
    }
    
    func messageAdded(channel: SWAMessagingChannel, message: SWAMessagingMessage, isLatestMessage: Bool) {
        print("Message Added Delegate Callback :: \(channel.channelId) :: \(message.messageId) :: isLatestMessage \(isLatestMessage)")
        if isLatestMessage {
            currentChatRoom = channel
            reloadCurrentChatMessages(channel)
        }
    }
    
    func messageModified(channel: SWAMessagingChannel, message: SWAMessagingMessage) {
        print("Message Modified Delegate Callback :: \(channel.channelId) :: \(message.messageId)")
        reloadCurrentChatMessages(channel)
    }
    
    func messageRemoved(channel: SWAMessagingChannel, message: SWAMessagingMessage) {
        print("Message Deleted Delegate Callback :: \(channel.channelId) :: \(message.messageId)")
        reloadCurrentChatMessages(channel)
    }
}

// MARK: - Table View Delegate

extension ChatViewController: UITableViewDelegate {
}

// MARK: - Table View Datasource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageData = messages[indexPath.row]
        messageData.markAsReadByMe()
        
        if messageData.sender.displayName == ChatManager.shared.username {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRightBlueBubbleCell", for: indexPath as IndexPath) as? ChatBubbleCell else {
                return UITableViewCell()
            }
            
            cell.messageData = messageData
            return cell
                
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatLeftGrayBubbleCell", for: indexPath as IndexPath) as? ChatBubbleCell else {
                return UITableViewCell()
            }
            
            cell.messageData = messageData
            return cell
                
        }
    }
    
    
}
