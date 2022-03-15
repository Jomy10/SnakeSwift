//
//  renderer.swift
//
//  The renderer that renders to the Canvas
//
//  Created by Jonas Everaert on 13/03/2022.
//

import Foundation
import TokamakShim

/// Renders the content to a `Canvas`. In this caes the `html canvas`
public class GraphicsRenderer {
    private var gc: GraphicsContext
    /// Canvas size
    private var size: CGSize
    private var cellSize: CGFloat
    private var board: BoardState
    /// The events that have to be executed in this frame
    public var events: [GameEvent]
    /// The current direction the snake is moving in (`MoveUp`, `MoveLeft`, `MoveDown`, `MoveDown`)
    private var moveDirection: GameEvent
    /// Increases the difficulty by the given parameter
    private let increaseDifficulty: (_ fps: Int, _ points: Int) -> ()
    /// Called on game over witth the player's score
    private let gameOver: (Int) -> ()
    /// Called when the player makes a point
    private let newScore: (Int) -> ()
    /// Called when drawing to canvas has finished
    private let drawn: () -> ()
    
    public init(
        context gc: inout GraphicsContext,
        canvasSize size: CGSize,
        boardSize: Int = 50,
        increaseDifficultyCallback: @escaping (Int, Int) -> (),
        gameOverCallback: @escaping (Int) -> (),
        scoreCallback: @escaping (Int) -> (),
        /// Called when drawn to canvas has finished (needed on macOS for now)
        drawCallback: @escaping () -> () =  {}
    ) {
        self.gc = gc
        self.size = size
        self.board = BoardState(
            size: (rows: boardSize, cols: boardSize),
            food: Coordinate.randomCoordinate(
                // somewhere in front of the player, close to the player
                minX: (boardSize/4), maxX: (boardSize/2)-2,
                minY: (boardSize/2)-(boardSize/4), maxY: (boardSize/2)+(boardSize/4)
            ),
            // 3 long player
            player: [
                Coordinate(x: boardSize/2 - 1, y: boardSize/2),
                Coordinate(x: boardSize/2, y: boardSize/2),
                Coordinate(x: boardSize/2 + 1, y: boardSize/2)
            ])
        self.cellSize = min(self.size.width, self.size.height) / CGFloat(self.board.size.cols)
        self.events = []
        self.moveDirection = GameEvent.MoveLeft
        self.increaseDifficulty = increaseDifficultyCallback
        self.gameOver = gameOverCallback
        self.newScore = scoreCallback
        self.drawn = drawCallback
    }
}


extension GraphicsRenderer {
    public func set(graphicsContext gc: inout GraphicsContext) {
        self.gc = gc
    }
    
    public func resetGame() {
        self.board = BoardState(
            size: (rows: self.board.size.rows, cols: self.board.size.cols),
            food: Coordinate.randomCoordinate(
                // somewhere in front of the player, close to the player
                minX: (self.board.size.cols/4), maxX: (self.board.size.cols/2)-2,
                minY: (self.board.size.rows/2)-(self.board.size.rows/4), maxY: (self.board.size.rows/2)+(self.board.size.rows/4)
            ),
            // 3 long player
            player: [
                Coordinate(x: self.board.size.cols/2 - 1, y: self.board.size.rows/2),
                Coordinate(x: self.board.size.cols/2, y: self.board.size.rows/2),
                Coordinate(x: self.board.size.cols/2 + 1, y: self.board.size.rows/2)
            ])
        self.events = []
        self.moveDirection = GameEvent.MoveLeft
    }
}

extension GraphicsRenderer {
    /// Call when canvas is resized
    public func onResize(newSize: CGSize) {
        self.size = newSize
        self.cellSize = min(self.size.width, self.size.height) / CGFloat(self.board.size.cols)
    }
    
