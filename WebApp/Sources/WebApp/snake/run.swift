//
//  run.swift
//  
//  Start a game
//
//  Created by Jonas Everaert on 14/03/2022.
//

import Foundation
import JavaScriptKit
import TokamakDOM

func startGame(
    gc: inout GraphicsContext,
    cSize: CGSize,
    onPoint: @escaping (Int) -> (),
    onGameOver: @escaping (Int) -> ())
{
    // The renderer and GameLooop should only be initialized once
    if renderer == nil {
        renderer = GraphicsRenderer(
            context: gc,
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
                loop = nil
                onGameOver(finalScore)
            },
            scoreCallback: { newScore in
                onPoint(newScore)
            }
        )
        // SwiftUI (For later)
        // Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer  in
        //     print("timed")
        // })
        
        // JS
        // handle keyboard input
        let document = JSObject.global.document.object!
        let keyboardHandler = KeyboardHandler(renderer!)
        
        let eventListener = JSClosure { key in
            (key as [JSValue]).forEach { val in
                if let _val = val.object?.code {
                    keyboardHandler.handleKeyIn(key: _val)
                }
            }
            return JSValue.undefined
        }
        let _ = document.addEventListener!("keydown", JSValue.object(eventListener))
        
        // Game loop
        startGameLoop(renderer: renderer!)
    }
    
    // Set new size (when resized)
    renderer!.onResize(newSize: cSize)
    
    // Redraw on resize as well
    renderer!.drawFrame()
}

func startGameLoop(renderer: GraphicsRenderer) {
    // Start with 2 frames per second (snake moves twice per second)
    loop = GameLoop(fps: 2, callback: {
        renderer.handleNextFrame()
    })
}
