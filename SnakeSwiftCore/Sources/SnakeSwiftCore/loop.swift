//
//  loop.swift
//
//  The game loop logic
//
//  Created by Jonas Everaert on 13/03/2022.
//

import Foundation
import JavaScriptKit

/// GameLoop for TokamakUI using Javascript timer
public struct GameLoop {
    private var fps: Int = 60
    private var timer: JSTimer?
    private let callback: () -> ()
}

extension GameLoop {
    /// - `callback`: gets executed every frame
    public init(fps: Int = 60, callback: @escaping () -> ()) {
        self.fps = fps
        let milisecDelay = (1.0 / Double(self.fps)) * 1000.0
        self.callback = callback
        self.timer = JSTimer(millisecondsDelay: milisecDelay, isRepeating: true, callback: callback)
    }
}

extension GameLoop {
    /// Set a new fps
    public mutating func newFps(fps: Int) {
        self.fps = fps
        let milisecDelay = (1.0 / Double(self.fps)) * 1000.0
        self.timer = JSTimer(millisecondsDelay: milisecDelay, isRepeating: true, callback: self.callback)
    }
    
    public func getFps() -> Int {
        self.fps
    }
}
