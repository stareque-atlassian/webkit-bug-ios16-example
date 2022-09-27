//Instructions
//This test will not pass when run on Intel mac using Xcode 14 beta 5 on iOS16
//This test will pass on any other scenario, an iOS less than 16 or on a M1 mac or an Xcode version less than 14

import XCTest
import WebKit
@testable import WebKitBugExample

class WebKitBugExampleTests: XCTestCase, WKNavigationDelegate {
    
    static let defaultTimeout: TimeInterval = 5.0
    
    lazy var wkWebView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(origin: .zero, size: CGSize(width: 500, height: 500)), configuration: config)
        webView.navigationDelegate = self
        return webView
    }()

    var onFinishNavigation: ((WKNavigation) -> Void)? = nil
    var onFailWithError: ((WKNavigation, Error) -> Void)? = nil

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start: \(navigation.debugDescription)")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("commit: \(navigation.debugDescription)")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == self.wkWebView {
            onFinishNavigation?(navigation)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if webView == self.wkWebView {
            onFailWithError?(navigation, error)
        }
    }
    
    func testShowWebKitErrorExample() throws {
        let expectation = XCTestExpectation(description: #function)
        var loadNavigation: WKNavigation? = nil
        let htmlStr = """
        <!DOCTYPE html>
        <html>
        <body>
            <button type="button" onclick="myFunction()" id="someElement">
                My Button
            </button>
        </body>
        </html>
        """
        onFinishNavigation = { [webView = self.wkWebView] navigation in
            if navigation == loadNavigation {
                webView.evaluateJavaScript("document.getElementById('someElement').innerText") { (result, error) in
                    print("-> Entered evaluateJavaScript() closure")
                    dump(result)
                    dump(error)
                    let resultString = result as? String ?? ""
                    XCTAssertEqual(resultString, "My Button")
                    expectation.fulfill()
                }
            }
        }
        onFailWithError = { navigation, error in
            if navigation == loadNavigation {
                XCTFail(error.localizedDescription)
            }
        }
        
        loadNavigation = wkWebView.loadHTMLString(htmlStr, baseURL: Bundle.main.resourceURL)
        
        wait(for: [expectation], timeout: Self.defaultTimeout)
    }


    @MainActor
    func testShowWebKitErrorExampleWithActor() throws {
        let expectation = XCTestExpectation(description: #function)
        var loadNavigation: WKNavigation? = nil
        let htmlStr = """
        <!DOCTYPE html>
        <html>
        <body>
            <button type="button" onclick="myFunction()" id="someElement">
                My Button
            </button>
        </body>
        </html>
        """
        onFinishNavigation = { navigation in
            if navigation == loadNavigation {
                Task { [wkWebView = self.wkWebView] in
                    do {
                        let evalutatedResult = try await wkWebView.evaluateJavaScript("document.getElementById('someElement').innerText")
                        let result = evalutatedResult as? String ?? ""
                        dump(result)
                        XCTAssertEqual(result, "My Button")
                        expectation.fulfill()
                        print("-> Printing final value of isDefinedResult: \(result)")
                    } catch {
                        dump(error)
                        XCTFail(error.localizedDescription)
                    }
                }
            }
        }
        onFailWithError = { navigation, error in
            if navigation == loadNavigation {
                XCTFail(error.localizedDescription)
            }
        }
        
        loadNavigation = wkWebView.loadHTMLString(htmlStr, baseURL: Bundle.main.resourceURL)
        
        wait(for: [expectation], timeout: Self.defaultTimeout)
    }

}
