//
//  SWAMessagingApp.swift
//  ChatDemo
//

import Foundation
import Firebase

public protocol SWAMessagingChannelsDelegate: AnyObject {
    func channelAdded(channel: SWAMessagingChannel, index: Int)
    func channelModified(channel: SWAMessagingChannel, index: Int)
    func channelRemoved(channel: SWAMessagingChannel, index: Int)
    
    func unreadMessageCountDidChange(channel: SWAMessagingChannel, index: Int, count: Int)
}

extension SWAMessagingChannelsDelegate {
    
    // Make Optional
    // Stub functions so this can be optional in the class designated as delegates
    
    public func channelAdded(channel: SWAMessagingChannel, index: Int) {}
    public func channelModified(channel: SWAMessagingChannel, index: Int) {}
    public func channelRemoved(channel: SWAMessagingChannel, index: Int) {}
    public func unreadMessageCountDidChange(channel: SWAMessagingChannel, index: Int, count: Int) {}
}


public class SWAMessagingApp: NSObject {
    
    private var _cachedChannels: [String: SWAMessagingChannel] = [:]
    
    public var conversationChannels: [SWAMessagingChannel] {
        get {
            _cachedChannels.values.sorted()
        }
    }
    
    public var appId: String
    public var name: String
    
    public init(appId: String, name: String) {
        self.appId = appId
        self.name = name
        
//        self.setupChannelListener(withinOpHours: true)
    }
    
    public init?(document: DocumentSnapshot) {
        
        let data = document.data()
        
        guard let name = data?["name"] as? String else {
            return nil
        }
        
        self.appId = document.documentID
        self.name = name
        
//        self.setupChannelListener(withinOpHours: true)
    }
    
    deinit {
        print("Deinit !!!!!!!!!! :: App :: \(self.name)")
        destroy()
    }
    
    private func destroy() {
        self.removeChannelListener()
        self.removeChannelUserParticipantListener()
        clearAllCachedChannel()
    }
    
    func cleanup() {
        destroy()
    }
    
    private var firebaseFirestore: Firestore { return SWAMessagingManager.shared.firebaseManager.firebaseFirestore }
    
    private var channelIdListeners: [String : ListenerRegistration] = [:]
    private var channelListener: ListenerRegistration?
    private var channelUserParticipantListener: ListenerRegistration?
    
    public var channelUserParticipantId: String? {
        didSet {
            
            removeChannelUserParticipantListener()
            
            if let userId = self.channelUserParticipantId {
                setupChannelUserParticipantListener(userId: userId, withinOpHours: true)
            }
        }
    }
    
    private lazy var channelsReference: CollectionReference = {
        return SWAMessagingManager.shared.appDocReference.collection("channels")
    }()
    
