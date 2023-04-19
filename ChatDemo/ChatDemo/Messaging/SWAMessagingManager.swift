//
//  SWAMessagingManager.swift
//  ChatDemo
//

import Foundation
import Firebase

public enum MessagingNotifications: String {
    case AppUnreadCountUpdate       = "MessagingNotifications.AppUnreadCountUpdate"
    case ChannelUnreadCountUpdate   = "MessagingNotifications.ChannelUnreadCountUpdate"
    
    var notification : Notification.Name  {
        return Notification.Name(rawValue: self.rawValue )
    }
}

public protocol SWAMessagingAppsDelegate: AnyObject {
    func appAdded(app: SWAMessagingApp)
    func appModified(app: SWAMessagingApp)
    func unreadMessageCountDidChange(app: SWAMessagingApp, count: Int) -> Void
}

extension SWAMessagingAppsDelegate {
    
    // Make Optional
    // Stub functions so this can be optional in the class designated as delegates
    
    public func appAdded(app: SWAMessagingApp) {}
    public func appModified(app: SWAMessagingApp) {}
    public func unreadMessageCountDidChange(app: SWAMessagingApp, count: Int) {}
}


// MARK: - SWAMessagingManager Stages

// Different stages for SWAMessagingManager
// The SWAMessagingManager.stage var is a string allowing flexability
// of any values, but it's preferred to the rawValue from the
// SwaRemoteAppConfigStages enum.

public enum SWAMessagingManagerStages: String {
    case production         = "PROD"
    case qualityAssurance   = "QA"
    case development        = "DEV"
}

class SWAMessagingManager: NSObject {
    static let shared = SWAMessagingManager()
    
    var firebaseFirestore = Firestore.firestore()
    
    //should be private
    private let stage: SWAMessagingManagerStages = .development
    private let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    private let appId = Bundle.main.bundleIdentifier!
    
    var firebaseManager: SWAMessagingFirebaseManager = SWAMessagingFirebaseManager()
    
    // MARK: Messaging Manager
    /// Properties and Functions
        
    // This is the main SWAMessagingApp that keeps track of all user channels and has a connection to the firebase object
    public private(set) var messagingApp: SWAMessagingApp?
    
    weak var messagingAppDelegate: SWAMessagingAppsDelegate?
    weak var messagingChannelsDelegate: SWAMessagingChannelsDelegate?
    weak var messagingMessagesDelegate: SWAMessagingMessagesDelegate?
    
    //Gets the firebase collection for the appName and stage name
    //lazy = doesn't execute until first time referenced
    //benefit of doing = {}() is it shows the stored same value, while without it, it reruns the code block
    //lazy and ={}() are used together it seems
    //meant to allow for easy update/refactor if firebase location changes
    public private(set) lazy var appCollectionReference: CollectionReference = {
        return firebaseFirestore.collection("\(appName)-\(stage)")
    }()
    
    //return the document
    public private(set) lazy var appDocReference: DocumentReference = {
        return appCollectionReference.document(appId)
    }()
    
    private var appListener: ListenerRegistration?
    
    public func anonymousLoginAndLoad(_ completion: ((AuthDataResult?, Error?) -> Void)?) {
        //if device is already a user, use that
        if firebaseManager.firebaseUser != nil {
            completion?(nil,  nil)
        } else {
            //if not, try and sign in with the new device/user
            firebaseManager.signInAnonymously { authResult, user, error in
                guard error == nil else {
                    completion?(authResult, error)
                    return
                }
                
                self.firebaseManager.clearFirestorePersistence() { error in
                    completion?(nil, error)
                }
            }
        }
    }
    
    // this is light compared to other files' "destroy" function
    private func destroy() {
        removeAppListener()
    }
    
    // for garbage collection and memory leaks
    public func cleanup() {
        destroy()
    }
    
    public func setupAppListener(appId: String) {
        
        self.appListener = appDocReference.addSnapshotListener { [weak self] documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            self?.handleAppChange(document)
        }
    }
    
    public func removeAppListener () {
        if self.appListener == nil { return }
        self.appListener?.remove()
        self.appListener = nil
    }
    
    public func appInitializer(completion: @escaping (SWAMessagingApp?, Error?) -> Swift.Void) -> Swift.Void {
        appInitializer(appId: appId, name: appName, completion: completion)
    }
    
