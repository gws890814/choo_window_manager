//
//  ChooWindowManager.swift
//  choo_window_manager
//
//  Created by 龚文硕 on 2025/5/3.
//
import Cocoa
import FlutterMacOS

/// 窗口动画行为映射表（获取）
/// 用于将整数值映射到对应的动画行为字符串
let GetAnimationBehaviorMap: [Int: String] = [
  2: "none",
  3: "documentWindow",
  4: "utilityWindow",
  5: "alertPanel",
]

/// 窗口动画行为映射表（设置）
/// 用于将字符串映射到对应的NSWindow.AnimationBehavior枚举值
let SetAnimationBehaviorMap: [String: NSWindow.AnimationBehavior] = [
  "none": .none,
  "documentWindow": .documentWindow,
  "utilityWindow": .utilityWindow,
  "alertPanel": .alertPanel,
]

/// 标题栏样式映射表（获取）
/// 用于将整数值映射到对应的标题栏可见性字符串
let GetTitleBarStyleMap: [Int: String] = [
  0: "visible",
  1: "hidden",
]

/// 标题栏样式映射表（设置）
/// 用于将字符串映射到对应的NSWindow.TitleVisibility枚举值
let SetTitleBarStyleMap: [String: NSWindow.TitleVisibility] = [
  "hidden": .hidden,
  "visible": .visible,
]

/// ChooWindowManager 是窗口管理器的核心类
///
/// 该类负责管理macOS窗口的生命周期和行为，实现了以下主要功能：
/// - 窗口的显示、隐藏、关闭等基本操作
/// - 窗口大小和位置的调整
/// - 窗口样式和动画行为的控制
/// - 事件监听和处理
/// - 与Flutter层的通信
open class ChooWindowManager: NSObject, NSWindowDelegate {
  /// 管理的窗口实例
  public let window: NSWindow

  /// 窗口的唯一标识符
  public let windowId: Int64

  /// 创建此窗口前的窗口ID
  public var beforeWindowId: Int64?

  /// 窗口是否已完成初始化
  public var isInit: Bool = false

  /// 全局方法通道，用于处理应用级别的操作
  public var globalChannel: FlutterMethodChannel?

  /// 窗口专用方法通道，用于处理特定窗口的操作
  public var windowChannel: FlutterMethodChannel?

  /// 窗口是否已准备就绪
  public var windowReady: Bool = false

  /// 是否已添加事件监听器
  public var listener: Bool = false

  /// 是否拦截窗口关闭事件
  private var interceptClose: Bool = false

  /// 窗口是否处于最大化状态
  private var isMaximize: Bool = false

  /// 拖拽事件监听器
  private var panEvent: Any? = nil

  /// 移动事件监听器
  private var moveEvent: Any? = nil

  /// 拖拽开始时的坐标点
  private var panStartPoint: CGPoint? = nil

  /// 悬停事件ID列表
  private var hoverIds: [String] = []

  /// 键盘事件监听器
  private var keyboardEventMonitor: Any? = nil

  private var customTitleBar: ChooWindowOperationButtonManager? = nil

  public init(_ window: NSWindow) {
    windowId = ChooWindowManager.incrementid
    ChooWindowManager.incrementid += 1
    self.window = window
    super.init()
    ChooWindowManager.windowMap[windowId] = self
  }

  /// 显示窗口
  ///
  /// 该方法会执行以下操作：
  /// 1. 设置窗口为可见状态
  /// 2. 激活应用程序并将窗口置于前台
  /// 3. 发送显示事件通知
  ///
  /// 窗口显示过程在主线程异步执行，以确保UI操作的线程安全
  public func show() {
    window.setIsVisible(true)
    DispatchQueue.main.async {
      NSApp.activate(ignoringOtherApps: true)
      self.window.makeKeyAndOrderFront(nil)
      self.emitEvent("show", args: nil)
    }
  }

  /// 隐藏窗口
  ///
  /// 该方法会异步执行以下操作：
  /// 1. 将窗口从屏幕上移除
  /// 2. 发送隐藏事件通知
  ///
  /// 窗口隐藏过程在主线程异步执行，以确保UI操作的线程安全
  public func hide() {
    DispatchQueue.main.async {
      self.window.orderOut(nil)
      self.emitEvent("hide", args: nil)
    }
  }

  /// 使窗口获得焦点
  ///
  /// 该方法会执行以下操作：
  /// 1. 激活应用程序（不忽略其他应用）
  /// 2. 将窗口设置为主窗口并置于前台
  public func focus() {
    NSApp.activate(ignoringOtherApps: false)
    window.makeKeyAndOrderFront(nil)
  }

  /// 使窗口失去焦点
  ///
  /// 该方法会将窗口移到窗口栈的最后面，
  /// 使其失去焦点并可能被其他窗口遮挡
  public func blur() {
    window.orderBack(nil)
  }

  /// 关闭窗口
  ///
  /// - Parameters:
  ///   - force: 是否强制关闭窗口
  ///     - true: 直接关闭窗口，不触发关闭确认
  ///     - false: 执行正常的关闭流程，可能会触发关闭确认
  public func close(_ force: Bool = false) {
    if force {
      window.close()
    } else {
      window.performClose(nil)
    }
  }

  /// 获取窗口的可见状态
  ///
  /// - Returns: 布尔值
  ///   - true: 窗口当前可见
  ///   - false: 窗口当前隐藏
  public func isVisible() -> Bool {
    return window.isVisible
  }

  /// 获取窗口的最大化状态
  ///
  /// - Returns: 布尔值
  ///   - true: 窗口当前处于最大化状态
  ///   - false: 窗口当前不是最大化状态
  public func isMaximized() -> Bool {
    return isMaximize
  }

