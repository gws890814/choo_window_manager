import Cocoa
import FlutterMacOS

/// 窗口动画行为映射表，用于将整数值映射到对应的动画行为字符串
let GetAnimationBehaviorMap: [Int: String] = [
  2: "none",
  3: "documentWindow",
  4: "utilityWindow",
  5: "alertPanel"
]

/// 窗口动画行为映射表，用于将字符串映射到对应的NSWindow.AnimationBehavior枚举值
let SetAnimationBehaviorMap: [String: NSWindow.AnimationBehavior] = [
  "none": .none,
  "documentWindow": .documentWindow,
  "utilityWindow": .utilityWindow,
  "alertPanel": .alertPanel
]

/// 标题栏样式映射表，用于将整数值映射到对应的样式字符串
let GetTitleBarStyleMap: [Int: String] = [
  0: "visible",
  1: "hidden"
]

/// 标题栏样式映射表，用于将字符串映射到对应的NSWindow.TitleVisibility枚举值
let SetTitleBarStyleMap: [String: NSWindow.TitleVisibility] = [
  "hidden": .hidden,
  "visible": .visible
]

/// ChooWindowManager类负责管理macOS平台上的窗口操作和事件处理
/// 实现了窗口的显示、隐藏、最大化、最小化等基本功能，以及窗口事件的监听和处理
open class ChooWindowManager: NSObject, NSWindowDelegate {
  /// 当前管理的NSWindow实例
  public let window: NSWindow
  /// 窗口的唯一标识符
  public let windowId: Int64
  /// 前一个窗口的ID，用于窗口间的关联
  public var beforeWindowId: Int64?
  /// 标记窗口是否已初始化
  public var isInit: Bool = false
  /// 全局Flutter方法通道，用于处理全局窗口事件
  public var globalChannel: FlutterMethodChannel?
  /// 窗口特定的Flutter方法通道
  public var windowChannel: FlutterMethodChannel?
  /// 标记窗口是否准备就绪
  public var windowReady: Bool = false
  /// 标记是否启用事件监听
  public var listener: Bool = false
  /// 标记是否拦截窗口关闭事件
  private var interceptClose: Bool = false
  /// 标记窗口是否最大化
  private var isMaximize: Bool = false
  /// 平移事件监听器
  private var panEvent: Any? = nil
  /// 移动事件监听器
  private var moveEvent: Any? = nil
  /// 平移开始时的点位置
  private var panStartPoint: CGPoint? = nil
  /// 悬停事件ID列表
  private var hoverIds: [Int64] = []

  /// 初始化窗口管理器
  /// - Parameter window: 要管理的NSWindow实例
  public init(_ window: NSWindow) {
    windowId = ChooWindowManager.incrementid
    ChooWindowManager.incrementid += 1
    self.window = window
    super.init()
    ChooWindowManager.windowMap[windowId] = self
  }
  
  /// 显示窗口并使其成为主窗口
  public func show() {
    window.setIsVisible(true)
    DispatchQueue.main.async {
      NSApp.activate(ignoringOtherApps: true)
      self.window.makeKeyAndOrderFront(nil)
      self.emitEvent("show", args: nil)
    }
  }
  
  /// 隐藏窗口
  public func hide() {
    DispatchQueue.main.async {
      self.window.orderOut(nil)
      self.emitEvent("hide", args: nil)
    }
  }
  
  /// 使窗口获得焦点
  public func focus() {
    NSApp.activate(ignoringOtherApps: false)
    window.makeKeyAndOrderFront(nil)
  }
  
  /// 使窗口失去焦点
  public func blur() {
    window.orderBack(nil)
  }
  
  /// 关闭窗口
  public func close() {
    window.performClose(nil)
  }
  
  /// 检查窗口是否可见
  /// - Returns: 窗口可见状态
  public func isVisible() -> Bool {
      return window.isVisible
  }
  
  /// 检查窗口是否最大化
  /// - Returns: 窗口最大化状态
  public func isMaximized() -> Bool {
      return isMaximize
  }
  
  /// 最大化窗口
  public func maximize() {
      if (!isMaximized()) {
        window.zoom(nil);
      }
  }
  
  /// 还原窗口大小
  public func unmaximize() {
      if (isMaximized()) {
        window.zoom(nil);
      }
  }
  
  /// 检查窗口是否最小化
  /// - Returns: 窗口最小化状态
  public func isMinimized() -> Bool {
      return window.isMiniaturized
  }
  
