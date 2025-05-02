import FlutterMacOS

/// NSWindow的扩展，提供窗口启动时的隐藏功能
extension NSWindow {
  /// 在窗口启动时隐藏窗口
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

/// 自定义窗口类，继承自NSWindow，提供窗口ID和初始化功能
class ChooWindow: NSWindow {
  /// 窗口的唯一标识符
  public var windowId: Int64? {
    get {
      return (delegate as? ChooWindowManager)?.windowId
    }
  }
  
  /// 初始化窗口
  /// - Parameters:
  ///   - contentRect: 窗口内容区域的尺寸和位置
  ///   - style: 窗口样式掩码
  ///   - backingStoreType: 窗口的后备存储类型
  ///   - flag: 是否延迟创建窗口
  override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
    super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    let chooWindowManager = ChooWindowManager(self)
    delegate = chooWindowManager
  }
  
  /// 重写窗口排序方法，在窗口显示时调用隐藏方法
  /// - Parameters:
  ///   - place: 窗口排序模式
  ///   - otherWin: 相对窗口的编号
  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
      super.order(place, relativeTo: otherWin)
      hiddenWindowAtLaunch()
  }
}

/// Flutter视图控制器，用于管理窗口的Flutter内容
open class ChooFlutterViewController: FlutterViewController {
  /// 内部存储的窗口ID
  private var _windowId: Int64?
  /// 窗口的唯一标识符
  public var windowId: Int64 {
    get {
      return _windowId ?? 0
    }
    set (value) {
      _windowId = value
    }
  }
}

/// 创建新窗口
/// - Parameter args: 包含窗口创建参数的字典
/// - Returns: 新创建窗口的ID，如果创建失败则返回nil
func createWindow(args: [String: Any]) -> Int64? {
//  if (ChooWindowManager.windowMap.keys.count > 1) {
//    // 创建一个Command+W组合键事件
//    let event = NSEvent.keyEvent(
//        with: .keyDown,                // 事件类型：按键按下
//        location: NSPoint.zero,        // 事件位置
//        modifierFlags: [.command],       // 修饰键：Command
//        timestamp: ProcessInfo.processInfo.systemUptime,
//        windowNumber: 0,
//        context: nil,
//        characters: "w",               // 字符
//        charactersIgnoringModifiers: "w",
//        isARepeat: false,
//        keyCode: 13                    // W键的键码是13
//    )
//    NSApp.sendEvent(event!)
//
//    return nil
//  }
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
    window.isMovableByWindowBackground = true
    window.makeKeyAndOrderFront(nil)
    RegisterGeneratedPlugins(flutterViewController)
    return windowId
  }
  return nil
}

/// 关闭指定的窗口
/// - Parameter windowIds: 要关闭的窗口ID数组，如果为nil则关闭所有窗口
func closeWindows(_ windowIds: [Int64]?) {
  for id in (windowIds ?? Array(ChooWindowManager.windowMap.keys)) {
    if let wManager = ChooWindowManager.windowMap[id] {
      wManager.close()
    }
  }
}