  /// 最大化窗口
  ///
  /// 如果窗口当前不是最大化状态，
  /// 该方法会将窗口放大到最大尺寸。
  /// 如果窗口已经是最大化状态，则不执行任何操作。
  public func maximize() {
    if !isMaximized() {
      window.zoom(nil)
    }
  }

  /// 还原窗口大小
  ///
  /// 如果窗口当前处于最大化状态，
  /// 该方法会将窗口还原到之前的大小。
  /// 如果窗口不是最大化状态，则不执行任何操作。
  public func unmaximize() {
    if isMaximized() {
      window.zoom(nil)
    }
  }

  /// 获取窗口的最小化状态
  ///
  /// - Returns: 布尔值
  ///   - true: 窗口当前处于最小化状态
  ///   - false: 窗口当前不是最小化状态
  public func isMinimized() -> Bool {
    return window.isMiniaturized
  }

  /// 最小化窗口
  ///
  /// 将窗口最小化到Dock栏。
  /// 该操作会触发windowDidMiniaturize代理方法。
  public func minimize() {
    window.miniaturize(nil)
  }

  /// 从最小化状态恢复窗口
  ///
  /// 将最小化的窗口从Dock栏恢复到原来的位置和大小。
  /// 该操作会触发windowDidDeminiaturize代理方法。
  public func restore() {
    window.deminiaturize(nil)
  }

  /// 获取窗口的全屏状态
  ///
  /// - Returns: 布尔值
  ///   - true: 窗口当前处于全屏模式
  ///   - false: 窗口当前不是全屏模式
  public func isFullScreen() -> Bool {
    return window.styleMask.contains(.fullScreen)
  }

  /// 设置窗口的全屏状态
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - isFullScreen: 是否进入全屏模式
  ///       - true: 如果窗口不是全屏，则进入全屏模式
  ///       - false: 如果窗口是全屏，则退出全屏模式
  ///
  /// 该方法会根据当前窗口状态和目标状态决定是否切换全屏模式
  public func setFullScreen(args: [String: Any]) {
    let isFullScreen: Bool = args["isFullScreen"] as! Bool

    if isFullScreen {
      if !window.styleMask.contains(.fullScreen) {
        window.toggleFullScreen(nil)
      }
    } else {
      if window.styleMask.contains(.fullScreen) {
        window.toggleFullScreen(nil)
      }
    }
  }

  /// 获取窗口的当前大小
  ///
  /// - Returns: NSSize对象，包含窗口的宽度和高度
  public func getSize() -> NSSize {
    return window.frame.size
  }

  /// 设置窗口的大小
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - width: 窗口的目标宽度
  ///     - height: 窗口的目标高度
  ///     - animate: 是否使用动画效果（可选，默认为false）
  ///
  /// 该方法会调整窗口的大小，同时保持窗口顶部位置不变。
  /// 如果指定了动画效果，窗口大小的改变会平滑过渡。
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

  /// 应用窗口框架的变更
  ///
  /// - Parameters:
  ///   - frameRect: 新的窗口框架矩形
  ///   - animate: 是否使用动画效果
  ///
  /// 该私有方法负责实际执行窗口框架的更改。
  /// 根据animate参数决定是否使用动画效果来平滑过渡到新的窗口状态。
  private func applyFrameChange(frameRect: NSRect, animate: Bool) {
    if animate {
      window.animator().setFrame(frameRect, display: true, animate: true)
    } else {
      window.setFrame(frameRect, display: true)
    }
  }

  /// 获取窗口的最小尺寸限制
  ///
  /// - Returns: 包含最小尺寸信息的字典
  ///   - width: 窗口允许的最小宽度
  ///   - height: 窗口允许的最小高度
  ///
  /// 窗口不能被调整到小于这个尺寸
  public func getMinSize() -> [String: Any] {
    return [
      "width": window.minSize.width,
      "height": window.minSize.height,
    ]
  }

  /// 设置窗口的最小尺寸限制
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - width: 窗口允许的最小宽度
  ///     - height: 窗口允许的最小高度
  ///
  /// 设置后，用户将无法将窗口调整得比这个尺寸更小
  public func setMinSize(args: [String: Any]) {
    let minSize: NSSize = NSSize(
      width: args["width"] as! CGFloat,
      height: args["height"] as! CGFloat
    )
    window.minSize = minSize
  }

  /// 获取窗口的最大尺寸限制
  ///
  /// - Returns: 包含最大尺寸信息的字典
  ///   - width: 窗口允许的最大宽度
  ///   - height: 窗口允许的最大高度
  ///
  /// 窗口不能被调整到大于这个尺寸
  public func getMaxSize() -> [String: Any] {
    return [
      "width": window.maxSize.width,
      "height": window.maxSize.height,
    ]
  }

  /// 设置窗口的最大尺寸限制
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - width: 窗口允许的最大宽度
  ///     - height: 窗口允许的最大高度
  ///
  /// 设置后，用户将无法将窗口调整得比这个尺寸更大
  public func setMaxSize(args: [String: Any]) {
    let maxSize: NSSize = NSSize(
      width: args["width"] as! CGFloat,
      height: args["height"] as! CGFloat
    )
    window.maxSize = maxSize
  }

  /// 获取当前屏幕的可用尺寸
  ///
  /// - Returns: 屏幕的可用尺寸
  ///   如果无法获取屏幕信息，返回零尺寸
  ///
  /// 返回的尺寸不包括Dock栏和菜单栏占用的空间
  public func getScreenSize() -> NSSize {
    guard let screen = window.screen ?? NSScreen.main else { return .zero }
    return screen.visibleFrame.size
  }