  /// 最小化窗口
  public func minimize() {
    window.miniaturize(nil)
  }
  
  /// 从最小化状态恢复窗口
  public func restore() {
    window.deminiaturize(nil)
  }
  
  /// 检查窗口是否全屏
  /// - Returns: 窗口全屏状态
  public func isFullScreen() -> Bool {
    return window.styleMask.contains(.fullScreen)
  }
  
  /// 设置窗口全屏状态
  /// - Parameter args: 包含isFullScreen参数的字典
  public func setFullScreen(args: [String: Any]) {
    let isFullScreen: Bool = args["isFullScreen"] as! Bool
    
    if (isFullScreen) {
      if (!window.styleMask.contains(.fullScreen)) {
        window.toggleFullScreen(nil)
      }
    } else {
      if (window.styleMask.contains(.fullScreen)) {
        window.toggleFullScreen(nil)
      }
    }
  }
  
  /// 获取窗口大小
  /// - Returns: 窗口的尺寸
  public func getSize() -> NSSize {
    return window.frame.size
  }
  
  /// 设置窗口大小
  /// - Parameter args: 包含width、height和animate参数的字典
  public func setSize(args: [String: Any?]) {
    let animate: Bool = args["animate"] as? Bool ?? false
    let width: CGFloat = args["width"] as! CGFloat
    let height: CGFloat = args["height"] as! CGFloat
    var frameRect = window.frame
    
    frameRect.origin.y += (frameRect.size.height - height)
    frameRect.size.width = width
    frameRect.size.height = height
    applyFrameChange(frameRect: frameRect, animate: animate)
  }
  
  /// 应用窗口框架变更
  /// - Parameters:
  ///   - frameRect: 新的窗口框架矩形
  ///   - animate: 是否使用动画
  private func applyFrameChange(frameRect: NSRect, animate: Bool) {
    if (animate) {
      window.animator().setFrame(frameRect, display: true, animate: true)
    } else {
      window.setFrame(frameRect, display: true)
    }
  }
  
  /// 获取窗口最小尺寸
  /// - Returns: 包含width和height的字典
  public func getMinSize() -> [String: Any] {
    return [
      "width": window.minSize.width,
      "height": window.minSize.height
    ]
  }
  
  /// 设置窗口最小尺寸
  /// - Parameter args: 包含width和height参数的字典
  public func setMinSize(args: [String: Any]) {
    let minSize: NSSize = NSSize(
      width: args["width"] as! CGFloat,
      height: args["height"] as! CGFloat
    )
    window.minSize = minSize
  }
  
  /// 获取窗口最大尺寸
  /// - Returns: 包含width和height的字典
  public func getMaxSize() -> [String: Any] {
    return [
      "width": window.maxSize.width,
      "height": window.maxSize.height
    ]
  }
  
  /// 设置窗口最大尺寸
  /// - Parameter args: 包含width和height参数的字典
  public func setMaxSize(args: [String: Any]) {
    let maxSize: NSSize = NSSize(
      width: args["width"] as! CGFloat,
      height: args["height"] as! CGFloat
    )
    window.maxSize = maxSize
  }
  
  /// 获取屏幕可见区域大小
  /// - Returns: 屏幕的可见区域尺寸
  public func getScreenSize() -> NSSize {
    guard let screen = window.screen ?? NSScreen.main else { return .zero }
    return screen.visibleFrame.size
  }
  
  /// 将窗口居中显示
  /// - Parameter args: 包含animate参数的字典
  public func center(args: [String: Any?]) {
    let animate: Bool = args["animate"] as? Bool ?? false
    let screen = (window.screen ?? NSScreen.main)!
    var frame = window.frame
    frame.origin.x = screen.visibleFrame.minX + (screen.visibleFrame.width - frame.width) / 2
    frame.origin.y = screen.visibleFrame.minY + (screen.visibleFrame.height - frame.height) / 2
    applyFrameChange(frameRect: frame, animate: animate)
  }
  
