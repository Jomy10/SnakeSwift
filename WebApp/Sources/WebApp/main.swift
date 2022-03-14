import TokamakDOM
import Foundation

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
    
    @State var canvasSize: CGFloat = 0
    /// sidebar width after calculating canvas size
    @State var newSideBarWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Text("Snake")
                    .font(.system(size: 30))
                    .padding()
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
                            size: CGSize(width: self.canvasSize, height: self.canvasSize)
                        )
                    }

                    VStack {
                        Text("Highscore: \(self.highScore)")
                        if gameOver {
                            Text("Game Over")
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
                    .frame(width: self.newSideBarWidth, alignment: .center)
                }
            }
            .onAppear {
                self.highScore = LocalStorage.standard.read(key: "highScore") ?? 0
                
                let screenSize = proxy.size
                self.canvasSize = min(screenSize.width - self.sideBarSize.width, screenSize.height - self.topBarSize.height - 50 /*Extra bottom padding*/)
                self.newSideBarWidth = max(screenSize.width - self.canvasSize - (screenSize.width / 3) /*Extra padding for canvas (so it isn't against the edge*/, self.sideBarSize.width /*min width*/)
            }
        }
    }
}

TokamakApp.main()
