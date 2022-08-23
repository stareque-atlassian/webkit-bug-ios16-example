## Overview

A sample project to demonstrate that a WebKit internal crash/bug occurs when on (Intel Mac/Xcode14 beta5/Simulator/iOS16) and running `WKWebView.evaluateJavaScript(..) {} `. The closure passed does not get called and a WebKit crash is logged in console.

This happens only when all the cases are met:
* Developer on Intel Mac
* Xcode 14 beta5
* Simulator on iOS 16
  
There is no issue when tested on a lower verison from the above cases, i.e. tested on iOS 15.5.

The eror logs that show a WebKit crash:
```
[ProcessSuspension] endowmentsForHandle: Process with PID 62886 is not running
2022-08-24 07:24:08.094225+1000 xctest[62886:2912224] [Process] 0x114064100 - [PID=0] WebProcessProxy::didFinishLaunching: Invalid connection identifier (web process failed to launch)
2022-08-24 07:24:08.094369+1000 xctest[62886:2912224] [Process] 0x114064100 - [PID=0] WebProcessProxy::processDidTerminateOrFailedToLaunch: reason=Crash
2022-08-24 07:24:08.094656+1000 xctest[62886:2912224] [Process] 0x7fcb96020c20 - [pageProxyID=6, webPageID=7, PID=0] WebPageProxy::processDidTerminate: (pid 0), reason=Crash
2022-08-24 07:24:08.095603+1000 xctest[62886:2912224] [Loading] 0x7fcb96020c20 - [pageProxyID=6, webPageID=7, PID=0] WebPageProxy::dispatchProcessDidTerminate: reason=Crash
2022-08-24 07:24:08.095762+1000 xctest[62886:2912224] [Loading] 0x7fcb96020c20 - [pageProxyID=6, webPageID=7, PID=0]
```

Sometimes this is accompanied by a crash related to PosterBoard.app similar to what is mentioned in the forum [here](https://developer.apple.com/forums/thread/711121)

## Steps to reproduce

### Preprequisites
Use an Intel mac

### Failure case, run on iOS16/Xc14b5
Steps:
* Open `WebKitBugExample.xcodeproj` using Xcode14 beta5
* Run test `WebKitBugExampleTests.WebKitBugExampleTests` in test target `WebKitBugExampleTests`
* Run on simulator with iOS16

Expectation:
* Test should pass and show no error logs as shown above

Actual:
* Test fails and shows error logs

### Successful case, run on iOS15.5/Xc14b5
Steps:
* Open `WebKitBugExample.xcodeproj` using Xcode14 beta5
* Run test `WebKitBugExampleTests.WebKitBugExampleTests` in test target `WebKitBugExampleTests`
* Run on simulator with iOS15.5

Actual:
* Test passes
