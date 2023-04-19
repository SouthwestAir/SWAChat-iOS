//
//  SWAMessagingFirebaseManager.swift
//  ChatDemo
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// MARK: Firebase Service Delegate Protocol
public protocol SWAMessagingFirebaseManagerDelegate: AnyObject {
    func authStateDidChange(auth: Auth, user: User?) -> Void // Optional
    func authStateDidSignUp(authResult: AuthDataResult?, user: User?, error: Error?) -> Void // Optional
    func authStateDidSignIn(authResult: AuthDataResult?, user: User?, error: Error?) -> Void // Optional
    func authStateDidSignInAnonymously(authResult: AuthDataResult?, user: User?, error: Error?) -> Void // Optional
    func authStateDidSignOut(error: Error?) -> Void // Optional
}

// Make Optional
// Stub functions so this can be optional in the class designated as delegates
public extension SWAMessagingFirebaseManagerDelegate {
    func authStateDidChange(auth: Auth, user: User?) -> Void {}
    func authStateDidSignUp(authResult: AuthDataResult?, user: User?, error: Error?) -> Void {}
    func authStateDidSignIn(authResult: AuthDataResult?, user: User?, error: Error?) -> Void {}
    func authStateDidSignInAnonymously(authResult: AuthDataResult?, user: User?, error: Error?) -> Void {}
    func authStateDidSignOut(error: Error?) -> Void {}
}


// MARK: Callback Type Aliases
public typealias AuthResultCallback = (_ authResult: AuthDataResult?,_ user: User?, _ error: Error?) -> Void
public typealias SignOutCallback = (_ error: Error?) -> Void

open class SWAMessagingFirebaseManager {
    
    // MARK: Firebase Service Properties
    
    weak var delegate: SWAMessagingFirebaseManagerDelegate?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?

    public private(set) var firebaseUser: User?
    public private(set) var firebaseAuth: Auth = Firebase.Auth.auth()
    public private(set) var firebaseFirestore: Firestore = Firestore.firestore()
    
    public let dataSyncSaveSerialQueue = DispatchQueue(label: "com.swa.innovationlabs.SWAMessagingFirebaseManager.queue.saveQueue")
    
    // MARK: Firestore Helpers
    
    public func clearFirestorePersistence(completion: ((Error?)-> Void)? = nil) {
        self.firebaseFirestore.clearPersistence { (error) in
            completion?(error)
        }
    }
    
    // MARK: Firebase Auth Helpers
    
    public func startAuthStateListener(didChangeHandler: ((Auth, User?) -> Void)? = nil) {
        
        stopAuthStateListener()
        
        // monitor authentication changes using firebase
        authStateListener = firebaseAuth.addStateDidChangeListener { [weak self] (auth, user) in
            
            if let user = user {
                debugPrint("SWAMessagingFirebaseManager :: startAuthStateListener :: Received a user, let's see if it is still valid")
                
                self?.firebaseUser = user
                
                self?.delegate?.authStateDidChange(auth: auth, user: user)
                didChangeHandler?(auth, user)
                
            } else {
                debugPrint("SWAMessagingFirebaseManager :: startAuthStateListener :: User received is nil")
                self?.firebaseUser = nil
                
                self?.delegate?.authStateDidChange(auth: auth, user: nil)
                didChangeHandler?(auth, nil)
            }
        }
    }
    
    public func stopAuthStateListener() {
        if let authStateListener = self.authStateListener {
            firebaseAuth.removeStateDidChangeListener(authStateListener)
            self.authStateListener = nil
        }
    }
    
    public func signUp(email: String, password: String, completion: AuthResultCallback? = nil) {
        firebaseAuth.createUser(withEmail: email, password: password) { (authResult, error) in
            
            var err: Error? = nil
            
            if let error = error  {
                err = error
                debugPrint("ERROR: SWAMessagingFirebaseManager :: Email and Password Sign In :: \(error.localizedDescription)")
            } else {
                
                if let user = authResult?.user  {
                    debugPrint("User is anonymous :: \(user.isAnonymous ? "TRUE" : "FALSE") :: \(user.uid)")
                } else {
                    err = NSError(domain: "com.swa.innovationlabs.firebase.authResult.no.user", code: 500, userInfo: nil)
                    debugPrint("ERROR: SWAMessagingFirebaseManager :: Email and Password Sign In :: No User")
                }
            }

            self.firebaseUser = authResult?.user
            
            self.delegate?.authStateDidSignUp(authResult: authResult, user: authResult?.user, error: err)
            completion?(authResult, authResult?.user, error)
        }
    }
    
    public func signIn(email: String, password: String, completion: AuthResultCallback? = nil) {
        firebaseAuth.signIn(withEmail: email, password: password) { (authResult, error) in
            
            var err: Error? = nil
            
            if let error = error  {
                err = error
                debugPrint("ERROR: SWAMessagingFirebaseManager :: Email and Password Sign In :: \(error.localizedDescription)")
            } else {
                
                if let user = authResult?.user  {
                    debugPrint("User is anonymous :: \(user.isAnonymous ? "TRUE" : "FALSE") :: \(user.uid)")
                } else {
                    err = NSError(domain: "com.swa.innovationlabs.firebase.authResult.no.user", code: 500, userInfo: nil)
                    debugPrint("ERROR: SWAMessagingFirebaseManager :: Email and Password Sign In :: No User")
                }
            }

            self.firebaseUser = authResult?.user
            
            self.delegate?.authStateDidSignIn(authResult: authResult, user: authResult?.user, error: err)
            completion?(authResult, authResult?.user, error)
        }
    }
    
    public func signInAnonymously(completion: AuthResultCallback? = nil) {
        
        firebaseAuth.signInAnonymously { (authResult, error) in
            
            var err: Error? = nil
            
            if let error = error  {
                err = error
                debugPrint("ERROR: SWAMessagingFirebaseManager :: Email and Password Sign In :: \(error.localizedDescription)")
            } else {
                
                if let user = authResult?.user  {
                    debugPrint("User is anonymous :: \(user.isAnonymous ? "TRUE" : "FALSE") :: \(user.uid)")
                } else {
                    err = NSError(domain: "com.swa.innovationlabs.firebase.authResult.no.user", code: 500, userInfo: nil)
                    debugPrint("ERROR: SWAMessagingFirebaseManager :: Email and Password Sign In :: No User")
                }
            }

            self.firebaseUser = authResult?.user
            
            self.delegate?.authStateDidSignInAnonymously(authResult: authResult, user: authResult?.user, error: err)
            completion?(authResult, authResult?.user, error)
        }
    }

    @discardableResult
    public func signOut (completion: SignOutCallback? = nil) -> Bool {
        do {
            try firebaseAuth.signOut()
            self.firebaseUser = nil
            
            //self.delegates.invoke { $0.authStateDidSignOut(error: nil) }
            self.delegate?.authStateDidSignOut(error: nil)
            completion?(nil)
            
            return true
            
        } catch let signOutError as NSError {
            
            //self.delegates.invoke { $0.authStateDidSignOut(error: signOutError) }
            self.delegate?.authStateDidSignOut(error: signOutError)
            completion?(signOutError)
            
            return false
        }
    }
}
