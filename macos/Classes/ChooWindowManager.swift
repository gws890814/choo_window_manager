import Cocoa
import FlutterMacOS

let GetAnimationBehaviorMap: [Int: String] = [
  2: "none",
  3: "documentWindow",
  4: "utilityWindow",
  5: "alertPanel"
]

let SetAnimationBehaviorMap: [String: NSWindow.AnimationBehavior] = [
  "none": .none,
  "documentWindow": .documentWindow,
  "utilityWindow": .utilityWindow,
  "alertPanel": .alertPanel
]

let GetTitleBarStyleMap: [Int: String] = [
  0: "visible",
  1: "hidden"
]

let SetTitleBarStyleMap: [String: NSWindow.TitleVisibility] = [
  "hidden": .hidden,
  "visible": .visible
]

open class ChooWindowManager: NSObject, NSWindowDelegate {
  public let window: NSWindow
  public let windowId: Int64
  public var beforeWindowId: Int64?
  public var isInit: Bool = false
  public var globalChannel: FlutterMethodChannel?
  public var windowChannel: FlutterMethodChannel?
  public var windowReady: Bool = false
  public var listener: Bool = false
  private var interceptClose: Bool = false
  private var isMaximize: Bool = false
  private var panEvent: Any? = nil
  private var moveEvent: Any? = nil
  private var panStartPoint: CGPoint? = nil
  private var hoverIds: [Int64] = []

  public init(_ window: NSWindow) {
    windowId = ChooWindowManager.incrementid
    ChooWindowManager.incrementid += 1
    self.window = window
    super.init()
    ChooWindowManager.windowMap[windowId] = self
  }
  
  public func show() {
    window.setIsVisible(true)
    DispatchQueue.main.async {
      NSApp.activate(ignoringOtherApps: true)
      self.window.makeKeyAndOrderFront(nil)
      self.emitEvent("show", args: nil)
    }
  }
  
  public func hide() {
    DispatchQueue.main.async {
      self.window.orderOut(nil)
      self.emitEvent("hide", args: nil)
    }
  }
  
  public func focus() {
    NSApp.activate(ignoringOtherApps: false)
    window.makeKeyAndOrderFront(nil)
  }
  
  public func blur() {
    window.orderBack(nil)
  }
  
  public func close() {
    window.performClose(nil)
  }
  
  public func isVisible() -> Bool {
      return window.isVisible
  }
  
  public func isMaximized() -> Bool {
      return isMaximize
  }
  
  public func maximize() {
      if (!isMaximized()) {
        window.zoom(nil);
      }
  }
  
  public func unmaximize() {
      if (isMaximized()) {
        window.zoom(nil);
      }
  }
  
  public func isMinimized() -> Bool {
      return window.isMiniaturized
  }
  
  public func minimize() {
    window.miniaturize(nil)
  }
  
  public func restore() {
    window.deminiaturize(nil)
  }
  
  public func isFullScreen() -> Bool {
    return window.styleMask.contains(.fullScreen)
  }
  
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
  
  public func getSize() -> NSSize {
    return window.frame.size
  }
  
  public func setSize(args: [String: Any?]) {
    let animate: Bool = args["animate"] as? Bool ?? false
    let width: CGFloat = args["width"] as! CGFloat
    let height: CGFloat = args["height"] as! CGFloat
    var frameRect = window.frame
    
    frameRect.origin.y += (frameRect.size.height - height)
    frameRect.size.width = width
    frameRect.size.height = height
    if (animate) {
      window.animator().setFrame(frameRect, display: true, animate: true)
    } else {
      window.setFrame(frameRect, display: true)
    }
  }
  
  public func getMinSize() -> [String: Any] {
    return [
      "width": window.minSize.width,
      "height": window.minSize.height
    ]
  }
  
  public func setMinSize(args: [String: Any]) {
    let minSize: NSSize = NSSize(
      width: args["width"] as! CGFloat,
      height: args["height"] as! CGFloat
    )
    window.minSize = minSize
  }
  
  public func getMaxSize() -> [String: Any] {
    return [
      "width": window.maxSize.width,
      "height": window.maxSize.height
    ]
  }
  
  public func setMaxSize(args: [String: Any]) {
    let maxSize: NSSize = NSSize(
      width: args["width"] as! CGFloat,
      height: args["height"] as! CGFloat
    )
    window.maxSize = maxSize
  }
  
  public func getScreenSize() -> NSSize {
    guard let screen = window.screen ?? NSScreen.main else { return .zero }
    return screen.visibleFrame.size
  }
  
