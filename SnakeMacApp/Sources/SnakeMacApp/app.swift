import SwiftUI

@main
struct SnakeMacApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		WindowGroup {
			ContentView()
		}.commands {
			CommandMenu("Custom Menu") {
				Button("A") {
					print("A pressed")
				}.keyboardShortcut("a")
			}
		}
	}
}

/// Without this, there will just be a window without an actual app
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		NSApplication.shared.setActivationPolicy(.regular)
		NSApplication.shared.activate(ignoringOtherApps: true)
	}
}