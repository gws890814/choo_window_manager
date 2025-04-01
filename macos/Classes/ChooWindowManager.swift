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
  public var globalChannel: FlutterMethodChannel!
  public var windowChannel: FlutterMethodChannel!
  public var windowReady: Bool = false
  private var interceptClose: Bool = false
  
  public var beforeWindowManager: ChooWindowManager? {
    get {
      if beforeWindowId != nil {
        return ChooWindowManager.windowMap[beforeWindowId!]
      } else {
        return nil
      }
    }
  }

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
      self.window.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
    }
  }
  
  public func hide() {
    DispatchQueue.main.async {
      self.window.orderOut(nil)
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
    let screen = (beforeWindowManager?.window.screen ?? window.screen ?? NSScreen.main)!
    var frame = window.frame
    frame.origin.x = screen.visibleFrame.minX + (screen.visibleFrame.width - frame.width) / 2
    frame.origin.y = screen.visibleFrame.minY + (screen.visibleFrame.height - frame.height) / 2
    if (animate) {
      window.animator().setFrame(frame, display: true, animate: true)
    } else {
      window.setFrame(frame, display: true)
    }
  }
  
  public func getPosition() -> NSPoint {
    let windowFrame = window.frame
    let screenHeight = NSScreen.main!.visibleFrame.maxY
    let y = screenHeight - (windowFrame.origin.y + windowFrame.height)
    return NSPoint(x: windowFrame.origin.x, y: y)
  }
  
  public func setPosition(args: [String: Any]) {
    let animate: Bool = args["animate"] as? Bool ?? false
    guard let x = args["x"] as? CGFloat,
          let y = args["y"] as? CGFloat else {
      print("Invalid arguments: x or y missing or not CGFloat")
      return
    }
    let screen = (beforeWindowManager?.window.screen ?? window.screen ?? NSScreen.main)!
    var frame = window.frame
    
    frame.origin.x = screen.visibleFrame.origin.x + x
    frame.origin.y = screen.visibleFrame.maxY - y - frame.height
    
    if (animate) {
      window.animator().setFrame(frame, display: true, animate: true)
    } else {
      window.setFrame(frame, display: true)
    }
  }
  
  public func getBounds() -> NSRect {
      let frameRect: NSRect = window.frame;
    return NSRect(x: frameRect.topLeft.x, y: frameRect.topLeft.y, width: frameRect.size.width, height: frameRect.size.height)
  }
  
  public func setBounds(rect: NSRect, animate: Bool) {
    var frame: NSRect = window.frame;
    let width = rect.size.width;
    let height = rect.size.height;
    let x = rect.origin.x;
    let y = rect.origin.y;
    
    let screen = (beforeWindowManager?.window.screen ?? window.screen ?? NSScreen.main)!
    
    frame.size.width = width
    frame.size.height = height
    frame.origin.x = screen.visibleFrame.origin.x + x
    frame.origin.y = screen.visibleFrame.maxY - y - height
    if (animate) {
      window.animator().setFrame(frame, display: true, animate: true)
    } else {
      window.setFrame(frame, display: true)
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
      static var allowClosing: Bool = true
  }
  var allowClosing: Bool {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.allowClosing) as? Bool ?? true
    }
    set(value) {
      objc_setAssociatedObject(self, &AssociatedKeys.allowClosing, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  public func windowShouldClose(_ sender: NSWindow) -> Bool {
    if allowClosing {
      ChooWindowManager.windowMap.removeValue(forKey: windowId)
    }
    return allowClosing
  }
}