  public func center(args: [String: Any?]) {
    let animate: Bool = args["animate"] as? Bool ?? false
    let screen = (window.screen ?? NSScreen.main)!
    var frame = window.frame
    frame.origin.x = screen.visibleFrame.minX + (screen.visibleFrame.width - frame.width) / 2
    frame.origin.y = screen.visibleFrame.minY + (screen.visibleFrame.height - frame.height) / 2
    if (animate) {
      window.animator().setFrame(frame, display: true, animate: true)
    } else {
      window.setFrame(frame, display: true)
    }
  }
  
  public func getPosition(args: [String: Any]) -> [String: CGFloat]? {
    let global: Bool = args["global"] as? Bool ?? false
    let windowFrame = window.frame
    if (window.screen == nil) {
      return nil
    }
    if (global) {
      let allVisibleFrames = NSScreen.screens.map { $0.visibleFrame }
      let globalTop = allVisibleFrames.map { $0.maxY }.max() ?? 0
      
      let windowTop = windowFrame.origin.y + windowFrame.height
      let globalX = windowFrame.origin.x
      let globalY = globalTop - windowTop
      
      let screenHeight = window.screen!.visibleFrame.maxY
      let x = windowFrame.origin.x - window.screen!.visibleFrame.origin.x
      let y = screenHeight - (windowFrame.origin.y + windowFrame.height)

      return ["globalX": globalX, "globalY": globalY, "x": x, "y": y]
    }
    let screenHeight = window.screen!.visibleFrame.maxY
    let x = windowFrame.origin.x - window.screen!.visibleFrame.origin.x
    let y = screenHeight - (windowFrame.origin.y + windowFrame.height)
    return ["x": x, "y": y]
  }
  
  public func setPosition(args: [String: Any]) {
    let animate: Bool = args["animate"] as? Bool ?? false
    let global: Bool = args["global"] as? Bool ?? false
    let point: NSPoint = NSPoint(x: args["x"] as! CGFloat, y: args["y"] as! CGFloat)
    
    var targetFrame = window.frame
    targetFrame.origin = point // 先假设point是origin
    guard let currentScreen = window.screen ?? NSScreen.main else {
      print("屏幕都找不到")
      return
    }
    
    if global {
      let allVisibleFrames = NSScreen.screens.map { $0.visibleFrame }
      let globalTop = allVisibleFrames.map { $0.maxY }.max() ?? 0
      targetFrame.origin.x = point.x
      targetFrame.origin.y = globalTop - point.y - targetFrame.height
    } else {
      // 本地坐标系 → 当前屏幕可见区域转换
      let visibleFrame = currentScreen.visibleFrame
      
      // 计算窗口左上角在屏幕可见区域的位置
      targetFrame.origin.x = visibleFrame.origin.x + point.x
      let windowTop = visibleFrame.maxY - point.y
      targetFrame.origin.y = windowTop - targetFrame.height
    }
    
    // 执行动画或直接设置
    if animate {
        window.animator().setFrame(targetFrame, display: true)
    } else {
        window.setFrame(targetFrame, display: true)
    }
  }
  
  public func getBounds(args: [String: Any]) -> NSRect {
    let global: Bool = args["global"] as? Bool ?? false
    let size: NSSize = getSize()
    let point: [String: CGFloat] = getPosition(args: ["global": global])!
    return NSRect(x: (point["globalX"] ?? point["x"])!, y: (point["globalY"] ?? point["y"])!, width: size.width, height: size.height)
  }
  
  public func setBounds(args: [String: Any]) {
    // 直接访问非可选的 window，去他妈的条件绑定
    var newFrame = NSRect.zero
    newFrame.size = NSSize(width: args["width"] as! CGFloat, height: args["height"] as! CGFloat)
    
    let x = args["x"] as! CGFloat
    let y = args["y"] as! CGFloat
    let animate = args["animate"] as? Bool ?? false
    let global = args["global"] as? Bool ?? false
    
    // 直接获取当前屏幕（因为 window 非可选）
    let currentScreen = window.screen ?? NSScreen.main!
    
    if global {
      let allVisibleFrames = NSScreen.screens.map { $0.visibleFrame }
      let globalTop = allVisibleFrames.map { $0.maxY }.max() ?? 0
      newFrame.origin = NSPoint(
        x: x,
        y: globalTop - y - newFrame.height
      )
    } else {
      newFrame.origin = NSPoint(
        x: currentScreen.visibleFrame.origin.x + x,
        y: currentScreen.visibleFrame.maxY - y - newFrame.height
      )
    }
    
    // 直接设置 frame，不用判断 window 是否存在
    if animate {
      window.animator().setFrame(newFrame, display: true)
    } else {
      window.setFrame(newFrame, display: true)
    }
  }
  
