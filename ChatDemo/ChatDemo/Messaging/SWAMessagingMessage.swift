//
//  SWAMessagingChannel.swift
//  ChatDemo
//

import FirebaseFirestore
import UIKit


public class SWAMessagingMessage: SWAMessagingMessageType {
    
    public weak var parentChannel: SWAMessagingChannel?
    
    public let id: String?
    
    public let content: String?
    
    public let sentDate: Date
    public let sender: SWAMessagingSender
    
    public var readBy: [String:Date] = [:]
    
    deinit {
        print("Deinit !!!!!!!!!! :: Message :: \(self.content)")
    }
    
    public var isFromMe: Bool {
        get {
            guard let channelUserParticipantId = parentChannel?.parentApp?.channelUserParticipantId else { return false }
            return channelUserParticipantId == sender.id
        }
    }
    
    public var image: UIImage? = nil
    public var downloadURL: URL? = nil
    public var request: SWAMessagingRequest? = nil
    
    public var data: SWAMessagingMessageData {
        if let image = image {
            return .photo(image)
        } else if let request = request {
            return .request(request)
        } else {
            return .text(content ?? "")
        }
    }
    
    public var messageId: String {
        return id ?? UUID().uuidString
    }
    
    public init(userId: String, displayName: String, content: String, roleName: String? = nil) {
        sender = SWAMessagingSender(id: userId, displayName: displayName, displayRole: roleName)
        self.content = content
        sentDate = Date()
        id = nil
    }

    public init(sender: SWAMessagingSender, content: String) {
        self.sender = sender
        self.content = content
        sentDate = Date()
        id = nil
    }
    
    public init(userId: String, displayName: String, image: UIImage) {
        sender = SWAMessagingSender(id: userId, displayName: displayName)
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
    }
    
    public init(sender: SWAMessagingSender, image: UIImage) {
        self.sender = sender
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
    }
    
    public init(userId: String, displayName: String, request: SWAMessagingRequest, roleName: String? = nil) {
        sender = SWAMessagingSender(id: userId, displayName: displayName, displayRole: roleName)
        self.request = request
        content = request.name()
        sentDate = Date()
        id = nil
    }
    
    public init(sender: SWAMessagingSender, request: SWAMessagingRequest) {
        self.sender = sender
        self.request = request
        content = ""
        sentDate = Date()
        id = nil
    }

    
    public init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let sentDate = data["created"] as? Timestamp else {
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }
        
        id = document.documentID
        let displayRole = data["senderRole"] as? String
        
        self.sentDate = sentDate.dateValue()
        sender = SWAMessagingSender(id: senderID, displayName: senderName, displayRole: displayRole)
        
        if let content = data["content"] as? String {
            self.downloadURL = nil
            self.content = content
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            self.downloadURL = url
            self.content = ""
        } else if let requestString = data["request"] as? String {
            let decoder = JSONDecoder()
            if let requestData = requestString.data(using: .utf8) {
                self.request = try? decoder.decode(SWAMessagingRequest.self, from: requestData)
            }
            self.content = ""
        } else {
            return nil
        }
        
        if let readByDict = data["readBy"] as? [String: Timestamp] {
            
            let convertedDict: [String: Date] = readByDict.mapValues({ (timestamp) -> Date in
                return timestamp.dateValue()
            })
            
            readBy = convertedDict
        }
    }
    
    private var messageReference: DocumentReference? {
        get  {
            guard let parentChannel = parentChannel, let id = id else { return nil }
            return parentChannel.messagesReference.document(id)
        }
    }
    
    public func markAsReadByMe() {
        if isReadByMe || isFromMe { return }
        
        guard let channelUserParticipantId = parentChannel?.parentApp?.channelUserParticipantId else { return }
        readBy[channelUserParticipantId] = Date()
        
        if let messageReference = messageReference {
            messageReference.setData(self.representation) { (err) in
                if let err = err {
                    print("Error updating message: \(err)")
                } else {
                    print("Message successfully updated")
                }
            }
        }
    }
    
    public var isReadByMe: Bool {
        get {
            guard let channelUserParticipantId = parentChannel?.parentApp?.channelUserParticipantId else { return false }
            return readBy[channelUserParticipantId] != nil
        }
    }
}

extension SWAMessagingMessage: DatabaseRepresentation {
    
    public var representation: [String : Any] {
        
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.id,
            "senderName": sender.displayName,
            "readBy": readBy
        ]
        
        if let displayRole = sender.displayRole {
          rep["senderRole"] = displayRole
        }
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else if let request = request {
            let encoder = JSONEncoder()
            do {
                rep["request"] = try String(data: encoder.encode(request), encoding: .utf8)
            } catch {
                print (error)
            }
        } else {
            rep["content"] = content
        }
        
        return rep
    }
    
}

extension SWAMessagingMessage: Comparable {
    
    public static func == (lhs: SWAMessagingMessage, rhs: SWAMessagingMessage) -> Bool {
        return lhs.id == rhs.id
    }
    
    public static func < (lhs: SWAMessagingMessage, rhs: SWAMessagingMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}