  /// 获取窗口位置
  /// - Parameter args: 包含global参数的字典，决定是否返回全局坐标
  /// - Returns: 包含窗口位置信息的字典
  public func getPosition(args: [String: Any]) -> [String: CGFloat]? {
    let global: Bool = args["global"] as? Bool ?? false
    let windowFrame = window.frame
    if (window.screen == nil) {
      return nil
    }
    
    // 计算本地坐标
    let screenHeight = window.screen!.visibleFrame.maxY
    let x = windowFrame.origin.x - window.screen!.visibleFrame.origin.x
    let y = screenHeight - (windowFrame.origin.y + windowFrame.height)
    
    if (global) {
      let globalTop = getGlobalTop()
      let windowTop = windowFrame.origin.y + windowFrame.height
      let globalX = windowFrame.origin.x
      let globalY = globalTop - windowTop

      return ["globalX": globalX, "globalY": globalY, "x": x, "y": y]
    }
    
    return ["x": x, "y": y]
  }
  
  /// 设置窗口位置
  /// - Parameter args: 包含x、y、animate和global参数的字典
  public func setPosition(args: [String: Any]) {
    let animate: Bool = args["animate"] as? Bool ?? false
    let global: Bool = args["global"] as? Bool ?? false
    let point: NSPoint = NSPoint(x: args["x"] as! CGFloat, y: args["y"] as! CGFloat)
    
    var targetFrame = window.frame
    targetFrame.origin = calculateWindowOrigin(point: point, global: global, size: targetFrame.size)
    applyFrameChange(frameRect: targetFrame, animate: animate)
  }
  
  /// 获取全局坐标系中的顶部位置
  /// - Returns: 所有屏幕可见区域的最大Y值
  private func getGlobalTop() -> CGFloat {
    let allVisibleFrames = NSScreen.screens.map { $0.visibleFrame }
    return allVisibleFrames.map { $0.maxY }.max() ?? 0
  }
  
  /// 计算窗口原点位置
  /// - Parameters:
  ///   - point: 输入的点坐标
  ///   - global: 是否使用全局坐标系
  ///   - size: 窗口大小
  /// - Returns: 计算后的窗口原点位置
  private func calculateWindowOrigin(point: NSPoint, global: Bool, size: NSSize) -> NSPoint {
    guard let currentScreen = window.screen ?? NSScreen.main else {
      print("屏幕都找不到")
      return .zero
    }
    
    var origin = NSPoint.zero
    
    if global {
      let globalTop = getGlobalTop()
      origin.x = point.x
      origin.y = globalTop - point.y - size.height
    } else {
      // 本地坐标系 → 当前屏幕可见区域转换
      let visibleFrame = currentScreen.visibleFrame
      
      // 计算窗口左上角在屏幕可见区域的位置
      origin.x = visibleFrame.origin.x + point.x
      let windowTop = visibleFrame.maxY - point.y
      origin.y = windowTop - size.height
    }
    
    return origin
  }
  
  /// 获取窗口边界
  /// - Parameter args: 包含global参数的字典
  /// - Returns: 窗口的边界矩形
  public func getBounds(args: [String: Any]) -> NSRect {
    let global: Bool = args["global"] as? Bool ?? false
    let size: NSSize = getSize()
    let point: [String: CGFloat] = getPosition(args: ["global": global])!
    return NSRect(x: (point["globalX"] ?? point["x"])!, y: (point["globalY"] ?? point["y"])!, width: size.width, height: size.height)
  }
  
  /// 设置窗口边界
  /// - Parameter args: 包含x、y、width、height、animate和global参数的字典
  public func setBounds(args: [String: Any]) {
    var newFrame = NSRect.zero
    newFrame.size = NSSize(width: args["width"] as! CGFloat, height: args["height"] as! CGFloat)
    
    let x = args["x"] as! CGFloat
    let y = args["y"] as! CGFloat
    let animate = args["animate"] as? Bool ?? false
    let global = args["global"] as? Bool ?? false
    
    let point = NSPoint(x: x, y: y)
    newFrame.origin = calculateWindowOrigin(point: point, global: global, size: newFrame.size)
    applyFrameChange(frameRect: newFrame, animate: animate)
  }
  
  /// 获取窗口标题
  /// - Returns: 窗口的标题文本
  public func getTitle() -> String {
    return window.title
  }
  
  /// 设置窗口标题
  /// - Parameter args: 包含title参数的字典
  public func setTitle(args: [String: Any]) {
    let title: String = args["title"] as? String ?? ""
    window.title = title
  }
  
  /// 获取窗口动画行为
  /// - Returns: 动画行为的字符串描述
  public func getAnimationBehavior() -> String? {
    return GetAnimationBehaviorMap[window.animationBehavior.rawValue]
  }
  
