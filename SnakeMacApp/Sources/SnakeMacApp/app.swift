import SwiftUI

/// Snake game for macOS
@main
struct SnakeApp: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	var body: some Scene {
		WindowGroup("Snake") {
			ContentView()
		}
	}
}

/// Without this, there will just be a window without an actual app
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		NSApplication.shared.setActivationPolicy(.regular)
		NSApplication.shared.activate(ignoringOtherApps: true)
		NSApplication.shared.windows.forEach { window in window.center() }
	}

	/// Close application when the window is closed
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

	func applicationWillUpdate(_ notification: Notification) {
		if let menu = NSApplication.shared.mainMenu {
			// Remove default menu items that we don't need
			// removeAll(where)
			menu.items.removeAll { $0.title == "Edit" }
			menu.items.removeAll { $0.title == "File" }
			menu.items.removeAll { $0.title == "Help" }
		}
	}

	// TODO: find a way to prevent multiple window/tabs to be open
}