    public func loadAllChannels(completion: @escaping ()->()) {
        channelsReference.getDocuments{ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let channel = SWAMessagingChannel(document: document)
                    channel?.parentApp = self
                    
                    self._cachedChannels[document.documentID] = channel
                }
                completion()
            }
        }
    }
    
    public func createChannel(channelId: String, userId: String, userIds: [String]? = nil) {
        self.addChannel(channelId: channelId, name: userId, userIds: userIds, completionHandler: { (channel, error) in
            if let channelId = channel?.channelId {
                self.setupChannelIdListener(forId: channelId)
                self.calculateUnreadMessagesCount()
            }
        })
    }
    
    // MARK: - Gate State Cached Data Getters
    
    public func addCachedChannel(channel: SWAMessagingChannel) {
        _cachedChannels[channel.channelId] = channel
    }
    
    public func removeCachedChannel(channel: SWAMessagingChannel) {
        removeCachedChannel(channelId: channel.channelId)
    }
    
    public func removeCachedChannel(channelId: String) {
        _cachedChannels.removeValue(forKey: channelId)
    }
    
    public func cachedChannel(channelId: String) -> SWAMessagingChannel? {
        guard let cachedChannel = _cachedChannels[channelId] else {
            return nil
        }
        return cachedChannel
    }
    
    public func clearAllCachedChannel() {
        for (key, _) in _cachedChannels { _cachedChannels.removeValue(forKey: key) }
    }
    
    
    
    public func setupChannelIdListener(forId channelId: String, withinOpHours: Bool = true) {
        
        guard channelIdListeners[channelId] == nil else { return } // Make sure there is NOT listener for this channelId
        
        let baseChannelQuery = channelsReference.whereField("channelId", isEqualTo: channelId)
            
        self.channelIdListeners[channelId] = baseChannelQuery.addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self?.handleChannelChange(change)
            }
        }
        
        print ("Setup Channel Listener with Ops Hours :: \(withinOpHours) :: \(self.channelListener.debugDescription)")
        print ("Current Channels Delegate :: \(SWAMessagingManager.shared.debugDescription)")
    }
    
    public func removeChannelIdListener (forId channelId: String) {
        
        guard let channelIdListener = channelIdListeners[channelId] else { return } // Make sure there is a listener for this channelId
        
        channelIdListener.remove()
        self.channelIdListeners.removeValue(forKey: channelId)
        self.removeCachedChannel(channelId: channelId)
        
        print ("Destroyed Channel Listener")
    }
    
    public func removeAllChannelIdListener() {
        for (key, _) in channelIdListeners {
            removeChannelIdListener(forId: key)
        }
    }
    
    public func setupChannelListener(withinOpHours: Bool = true) {
        
        var baseChannelQuery = channelsReference.whereField("hasUsers", isEqualTo: false)
        
        if withinOpHours {
            baseChannelQuery = baseChannelQuery.whereField("created", isDateInToday: Date(), timeZone: "America/Chicago")
        }
            
        self.channelListener = baseChannelQuery.addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self?.handleChannelChange(change)
            }
        }
        
        print ("Setup Channel Listener with Ops Hours :: \(withinOpHours) :: \(self.channelListener.debugDescription)")
        print ("Current Channels Delegate :: \(SWAMessagingManager.shared.debugDescription)")
    }
    
    public func removeChannelListener () {
        
        if self.channelListener == nil { return }
        
        self.channelListener?.remove()
        self.channelListener = nil
        
        print ("Destroyed Channel Listener")
    }
    
    public func setupChannelUserParticipantListener(userId: String, withinOpHours: Bool = true) {
            
        var baseChannelQuery = channelsReference.whereField("userIds", arrayContains: userId)
        
        if withinOpHours {
            baseChannelQuery = baseChannelQuery.whereField("created", isDateInToday: Date(), timeZone: "America/Chicago")
        }
            
        self.channelUserParticipantListener = baseChannelQuery.addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self?.handleChannelChange(change)
            }
        }
        
        print ("Setup Channel User Participant Listener with Ops Hours :: \(withinOpHours) :: \(self.channelUserParticipantListener.debugDescription)")
        print ("Current Channels Delegate :: \(SWAMessagingManager.shared.debugDescription)")
    }
    
    public func removeChannelUserParticipantListener () {
        
        if self.channelUserParticipantListener == nil { return }
        
        self.channelUserParticipantListener?.remove()
        self.channelUserParticipantListener = nil
        
        print ("Destroyed Channel User Participant Listener")
    }
    

    // MARK: - Turn CRUD Management
    
    public func saveChannel(channel: SWAMessagingChannel, completionHandler: ((SWAMessagingChannel?, Error?) -> Swift.Void)?) -> Swift.Void {
        
        // Add Channel so the object that is created by code is the same returned in insert call back.
        addCachedChannel(channel: channel)
        
        // Stack saves into a serial Dispatch Queue to make sure they are saved in the order they are called.
        self.channelsReference.document(channel.channelId).setData(channel.representation) { [weak self] error in
            
            if let e = error {
                print("Error saving messagingApp: \(e.localizedDescription)")
                
                // Since remote insert failed, remove from cache.
                self?.removeCachedChannel(channel: channel)
                completionHandler?(nil, error)
                
            } else {
                completionHandler?(channel, nil)
            }
        }
    }
    
    public func addChannel(channelId: String, name: String, userIds: [String]?, completionHandler: @escaping (SWAMessagingChannel?, Error?) -> Swift.Void) -> Swift.Void {
        
        getChannel(channelId: channelId) { (messagingChannel, error) in
            
            if let channel = messagingChannel {
                completionHandler(channel, nil)
            } else {
                
                let channel = SWAMessagingChannel(channelId: channelId, appId: self.appId, name: name, userIds: userIds)
                channel.parentApp = self
                
                self.saveChannel(channel: channel) { (savedChannel, error) in
                    completionHandler(savedChannel, error)
                }
            }
        }
    }
    
    public func getChannel(channelId: String, completionHandler: @escaping (SWAMessagingChannel?, Error?) -> Swift.Void) -> Swift.Void {
        
        if let cachedChannel = cachedChannel(channelId: channelId) {
            cachedChannel.parentApp = self
            completionHandler(cachedChannel, nil);
        } else {
            
            self.channelsReference.document(channelId).getDocument { (document, error) in
                if let document = document, document.exists {
                    let channel = SWAMessagingChannel(document: document)
                    channel?.parentApp = self
                    completionHandler(channel, error);
                } else {
                    completionHandler(nil, error);
                    print("Document does not exist")
                }
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
            
            for channel in self?.conversationChannels ?? [] {
                newCount += channel.unreadMessageCount
            }
            
            if let hSelf = self, newCount != hSelf.unreadMessageCount {
                hSelf.unreadMessageCount = newCount
                
                SWAMessagingManager.shared.unreadMessageCountDidChange(app: hSelf, count: newCount)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: MessagingNotifications.AppUnreadCountUpdate.notification, object: nil)
                }
            }
            
            self?.killCalculateUnreadMessagesTimer()
        })
    }
    
    private func killCalculateUnreadMessagesTimer() {
        calculateUnreadMessagesTimer?.invalidate()
        calculateUnreadMessagesTimer = nil
    }
    
}

