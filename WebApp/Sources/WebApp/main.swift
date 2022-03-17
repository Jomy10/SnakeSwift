//
//  main.swift
//
//  The main Tokamak App. Contains all the UI elements (only for the web).
//

import TokamakDOM
import Foundation
import SnakeSwiftCore
import JavaScriptKit

struct TokamakApp: App {
    var body: some Scene {
        WindowGroup("Snake Game") {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State var highScore: Int = 0
    @State var currentScore: Int = 0
    @State var gameOver = false
    
    /// Size of top bar in `HTML`
    let topBarSize = CGSize(width: 74, height: 55)
    let sideBarSize = CGSize(width: 298, height: 68)
    
    let mobile$controllerSize = CGSize(width: 895, height: 246)
    let mobile$topBarSize = CGSize(width: 0, height: 55 + 68)
    
    @State var canvasSize: CGFloat = 0
    /// sidebar width after calculating canvas size
    @State var newSideBarWidth: CGFloat = 0
    
    @State var isMobile = false
    
    @State var mobile$isMovingUp: Bool = false
    @State var mobile$isMovingDown: Bool = false
    @State var mobile$isMovingLeft: Bool = false
    @State var mobile$isMovingRight: Bool = false
    
    @State var mobile$keyboardHandler: KeyboardHandler?
    
    @State var debugMessage: String
    
    init() {
        // TODO: init once
        let window = JSObject.global.window.object!
        let navigator = window.navigator.object!
        let userAgent = navigator.userAgent.jsValue().string!
        let mobileRegex = try! NSRegularExpression(pattern: "Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|mobi")
        self.debugMessage = "UserAgent: " + userAgent + "<br/>"
        
        print("UserAgent: \(userAgent)")
        print("===")
        print(self.debugMessage)
        // Should we use the more thorough version? https://stackoverflow.com/a/3540295/14874405
        if mobileRegex.firstMatch(in: userAgent, options: [], range: NSRange.init(location: 0, length: userAgent.count)) != nil {
            self.isMobile = true
        }
        
        self.debugMessage.append("regexMatch: \(String(describing: mobileRegex.firstMatch(in: userAgent, options: [], range: NSRange.init(location: 0, length: userAgent.count))))")
        print(mobileRegex.firstMatch(in: userAgent, options: [], range: NSRange.init(location: 0, length: userAgent.count)))
        print("===")
        print(self.debugMessage)
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Text("Debug information: \(self.debugMessage)")
                Text("Snake")
                    .font(.system(size: self.isMobile ? 20 : 30))
                    .padding()
                if self.isMobile {
                    SideBarView(currentScore: self.$currentScore, highScore: self.$highScore, gameOver: self.$gameOver, width: self.$newSideBarWidth)
                }
                
                HStack {
                    HTML("div", ["id": "CanvasContainer", "style": "display: flex; justify-content: center; width: 100%;"]) {
                        SizedCanvas(
                            renderer: {gc, cSize in
                                startGame(
                                    gc: &gc,
                                    cSize: cSize,
                                    onPoint: { newScore in
                                        self.currentScore = newScore
                                    }, onGameOver: { finalScore in
                                        self.currentScore = finalScore
                                        self.gameOver = true
                                        if finalScore > self.highScore {
                                            LocalStorage.standard.store(key: "highScore", value: finalScore as Int?)
                                            self.highScore = finalScore
                                        }
                                    }
                                )
                            },
                            size: CGSize(width: self.canvasSize < 100 ? 100 : self.canvasSize, height: self.canvasSize < 100 ? 100 : self.canvasSize)
                        )
                    }

                    if !self.isMobile {
                        SideBarView(currentScore: self.$currentScore, highScore: self.$highScore, gameOver: self.$gameOver, width: self.$newSideBarWidth)
                    }
                }
                
                if self.isMobile {
                    // Controller
                    HStack {
                        Spacer()
                        ZStack {
                            VStack {
                                Spacer()
                                ControllerButtonView(.MoveUp, pressed: self.$mobile$isMovingUp, setDirection: self.setDirection(_:))
                                Spacer()
                                ControllerButtonView(.MoveDown, pressed: self.$mobile$isMovingDown, setDirection: self.setDirection(_:))
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                ControllerButtonView(.MoveLeft, pressed: self.$mobile$isMovingLeft, setDirection: self.setDirection(_:))
                                Spacer()
                                ControllerButtonView(.MoveRight, pressed: self.$mobile$isMovingRight, setDirection: self.setDirection(_:))
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
            }
            .onAppear {
                self.highScore = LocalStorage.standard.read(key: "highScore") ?? 0
            
                let screenSize = proxy.size
                if !self.isMobile {
                    let sWidth = screenSize.width - self.sideBarSize.width
                    let sHeight = screenSize.height - self.topBarSize.height - 50 /*Extra bottom padding*/
                    self.canvasSize = min(
                        sWidth < 100
                            ? screenSize.width < 100 ? 100
                            : screenSize.width : sWidth,
                        sHeight < 0 ? screenSize.height : sHeight )
                    self.newSideBarWidth = max(screenSize.width - self.canvasSize - (screenSize.width / 3) /*Extra padding for canvas (so it isn't against the edge*/, self.sideBarSize.width /*min width*/)
                } else {
                    let maxHeight = screenSize.height - self.mobile$topBarSize.height - self.mobile$controllerSize.height
                    self.canvasSize = min(screenSize.width, maxHeight < 0 ? 999999 : maxHeight)
                    self.newSideBarWidth = screenSize.width
                }
            }
        }
    }
    
    private func setDirection(_ dir: GameEvent) {
        if self.mobile$keyboardHandler == nil {
            self.mobile$keyboardHandler = KeyboardHandler(renderer!)
        }
        
        self.mobile$isMovingUp = false
        self.mobile$isMovingDown = false
        self.mobile$isMovingLeft = false
        self.mobile$isMovingRight = false
        
        switch dir {
        case .MoveUp:
            self.mobile$isMovingUp = true
        case .MoveDown:
            self.mobile$isMovingDown = true
        case .MoveLeft:
            self.mobile$isMovingLeft = true
        case .MoveRight:
            self.mobile$isMovingRight = true
        default:
            print("Unexpected: \(dir)")
        }
        
        self.mobile$keyboardHandler!.move(dir)
    }
}

fileprivate struct ControllerButtonView: View {
    private let idleSrc: String
    private let pressedSrc: String
    @Binding private var pressed: Bool
    private let setDirection: (GameEvent) -> ()
    private let dir: GameEvent
    private let name: String

    init(_ type: GameEvent, pressed: Binding<Bool>, setDirection: @escaping (GameEvent) -> ()) {
        self.dir = type
        switch type {
        case .MoveUp:
            self.idleSrc = "assets/Up_idle.png"
            self.pressedSrc = "assets/Up_Pushed.png"
            self.name = "up"
        case .MoveDown:
            self.idleSrc = "assets/Down_idle.png"
            self.pressedSrc = "assets/Down_Pushed.png"
            self.name = "down"
        case .MoveLeft:
            self.idleSrc = "assets/Previous_idle.png"
            self.pressedSrc = "assets/Previous_Pushed.png"
            self.name = "left"
        case .MoveRight:
            self.idleSrc = "assets/Next_idle.png"
            self.pressedSrc = "assets/Next_Pushed.png"
            self.name = "right"
        default:
            print("Unexpected: \(type)")
            self.idleSrc = "assets/error.png"
            self.pressedSrc = "assets/error.png"
            self.name = "error"
        }
        self._pressed = pressed
        self.setDirection = setDirection
    }
    
    var body: some View {
        ZStack {
            DynamicHTML(
                "img",
                [
                    "width": "100px", "height": "100px",
                    "src": self.pressedSrc,
                    "alt": self.name
                ],
                listeners: [
                    "mousedown": { _ in
                        setDirection(dir)
                    }
                ]
            ).opacity(self.pressed ? 100 : 0)
            DynamicHTML(
                "img",
                [
                    "width": "100px", "height": "100px",
                    "src": self.idleSrc,
                    "alt": self.name
                ]//,
                // listeners: [
                //     "mousedown": { _ in
                //         setDirection(dir)
                //     }
                // ]
            ).opacity(self.pressed ? 0 : 100)
        }
    }
}

fileprivate struct SideBarView: View {
    @Binding var currentScore: Int
    @Binding var highScore: Int
    @Binding var gameOver: Bool
    @Binding var width: CGFloat
    
    var body: some View {
        VStack {
            Text("HighScore: \(self.highScore)")
            if self.gameOver {
                Text("Game Over")
                    .foregroundColor(.red)
                Text("Your score is: \(self.currentScore)")
                Button("Play again") {
                    self.currentScore = 0
                    self.gameOver = false
                    renderer!.resetGame()
                    startGameLoop(renderer: renderer!)
                }
            } else {
                Text("Score: \(self.currentScore)")
            }
        }
        .padding()
        .frame(width: self.width, alignment: .center)
    }
}

TokamakApp.main()
