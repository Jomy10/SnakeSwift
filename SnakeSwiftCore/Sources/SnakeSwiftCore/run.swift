//
//  run.swift
//  
//  Start a game
//
//  Created by Jonas Everaert on 14/03/2022.
//

import Foundation
// TokamakShim imorts TokamakDOM for WASI, GTK for linux and SwiftUI for platforms that can use SwiftUI
import TokamakShim

public func startGame(
    gc: inout GraphicsContext,
    cSize: CGSize,
    onPoint: @escaping (Int) -> (),
    onGameOver: @escaping (Int) -> (),
    /// Update view on draw
    onDraw: @escaping () -> () = {}
) {
    // Setup code
    // The renderer and GameLooop should only be initialized once
    if renderer == nil {
        renderer = GraphicsRenderer(
            context: &gc,
            canvasSize: cSize,
            increaseDifficultyCallback: { fps, points in
                let currentFps = loop?.getFps() ?? 2
                var maxSpeed: Int = 9
                if points > 10 {
                    if points > 500 {
                        maxSpeed = 100
                    } else if points > 200 {
                        maxSpeed = 50
                    } else if points > 100 {
                        maxSpeed = 20
                    } else if points > 50 {
                        maxSpeed = 30
                    } else if points > 20 {
                        maxSpeed = 13
                    } else if points > 15 {
                        maxSpeed = 10
                    }
                }
                loop?.newFps(fps: min(currentFps + fps, maxSpeed))
            },
            gameOverCallback: { finalScore in
                #if os(WASI)
                loop = nil
                #else
                loop?.stop()
                #endif
                onGameOver(finalScore)
            },
            scoreCallback: { newScore in
                onPoint(newScore)
            },
            drawCallback: onDraw
        )
        
        // handle keyboard input
        KeyboardHandler.listen(renderer: renderer!)
        
        // Game loop
        startGameLoop(renderer: renderer!)
    } else {
        renderer!.set(graphicsContext: &gc)
    }
    
    // Set new size (when resized)
    renderer!.onResize(newSize: cSize)
    
    // Redraw on resize as well
    renderer!.drawFrame()
}

public func startGameLoop(renderer: GraphicsRenderer) {
    // Start with 2 frames per second (snake moves twice per second)
    #if os(WASI)
    loop = GameLoop(fps: 2, callback: {
        renderer.handleNextFrame()
    })
    #else
    loop = GameLoop(fps: 2, callback: { _ in
        renderer.handleNextFrame()
    })
    #endif
}
