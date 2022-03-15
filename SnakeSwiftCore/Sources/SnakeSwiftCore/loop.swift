//
//  loop.swift
//
//  The game loop logic
//
//  Created by Jonas Everaert on 13/03/2022.
//

import Foundation
#if os(WASI)
import JavaScriptKit
#endif

#if os(WASI)
/// GameLoop for TokamakUI using Javascript timer
public struct GameLoop {
    private var fps: Int
    private var timer: JSTimer?
    private let callback: () -> ()
}

extension GameLoop {
    /// - `callback`: gets executed every frame
    public init(fps: Int = 2, callback: @escaping () -> ()) {
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
}
#else
/// GameLoop for SwiftUI using the Foundation Timer
public struct GameLoop {
    private var fps: Int
    private var timer: Timer
    private let callback: (Timer) -> ()
}

extension GameLoop {
    public init(fps: Int = 2, callback: @escaping (Timer) -> ()) {
        self.fps = fps
        let secDelay = (1.0 / Double(self.fps))
        self.callback = callback
        self.timer = Timer.scheduledTimer(withTimeInterval: secDelay, repeats: true, block: callback)
    }
}

extension GameLoop {
    public mutating func newFps(fps: Int) {
        self.fps = fps
        let secDelay = (1.0 / Double(self.fps))
        self.timer.invalidate() // Stop current timr
        self.timer = Timer.scheduledTimer(withTimeInterval: secDelay, repeats: true, block: self.callback)
    }
}
#endif

extension GameLoop {
    public func getFps() -> Int {
        self.fps
    }
}
