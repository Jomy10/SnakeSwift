//
//  keyboard.swift
//  
//  Handle keyboard input (WASD and arrow keys)
//
//  Created by Jonas Everaert on 13/03/2022.
//

#if os(WASI)
import JavaScriptKit
#elseif os(macOS)
import CoreGraphics
#endif

public class KeyboardHandler {
    let renderer: GraphicsRenderer
    
    public init(_ renderer: GraphicsRenderer) {
        self.renderer = renderer
    }
}

#if os(WASI)
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
    
    public static func listen(renderer: GraphicsRenderer) {
        let document = JSObject.global.document.object!
        let keyboardHandler = KeyboardHandler(renderer)
        
        let eventListener = JSClosure { key in
            (key as [JSValue]).forEach { val in
                if let _val = val.object?.code {
                    keyboardHandler.handleKeyIn(key: _val)
                }
            }
            return JSValue.undefined
        }
        let _ = document.addEventListener!("keydown", JSValue.object(eventListener))
    }
}
#elseif os(macOS)
extension KeyboardHandler {
    public func handleKeyIn() {
        if CGKeyCode.kVK_UpArrow.isPressed || CGKeyCode.kVK_ANSI_W.isPressed {
            self.renderer.events.append(GameEvent.MoveUp)
        } else if CGKeyCode.kVK_DownArrow.isPressed || CGKeyCode.kVK_ANSI_S.isPressed {
            self.renderer.events.append(GameEvent.MoveDown)
        } else if CGKeyCode.kVK_LeftArrow.isPressed || CGKeyCode.kVK_ANSI_A.isPressed {
            self.renderer.events.append(GameEvent.MoveLeft)
        } else if CGKeyCode.kVK_RightArrow.isPressed || CGKeyCode.kVK_ANSI_D.isPressed {
            self.renderer.events.append(GameEvent.MoveRight)
        }
    }
    
    public static func listen(renderer: GraphicsRenderer) {
        let keyboardHandler = KeyboardHandler(renderer)
        
        let sem = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "key_polling", attributes: .concurrent)
        queue.async {
            while true {
                keyboardHandler.handleKeyIn()
                
                let _ = sem.wait(timeout: .now() + .milliseconds(50))
            }
        }
    }
}

extension CGKeyCode {
    // All keycodes: https://gist.github.com/chipjarred/cbb324c797aec865918a8045c4b51d14
    // Credits to: https://stackoverflow.com/a/68206622/14874405
    public static let kVK_LeftArrow                 : CGKeyCode = 0x7B
    public static let kVK_RightArrow                : CGKeyCode = 0x7C
    public static let kVK_DownArrow                 : CGKeyCode = 0x7D
    public static let kVK_UpArrow                   : CGKeyCode = 0x7E
    public static let kVK_ANSI_W                    : CGKeyCode = 0x0D // AZERTY: Z
    public static let kVK_ANSI_A                    : CGKeyCode = 0x00 // AZERTY: Q
    public static let kVK_ANSI_S                    : CGKeyCode = 0x01
    public static let kVK_ANSI_D                    : CGKeyCode = 0x02

    public var isPressed: Bool {
        CGEventSource.keyState(.combinedSessionState, key: self)
    }
}
#endif
