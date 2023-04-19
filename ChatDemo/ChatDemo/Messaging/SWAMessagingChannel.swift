//
//  SWAMessagingChannel.swift
//  ChatDemo
//

import Firebase

public protocol SWAMessagingMessagesDelegate: AnyObject {
    func messageAdded(channel: SWAMessagingChannel, message: SWAMessagingMessage, isLatestMessage: Bool)
    func messageModified(channel: SWAMessagingChannel, message: SWAMessagingMessage)
    func messageRemoved(channel: SWAMessagingChannel, message: SWAMessagingMessage)
}

extension SWAMessagingMessagesDelegate {
    
    // Make Optional
    // Stub functions so this can be optional in the class designated as delegates
    
    public func messageAdded(channel: SWAMessagingChannel, message: SWAMessagingMessage, isLatestMessage: Bool) {}
    public func messageModified(channel: SWAMessagingChannel, message: SWAMessagingMessage) {}
    public func messageRemoved(channel: SWAMessagingChannel, message: SWAMessagingMessage) {}
}


public class SWAMessagingChannel: NSObject {
    
    weak var parentApp: SWAMessagingApp?
    
    public var messages: [SWAMessagingMessage] = []
    public var channelParticipants: [String: SWAMessagingSender] = [:]
    
    public var channelId: String
    public var appId: String
    public var name: String
    
    // If this is empty, then the channel is open to everyone.
    public var userIds: [String]?
    
    public var userIdsWithoutParticipant: [String]? {
        guard let userIds = userIds, let participantId = parentApp?.channelUserParticipantId, let meIndex = userIds.firstIndex(of: participantId) else {
            return nil
        }
        
        var trimmedUserIds = userIds
        
        trimmedUserIds.remove(at: meIndex)
        return trimmedUserIds
    }
    
    public var isOpenConversationChannel: Bool {
        get {
            return hasUsers == false
        }
    }
    
    public var hasUsers: Bool {
        get {
            return userIds?.count ?? 0 > 0
        }
    }
    
    public var latestMessage: SWAMessagingMessage? {
        get {
            return messages.sorted().last
        }
    }
    
    public private(set) var createdDate: Date
    
    public init(channelId: String, appId: String, name: String, userIds: [String]?) {
        self.channelId = channelId
        self.appId = appId
        self.name = name
        self.userIds = userIds
        self.createdDate = Date()
        
        super.init()
        self.setupListener()
    }
    
    public init?(document: DocumentSnapshot) {
        
        let data = document.data()
        
        guard let name = data?["name"] as? String,
            let appId = data?["appId"] as? String
            else {
                return nil
        }
        
        guard let created = data?["created"] as? Timestamp else {
            return nil
        }
        
        self.channelId = document.documentID
        self.appId = appId
        self.name = name
        self.userIds = data?["userIds"] as? [String]
        self.createdDate = created.dateValue()
        
        super.init()
        self.setupListener()
    }
    
    deinit {
        print("Deinit !!!!!!!!!! :: Channel :: \(self.name)")
        destroy()
    }
    
    private func destroy() {
        removeListener()
        messages = []
    }
    
    public func cleanup() {
        destroy()
    }
    
    private var firebaseFirestore: Firestore { return SWAMessagingManager.shared.firebaseManager.firebaseFirestore }
    
    private var messageListener: ListenerRegistration?
    
    public lazy var messagesReference: CollectionReference = {
        return SWAMessagingManager.shared.appDocReference.collection(["channels", channelId, "messages"].joined(separator: "/"))
    }()
    
