import Cocoa
import FlutterMacOS
import choo_window_manager

@main
class AppDelegate: ChooAppDelegate {
  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
