//
//  websocket.swift
//  
//
//  Created by Jonas Everaert on 17/03/2022.
//

import Foundation
import JavaScriptKit

class WebSocket {
    public class var constructor: JSFunction {
        get {
            JSObject.global.WebSocket.function!
        }
    }
}
