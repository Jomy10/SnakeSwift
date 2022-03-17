import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.webSocket("player") { req, ws in
        ws.send("Hello WebSocket!")
        ws.onText { ws, data in
            print(data)
        }
    }

    try app.register(collection: TodoController())
}
