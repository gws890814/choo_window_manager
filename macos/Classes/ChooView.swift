import FlutterMacOS

extension NSWindow {
  public func hiddenWindowAtLaunch() {
    if delegate is ChooWindowManager && (delegate as! ChooWindowManager).isInit {
      return;
    }
    if delegate is ChooWindowManager {
      (delegate as! ChooWindowManager).isInit = true
    }
    self.setIsVisible(false)
  }
}

extension NSRect {
    var topLeft: CGPoint {
      set {
        let screenFrameRect = NSScreen.screens[0].frame
        origin.x = newValue.x
        origin.y = screenFrameRect.height - newValue.y - size.height
      }
      get {
        let screenFrameRect = NSScreen.screens[0].frame
        return CGPoint(x: origin.x, y: screenFrameRect.height - origin.y - size.height)
      }
  }
}

class ChooWindow: NSWindow {
  public var windowId: Int64? {
    get {
      return (delegate as? ChooWindowManager)?.windowId
    }
  }
  
  override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
    super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    let chooWindowManager = ChooWindowManager(self)
    delegate = chooWindowManager
  }
  
  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
      super.order(place, relativeTo: otherWin)
      hiddenWindowAtLaunch()
  }
}

open class ChooFlutterViewController: FlutterViewController {
  private var _windowId: Int64?
  public var windowId: Int64 {
    get {
      return _windowId ?? 0
    }
    set (value) {
      _windowId = value
    }
  }
}


func createWindow(args: [String: Any]) -> Int64? {
  if let RegisterGeneratedPlugins = ChooWindowManagerPlugin.RegisterGeneratedPlugins {
    let beforeWindowId: Int64 = args["beforeWindowId"] as! Int64
    let project = FlutterDartProject()
    let screen: NSScreen = (ChooWindowManager.windowMap[beforeWindowId]?.window.screen ?? NSApp.mainWindow?.screen ?? NSScreen.main)!
    let window = ChooWindow(
      contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
      styleMask: [.miniaturizable, .closable, .resizable, .titled],
      backing: .buffered,
      defer: false,
      screen: screen
    )
    let windowId = (window.delegate as? ChooWindowManager)!.windowId
    var commandLineArguments: [String: Any] = [:]
    commandLineArguments.merge(args) { (current, _) in current }
    
    if window.delegate is ChooWindowManager {
      (window.delegate as! ChooWindowManager).beforeWindowId = beforeWindowId
    }
    
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: commandLineArguments, options: .prettyPrinted)
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        project.dartEntrypointArguments = ["\(windowId)", jsonString]
      }
    } catch {
      project.dartEntrypointArguments = ["\(windowId)"]
    }
    let flutterViewController = ChooFlutterViewController(project: project)
    flutterViewController.windowId = windowId
    window.contentViewController = flutterViewController
    window.disableSnapshotRestoration()
    window.makeKeyAndOrderFront(nil)
    window.contentView?.translatesAutoresizingMaskIntoConstraints = true
    RegisterGeneratedPlugins(flutterViewController)
    return windowId
  }
  return nil
}

func closeWindows(_ windowIds: [Int64]?) {
  for id in (windowIds ?? Array(ChooWindowManager.windowMap.keys)) {
    if let wManager = ChooWindowManager.windowMap[id] {
      wManager.close()
    }
  }
}
