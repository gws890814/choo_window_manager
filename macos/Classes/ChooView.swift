//
//  ChooView.swift
//  choo_window_manager
//
//  Created by 龚文硕 on 2025/5/3.
//

import FlutterMacOS

/// NSWindow的扩展，提供窗口初始化时的隐藏功能
///
/// 该扩展主要用于控制窗口在启动时的可见性，防止窗口闪烁。
extension NSWindow {
  /// 在窗口启动时隐藏窗口
  ///
  /// 该方法确保窗口在初始化过程中保持隐藏状态，直到准备就绪。
  /// 它会检查窗口管理器的初始化状态，避免重复设置。
  public func hiddenWindowAtLaunch() {
    if delegate is ChooWindowManager && (delegate as! ChooWindowManager).isInit {
      return
    }
    if delegate is ChooWindowManager {
      (delegate as! ChooWindowManager).isInit = true
    }
    self.setIsVisible(false)
  }
}

open class ChooBaseWindow: NSWindow {
  private var trackingArea: NSTrackingArea?

  override open func awakeFromNib() {
    super.awakeFromNib()
    setupTrackingArea()
  }

  private func setupTrackingArea() {
    // 移除旧的 trackingArea（如果存在）
    if let oldArea = trackingArea {
      contentView?.removeTrackingArea(oldArea)
    }

    // 创建新的 trackingArea
    let options: NSTrackingArea.Options = [
      .mouseEnteredAndExited,
      .activeAlways,  // 即使窗口非活跃也监听
      .inVisibleRect,  // 只在可见区域跟踪
    ]

    trackingArea = NSTrackingArea(
      rect: .zero,
      options: options,
      owner: self,
      userInfo: nil
    )

    contentView?.addTrackingArea(trackingArea!)
  }

  // MARK: - 鼠标事件回调
  override open func mouseEntered(with event: NSEvent) {
    if styleMask.contains(.fullSizeContentView) && titlebarAppearsTransparent {
      isMovable = false
    }
  }

  override open func mouseExited(with event: NSEvent) {
    isMovable = true
  }

}

/// 自定义窗口类，继承自NSWindow
///
/// ChooWindow提供了与ChooWindowManager的集成，支持窗口标识和自定义行为。
class ChooWindow: ChooBaseWindow {
  /// 窗口的唯一标识符
  ///
  /// 通过窗口管理器获取的唯一ID，用于在多窗口环境中识别特定窗口。
  public var windowId: Int64? {
    return (delegate as? ChooWindowManager)?.windowId
  }

  /// 初始化一个新的ChooWindow实例
  ///
  /// - Parameters:
  ///   - contentRect: 窗口的内容区域
  ///   - style: 窗口的样式掩码
  ///   - backingStoreType: 窗口的背景存储类型
  ///   - flag: 是否延迟窗口创建
  override init(
    contentRect: NSRect, styleMask style: NSWindow.StyleMask,
    backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool
  ) {
    super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    let chooWindowManager = ChooWindowManager(self)
    delegate = chooWindowManager
  }

  /// 重写窗口排序方法
  ///
  /// 在窗口排序时确保正确处理窗口的可见性。
  ///
  /// - Parameters:
  ///   - place: 窗口的排序模式
  ///   - otherWin: 相对窗口的标识符
  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    hiddenWindowAtLaunch()
  }
}

/// Flutter视图控制器，用于管理窗口的Flutter内容
/// Flutter视图控制器，用于管理窗口的Flutter内容
///
/// 该类扩展了FlutterViewController，添加了窗口ID的支持，
/// 使其能够与窗口管理系统集成。
open class ChooFlutterViewController: FlutterViewController {
  /// 内部存储的窗口ID
  private var _windowId: Int64?

  /// 视图控制器关联的窗口ID
  ///
  /// 用于标识该视图控制器所属的窗口，默认为0
  public var windowId: Int64 {
    get {
      return _windowId ?? 0
    }
    set(value) {
      _windowId = value
    }
  }
}

/// 创建一个新的窗口
///
/// 该函数负责创建和配置新的ChooWindow实例，设置其Flutter内容和初始属性。
///
/// - Parameter args: 包含窗口创建参数的字典
/// - Returns: 新创建窗口的ID，如果创建失败则返回nil
func createWindow(args: [String: Any]) -> Int64? {
  if let RegisterGeneratedPlugins = ChooWindowManagerPlugin.RegisterGeneratedPlugins {
    let beforeWindowId: Int64 = args["beforeWindowId"] as! Int64
    let project = FlutterDartProject()
    let screen: NSScreen =
      (ChooWindowManager.windowMap[beforeWindowId]?.window.screen ?? NSApp.mainWindow?.screen
      ?? NSScreen.main)!
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
      let jsonData = try JSONSerialization.data(
        withJSONObject: commandLineArguments, options: .prettyPrinted)
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

/// 关闭指定的窗口或所有窗口
///
/// - Parameter windowIds: 要关闭的窗口ID数组，如果为nil则关闭所有窗口
func closeWindows(_ windowIds: [Int64]?) {
  for id in (windowIds ?? Array(ChooWindowManager.windowMap.keys)) {
    if let wManager = ChooWindowManager.windowMap[id] {
      wManager.close()
    }
  }
}
