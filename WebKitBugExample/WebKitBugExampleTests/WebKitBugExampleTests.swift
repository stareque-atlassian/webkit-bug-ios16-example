//Instructions
//This test will not pass when run on Intel mac using Xcode 14 beta 5 on iOS16
//This test will pass on any other scenario, an iOS less than 16 or on a M1 mac or an Xcode version less than 14

import XCTest
import WebKit
@testable import WebKitBugExample

class WebKitBugExampleTests: XCTestCase {
    
    var wkWebView: WKWebView!

    func testShowWebKitErrorExample() throws {
        
        let config = WKWebViewConfiguration()
        let htmlStr = "<!DOCTYPE html><html> <body> <button type=\"button\" onclick=\"myFunction()\" id=\"someElement\" >My Button</button> </body> </html>"
        var isDefinedResult: Bool? = nil
        
        wkWebView = WKWebView(frame: CGRect.init(x: 0, y: 0, width: 500, height: 900), configuration: config)
        wkWebView.loadHTMLString(htmlStr, baseURL: Bundle.main.resourceURL)
        wkWebView.evaluateJavaScript("document.getElementById('someElement').innerText") { (result, error) in
            print("-> Entered evaluateJavaScript() closure")
            dump(result)
            dump(error)
            isDefinedResult = (result as? Bool) ?? false
        }
        
        XCTestCase.waitUntil(timeout: 30, isDefinedResult != nil)
        print("-> Printing final value of isDefinedResult: \(isDefinedResult)")
    }
}

public extension XCTestCase {
    static let defaultTimeout: TimeInterval = 30.0
    static let defaultPollingInterval: TimeInterval = 0.2

    static func waitUntil(timeout: TimeInterval = XCTestCase.defaultTimeout,
                          file: StaticString = #file,
                          line: UInt = #line,
                          _ condition: @autoclosure () -> Bool) {
        let timeoutDate = Date(timeIntervalSinceNow: timeout)

        while (!condition() && timeoutDate.timeIntervalSinceNow > 0) {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: XCTestCase.defaultPollingInterval))
        }

        XCTAssertTrue(condition(), "Failed to satisfy the condition", file: file, line: line)
    }

}
