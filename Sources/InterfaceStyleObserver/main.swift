import Foundation
import AppKit

@available(macOS 10.13, *)
func shell(_ launchPath: String, _ arguments: [String] = []) throws -> (String?, Int32) {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe 
    task.standardError = pipe 
    
    task.arguments = arguments
    task.executableURL = URL(fileURLWithPath: launchPath)
    task.standardInput = nil
    
    try task.run()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    task.waitUntilExit()

    return (output, task.terminationStatus) 
}

func darkModeEnabled() -> Bool {
    return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
}

@discardableResult
@available(macOS 10.13, *)
func darkModeChanged() -> Int32 {
    var env = ProcessInfo.processInfo.environment
    env["MACOS_CURRENT_COLOR_SCHEME"] = darkModeEnabled() ? "dark" : "light"
    
    do {
        let output = (try shell("/usr/bin/env zsh", ["pgrep", "nvim"]).0)!
        
        guard let pid = Int32(output) else {
            return 1
        }
        
        return try sendSignal(pid: pid)
    } catch {
        return 1
    }
}

@available(macOS 10.13, *)
func sendSignal(pid: Int32, signal: Int32 = 10) throws -> Int32 {
    return try shell("/bin/zsh", ["kill", "-\(signal)", String(pid)]).1
}

DistributedNotificationCenter.default.addObserver(
    forName: Notification.Name("AppleInterfaceThemeChangedNotification"), 
    object: nil, 
    queue: nil) { (notification) in
        if #available(macOS 10.13, *) {
            darkModeChanged()
        } else {
            exit(1)
        }
}

NSApplication.shared.run()
