import Foundation
import AppKit

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()

    task.launchPath = "/usr/bin/env"
    task.arguments = args
    
    task.launch()
    task.waitUntilExit()
   
    return task.terminationStatus
}

@available(macOS 10.15.4, *)
func shellOutput(_ args: String...) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe 
    task.standardError = pipe 
    
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    
    task.standardInput = nil
    task.launch()
    
    let data = (try pipe.fileHandleForReading.readToEnd())!
    let output = String(data: data, encoding: .utf8)!

    return output 
}

func darkModeEnabled() -> Bool {
    return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
}

func darkModeChanged() {
    var env = ProcessInfo.processInfo.environment
    env["MACOS_CURRENT_COLOR_SCHEME"] = darkModeEnabled() ? "dark" : "light"


}

func sendSignal(pid: Int32, signal: Int32 = 10) -> Int32 {
    return shell("kill", "-\(signal)", String(pid))
}



DistributedNotificationCenter.default.addObserver(
    forName: Notification.Name("AppleInterfaceThemeChangedNotification"), 
    object: nil, 
    queue: nil) { (notification) in
        darkModeChanged()
}

NSApplication.shared.run()