  /// 将窗口居中显示在屏幕上
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - animate: 是否使用动画效果（可选，默认为false）
  ///
  /// 该方法会将窗口移动到当前屏幕的中心位置。
  /// 计算时会考虑屏幕的可见区域（不包括Dock栏和菜单栏）。
  /// 如果指定了动画效果，窗口的移动会平滑过渡。
  public func center(args: [String: Any?]) {
    let animate: Bool = args["animate"] as? Bool ?? false
    let screen = (window.screen ?? NSScreen.main)!
    var frame = window.frame
    frame.origin.x = screen.visibleFrame.minX + (screen.visibleFrame.width - frame.width) / 2
    frame.origin.y = screen.visibleFrame.minY + (screen.visibleFrame.height - frame.height) / 2
    applyFrameChange(frameRect: frame, animate: animate)
  }

  /// 获取窗口的当前位置
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - global: 是否返回全局坐标（可选，默认为false）
  ///
  /// - Returns: 包含窗口位置信息的字典，如果无法获取屏幕信息则返回nil
  ///   当global为false时：
  ///   - x: 相对于当前屏幕左边界的水平距离
  ///   - y: 相对于当前屏幕顶部的垂直距离
  ///   当global为true时：
  ///   - globalX: 相对于所有屏幕左边界的水平距离
  ///   - globalY: 相对于所有屏幕顶部的垂直距离
  ///   - x: 相对于当前屏幕的坐标
  ///   - y: 相对于当前屏幕的坐标
  public func getPosition(args: [String: Any]) -> [String: CGFloat]? {
    let global: Bool = args["global"] as? Bool ?? false
    let windowFrame = window.frame
    if window.screen == nil {
      return nil
    }

    let screenHeight = window.screen!.visibleFrame.maxY
    let x = windowFrame.origin.x - window.screen!.visibleFrame.origin.x
    let y = screenHeight - (windowFrame.origin.y + windowFrame.height)

    if global {
      let globalTop = getGlobalTop()
      let windowTop = windowFrame.origin.y + windowFrame.height
      let globalX = windowFrame.origin.x
      let globalY = globalTop - windowTop

      return ["globalX": globalX, "globalY": globalY, "x": x, "y": y]
    }

    return ["x": x, "y": y]
  }

  /// 设置窗口的位置
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - x: 目标X坐标
  ///     - y: 目标Y坐标
  ///     - global: 是否使用全局坐标系（可选，默认为false）
  ///     - animate: 是否使用动画效果（可选，默认为false）
  ///
  /// 该方法会将窗口移动到指定位置。
  /// 可以选择使用全局坐标系（相对于所有屏幕）或本地坐标系（相对于当前屏幕）。
  /// 如果指定了动画效果，窗口的移动会平滑过渡。
  public func setPosition(args: [String: Any]) {
    let animate: Bool = args["animate"] as? Bool ?? false
    let global: Bool = args["global"] as? Bool ?? false
    let point: NSPoint = NSPoint(x: args["x"] as! CGFloat, y: args["y"] as! CGFloat)

    var targetFrame = window.frame
    targetFrame.origin = calculateWindowOrigin(point: point, global: global, size: targetFrame.size)
    applyFrameChange(frameRect: targetFrame, animate: animate)
  }

  /// 获取所有屏幕中最高点的Y坐标
  ///
  /// - Returns: 所有可见屏幕中最高点的Y坐标值
  ///   如果没有可用屏幕，返回0
  ///
  /// 该方法用于计算全局坐标系中的垂直位置
  private func getGlobalTop() -> CGFloat {
    let allVisibleFrames = NSScreen.screens.map { $0.visibleFrame }
    return allVisibleFrames.map { $0.maxY }.max() ?? 0
  }

  /// 计算窗口的原点位置
  ///
  /// - Parameters:
  ///   - point: 目标位置点
  ///   - global: 是否使用全局坐标系
  ///   - size: 窗口的大小
  ///
  /// - Returns: 计算后的窗口原点位置
  ///   如果无法获取屏幕信息，返回零点
  ///
  /// 该方法根据不同的坐标系统计算窗口的实际位置：
  /// - 全局坐标系：相对于所有屏幕的位置
  /// - 本地坐标系：相对于当前屏幕的位置
  /// 计算时会考虑窗口大小和屏幕边界
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

  /// 获取窗口的边界矩形
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - global: 是否使用全局坐标系（可选，默认为false）
  ///
  /// - Returns: 窗口的边界矩形，包含位置和大小信息
  ///
  /// 该方法返回一个描述窗口完整边界的矩形。
  /// 坐标系统可以是全局的（相对于所有屏幕）或本地的（相对于当前屏幕）。
  public func getBounds(args: [String: Any]) -> NSRect {
    let global: Bool = args["global"] as? Bool ?? false
    let size: NSSize = getSize()
    let point: [String: CGFloat] = getPosition(args: ["global": global])!
    return NSRect(
      x: (point["globalX"] ?? point["x"])!, y: (point["globalY"] ?? point["y"])!, width: size.width,
      height: size.height)
  }

  /// 设置窗口的边界矩形
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - width: 窗口宽度
  ///     - height: 窗口高度
  ///     - x: 目标X坐标
  ///     - y: 目标Y坐标
  ///     - global: 是否使用全局坐标系（可选，默认为false）
  ///     - animate: 是否使用动画效果（可选，默认为false）
  ///
  /// 该方法同时设置窗口的位置和大小。
  /// 可以选择使用全局坐标系或本地坐标系，
  /// 并可以指定是否使用动画效果来平滑过渡到新的状态。
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