  public func getTitle() -> String {
    return window.title
  }
  
  public func setTitle(args: [String: Any]) {
    let title: String = args["title"] as? String ?? ""
    window.title = title
  }
  
  public func getAnimationBehavior() -> String? {
    return GetAnimationBehaviorMap[window.animationBehavior.rawValue]
  }
  
  public func setAnimationBehavior(args: [String: Any]) {
    let animationBehaviorString = args["animationBehavior"] as? String ?? "default"
    let animationBehavior: NSWindow.AnimationBehavior = SetAnimationBehaviorMap[animationBehaviorString] ?? .default
    window.animationBehavior = animationBehavior
  }
  
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
  
  public func getTitleBarStyle() -> String {
    return GetTitleBarStyleMap[window.titleVisibility.rawValue]!
  }
  
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
  
  public func isMovable() -> Bool {
      return window.isMovable
  }
  
  public func setMovable(_ args: [String: Any]) {
      let isMovable: Bool = args["isMovable"] as! Bool
      window.isMovable = isMovable
  }
  
  public func getOpacity() -> CGFloat {
    return window.alphaValue
  }
  
  public func setOpacity(args: [String: Any]) {
    let opacity: CGFloat = args["opacity"] as! CGFloat
    window.alphaValue = opacity
  }
  
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
  
  public func removeListenHover(_ id: Int64) {
    if let index = hoverIds.firstIndex(of: id) {
      hoverIds.remove(at: index)
    }
    if nil != moveEvent && hoverIds.count == 0 {
      NSEvent.removeMonitor(moveEvent!)
      moveEvent = nil
    }
  }
  
  public func addPreListenPan(_ id: Int64) {
    addListenHover(id) { point in
      self.panStartPoint = point
    }
  }
  
  public func removePreListenPan(_ id: Int64) {
    removeListenHover(id)
  }
  
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
  
  public func removeListenPan() {
    if panEvent != nil {
      NSEvent.removeMonitor(panEvent!)
      panEvent = nil
    }
  }
  
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




extension ChooWindowManager {
  static private var incrementid: Int64 = 0
  static public var windowMap: [Int64: ChooWindowManager] = [:]
  
  static public func destroy() {
      NSApp.terminate(nil)
  }
}

extension ChooWindowManager {
  private struct AssociatedKeys {
      static var allowClosing: Bool? = nil
  }
  var allowClosing: Bool? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.allowClosing) as? Bool
    }
    set(value) {
      objc_setAssociatedObject(self, &AssociatedKeys.allowClosing, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
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
  public func emitGlobalEvent(_ eventName: String, args: [String: Any]?) {}
  
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
  
  public func windowDidMove(_ notification: Notification) {
    let point: [String: CGFloat]? = getPosition(args: ["global": true])
    if (point == nil) {
      return
    }
    emitEvent("move", args: point)
  }
  
  public func windowWillMove(_ notification: Notification) {
    let point: [String: CGFloat]? = getPosition(args: ["global": true])
    if (point == nil) {
      return
    }
    emitEvent("move", args: point)
  }
  
  public func windowDidBecomeMain(_ notification: Notification) {
    emitEvent("focus", args: nil);
  }
  
  public func windowDidResignMain(_ notification: Notification){
    emitEvent("blur", args: nil);
  }
  
  public func windowDidMiniaturize(_ notification: Notification) {
    emitEvent("minimize", args: nil);
  }
  
  public func windowDidDeminiaturize(_ notification: Notification) {
    emitEvent("restore", args: nil);
  }
  
  public func windowWillEnterFullScreen(_ notification: Notification){
    emitEvent("willEnterFullScreen", args: nil);
  }
  
  public func windowDidEnterFullScreen(_ notification: Notification){
    emitEvent("didEnterFullScreen", args: nil);
  }
  
  public func windowWillExitFullScreen(_ notification: Notification){
    emitEvent("willLeaveFullScreen", args: nil);
  }
  
  public func windowDidExitFullScreen(_ notification: Notification){
    emitEvent("didLeaveFullScreen", args: nil);
  }
  
  public func windowWillClose(_ notification: Notification) {
    emitEvent("close", args: nil)
  }
  
}