    /// Move player, eat food, calculate new food position, draw scene
    public func handleNextFrame() {
        // Handle events
        var addTailThisFrame = false
        var newMoveDir = self.moveDirection
        while !events.isEmpty {
            let event = events.remove(at: 0)
            if event.isMoveAction {
                // Don't allow 180° turns
                if !self.moveDirection.isOpositeOf(event) {
                    newMoveDir = event
                }
            } else if event == .AddTail {
                addTailThisFrame = true
            }
        }
        self.moveDirection = newMoveDir
        
        // Move character
        switch self.moveDirection {
        case .MoveLeft:
            // Insert new head at new position
            self.board.player.insert(
                Coordinate(
                    x: self.board.player[0].x - 1,
                    y: self.board.player[0].y
                ), at: 0
            )
            // Remove last tail
            if addTailThisFrame == false {
                let _ = self.board.player.popLast()
            }
        case .MoveRight:
            // Insert new head at new position
            self.board.player.insert(
                Coordinate(
                    x: self.board.player[0].x + 1,
                    y: self.board.player[0].y
                ), at: 0
            )
            // Remove last tail
            if addTailThisFrame == false {
                let _ = self.board.player.popLast()
            }
        case .MoveUp:
            // Insert new head at new position
            self.board.player.insert(
                Coordinate(
                    x: self.board.player[0].x,
                    y: self.board.player[0].y - 1
                ), at: 0
            )
            // Remove last tail
            if addTailThisFrame == false {
                let _ = self.board.player.popLast()
            }
        case .MoveDown:
            // Insert new head at new position
            self.board.player.insert(
                Coordinate(
                    x: self.board.player[0].x,
                    y: self.board.player[0].y + 1
                ), at: 0
            )
            // Remove last tail
            if addTailThisFrame == false {
                let _ = self.board.player.popLast()
            }
        default:
            print("Unexpected:", self.moveDirection)
        }
        
        // Handle eat
        if self.board.player[0] == self.board.food {
            // New food location
            var randLoc = Coordinate.randomCoordinate(
                maxX: self.board.size.rows, maxY: self.board.size.cols)
            
            var insidePlayer = true
            while insidePlayer {
                insidePlayer = false
                self.board.player.forEach { pCo in
                    if pCo == randLoc {
                        insidePlayer = true
                        randLoc = Coordinate.randomCoordinate(
                            maxX: self.board.size.rows, maxY: self.board.size.cols)
                    }
                }
            }
            
            self.board.food = randLoc
            
            // Increase player score
            self.board.score += 1
            self.newScore(self.board.score)
            
            // Increase player length
            self.events.append(.AddTail)
            
            // Increase difficulty
            self.increaseDifficulty(1, self.board.score)
        }
        
        // Handle edge of screen
        self.board.player.enumerated().forEach { idx, co in
            if co.x < 0 {
                self.board.player[idx].x = self.board.size.cols - 1
            } else if co.x > self.board.size.cols - 1 {
                self.board.player[idx].x = 0
            }
            
            if co.y < 0 {
                self.board.player[idx].y = self.board.size.rows - 1
            } else if co.y > self.board.size.rows - 1 {
                self.board.player[idx].y = 0
            }
        }
        
        // Handle snake bite itself
        if self.board.player[1...self.board.player.count-1]
            .contains(self.board.player[0])
        {
            self.gameOver(self.board.score)
        }
        
        // Draw frame again
        self.drawFrame()
    }
    
    /// Draws the current state of the game
    public func drawFrame() {
        // bg
        self.gc.fill(
            Path(CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)),
            with: GraphicsContext.Shading.color(.secondary)
        )
        // Draw food item
        self.gc.fill(self.foodPath(), with: GraphicsContext.Shading.color(.red))
        // Draw player
        self.board.player.forEach { co in
            self.gc.fill(
                self.rectPath(at: (x: co.x, y: co.y)),
                with: GraphicsContext.Shading.color(.green)
            )
        }
        
        self.drawn()
    }
    
    /// `Path` for a rectangle
    public func rectPath(at coordinate: (x: Int, y: Int)) -> Path {
        return Path(CGRect(
            x: CGFloat(coordinate.x)  * self.cellSize,
            y: CGFloat(coordinate.y) * self.cellSize,
            width: self.cellSize,
            height: self.cellSize))
    }
 
    /// Returns the path of a food item
    public func foodPath() -> Path {
        return rectPath(at: (x: self.board.food.x, y: self.board.food.y))
    }
}