  /// 获取窗口的标题文本
  ///
  /// - Returns: 当前窗口的标题文本字符串
  ///
  /// 该方法返回窗口当前显示的标题文本。
  /// 标题通常显示在窗口的标题栏中，用于标识窗口的内容或用途。
  public func getTitle() -> String {
    return window.title
  }

  /// 设置窗口的标题文本
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - title: 要设置的标题文本字符串
  ///            如果未提供标题或类型转换失败，将使用空字符串
  ///
  /// 该方法用于更新窗口的标题文本。
  /// 新的标题将立即显示在窗口的标题栏中。
  public func setTitle(args: [String: Any]) {
    let title: String = args["title"] as? String ?? ""
    window.title = title
    emitEvent("changeTitle", args: ["title": title])
  }

  /// 获取窗口的动画行为
  ///
  /// - Returns: 表示当前动画行为的字符串，可能的值包括：
  ///   - "none": 无动画效果
  ///   - "documentWindow": 文档窗口动画
  ///   - "utilityWindow": 实用工具窗口动画
  ///   - "alertPanel": 警告面板动画
  ///   如果当前动画行为未在映射表中定义，则返回nil
  ///
  /// 该方法返回窗口当前使用的动画行为类型。
  /// 不同的动画行为会影响窗口在显示、隐藏等操作时的视觉效果。
  public func getAnimationBehavior() -> String? {
    return GetAnimationBehaviorMap[window.animationBehavior.rawValue]
  }

  /// 设置窗口的动画行为
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - animationBehavior: 要设置的动画行为字符串，可选值：
  ///       - "none": 禁用所有动画效果
  ///       - "documentWindow": 使用标准文档窗口动画
  ///       - "utilityWindow": 使用实用工具窗口动画
  ///       - "alertPanel": 使用警告面板动画
  ///       如果提供的值无效或未指定，将使用默认动画行为
  ///
  /// 该方法用于更改窗口的动画行为，影响窗口在各种操作（如显示、隐藏）时的动画效果。
  /// 新的动画行为将立即生效，并应用于后续的窗口操作。
  public func setAnimationBehavior(args: [String: Any]) {
    let animationBehaviorString = args["animationBehavior"] as? String ?? "default"
    let animationBehavior: NSWindow.AnimationBehavior =
      SetAnimationBehaviorMap[animationBehaviorString] ?? .default
    window.animationBehavior = animationBehavior
  }

  /// 将窗口设置为无边框样式
  ///
  /// 该方法会执行以下操作：
  /// 1. 启用全尺寸内容视图模式
  /// 2. 隐藏标题栏
  /// 3. 设置窗口为透明
  /// 4. 移除窗口阴影
  /// 5. 如果窗口有标题栏，则隐藏标题栏视图
  ///
  /// 这种样式通常用于创建自定义外观的窗口，
  /// 例如无边框的媒体播放器或工具面板。
  public func setAsFrameless() {
    window.styleMask.insert(.fullSizeContentView)
    window.titleVisibility = .hidden
    window.isOpaque = true
    window.hasShadow = false
    window.backgroundColor = NSColor.clear
    if window.styleMask.contains(.titled) {
      let titleBarView: NSView = (window.standardWindowButton(.closeButton)?.superview)!.superview!
      titleBarView.isHidden = true
    }
  }

  /// 获取窗口的标题栏样式
  ///
  /// - Returns: 表示标题栏可见性的字符串
  ///   - "visible": 标题栏可见
  ///   - "hidden": 标题栏隐藏
  ///
  /// 该方法通过查询窗口的titleVisibility属性，
  /// 返回当前标题栏的可见性状态。
  public func getTitleBarStyle() -> String {
    return GetTitleBarStyleMap[window.titleVisibility.rawValue]!
  }

  /// 设置窗口标题栏的样式
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - titleBarStyle: 标题栏样式字符串
  ///       - "visible": 显示标题栏
  ///       - "hidden": 隐藏标题栏
  ///
  /// 该方法会根据指定的样式调整窗口的外观：
  /// - 当设置为hidden时：
  ///   1. 隐藏标题栏
  ///   2. 使标题栏透明
  ///   3. 启用全尺寸内容视图
  ///   4. 禁用窗口移动
  /// - 当设置为visible时：
  ///   1. 显示标题栏
  ///   2. 恢复标题栏不透明
  ///   3. 禁用全尺寸内容视图
  ///   4. 启用窗口移动
  ///
  /// 无论何种样式，窗口都将保持：
  /// - 非不透明（支持透明效果）
  /// - 显示窗口阴影
  public func setTitleBarStyle(args: [String: Any]) {
    let titleBarStyle: NSWindow.TitleVisibility =
      SetTitleBarStyleMap[args["titleBarStyle"] as! String] ?? .visible
    window.titleVisibility = titleBarStyle
    if titleBarStyle == .hidden {
      window.titlebarAppearsTransparent = true
      window.styleMask.insert([.fullSizeContentView])
      
      customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
      setMovable(["isMovable": false])
      customTitleBar?.enabled = true
    } else {
      // 首先确保窗口样式包含标题栏和标准按钮
      window.styleMask.remove(.fullSizeContentView)
      window.titlebarAppearsTransparent = false
      setMovable(["isMovable": true])
      customTitleBar?.enabled = false
    }
  }

  /// 获取窗口是否可移动
  ///
  /// 该方法用于检查窗口当前是否可以被用户拖拽移动。
  /// 窗口的可移动性通常受以下因素影响：
  /// - 窗口的样式设置
  /// - 窗口的当前状态（如全屏模式）
  /// - 应用程序的权限设置
  ///
  /// - Returns: 布尔值
  ///   - true: 窗口当前可以被移动
  ///   - false: 窗口当前不可移动
  public func isMovable() -> Bool {
    return window.isMovable
  }

