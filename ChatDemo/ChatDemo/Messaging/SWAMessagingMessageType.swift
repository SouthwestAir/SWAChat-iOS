//
//  SWAMessagingMesssageType.swift
//  ChatDemo
//

import Foundation

/// A standard protocol representing a message.
public protocol SWAMessagingMessageType {
    
    /// The sender of the message.
    var sender: SWAMessagingSender { get }
    
    /// The unique identifier for the message.
    ///
    /// NOTE: This value must be unique for all messages as it is used to cache layout information.
    var messageId: String { get }
    
    /// The date the message was sent.
    var sentDate: Date { get }
    
    /// The kind of message and its underlying data.
    var data: SWAMessagingMessageData { get }
    
}
