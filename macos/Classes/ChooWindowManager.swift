//
//  ChooWindowManager.swift
//  choo_window_manager
//
//  Created by 龚文硕 on 2025/5/3.
//
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
  private var keyboardEventMonitor: Any? = nil

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
  
  public func close(_ force: Bool = false) {
    if force {
      window.close()
    } else { 
      window.performClose(nil)
    }
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
    applyFrameChange(frameRect: frameRect, animate: animate)
  }
  
  private func applyFrameChange(frameRect: NSRect, animate: Bool) {
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
    applyFrameChange(frameRect: frame, animate: animate)
  }
  
  public func getPosition(args: [String: Any]) -> [String: CGFloat]? {
    let global: Bool = args["global"] as? Bool ?? false
    let windowFrame = window.frame
    if (window.screen == nil) {
      return nil
    }
    
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
  
  public func setPosition(args: [String: Any]) {
    let animate: Bool = args["animate"] as? Bool ?? false
    let global: Bool = args["global"] as? Bool ?? false
    let point: NSPoint = NSPoint(x: args["x"] as! CGFloat, y: args["y"] as! CGFloat)
    
    var targetFrame = window.frame
    targetFrame.origin = calculateWindowOrigin(point: point, global: global, size: targetFrame.size)
    applyFrameChange(frameRect: targetFrame, animate: animate)
  }
  
  private func getGlobalTop() -> CGFloat {
    let allVisibleFrames = NSScreen.screens.map { $0.visibleFrame }
    return allVisibleFrames.map { $0.maxY }.max() ?? 0
  }
  
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
      let visibleFrame = currentScreen.visibleFrame
      
      origin.x = visibleFrame.origin.x + point.x
      let windowTop = visibleFrame.maxY - point.y
      origin.y = windowTop - size.height
    }
    
    return origin
  }
  
  public func getBounds(args: [String: Any]) -> NSRect {
    let global: Bool = args["global"] as? Bool ?? false
    let size: NSSize = getSize()
    let point: [String: CGFloat] = getPosition(args: ["global": global])!
    return NSRect(x: (point["globalX"] ?? point["x"])!, y: (point["globalY"] ?? point["y"])!, width: size.width, height: size.height)
  }
  
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

    var allScreensFrame = CGRect.zero
    NSScreen.screens.forEach { screen in
        allScreensFrame = allScreensFrame.union(screen.frame)
    }

    let globalX = mouseLocation.x - allScreensFrame.origin.x
    let globalY = (allScreensFrame.origin.y + allScreensFrame.height) - mouseLocation.y
    return [
      "x": globalX,
      "y": globalY
    ]
  }
  
  public func addHoverListener(_ id: Int64, _ callback: ((_ point: NSPoint) -> Void)? = nil) {
    if !hoverIds.contains(id) {
      hoverIds.append(id)
    }
    
    if let monitor = moveEvent {
      NSEvent.removeMonitor(monitor)
    }
    
    sendHoverEvent(callback)
    
    moveEvent = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
      guard let self = self else { return event }
      
      if self.processMouseEvent(callback) {
        return event
      } else {
        return event
      }
    }
  }
  
  private func processMouseEvent(_ callback: ((_ point: NSPoint) -> Void)? = nil) -> Bool {
    guard let contentView = window.contentView else { return false }
    
    let screenLocation = NSEvent.mouseLocation
    
    let windowLocation = window.convertPoint(fromScreen: screenLocation)
    
    let viewLocation = contentView.convert(windowLocation, from: nil)
    
    let flippedY = contentView.bounds.height - viewLocation.y
    let point = CGPoint(x: viewLocation.x, y: flippedY)
    
    if point.x < 0 || point.x > window.frame.width || 
       point.y < 0 || point.y > window.frame.height {
      return false
    }
    
    callback?(windowLocation)
    
    emitEvent("hover", args: ["x": point.x, "y": point.y])
    
    return true
  }
  
  private func sendHoverEvent(_ callback: ((_ point: NSPoint) -> Void)? = nil) {
    _ = processMouseEvent(callback)
  }
  
  public func removeHoverListener(_ id: Int64?) {
    if (id == nil) {
      hoverIds.removeAll()
      if let event = moveEvent {
        NSEvent.removeMonitor(event)
        moveEvent = nil
      }
      return
    }
    if let index = hoverIds.firstIndex(of: id!) {
      hoverIds.remove(at: index)
    }
    if nil != moveEvent && hoverIds.count == 0 {
      NSEvent.removeMonitor(moveEvent!)
      moveEvent = nil
    }
  }
  
  public func addPrePanListener(_ id: Int64) {
    addHoverListener(id) { point in
      self.panStartPoint = point
    }
  }
  
  public func removePrePanListener(_ id: Int64) {
    removeHoverListener(id)
  }
  
  public func addPanListener() -> [String: CGFloat] {
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
          location: windowLocation,
          modifierFlags: [.command],
          timestamp: CACurrentMediaTime(),
          windowNumber: self.window.windowNumber,
          context: nil,
          eventNumber: 0,
          clickCount: 1,
          pressure: 0.5
      ) else { return event }

      self.window.performDrag(with: event)
      self.windowChannel?.invokeMethod("pan", arguments: self.getPosition(args: ["global": true]))
      return event
    }
    return getPosition(args: ["global": true])!
  }
  
  public func removePanListener() {
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
    static var AllowKeyboard = UnsafeRawPointer(bitPattern: "AllowKeyboard".hashValue)!
  }

  var allowClosing: Bool? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.allowClosing) as? Bool
    }
    set(value) {
      objc_setAssociatedObject(self, &AssociatedKeys.allowClosing, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  var AllowKeyboard: NSEvent? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.AllowKeyboard) as? NSEvent
    }
    set(value) {
      objc_setAssociatedObject(self, &AssociatedKeys.AllowKeyboard, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  public func emitEvent(_ eventName: String, args: [String: Any?]?, callback: ((_ id: Int64, _ args: Any?) -> Void)? = nil) {
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
    addKeyboardEvent()
    emitEvent("focus", args: nil);
  }
  
  public func windowDidResignMain(_ notification: Notification) {
    removeKeyboardEvent()
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
  
  public func windowWillClose(_ notification: Notification) {
    removeKeyboardEvent()
    removeHoverListener(nil)
    
    emitEvent("close", args: nil)
  }
    
  private func addKeyboardEvent() {
    if keyboardEventMonitor != nil {
      removeKeyboardEvent()
    }
    
    keyboardEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
      guard let self = self else { return event }
      
      if self.AllowKeyboard == nil {
        var modifierFlags: [String] = []
        if event.modifierFlags.contains(.shift) {
          modifierFlags.append("shift")
        }
        if event.modifierFlags.contains(.control) {
          modifierFlags.append("control")
        }
        if event.modifierFlags.contains(.option) {
          modifierFlags.append("option")
        }
        if event.modifierFlags.contains(.command) {
          modifierFlags.append("command")
        }
        if event.modifierFlags.contains(.capsLock) {
          modifierFlags.append("capsLock")
        }
        if event.modifierFlags.contains(.function) {
          modifierFlags.append("function")
        }
        if event.modifierFlags.contains(.numericPad) {
          modifierFlags.append("numericPad")
        }
        if event.modifierFlags.contains(.help) {
          modifierFlags.append("help")
        }
        if event.modifierFlags.contains(.deviceIndependentFlagsMask) {
          modifierFlags.append("deviceIndependentFlagsMask")
        }
        
        emitEvent(
          "keyboard",
          args: [
            "keyCode": event.keyCode,
            "modifierFlags": modifierFlags,
            "characters": event.characters,
            "charactersIgnoringModifiers": event.charactersIgnoringModifiers
          ],
          callback: { id, args in
            if args as! Bool {
              self.AllowKeyboard = event
              NSApp.sendEvent(event)
            }
          }
        )
        return nil
      }
      
      self.AllowKeyboard = nil
      
      if event.modifierFlags.contains(.command) && event.keyCode == 13 {
        self.close()
        return nil
      }
      
      return event
    }
  }
  
  private func removeKeyboardEvent() {
    if let monitor = keyboardEventMonitor {
      NSEvent.removeMonitor(monitor)
      keyboardEventMonitor = nil
    }
  }
}