  /// 设置窗口是否可移动
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - isMovable: 是否允许窗口移动
  ///       - true: 窗口可以被用户拖动移动
  ///       - false: 窗口不能被用户拖动移动
  ///
  /// 该方法控制窗口是否响应用户的拖拽移动操作
  /// 当设置为false时，用户将无法通过鼠标拖拽来移动窗口
  public func setMovable(_ args: [String: Any]) {
    let isMovable: Bool = args["isMovable"] as! Bool
    window.isMovable = isMovable
  }

  /// 获取窗口的透明度
  ///
  /// - Returns: 窗口当前的透明度值（0.0 ~ 1.0）
  ///   - 0.0: 完全透明
  ///   - 1.0: 完全不透明
  ///
  /// 该方法返回窗口当前的透明度值，用于实现特殊的视觉效果
  public func getOpacity() -> CGFloat {
    return window.alphaValue
  }

  /// 设置窗口的透明度
  ///
  /// - Parameters:
  ///   - args: 参数字典
  ///     - opacity: 目标透明度值（0.0 ~ 1.0）
  ///       - 0.0: 完全透明
  ///       - 1.0: 完全不透明
  ///
  /// 该方法用于调整窗口的透明度，可以创建半透明效果或动画过渡
  public func setOpacity(args: [String: Any]) {
    let opacity: CGFloat = args["opacity"] as! CGFloat
    window.alphaValue = opacity
  }

  /// 获取当前鼠标位置的全局坐标
  ///
  /// - Returns: 包含鼠标位置信息的字典
  ///   - x: 鼠标相对于所有屏幕左边界的水平距离
  ///   - y: 鼠标相对于所有屏幕顶部的垂直距离
  ///
  /// 该方法会计算鼠标在整个屏幕空间中的绝对位置，
  /// 考虑了多显示器的情况，返回统一的坐标系下的位置值
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
      "y": globalY,
    ]
  }

  /// 添加悬停事件监听器
  ///
  /// 该方法为窗口添加鼠标悬停事件监听功能，用于跟踪鼠标在窗口内的移动。
  /// 当鼠标在窗口内移动时，会触发回调函数并发送悬停事件。
  ///
  /// - Parameters:
  ///   - id: 监听器的唯一标识符
  ///   - callback: 可选的回调函数，接收鼠标位置作为参数
  ///     当鼠标移动时，会调用此回调函数并传入当前鼠标位置
  ///
  /// 该方法会执行以下操作：
  /// 1. 将监听器ID添加到悬停事件列表中
  /// 2. 移除已存在的移动事件监听器（如果有）
  /// 3. 发送初始悬停事件
  /// 4. 创建新的本地事件监听器来处理鼠标移动
  public func addHoverListener(_ id: String, _ callback: ((_ point: NSPoint) -> Void)? = nil) {
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

  /// 处理鼠标事件
  ///
  /// 该私有方法负责处理鼠标移动事件，计算鼠标在窗口中的位置，
  /// 并在鼠标位于窗口内时触发回调和发送事件。
  ///
  /// - Parameters:
  ///   - callback: 可选的回调函数，当鼠标在窗口内时被调用
  ///
  /// - Returns: 布尔值
  ///   - true: 鼠标在窗口内，事件已处理
  ///   - false: 鼠标在窗口外或处理失败
  ///
  /// 该方法执行以下步骤：
  /// 1. 获取鼠标在屏幕上的位置
  /// 2. 将屏幕坐标转换为窗口坐标
  /// 3. 将窗口坐标转换为视图坐标
  /// 4. 检查鼠标是否在窗口范围内
  /// 5. 如果在范围内，触发回调并发送悬停事件
  private func processMouseEvent(_ callback: ((_ point: NSPoint) -> Void)? = nil) -> Bool {
    guard let contentView = window.contentView else { return false }

    let screenLocation = NSEvent.mouseLocation

    let windowLocation = window.convertPoint(fromScreen: screenLocation)

    let viewLocation = contentView.convert(windowLocation, from: nil)

    let flippedY = contentView.bounds.height - viewLocation.y
    let point = CGPoint(x: viewLocation.x, y: flippedY)

    if point.x < 0 || point.x > window.frame.width || point.y < 0 || point.y > window.frame.height {
      return false
    }

    callback?(windowLocation)

    emitEvent("hover", args: ["x": point.x, "y": point.y])

    return true
  }

  /// 发送悬停事件
  ///
  /// 该私有方法用于立即发送一次悬停事件，通常在添加监听器时调用，
  /// 以确保立即获得鼠标位置信息，而不需要等待鼠标移动。
  ///
  /// - Parameters:
  ///   - callback: 可选的回调函数，用于处理鼠标位置信息
  ///
  /// 该方法通过调用processMouseEvent来处理和发送当前的鼠标位置信息
  private func sendHoverEvent(_ callback: ((_ point: NSPoint) -> Void)? = nil) {
    _ = processMouseEvent(callback)
  }

  /// 移除悬停事件监听器
  ///
  /// 该方法用于移除之前添加的悬停事件监听器。
  /// 可以移除特定ID的监听器，或移除所有监听器。
  ///
  /// - Parameters:
  ///   - id: 要移除的监听器ID
  ///     - nil: 移除所有监听器
  ///     - 特定ID: 只移除该ID对应的监听器
  ///
  /// 该方法会执行以下操作：
  /// 1. 如果ID为nil，移除所有监听器
  /// 2. 如果提供了特定ID，只移除该ID的监听器
  /// 3. 当没有剩余监听器时，清理事件监听器资源
  public func removeHoverListener(_ id: String?) {
    if id == nil {
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

  /// 添加预拖拽事件监听器
  ///
  /// 该方法为窗口添加预拖拽事件监听功能，用于在拖拽开始前
  /// 记录鼠标的初始位置。这对于实现准确的窗口拖拽非常重要。
  ///
  /// - Parameters:
  ///   - id: 监听器的唯一标识符
  ///
  /// 该方法通过添加悬停事件监听器来实现：
  /// 1. 监听鼠标移动
  /// 2. 记录鼠标位置作为拖拽的起始点
  /// 3. 为后续的拖拽操作提供参考点
  public func addPrePanListener(_ id: String) {
    addHoverListener(id) { point in
      self.panStartPoint = point
    }
  }

  /// 移除预拖拽事件监听器
  ///
  /// - Parameter id: 要移除的监听器ID
  ///
  /// 该方法用于移除之前添加的预拖拽事件监听器
  /// 通过调用removeHoverListener来清理相关的事件监听
  public func removePrePanListener(_ id: String) {
    removeHoverListener(id)
  }

  /// 添加窗口拖拽事件监听器
  ///
  /// 该方法为窗口添加拖拽事件监听，使窗口能够响应用户的拖拽操作。
  /// 监听器会跟踪鼠标左键拖拽事件，并实时更新窗口位置。
  /// 在拖拽过程中，会通过Flutter通道发送pan事件，
  /// 通知Flutter层窗口的最新位置信息。
  ///
  /// - Returns: 字典，包含窗口的初始全局位置信息
  ///   - globalX: 窗口相对于所有屏幕左边界的水平距离
  ///   - globalY: 窗口相对于所有屏幕顶部的垂直距离
  ///   - x: 窗口相对于当前屏幕的水平坐标
  ///   - y: 窗口相对于当前屏幕的垂直坐标
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
      guard
        let event = NSEvent.mouseEvent(
          with: .leftMouseDragged,
          location: windowLocation,
          modifierFlags: [.command],
          timestamp: CACurrentMediaTime(),
          windowNumber: self.window.windowNumber,
          context: nil,
          eventNumber: 0,
          clickCount: 1,
          pressure: 0.5
        )
      else { return event }

      self.window.performDrag(with: event)
      self.windowChannel?.invokeMethod("pan", arguments: self.getPosition(args: ["global": true]))
      return event
    }
    return getPosition(args: ["global": true])!
  }

  /// 移除拖拽事件监听器
  ///
  /// 该方法会执行以下操作：
  /// 1. 检查是否存在拖拽事件监听器
  /// 2. 如果存在，则移除监听器并清空引用
  ///
  /// 通常在窗口关闭或需要停止监听拖拽事件时调用
  public func removePanListener() {
    if panEvent != nil {
      NSEvent.removeMonitor(panEvent!)
      panEvent = nil
    }
  }

  /// 向指定窗口发送事件
  ///
  /// - Parameters:
  ///   - args: 事件参数字典
  ///     - targetId: 目标窗口的ID
  ///     - id: 源窗口的ID
  ///     - method: 要调用的方法名
  ///     - arguments: 传递给方法的参数
  ///   - callback: 事件处理完成后的回调函数
  ///     - windowId: 窗口ID
  ///     - args: 回调参数
  ///
  /// 该方法用于窗口间的通信，允许一个窗口向另一个窗口发送事件和数据
  public func windowEmit(
    args: [String: Any], callback: @escaping (_ windowId: Int64, _ args: Any?) -> Void
  ) {
    let targetId: Int64 = args["targetId"] as! Int64
    let sourceId: Int64 = args["id"] as! Int64
    if let target = ChooWindowManager.windowMap[targetId] {
      let method: String = args["method"] as! String
      let arguments: [String: Any] = [
        "method": method, "id": sourceId, "arguments": args["arguments"] as Any,
      ]
      target.emitEvent("event", args: arguments, callback: callback)
    }
  }
}