    public func appInitializer(appId: String, name: String, completion: @escaping (SWAMessagingApp?, Error?) -> Swift.Void) -> Swift.Void {
        
        if let cachedApp = messagingApp {
            completion(cachedApp, nil);
        } else {
        
            self.addApp(appId: appId, name: name) { (messagingApp, error) in
                self.messagingApp = messagingApp
                self.setupAppListener(appId: appId)
                completion(messagingApp, error)
            }
        }
    }
    
    private func addApp(appId: String, name: String, completionHandler: @escaping (SWAMessagingApp?, Error?) -> Swift.Void) -> Swift.Void {
        
        let messagingApp = SWAMessagingApp(appId: appId, name: name)
        
        self.appCollectionReference.document(appId).setData(messagingApp.representation) { error in
            if let e = error {
                print("Error saving messagingApp: \(e.localizedDescription)")
            } else {
                completionHandler(messagingApp, error)
                SWAMessagingManager.shared.appAdded(app: messagingApp)
            }
        }
    }
    
    private func getApp(appId: String, completionHandler: @escaping (SWAMessagingApp?, Error?) -> Swift.Void) -> Swift.Void {
        
        if let cachedApp = messagingApp {
            completionHandler(cachedApp, nil);
        } else {
            
            self.appCollectionReference.document(appId).getDocument { (document, error) in
                if let document = document, document.exists {
                    let messagingApp = SWAMessagingApp(document: document)
                    completionHandler(messagingApp, error);
                } else {
                    completionHandler(nil, error);
                    print("Document does not exist")
                }
            }
        }
    }
    
    //would fire if changing something in firestore while app is open
    private func handleAppChange(_ document: DocumentSnapshot) {
        
        guard let app = SWAMessagingApp(document: document) else {
            return
        }
        
        guard let cachedApp = messagingApp else { /* Handle nil case */ return }
        
        if (cachedApp.appId != app.appId) {
            cachedApp.appId = app.appId
        }
        if (cachedApp.name != app.name) {
            cachedApp.name = app.name
        }
        
        SWAMessagingManager.shared.appModified(app: cachedApp)
    }
    
    
}


extension SWAMessagingManager: SWAMessagingAppsDelegate {
    
    public func appAdded(app: SWAMessagingApp) {
        messagingAppDelegate?.appAdded(app: app)
    }
    
    public func appModified(app: SWAMessagingApp) {
        messagingAppDelegate?.appModified(app: app)
    }
    
    public func unreadMessageCountDidChange(app: SWAMessagingApp, count: Int) {
        messagingAppDelegate?.unreadMessageCountDidChange(app: app, count: count)
    }
}

extension SWAMessagingManager: SWAMessagingChannelsDelegate {
    
    public func channelAdded(channel: SWAMessagingChannel, index: Int) {
        messagingChannelsDelegate?.channelAdded(channel: channel, index: index)
    }
    
    public func channelModified(channel: SWAMessagingChannel, index: Int) {
        messagingChannelsDelegate?.channelModified(channel: channel, index: index)
    }
    
    public func channelRemoved(channel: SWAMessagingChannel, index: Int) {
        messagingChannelsDelegate?.channelRemoved(channel: channel, index: index)
    }
    
    public func unreadMessageCountDidChange(channel: SWAMessagingChannel, index: Int, count: Int) {
        messagingChannelsDelegate?.unreadMessageCountDidChange(channel: channel, index: index, count: count)
    }
}

extension SWAMessagingManager: SWAMessagingMessagesDelegate {
    
    public func messageAdded(channel: SWAMessagingChannel, message: SWAMessagingMessage, isLatestMessage: Bool) {
        messagingMessagesDelegate?.messageAdded(channel: channel, message: message, isLatestMessage: isLatestMessage)
    }
    
    public func messageModified(channel: SWAMessagingChannel, message: SWAMessagingMessage) {
        messagingMessagesDelegate?.messageModified(channel: channel, message: message)
    }
    
    public func messageRemoved(channel: SWAMessagingChannel, message: SWAMessagingMessage) {
        messagingMessagesDelegate?.messageRemoved(channel: channel, message: message)
    }
}
