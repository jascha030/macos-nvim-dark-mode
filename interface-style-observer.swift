#!/usr/bin/env swift

import Cocoa;

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    
    task.launch()
    task.waitUntilExit()
    
    return task.terminationStatus
}

func darkModeEnabled() -> Bool {
    return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
}

func darkModeChanged() {
    var env = ProcessInfo.processInfo.environment
    env["MACOS_CURRENT_COLOR_SCHEME"] = darkModeEnabled() ? "dark" : "light"
}

func sendSignal(pid: Int32, signal: Int32 = 10) -> Int32 {
    return shell("kill", "-\(signal)", pid)
}

DistributedNotificationCenter.default.addObserver(
    forName: Notification.Name("AppleInterfaceThemeChangedNotification"), 
    object: nil, 
    queue: nil) { (notification) in
        darkModeChanged()
}

NSApplication.shared.run()