/// ChooWindowManager的扩展，提供全局窗口管理功能
extension ChooWindowManager {
  /// 用于生成唯一的窗口标识符
  ///
  /// 每次创建新窗口时，该值会自增，
  /// 确保每个窗口都有一个唯一的ID
  static private var incrementid: Int64 = 0

  /// 存储所有窗口实例的映射表
  ///
  /// 键：窗口的唯一标识符（Int64）
  /// 值：对应的ChooWindowManager实例
  ///
  /// 用于在全局范围内管理和访问所有窗口实例
  static public var windowMap: [Int64: ChooWindowManager] = [:]

  /// 终止应用程序
  ///
  /// 该方法会立即关闭应用程序及其所有窗口。
  /// 调用此方法将触发应用程序的正常终止流程。
  static public func destroy() {
    NSApp.terminate(nil)
  }
}

extension ChooWindowManager {
  /// 关联对象的键定义结构体
  ///
  /// 该结构体定义了用于存储关联对象的键：
  /// - allowClosing: 用于存储窗口是否允许关闭的标志
  /// - AllowKeyboard: 用于存储键盘事件处理相关的数据
  private struct AssociatedKeys {
    static var allowClosing: Bool? = nil
    static var AllowKeyboard = UnsafeRawPointer(bitPattern: "AllowKeyboard".hashValue)!
    static var keyboardEvent = UnsafeRawPointer(bitPattern: "keyboardEvent".hashValue)!
    static var miniButtonState = UnsafeRawPointer(bitPattern: "miniButtonState".hashValue)!
  }

