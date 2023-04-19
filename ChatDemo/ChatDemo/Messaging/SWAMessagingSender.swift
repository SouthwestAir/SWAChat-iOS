//
//  SWAMessagingSender.swift
//  ChatDemo
//

import Foundation

/// An object that groups the metadata of a messages sender.
public struct SWAMessagingSender {
    
    /// MARK: - Properties
    
    /// The unique String identifier for the sender.
    ///
    /// Note: This value must be unique across all senders.
    public let id: String
    
    /// The display name of a sender.
    public let displayName: String
    
    public let displayRole: String?
    
    // MARK: - Intializers
    
    public init(id: String, displayName: String, displayRole: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.displayRole = displayRole
    }
}

// MARK: - Equatable Conformance

extension SWAMessagingSender: Equatable, Comparable {
    
    /// Two senders are considered equal if they have the same id.
    public static func == (left: SWAMessagingSender, right: SWAMessagingSender) -> Bool {
        return left.id == right.id
    }
    
    public static func < (left: SWAMessagingSender, right: SWAMessagingSender) -> Bool {
        return left.id < right.id
    }
}
