import Cocoa
import FlutterMacOS
import choo_window_manager

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let project = ChooWindowManagerPlugin.initFlutterObject()
    let flutterViewController = ChooFlutterViewController(project: project)
    let windowFrame = self.frame
    
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    ChooWindowManagerPlugin.RegisterGeneratedPlugins = RegisterGeneratedPlugins
    super.awakeFromNib()
  }
    
  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    hiddenWindowAtLaunch()
  }
}