  /// 窗口是否允许关闭的标志
  ///
  /// 该属性通过关联对象机制实现，用于控制窗口的关闭行为：
  /// - 当值为true时，允许窗口关闭
  /// - 当值为false时，阻止窗口关闭
  /// - 当值为nil时，表示尚未设置关闭权限
  var allowClosing: Bool? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.allowClosing) as? Bool
    }
    set(value) {
      objc_setAssociatedObject(
        self, &AssociatedKeys.allowClosing, value,
        objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  /// 键盘事件处理标志
  ///
  /// 该属性通过关联对象机制实现，用于控制键盘事件的处理：
  /// - 当有值时，表示当前正在处理的键盘事件
  /// - 当为nil时，表示没有正在处理的键盘事件
  ///
  /// 主要用于防止键盘事件的重复处理和管理事件的生命周期
  var AllowKeyboard: Bool {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.AllowKeyboard) as? Bool ?? false
    }
    set(value) {
      objc_setAssociatedObject(
        self, &AssociatedKeys.AllowKeyboard, value,
        objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  var keyboardEvent: NSEvent? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.keyboardEvent) as? NSEvent
    }
    set(value) {
      objc_setAssociatedObject(
        self, &AssociatedKeys.keyboardEvent, value,
        objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  var miniButtonState: Bool {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.miniButtonState) as? Bool ?? true
    }
    set(value) {
      objc_setAssociatedObject(
        self, &AssociatedKeys.miniButtonState, value,
        objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  /// 发送窗口事件
  ///
  /// - Parameters:
  ///   - eventName: 事件名称
  ///   - args: 事件参数
  ///   - callback: 事件处理完成后的回调函数
  ///     - id: 窗口ID
  ///     - args: 回调参数
  ///
  /// 该方法通过Flutter通道向Flutter层发送事件。
  /// 只有在事件监听器已启用的情况下才会发送事件。
  public func emitEvent(
    _ eventName: String, args: [String: Any?]?,
    callback: ((_ id: Int64, _ args: Any?) -> Void)? = nil
  ) {
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
  ///
  /// - Parameters:
  ///   - eventName: 事件名称
  ///   - args: 事件参数
  ///
  /// 该方法用于发送应用级别的全局事件
  /// 目前为预留方法，暂未实现具体功能
  public func emitGlobalEvent(_ eventName: String, args: [String: Any]?) {}

  /// 窗口大小改变时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口大小发生变化时被调用，执行以下操作：
  /// 1. 获取新的窗口大小并发送resize事件
  /// 2. 检测窗口是否进入或退出最大化状态
  /// 3. 根据状态变化发送maximize或unmaximize事件
  public func windowDidResize(_ notification: Notification) {
    let size: NSSize = getSize()
    emitEvent("resize", args: ["width": size.width, "height": size.height])
    if !isMaximize && window.isZoomed {
      isMaximize = true
      emitEvent("maximize", args: nil)
    }
    if isMaximize && !window.isZoomed {
      isMaximize = false
      emitEvent("unmaximize", args: nil)
    }
  }

  /// 窗口移动完成时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口完成移动时被调用
  /// 获取窗口的新位置并发送move事件
  public func windowDidMove(_ notification: Notification) {
    let point: [String: CGFloat]? = getPosition(args: ["global": true])
    if point == nil {
      return
    }
    emitEvent("move", args: point)
  }

  /// 窗口即将移动时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口开始移动时被调用
  /// 获取窗口的当前位置并发送move事件
  public func windowWillMove(_ notification: Notification) {
    let point: [String: CGFloat]? = getPosition(args: ["global": true])
    if point == nil {
      return
    }
    emitEvent("move", args: point)
  }

  /// 窗口成为主窗口时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口获得焦点成为主窗口时被调用，执行以下操作：
  /// 1. 添加键盘事件监听
  /// 2. 发送focus事件
  public func windowDidBecomeMain(_ notification: Notification) {
    addKeyboardEvent()
    customTitleBar?.setWindowState(true)
    emitEvent("focus", args: nil)
  }

  /// 窗口失去主窗口状态时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口失去焦点时被调用，执行以下操作：
  /// 1. 移除键盘事件监听
  /// 2. 发送blur事件
  public func windowDidResignMain(_ notification: Notification) {
    removeKeyboardEvent()
    customTitleBar?.setWindowState(false)
    emitEvent("blur", args: nil)
  }

  /// 窗口最小化时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口被最小化时被调用
  /// 发送minimize事件通知窗口状态的变化
  public func windowDidMiniaturize(_ notification: Notification) {
    emitEvent("minimize", args: nil)
  }

  /// 窗口从最小化恢复时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口从最小化状态恢复时被调用
  /// 发送restore事件通知窗口状态的变化
  public func windowDidDeminiaturize(_ notification: Notification) {
    emitEvent("restore", args: nil)
  }

  /// 窗口即将进入全屏模式时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口即将进入全屏模式时被调用
  /// 发送willEnterFullScreen事件
  public func windowWillEnterFullScreen(_ notification: Notification) {
    miniButtonState = customTitleBar?.buttons[1].isEnabled ?? true
    setTitleBarStyle(args: ["titleBarStyle": "visible"])
    emitEvent("willEnterFullScreen", args: nil)
  }

  /// 窗口已进入全屏模式时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口完成进入全屏模式时被调用
  /// 发送didEnterFullScreen事件
  public func windowDidEnterFullScreen(_ notification: Notification) {
    emitEvent("didEnterFullScreen", args: nil)
  }

  /// 发送willLeaveFullScreen事件
  public func windowWillExitFullScreen(_ notification: Notification) {
    setTitleBarStyle(args: ["titleBarStyle": "hidden"])
    customTitleBar?.setButtonEnabled([.miniaturizeButton], state: miniButtonState)
    emitEvent("willLeaveFullScreen", args: nil)
  }

  /// 窗口已退出全屏模式时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口完成退出全屏模式时被调用
  /// 发送didLeaveFullScreen事件
  public func windowDidExitFullScreen(_ notification: Notification) {
    emitEvent("didLeaveFullScreen", args: nil)

  }

  /// 窗口是否应该关闭的代理方法
  ///
  /// - Parameter sender: 发送关闭请求的窗口
  /// - Returns: 是否允许窗口关闭
  ///   - true: 允许关闭
  ///   - false: 不允许关闭
  ///
  /// 该方法实现了窗口关闭的拦截机制：
  /// 1. 首次调用时发送willClose事件，等待回调决定是否关闭
  /// 2. 回调中设置allowClosing标志并尝试关闭窗口
  /// 3. 再次调用时根据allowClosing标志决定是否允许关闭
  public func windowShouldClose(_ sender: NSWindow) -> Bool {
    if allowClosing == nil {
      emitEvent(
        "willClose", args: nil,
        callback: { id, arguments in
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

  /// 窗口即将关闭时的回调方法
  ///
  /// - Parameter notification: 通知对象
  ///
  /// 该方法会在窗口即将关闭时被调用，执行以下清理操作：
  /// 1. 移除键盘事件监听器
  /// 2. 移除悬停事件监听器
  /// 3. 发送close事件
  public func windowWillClose(_ notification: Notification) {
    removeKeyboardEvent()
    removeHoverListener(nil)

    emitEvent("close", args: nil)
  }

  /// 添加键盘事件监听器
  ///
  /// 该方法负责设置键盘事件的监听，主要功能包括：
  /// 1. 移除已存在的键盘事件监听器（如果有）
  /// 2. 创建新的本地事件监听器，监听按键按下事件
  /// 3. 处理修饰键（如Shift、Control、Option等）
  /// 4. 发送键盘事件到Flutter层
  /// 5. 处理特殊快捷键（如Command+W关闭窗口）
  ///
  /// 事件处理流程：
  /// 1. 检查是否允许处理键盘事件
  /// 2. 收集修饰键信息
  /// 3. 发送事件到Flutter层等待处理结果
  /// 4. 根据处理结果决定是否继续传递事件
  private func addKeyboardEvent() {
    if keyboardEventMonitor != nil {
      removeKeyboardEvent()
    }

    keyboardEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) {
      [weak self] event in
      guard let self = self else { return event }

      if !self.AllowKeyboard && self.keyboardEvent != event {
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
            "charactersIgnoringModifiers": event.charactersIgnoringModifiers,
          ],
          callback: { id, args in
            if args as? Bool ?? true {
              self.keyboardEvent = nil
              self.AllowKeyboard = true
              self.window.sendEvent(event)
            }
          }
        )
        return nil
      }

      self.AllowKeyboard = false

      if event.modifierFlags.contains(.command) && event.keyCode == 13 {
        self.close()
        return nil
      }
      
      if keyboardEvent == nil {
        keyboardEvent = event
        return event
      }
            
      return keyboardEvent == event ? nil : event
    }
  }

  /// 移除键盘事件监听器
  ///
  /// 该方法执行以下操作：
  /// 1. 检查是否存在键盘事件监听器
  /// 2. 如果存在，移除监听器并清空引用
  ///
  /// 通常在窗口失去焦点或关闭时调用，
  /// 用于清理键盘事件监听器，防止内存泄漏
  private func removeKeyboardEvent() {
    if let monitor = keyboardEventMonitor {
      NSEvent.removeMonitor(monitor)
      keyboardEventMonitor = nil
    }
  }
}

// 窗口操作
extension ChooWindowManager {
  public func setWindowButtonHidden(_ buttons: [String], state: Bool) {
    customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
    let buttonTypes: [NSWindow.ButtonType] = buttons.filter {
      return StringToButtonType[$0] != nil
    } .map {
      return StringToButtonType[$0]!
    }
    customTitleBar?.setButtonHidden(buttonTypes, state: state)
  }
  
  public func setWindowButtonEnabled(_ buttons: [String], state: Bool) {
    customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
    let buttonTypes: [NSWindow.ButtonType] = buttons.filter {
      return StringToButtonType[$0] != nil
    } .map {
      return StringToButtonType[$0]!
    }

    customTitleBar?.setButtonEnabled(buttonTypes, state: state)
  }
  
  public func getWindowButtonRegionPosition() -> CGPoint {
    customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
    let left: CGFloat = customTitleBar!.left!
    let top: CGFloat = customTitleBar!.top
    
    return CGPoint(x: left, y: top)
  }
  
  public func setWindowButtonRegionPosition(y: CGFloat, x: CGFloat? = nil) {
    customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
    customTitleBar?.left = x
    customTitleBar?.top = y
  }
  
  public func getWindowButtonRegionSize() -> CGSize {
    customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
    let width: CGFloat = customTitleBar!.width
    let height: CGFloat = customTitleBar!.height
    
    return CGSize(width: width, height: height)
  }
  
  public func setWindowButtonRegionHeight(height: CGFloat) {
    customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
    customTitleBar?.height = height
  }
  
  public func getWindowButtonSpacing() -> CGFloat {
    customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
    return customTitleBar!.spacing
  }
  
  public func setWindowButtonSpacing(spacing: CGFloat) {
    customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
    customTitleBar?.spacing = spacing
  }
  
  public func getWindowButtonSize() -> CGSize {
    customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
    return customTitleBar!.btnSize
  }
  
  public func setWindowButtonSize(_ size: CGSize) {
    customTitleBar = customTitleBar ?? ChooWindowOperationButtonManager(window)
    customTitleBar?.btnSize = size
  }
}
