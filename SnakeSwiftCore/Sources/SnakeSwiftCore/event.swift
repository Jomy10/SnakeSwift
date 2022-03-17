//
//  event.swift
//
//  GameEvent
//
//  Created by Jonas Everaert on 13/03/2022.
//

import Foundation

public enum GameEvent {
    case MoveUp
    case MoveDown
    case MoveLeft
    case MoveRight
    /// Player gets bigger
    case AddTail
}

extension GameEvent {
    public var isMoveAction: Bool {
        if self == .MoveUp || self == .MoveDown || self == .MoveLeft || self == .MoveRight {
            return true
        } else {
            return false
        }
    }
    
    public func isOpositeOf(_ other: GameEvent) -> Bool {
        if self == .MoveUp && other == .MoveDown ||
            self == .MoveDown && other == .MoveUp ||
            self == .MoveRight && other == .MoveLeft ||
            self == .MoveLeft && other == .MoveRight
        {
            return true
        } else {
            return false
        }
    }
}
