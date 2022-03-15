//
//  keyboard.swift
//  
//  Handle keyboard input (WASD and arrow keys)
//
//  Created by Jonas Everaert on 13/03/2022.
//

import TokamakDOM
import JavaScriptKit

public class KeyboardHandler {
    let renderer: GraphicsRenderer
    
    public init(_ renderer: GraphicsRenderer) {
        self.renderer = renderer
    }
}

extension KeyboardHandler {
    public func handleKeyIn(key: JSValue) {
        if key == "ArrowUp" || key == "KeyW" {
            self.renderer.events.append(GameEvent.MoveUp)
        } else if key == "ArrowLeft" || key == "KeyA" {
            self.renderer.events.append(GameEvent.MoveLeft)
        } else if key == "ArrowDown" || key == "KeyS" {
            self.renderer.events.append(GameEvent.MoveDown)
        } else if key == "ArrowRight" || key == "KeyD" {
            self.renderer.events.append(GameEvent.MoveRight)
        }
    }
}
