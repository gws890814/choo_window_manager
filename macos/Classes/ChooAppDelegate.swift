
import Cocoa
import FlutterMacOS

open class ChooAppDelegate: FlutterAppDelegate {
  open override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }
}
