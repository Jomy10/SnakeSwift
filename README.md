# Snake Game

Snake game built using Swift, playable on any browser using WebAssembly and on macOS.

## Browser
UI built using [Tokamak](https://github.com/TokamakUI/Tokamak), which is a SwiftUI compatible framework for WebAssembly. Interaction with the DOM is done through [JavaScriptKit](https://github.com/swiftwasm/JavaScriptKit). Built and bundles using [Carton](https://github.com/swiftwasm/carton).

Source code for the browser UI in [WebApp](WebApp).

## macOS
Since Tokamak is a SwiftUI compatible framework, a Mac app can be easily created without too much adjustments.

Source code for the mac version in [SnakeMacApp](SnakeWebApp).

## Core library
The core library contains all the game logic. This imports TokamakShim, which uses SwiftUI for compatible platforms, TokamakDOM for web and TokamakGTK for Linux. Using conditional compilation (`#if`), platform-specific functions are handled (e.g. using Foundation for macOS and JavaScriptKit for the web).

## Contributing
If you find any bugs or have any improvement suggestions, please open an issue first. If you get green light, you can open a pull request.

If you want to work on any open issues, just comment on the issue with your intentions. If you end up not working not working on it anymore, please comment again.

## License
Licensed under MIT license.