  /// 设置窗口动画行为
  /// - Parameter args: 包含animationBehavior参数的字典
  public func setAnimationBehavior(args: [String: Any]) {
    let animationBehaviorString = args["animationBehavior"] as? String ?? "default"
    let animationBehavior: NSWindow.AnimationBehavior = SetAnimationBehaviorMap[animationBehaviorString] ?? .default
    window.animationBehavior = animationBehavior
  }
  
  /// 将窗口设置为无边框样式
  public func setAsFrameless() {
    window.styleMask.insert(.fullSizeContentView)
    window.titleVisibility = .hidden
    window.isOpaque = true
    window.hasShadow = false
    window.backgroundColor = NSColor.clear
    if (window.styleMask.contains(.titled)) {
      let titleBarView: NSView = (window.standardWindowButton(.closeButton)?.superview)!.superview!
      titleBarView.isHidden = true
    }
  }
  
  /// 获取标题栏样式
  /// - Returns: 标题栏样式的字符串描述
  public func getTitleBarStyle() -> String {
    return GetTitleBarStyleMap[window.titleVisibility.rawValue]!
  }
  
  /// 设置标题栏样式
  /// - Parameter args: 包含titleBarStyle参数的字典
  public func setTitleBarStyle(args: [String: Any]) {
    let titleBarStyle: NSWindow.TitleVisibility = SetTitleBarStyleMap[args["titleBarStyle"] as! String] ?? .visible
    window.titleVisibility = titleBarStyle
    if (titleBarStyle == .hidden) {
      window.titlebarAppearsTransparent = true
      window.styleMask.insert(.fullSizeContentView)
      setMovable(["isMovable": false])
    } else {
      window.titlebarAppearsTransparent = false
      window.styleMask.remove(.fullSizeContentView)
      setMovable(["isMovable": true])
    }
    
    window.isOpaque = false
    window.hasShadow = true
  }
  
  /// 检查窗口是否可移动
  /// - Returns: 窗口可移动状态
  public func isMovable() -> Bool {
      return window.isMovable
  }
  
  /// 设置窗口是否可移动
  /// - Parameter args: 包含isMovable参数的字典
  public func setMovable(_ args: [String: Any]) {
      let isMovable: Bool = args["isMovable"] as! Bool
      window.isMovable = isMovable
  }
  
  /// 获取窗口透明度
  /// - Returns: 窗口的透明度值（0.0-1.0）
  public func getOpacity() -> CGFloat {
    return window.alphaValue
  }
  
  /// 设置窗口透明度
  /// - Parameter args: 包含opacity参数的字典
  public func setOpacity(args: [String: Any]) {
    let opacity: CGFloat = args["opacity"] as! CGFloat
    window.alphaValue = opacity
  }
  
  /// 获取鼠标位置
  /// - Returns: 包含x和y坐标的字典
  public func getMousePoint() -> [String: CGFloat] {
    let mouseLocation = NSEvent.mouseLocation

    // 计算所有屏幕的联合虚拟桌面范围（兼容各种奇葩屏幕排列）
    var allScreensFrame = CGRect.zero
    NSScreen.screens.forEach { screen in
        allScreensFrame = allScreensFrame.union(screen.frame)
    }

    // 转换为全屏幕左上角原点坐标系（Y轴反向）
    let globalX = mouseLocation.x - allScreensFrame.origin.x
    let globalY = (allScreensFrame.origin.y + allScreensFrame.height) - mouseLocation.y
    return [
      "x": globalX,
      "y": globalY
    ]
  }
  
