import SwiftUI
import Foundation
import SnakeSwiftCore

struct ContentView: View {
    @State var highScore: Int
    @State var currentScore: Int = 0
    @State var gameOver = false

    // hacky solution, should be replaced when I find a solution to the problem where
    // the canvas does not get redrawn until one of the UI elements gets updated.
    @State var update = false

    init() {
        let defaults = UserDefaults.standard
        self.highScore  = defaults.integer(forKey: "highscore")
        // Disable keyboard funk sound
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { _ in return nil }
    }

    var body: some View {
        HStack {
            Canvas(
                renderer: { gc, cSize in
                    startGame(
                        gc: &gc,
                        cSize: cSize,
                        onPoint: { newScore in 
                            self.currentScore = newScore
                        }, onGameOver: { finalScore in 
                            self.currentScore = finalScore
                            self.gameOver = true
                            if finalScore > self.highScore {
                                let defaults = UserDefaults.standard
                                defaults.set(finalScore, forKey: "highscore")
                                self.highScore = finalScore
                            }
                        // also part of the hacky solution
                        }, onDraw: {
                            self.update = !update
                        }
                    )
                }
            ).frame(width: 720, height: 720, alignment: .center)
            VStack {
                ZStack {
                    Text("Highscore: \(self.highScore)")
                        .fixedSize(horizontal: true, vertical: true)
                    // Part of the hacky solution
                    Text("\(self.update)" as String)
                        .hidden()
                }
                if self.gameOver {
                    Text("Game Over")
                        .fixedSize(horizontal: true, vertical: true)
                    Text("Your score is: \(self.currentScore)")
                        .fixedSize(horizontal: true, vertical: true)
                    Button("Play again") {
                        self.currentScore = 0
                        self.gameOver = false
                        renderer!.resetGame()
                        startGameLoop(renderer: renderer!)
                    }
                } else {
                    Text("Score: \(self.currentScore)")
                        .fixedSize(horizontal: true, vertical: true)
                }
            }.padding()
        }
    }
}
