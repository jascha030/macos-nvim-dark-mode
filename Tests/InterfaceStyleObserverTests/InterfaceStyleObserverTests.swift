import XCTest
import class Foundation.Bundle

@testable import InterfaceStyleObserver
final class InterfaceStyleObserverTests: XCTestCase {
    func testShell() throws {
        guard #available(macOS 10.13, *) else {
            return
        }
        
        let test = (try shell("/usr/bin/env", ["echo", "test"]).0)!
        
        XCTAssertEqual("test\n", test)
        
        let cmd = try shell("/usr/bin/env", ["pgrep", "Xcode"])
        
        XCTAssertNotNil((cmd.0)!)
        XCTAssertEqual(cmd.1, 0)
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}