extension SWAMessagingApp: DatabaseRepresentation {
    
    public var representation: [String : Any] {
        
        let rep = ["name": name, "appId": appId]
        
        return rep
    }
    
}

extension SWAMessagingApp: Comparable {
    
    public static func == (lhs: SWAMessagingApp, rhs: SWAMessagingApp) -> Bool {
        return lhs.appId == rhs.appId
    }
    
    public static func < (lhs: SWAMessagingApp, rhs: SWAMessagingApp) -> Bool {
        return lhs.name < rhs.name
    }
    
}

extension SWAMessagingApp {
    
    private func handleChannelChange(_ change: DocumentChange) {
        guard let channel = SWAMessagingChannel(document: change.document) else {
            return
        }
        
        channel.parentApp = self
        
        switch change.type {
        case .added:
            insertChannel(channel: channel)
            
        case .modified:
            modifyChannel(channel: channel)
            
        case .removed:
            deleteChannel(channel: channel)
        }
        
        calculateUnreadMessagesCount()
    }
    
    private func insertChannel(channel: SWAMessagingChannel) {
        
        print("About to call Insert Channel Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(channel.debugDescription)")
        
        guard cachedChannel(channelId: channel.channelId) == nil else { /* Handle NOT nil case */ return }
        
        addCachedChannel(channel: channel)
        let channelIndex: Int = conversationChannels.firstIndex(of: channel)! // Force unwrap because I know it's in the dictionary.
        
        print("Calling Insert Channel Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(channel.debugDescription)")
        SWAMessagingManager.shared.channelAdded(channel: channel, index: channelIndex)
    }
    
    private func modifyChannel(channel: SWAMessagingChannel) {
        
        print("About to call Modify Channel Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(channel.debugDescription)")
        
        guard let cachedChannel = cachedChannel(channelId: channel.channelId) else { /* Handle nil case */ return }
        let channelIndex: Int = conversationChannels.firstIndex(of: cachedChannel)! // Force unwrap because I know it's in the dictionary.
        
        if (cachedChannel.parentApp != channel.parentApp) {
            cachedChannel.parentApp = channel.parentApp
        }
        if (cachedChannel.channelId != channel.channelId) {
            cachedChannel.channelId = channel.channelId
        }
        if (cachedChannel.name != channel.name) {
            cachedChannel.name = channel.name
        }
        if (cachedChannel.appId != channel.appId) {
            cachedChannel.appId = channel.appId
        }
        
        print("Calling Modify Channel Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(channel.debugDescription)")
        SWAMessagingManager.shared.channelModified(channel: cachedChannel, index: channelIndex)
    }
    
    private func deleteChannel(channel: SWAMessagingChannel) {
        
        print("About to call Remove Channel Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(channel.debugDescription)")
        
        guard let cachedChannel = cachedChannel(channelId: channel.channelId) else { /* Handle nil case */ return }
        let channelIndex: Int = conversationChannels.firstIndex(of: cachedChannel)! // Force unwrap because I know it's in the dictionary.
        
        removeCachedChannel(channelId: cachedChannel.channelId)
        
        print("Calling Remove Channel Callback on :: \(SWAMessagingManager.shared.debugDescription) :: \(channel.debugDescription)")
        SWAMessagingManager.shared.channelRemoved(channel: cachedChannel, index: channelIndex)
    }
}
