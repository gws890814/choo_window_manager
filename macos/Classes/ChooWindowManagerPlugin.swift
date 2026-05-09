import Cocoa
import FlutterMacOS

/// ChooWindowManagerPlugin 是Flutter插件的主要实现类
///
/// 该类负责：
/// - 注册和初始化插件
/// - 处理Flutter和原生代码之间的通信
/// - 管理窗口的创建和销毁
/// - 处理窗口相关的方法调用
public class ChooWindowManagerPlugin: NSObject, FlutterPlugin {
  /// 插件注册回调函数
  /// 用于注册Flutter生成的插件
  public static var RegisterGeneratedPlugins:((FlutterPluginRegistry) -> Void)?
  /// 注册插件到Flutter引擎
  ///
  /// - Parameter registrar: Flutter插件注册器
  public static func register(with registrar: FlutterPluginRegistrar) {
    _ = ChooWindowManagerPlugin(registrar)
  }
  
  /// 初始化Flutter项目对象
  ///
  /// 创建一个新的Flutter项目实例，并配置其启动参数
  /// 
  /// - Returns: 配置好的FlutterDartProject实例
  public static func initFlutterObject() -> FlutterDartProject {
    let project = FlutterDartProject()
    let commandLineArguments: [String: Any] = [:]
    
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: commandLineArguments, options: .prettyPrinted)
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        project.dartEntrypointArguments = ["0", jsonString]
      }
    } catch {
      project.dartEntrypointArguments = ["0"]
    }
    return project
  }
  
  /// Flutter插件注册器实例
  private let registrar: FlutterPluginRegistrar
  
  /// 当前窗口的ID
  private var windowId: Int64 {
    get {
      (registrar.view!.window!.contentViewController as! ChooFlutterViewController).windowId
    }
  }
    
  /// 初始化插件实例
  ///
  /// - Parameter registrar: Flutter插件注册器
  public init(_ registrar: FlutterPluginRegistrar) {
    self.registrar = registrar;
    super.init()
    
    if ChooWindowManager.windowMap[windowId] == nil {
      let window: NSWindow = NSApplication.shared.windows[0]
      let chooWindowManager = ChooWindowManager(window)
      window.delegate = chooWindowManager
    }
    
    let wManager: ChooWindowManager = ChooWindowManager.windowMap[windowId]!
    
    wManager.globalChannel = FlutterMethodChannel(name: "choo_window_manager", binaryMessenger: registrar.messenger)
    wManager.windowChannel = FlutterMethodChannel(name: "choo_window_manager_\(windowId)", binaryMessenger: registrar.messenger)
    wManager.globalChannel?.setMethodCallHandler(globalHandle)
    wManager.windowChannel?.setMethodCallHandler(windowHandle)
  }

  /// 处理全局方法调用
  ///
  /// 处理应用级别的操作，如创建新窗口、关闭窗口等
  ///
  /// - Parameters:
  ///   - call: Flutter方法调用对象
  ///   - result: 结果回调
  public func globalHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args: [String: Any] = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "createWindow":
      let windowId: Int64? = createWindow(args: args)
      result(windowId)
    case "closeWindows":
      let ids: [Int64]? = args["ids"] as? [Int64]
      closeWindows(ids)
      result(true)
    case "destroy":
      NSApp.terminate(nil)
      result(nil)
    case "getWindowIds":
      result(Array(ChooWindowManager.windowMap.keys))
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  /// 处理窗口相关的方法调用
  ///
  /// 处理特定窗口的操作，如显示、隐藏、移动、调整大小等
  ///
  /// - Parameters:
  ///   - call: Flutter方法调用对象
  ///   - result: 结果回调
  public func windowHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let methodName: String = call.method
    let args: [String: Any] = call.arguments as? [String: Any] ?? [:]
    let id = args["id"] as! Int64;
    let wManager = ChooWindowManager.windowMap[id]!
    switch methodName {
    case "flutterReady":
      // Flutter引擎准备就绪的回调
      result(nil)
      break
    case "windowReady":
      // 窗口准备就绪，设置窗口状态为可用
      wManager.windowReady = true
      result(nil)
      break
    case "show":
      // 显示窗口
      wManager.show()
      result(nil)
      break
    case "focus":
      // 使窗口获得焦点
      wManager.focus()
      result(nil)
      break
    case "hide":
      // 隐藏窗口
      wManager.hide()
      result(nil)
      break
    case "blur":
      // 使窗口失去焦点
      wManager.blur()
      result(nil)
      break
    case "close":
      // 关闭窗口
      // - force: 是否强制关闭，忽略关闭确认
      wManager.close(args["force"] as? Bool ?? false)
      result(nil)
      break
    case "isVisible":
      // 获取窗口可见状态
      // 返回: Bool - 窗口是否可见
      result(wManager.isVisible())
      break
    case "isMaximized":
      // 获取窗口最大化状态
      // 返回: Bool - 窗口是否最大化
      result(wManager.isMaximized())
      break
    case "maximize":
      // 最大化窗口
      wManager.maximize()
      result(nil)
      break
    case "unmaximize":
      // 还原窗口大小
      wManager.unmaximize()
      result(nil)
      break
    case "isMinimized":
      // 获取窗口最小化状态
      // 返回: Bool - 窗口是否最小化
      result(wManager.isMinimized())
      break
    case "minimize":
      // 最小化窗口
      wManager.minimize()
      result(nil)
      break
    case "restore":
      // 从最小化状态恢复窗口
      wManager.restore()
      result(nil)
      break
    case "getSize":
      // 获取窗口大小
      // 返回: {width: Double, height: Double} - 窗口的宽度和高度
      let size: NSSize = wManager.getSize()
      result(["width": size.width, "height": size.height])
      break
    case "setSize":
      // 设置窗口大小
      // - width: 窗口宽度
      // - height: 窗口高度
      // - animate: 是否使用动画效果
      wManager.setSize(args: args)
      result(nil)
      break
    case "getMinSize":
      // 获取窗口最小尺寸限制
      // 返回: {width: Double, height: Double} - 最小宽度和高度
      result(wManager.getMinSize())
      break
    case "setMinSize":
      // 设置窗口最小尺寸
      // - width: 最小宽度
      // - height: 最小高度
      wManager.setMinSize(args: args)
      result(nil)
      break
    case "getMaxSize":
      // 获取窗口最大尺寸限制
      // 返回: {width: Double, height: Double} - 最大宽度和高度
      result(wManager.getMaxSize())
      break
    case "setMaxSize":
      // 设置窗口最大尺寸
      // - width: 最大宽度
      // - height: 最大高度
      wManager.setMaxSize(args: args)
      result(nil)
      break
    case "getScreenSize":
      // 获取屏幕尺寸
      // 返回: {width: Double, height: Double} - 屏幕的宽度和高度
      let size: NSSize = wManager.getScreenSize()
      result(["width": size.width, "height": size.height])
      break
    case "getPosition":
      // 获取窗口位置
      // - global: 是否返回全局坐标
      // 返回: {x: Double, y: Double} 或 {globalX: Double, globalY: Double, x: Double, y: Double}
      let position: [String: Any] = wManager.getPosition(args: args)!
      let global: Bool = args["global"] as? Bool ?? false
      if global {
        result(["globalX": position["globalX"], "globalY": position["globalY"], "x": position["x"], "y": position["y"]])
      } else {
        result(["x": position["x"], "y": position["y"]])
      }
      break
    case "setPosition":
      // 设置窗口位置
      // - x: 横坐标
      // - y: 纵坐标
      // - animate: 是否使用动画效果
      wManager.setPosition(args: args)
      result(nil)
      break
    case "center":
      // 将窗口居中显示
      // - animate: 是否使用动画效果
      wManager.center(args: args)
      result(nil)
      break
    case "getBounds":
      // 获取窗口边界信息
      // 返回: {x: Double, y: Double, width: Double, height: Double}
      let rect = wManager.getBounds(args: args)
      result(["x": rect.origin.x, "y": rect.origin.y, "width": rect.size.width, "height": rect.size.height])
      break
    case "setBounds":
      // 设置窗口边界
      // - x: 横坐标
      // - y: 纵坐标
      // - width: 宽度
      // - height: 高度
      // - animate: 是否使用动画效果
      wManager.setBounds(args: args)
      result(nil)
      break
    case "getTitle":
      // 获取窗口标题
      // 返回: String - 窗口标题文本
      result(wManager.getTitle())
      break
    case "setTitle":
      // 设置窗口标题
      // - title: 标题文本
      wManager.setTitle(args: args)
      result(true)
      break
    case "getAnimationBehavior":
      // 获取窗口动画行为
      // 返回: String - 动画行为类型
      result(wManager.getAnimationBehavior())
      break
    case "setAnimationBehavior":
      // 设置窗口动画行为
      // - animationBehavior: 动画行为类型
      wManager.setAnimationBehavior(args: args)
      result(nil)
      break
    case "setAsFrameless":
      // 设置为无边框窗口
      wManager.setAsFrameless()
      result(nil)
      break
    case "getTitleBarStyle":
      // 获取标题栏样式
      // 返回: String - 标题栏样式类型
      result(wManager.getTitleBarStyle())
      break
    case "setTitleBarStyle":
      // 设置标题栏样式
      // - titleBarStyle: 标题栏样式类型
      wManager.setTitleBarStyle(args: args)
      result(nil)
      break
    case "getOpacity":
      // 获取窗口透明度
      // 返回: Double - 透明度值(0.0-1.0)
      result(wManager.getOpacity())
      break
    case "setOpacity":
      // 设置窗口透明度
      // - opacity: 透明度值(0.0-1.0)
      wManager.setOpacity(args: args)
      result(nil)
      break
    case "addListener":
      // 添加窗口事件监听器
      wManager.listener = true
      result(nil)
      break
    case "removeListener":
      // 移除窗口事件监听器
      wManager.listener = false
      result(nil)
      break
    case "getMousePoint":
      // 获取鼠标位置
      // 返回: {x: Double, y: Double} - 鼠标坐标
      result(wManager.getMousePoint())
      break
    case "setWindowButtonHidden":
      wManager.setWindowButtonHidden(args["types"] as! [String], state: args["state"] as! Bool)
      result(nil)
      break
    case "setWindowButtonEnabled":
      wManager.setWindowButtonEnabled(args["types"] as! [String], state: args["state"] as! Bool)
      result(nil)
      break
    case "getWindowButtonRegionPosition":
      let point:CGPoint = wManager.getWindowButtonRegionPosition()
      result(["x": point.x, "y": point.y])
      break
    case "setWindowButtonRegionPosition":
      wManager.setWindowButtonRegionPosition(y: args["y"] as! CGFloat, x: args["x"] as? CGFloat)
      result(nil)
      break
    case "getWindowButtonRegionSize":
      let size: CGSize = wManager.getWindowButtonRegionSize()
      result(["width": size.width, "height": size.height])
      break
    case "setWindowButtonRegionHeight":
      wManager.setWindowButtonRegionHeight(height: args["height"] as! CGFloat)
      result(nil)
      break
    case "getWindowButtonSpacing":
      let spacing: CGFloat = wManager.getWindowButtonSpacing()
      result(spacing)
      break
    case "setWindowButtonSpacing":
      wManager.setWindowButtonSpacing(spacing: args["spacing"] as! CGFloat)
      result(nil)
      break
    case "getWindowButtonSize":
      let size: CGSize = wManager.getWindowButtonSize()
      result(["width": size.width, "height": size.height])
      break
    case "setWindowButtonSize":
      let size: CGSize = CGSize(width: args["width"] as! CGFloat, height: args["height"] as! CGFloat)
      wManager.setWindowButtonSize(size)
      result(nil)
      break
    case "addPanListener":
      // 添加窗口拖拽事件监听器
      // 返回: Bool - 是否添加成功
      result(wManager.addPanListener())
      break
    case "removePanListener":
      // 移除窗口拖拽事件监听器
      wManager.removePanListener()
      result(nil)
      break
    case "addHoverListener":
      // 添加鼠标悬停事件监听器
      // - eventid: 事件ID
      let eventid: String = args["eventid"] as! String
      wManager.addHoverListener(eventid)
      result(nil)
      break
    case "removeHoverListener":
      // 移除鼠标悬停事件监听器
      // - eventid: 事件ID
      let eventid: String = args["eventid"] as! String
      wManager.removeHoverListener(eventid)
      result(nil)
      break
    case "addPrePanListener":
      // 添加拖拽预处理事件监听器
      // - eventid: 事件ID
      let eventid: String = args["eventid"] as! String
      wManager.addPrePanListener(eventid)
      result(nil)
      break
    case "removePrePanListener":
      // 移除拖拽预处理事件监听器
      // - eventid: 事件ID
      let eventid: String = args["eventid"] as! String
      wManager.removePrePanListener(eventid)
      result(nil)
      break
    case "emit":
      // 发送自定义事件
      // - method: 事件名称
      // - arguments: 事件参数
      wManager.windowEmit(args: args, callback: { id, arguments  in
        let method: String = args["method"] as! String
        result(["id": id, "method": method, "arguments": arguments as Any?])
      })
      break
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