    public func setupListener() {
        
        self.messageListener = messagesReference.addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self?.handleMessageChange(change)
            }
        }
    }
    
    public func removeListener () {
        if self.messageListener == nil { return }
        self.messageListener?.remove()
        self.messageListener = nil
    }
    
    public func addMessage(message: SWAMessagingMessage) {
        
        message.parentChannel = self
        
        self.messagesReference.addDocument(data: message.representation) { error in
            if let e = error {
                print("Error sending message: \(e.localizedDescription)")
                return
            }
        }
    }
    
    
    // MARK: Unread Message Calculation
    
    public private(set) var unreadMessageCount = 0
    
    private var calculateUnreadMessagesTimer: Timer?
    
    public func calculateUnreadMessagesCount() {
        
        // This timer was created to catch any built up pending requests for calculating unread messages and stopping
        // these requests from all happening, but instead only running the update once with the appropiate count.
        // There were issues we saw that these request where piling up and still being run, so the count would be
        // off/delayed, and this caught this issue
        
        killCalculateUnreadMessagesTimer()
        calculateUnreadMessagesTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {[weak self] (timer) in
            
            var newCount: Int = 0
            
            for message in self?.messages ?? [] {
                if message.isFromMe == false && message.isReadByMe == false {
                    newCount += 1
                }
            }
            
            if let hSelf = self, newCount != hSelf.unreadMessageCount, let parentApp = hSelf.parentApp, let channelIndex = parentApp.conversationChannels.firstIndex(of: hSelf) {
                hSelf.unreadMessageCount = newCount
                
                SWAMessagingManager.shared.unreadMessageCountDidChange(channel: hSelf, index: channelIndex, count: newCount)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: MessagingNotifications.ChannelUnreadCountUpdate.notification, object: nil)
                }
                
                parentApp.calculateUnreadMessagesCount()
            }
            
            self?.killCalculateUnreadMessagesTimer()
        })
    }
    
    private func killCalculateUnreadMessagesTimer() {
        calculateUnreadMessagesTimer?.invalidate()
        calculateUnreadMessagesTimer = nil
    }
}

extension SWAMessagingChannel: DatabaseRepresentation {
    
    public var representation: [String : Any] {
        var rep = ["channelId": channelId, "appId": appId, "name": name, "created": createdDate, "userIds": userIds ?? []] as [String : Any]
        rep["hasUsers"] = hasUsers
        return rep
    }
}

extension SWAMessagingChannel: Comparable {
    
    public static func == (lhs: SWAMessagingChannel, rhs: SWAMessagingChannel) -> Bool {
        return lhs.channelId == rhs.channelId
    }
    
    public static func < (lhs: SWAMessagingChannel, rhs: SWAMessagingChannel) -> Bool {
        return lhs.name < rhs.name
    }
    
}

extension SWAMessagingChannel {
    
    private func handleMessageChange(_ change: DocumentChange) {
        guard let message = SWAMessagingMessage(document: change.document) else {
            return
        }
        
        message.parentChannel = self
        
        switch change.type {
        case .added:
            insertMessage(message: message)
            
        case .modified:
            modifyMessage(message: message)
            
        case .removed:
            deleteMessage(message: message)
        }
        
        calculateUnreadMessagesCount()
    }
    
    private func insertMessage(message: SWAMessagingMessage) {
        
        print("About to call Insert Message Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(message)")
        guard !messages.contains(message) else {
            return
        }
        
        messages.append(message)
        messages.sort()
        
        channelParticipants[message.sender.id] = message.sender
        
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        
        print("Calling Insert Message Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(message)")
        SWAMessagingManager.shared.messageAdded(channel: self, message: message, isLatestMessage: isLatestMessage)
    }
    
    private func modifyMessage(message: SWAMessagingMessage) {
        
        print("About to call Modify Message Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(message)")
        guard let messageIndex = messages.firstIndex(of: message) else {
            return
        }
        
        messages[messageIndex] = message
        messages.sort()
        
        channelParticipants[message.sender.id] = message.sender
        
        print("Calling Modify Message Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(message)")
        SWAMessagingManager.shared.messageModified(channel: self, message: message)
    }
    
    private func deleteMessage(message: SWAMessagingMessage) {
        
        print("About to call Remove Message Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(message)")
        guard let messageIndex = messages.firstIndex(of: message) else {
            return
        }
        
        messages.remove(at: messageIndex)
        messages.sort()
        
        channelParticipants.removeValue(forKey: message.sender.id)
        
        print("Calling Remove Message Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(message)")
        SWAMessagingManager.shared.messageRemoved(channel: self, message: message)
    }
}
