//
//  board.swift
//
//  Board and coordinates
//
//  Created by Jonas Everaert on 13/03/2022.
//

import Foundation

/// Position on the board
public struct Coordinate {
    var x, y: Int
}

extension Coordinate {
    public static func randomCoordinate(minX: Int = 0, maxX: Int, minY: Int = 0, maxY: Int) -> Coordinate {
        let x = Int.random(in: minX...maxX-1)
        let y = Int.random(in: minY...maxY-1)
        return Coordinate(x: x, y: y)
    }
}

extension Coordinate: Equatable {
    public static func == (lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

/// The current state of the game
public struct BoardState {
    public let size: (rows: Int, cols: Int)
    /// Next position of a food item
    public var food: Coordinate
    /// Location of the player and its tail pares
    public var players: [[Coordinate]]
    /// The player's current score
    public var score: Int = 0
}