  /// 添加鼠标悬停事件监听
  /// - Parameters:
  ///   - id: 监听器ID
  ///   - callback: 鼠标位置变化的回调函数
  public func addListenHover(_ id: Int64, _ callback: ((_ point: NSPoint) -> Void)? = nil) {
    // 监听所有鼠标事件（移动、拖拽、进入/离开窗口
    if !hoverIds.contains(id) {
      hoverIds.append(id)
    }
    if let monitor = moveEvent {
      NSEvent.removeMonitor(monitor)
    }
    let wManager = self
    moveEvent = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
      guard let window = self?.window else { return event }
        // 获取鼠标在窗口内的坐标（左下角为原点）
      let screenLocation = NSEvent.mouseLocation
      let windowLocation = window.convertPoint(fromScreen: screenLocation)
      // 转换为内容视图坐标系（左上角为原点）
      if let contentView = window.contentView {
        let viewLocation = contentView.convert(windowLocation, from: nil)
        let flippedY = contentView.bounds.height - viewLocation.y
        let point = CGPoint(x: viewLocation.x, y: flippedY)
        if point.x < 0 || point.x > wManager.window.frame.width || point.y < 0 || point.y > wManager.window.frame.height {
          return event
        }
        if callback != nil {
          callback!(windowLocation)
        }
        wManager.windowChannel?.invokeMethod("hover", arguments: ["x": point.x, "y": point.y])
      }
      return event
    }
  }
  
  /// 移除鼠标悬停事件监听
  /// - Parameter id: 要移除的监听器ID
  public func removeListenHover(_ id: Int64) {
    if let index = hoverIds.firstIndex(of: id) {
      hoverIds.remove(at: index)
    }
    if nil != moveEvent && hoverIds.count == 0 {
      NSEvent.removeMonitor(moveEvent!)
      moveEvent = nil
    }
  }
  
  /// 添加预平移事件监听
  /// - Parameter id: 监听器ID
  public func addPreListenPan(_ id: Int64) {
    addListenHover(id) { point in
      self.panStartPoint = point
    }
  }
  
  /// 移除预平移事件监听
  /// - Parameter id: 要移除的监听器ID
  public func removePreListenPan(_ id: Int64) {
    removeListenHover(id)
  }
  
  /// 添加平移事件监听
  /// - Returns: 包含初始位置信息的字典
  public func addListenPan() -> [String: CGFloat] {
    panEvent = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDragged]) { event in
      var windowLocation: CGPoint
      if self.panStartPoint == nil {
        let screenLocation = NSEvent.mouseLocation
        let windowFrame = self.window.frame
        windowLocation = NSPoint(
          x: screenLocation.x - windowFrame.origin.x,
          y: screenLocation.y - windowFrame.origin.y
        )
      } else {
        windowLocation = self.panStartPoint!
      }
      guard let event = NSEvent.mouseEvent(
          with: .leftMouseDragged,
          location: windowLocation, // 窗口内坐标（左下角为原点）
          modifierFlags: [.command], // 按下 Command 键
          timestamp: CACurrentMediaTime(), // 精准时间戳
          windowNumber: self.window.windowNumber,
          context: nil,
          eventNumber: 0,
          clickCount: 1,
          pressure: 0.5 // 中等压力值
      ) else { return event }

      // 触发拖拽
      self.window.performDrag(with: event)
      self.windowChannel?.invokeMethod("pan", arguments: self.getPosition(args: ["global": true]))
      return event
    }
    return getPosition(args: ["global": true])!
  }
  
  /// 移除平移事件监听
  public func removeListenPan() {
    if panEvent != nil {
      NSEvent.removeMonitor(panEvent!)
      panEvent = nil
    }
  }
  
  /// 发送窗口事件
  /// - Parameters:
  ///   - args: 包含targetId、id、method和arguments参数的字典
  ///   - callback: 事件处理完成的回调函数
  public func windowEmit(args: [String: Any], callback: @escaping (_ windowId: Int64, _ args: Any?) -> Void) {
    let targetId: Int64 = args["targetId"] as! Int64
    let sourceId: Int64 = args["id"] as! Int64
    if let target = ChooWindowManager.windowMap[targetId] {
      let method: String = args["method"] as! String
      let arguments: [String : Any] = ["method": method, "id": sourceId, "arguments": args["arguments"] as Any]
      target.emitEvent("event", args: arguments, callback: callback)
    }
  }
}




/// ChooWindowManager的静态属性和方法扩展
extension ChooWindowManager {
  /// 用于生成唯一的窗口ID
  static private var incrementid: Int64 = 0
  /// 存储所有窗口管理器实例的映射表
  static public var windowMap: [Int64: ChooWindowManager] = [:]
  
  /// 销毁应用程序
  static public func destroy() {
      NSApp.terminate(nil)
  }
}

