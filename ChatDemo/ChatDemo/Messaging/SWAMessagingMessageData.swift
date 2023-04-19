//
//  SWAMessagingMessageData.swift
//  ChatDemo
//

import UIKit
import Foundation
import class CoreLocation.CLLocation

/// An enum representing the kind of message and its underlying data.
public enum SWAMessagingMessageData {
    
    /// A standard text message.

    case text(String)
    
    /// A message with attributed text.
    case attributedText(NSAttributedString)
    
    /// A photo message.
    case photo(UIImage)
    
    /// A video message.
    case video(file: URL, thumbnail: UIImage)
    
    /// A location message.
    case location(CLLocation)
    
    /// An emoji message.
    case emoji(String)
    
    /// A request message
    case request(SWAMessagingRequest)
    
}

/// Enum for request types
public enum SWAMessagingRequest {
    ///An action request asks the recipient to do something for the sender
    case action(String, String)
    ///A notification is information only for the recipient
    case notification(String, String)
    
    public func name() -> String {
        switch self {
        case .action(let actionStr, let roleStr):
            return actionStr
        case .notification(let notificationStr, let roleStr):
            return notificationStr
        }
    }
    
    public func role() -> String {
        switch self {
        case .action(let actionStr, let roleStr):
            return roleStr
        case .notification(let notificationStr, let roleStr):
            return roleStr
        }
    }
}

extension SWAMessagingRequest: Codable {
    public enum CodingKeys: CodingKey {
        case action
        case notification
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        
        switch key {
        case .action:
            var actionContainer = try container.nestedUnkeyedContainer(forKey: .action)
            let actionStr = try actionContainer.decode(String.self)
            let roleStr = try actionContainer.decode(String.self)
            self = .action(actionStr, roleStr)
        case .notification:
            var notificationContainer = try container.nestedUnkeyedContainer(forKey: .notification)
            let notificationStr = try notificationContainer.decode(String.self)
            let roleStr = try notificationContainer.decode(String.self)
            self = .action(notificationStr, roleStr)
        default:
            throw DecodingError.keyNotFound(CodingKeys.action, DecodingError.Context(codingPath: [CodingKeys.action], debugDescription: "Unable to decode"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .action(let actionStr, let roleStr):
            var actionContainer = container.nestedUnkeyedContainer(forKey: .action)
            try actionContainer.encode(actionStr)
            try actionContainer.encode(roleStr)
        case .notification(let notificationStr, let roleStr):
            var notificationContainer = container.nestedUnkeyedContainer(forKey: .notification)
            try notificationContainer.encode(notificationStr)
            try notificationContainer.encode(roleStr)
        }
    }
}
