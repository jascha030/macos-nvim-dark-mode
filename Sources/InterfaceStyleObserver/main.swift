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

@available(macOS 10.13, *)
func darkModeChanged() throws {
    var env = ProcessInfo.processInfo.environment
    env["MACOS_CURRENT_COLOR_SCHEME"] = darkModeEnabled() ? "dark" : "light"
    
    do {
        let output = (try shell("/usr/bin/env", ["pgrep", "nvim"]).0)!
        
        let newlineChars = NSCharacterSet.newlines
        let lineArray = output.components(separatedBy: newlineChars)
        
        for line in lineArray {
            guard let pid = Int32(line) else {
                return
            }
            
            try sendSignal(pid: pid)
        }
    }
}

@discardableResult
@available(macOS 10.13, *)
func sendSignal(pid: Int32) throws -> Int32 {
    return try shell("/usr/bin/env", ["kill", "-SIGUSR1", String(pid)]).1
}

DistributedNotificationCenter.default.addObserver(
    forName: Notification.Name("AppleInterfaceThemeChangedNotification"), 
    object: nil, 
    queue: nil) { (notification) in
        if #available(macOS 10.13, *) {
            do {
                try darkModeChanged()
            } catch {
                print("Error")
            }
        } else {
            exit(1)
        }
}

NSApplication.shared.run()