/// ChooWindowManager的事件处理扩展
extension ChooWindowManager {
  /// 用于存储运行时属性的键
  private struct AssociatedKeys {
    /// 是否允许关闭窗口的标记
    static var allowClosing: Bool? = nil
    /// 是否允许缩小窗口的标记
    static var AllowShrinking: Bool? = nil
  }
  /// 控制窗口是否允许关闭的属性
  var allowClosing: Bool? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.allowClosing) as? Bool
    }
    set(value) {
      objc_setAssociatedObject(self, &AssociatedKeys.allowClosing, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  /// 发送窗口事件
  /// - Parameters:
  ///   - eventName: 事件名称
  ///   - args: 事件参数
  ///   - callback: 事件处理完成的回调函数
  public func emitEvent(_ eventName: String, args: [String: Any]?, callback: ((_ id: Int64, _ args: Any?) -> Void)? = nil) {
    if !listener {
      return
    }
    windowChannel?.invokeMethod(eventName, arguments: args) { result in
      if let callback = callback {
        callback(self.windowId, result)
      }
    }
  }
  /// 发送全局事件
  /// - Parameters:
  ///   - eventName: 事件名称
  ///   - args: 事件参数
  public func emitGlobalEvent(_ eventName: String, args: [String: Any]?) {}
  
  /// 处理窗口大小改变事件
  /// - Parameter notification: 通知对象
  public func windowDidResize(_ notification: Notification) {
    let size: NSSize = getSize()
    emitEvent("resize", args: ["width": size.width, "height": size.height])
    if (!isMaximize && window.isZoomed) {
      isMaximize = true
      emitEvent("maximize", args: nil)
    }
    if (isMaximize && !window.isZoomed) {
      isMaximize = false
      emitEvent("unmaximize", args: nil)
    }
    
  }
  
  /// 处理窗口移动完成事件
  /// - Parameter notification: 通知对象
  public func windowDidMove(_ notification: Notification) {
    let point: [String: CGFloat]? = getPosition(args: ["global": true])
    if (point == nil) {
      return
    }
    emitEvent("move", args: point)
  }
  
  /// 处理窗口即将移动事件
  /// - Parameter notification: 通知对象
  public func windowWillMove(_ notification: Notification) {
    let point: [String: CGFloat]? = getPosition(args: ["global": true])
    if (point == nil) {
      return
    }
    emitEvent("move", args: point)
  }
  
  /// 处理窗口成为主窗口事件
  /// - Parameter notification: 通知对象
  public func windowDidBecomeMain(_ notification: Notification) {
    emitEvent("focus", args: nil);
  }
  
  /// 处理窗口失去主窗口状态事件
  /// - Parameter notification: 通知对象
  public func windowDidResignMain(_ notification: Notification) {
    emitEvent("blur", args: nil);
  }
  
  /// 处理窗口最小化事件
  /// - Parameter notification: 通知对象
  public func windowDidMiniaturize(_ notification: Notification) {
    emitEvent("minimize", args: nil);
  }
  
  /// 处理窗口从最小化恢复事件
  /// - Parameter notification: 通知对象
  public func windowDidDeminiaturize(_ notification: Notification) {
    emitEvent("restore", args: nil);
  }
  
  /// 处理窗口即将进入全屏事件
  /// - Parameter notification: 通知对象
  public func windowWillEnterFullScreen(_ notification: Notification){
    emitEvent("willEnterFullScreen", args: nil);
  }
  
  /// 处理窗口已进入全屏事件
  /// - Parameter notification: 通知对象
  public func windowDidEnterFullScreen(_ notification: Notification){
    emitEvent("didEnterFullScreen", args: nil);
  }
  
  /// 处理窗口即将退出全屏事件
  /// - Parameter notification: 通知对象
  public func windowWillExitFullScreen(_ notification: Notification){
    emitEvent("willLeaveFullScreen", args: nil);
  }
  
  /// 处理窗口已退出全屏事件
  /// - Parameter notification: 通知对象
  public func windowDidExitFullScreen(_ notification: Notification){
    emitEvent("didLeaveFullScreen", args: nil);
  }
  
  /// 处理窗口是否应该关闭的事件
  /// - Parameter sender: 发送事件的窗口
  /// - Returns: 是否允许关闭窗口
  public func windowShouldClose(_ sender: NSWindow) -> Bool {
    if allowClosing == nil {
      emitEvent("willClose", args: nil, callback: { id, arguments in
        self.allowClosing = arguments as? Bool
        self.close()
      })
      return false
    } else {
      let isClose = allowClosing!
      allowClosing = nil
      return isClose
    }
  }
  
  /// 处理窗口即将关闭事件
  /// - Parameter notification: 通知对象
  public func windowWillClose(_ notification: Notification) {
    emitEvent("close", args: nil)
  }
  
}
