import Cocoa
import FlutterMacOS

/// Flutter插件类，负责管理macOS平台上的窗口操作
/// 实现了Flutter和原生窗口管理之间的通信桥接
public class ChooWindowManagerPlugin: NSObject, FlutterPlugin {
  /// 用于注册Flutter插件的回调函数
  public static var RegisterGeneratedPlugins:((FlutterPluginRegistry) -> Void)?
  /// 注册插件
  /// - Parameter registrar: Flutter插件注册器
  public static func register(with registrar: FlutterPluginRegistrar) {
    _ = ChooWindowManagerPlugin(registrar)
  }
  
  /// 初始化Flutter项目对象
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
  /// 当前窗口的唯一标识符
  private var windowId: Int64 {
    get {
      (registrar.view!.window!.contentViewController as! ChooFlutterViewController).windowId
    }
  }
    
  /// 初始化插件
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
  /// - Parameters:
  ///   - call: Flutter方法调用对象
  ///   - result: 结果回调闭包
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
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  /// 处理窗口相关的方法调用
  /// - Parameters:
  ///   - call: Flutter方法调用对象
  ///   - result: 结果回调闭包
  public func windowHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let methodName: String = call.method
    let args: [String: Any] = call.arguments as? [String: Any] ?? [:]
    let id = args["id"] as! Int64;
    let wManager = ChooWindowManager.windowMap[id]!
    switch methodName {
    case "flutterReady":
      /// Flutter引擎准备就绪的回调
      result(nil)
      break
    case "windowReady":
      /// 窗口准备就绪的回调，设置窗口状态为就绪
      wManager.windowReady = true
      result(nil)
      break
    case "show":
      /// 显示窗口
      wManager.show()
      result(nil)
      break
    case "focus":
      /// 使窗口获得焦点
      wManager.focus()
      result(nil)
      break
    case "hide":
      /// 隐藏窗口
      wManager.hide()
      result(nil)
      break
    case "blur":
      /// 使窗口失去焦点
      wManager.blur()
      result(nil)
      break
    case "close":
      /// 关闭窗口
      wManager.close(args["force"] as? Bool ?? false)
      result(nil)
      break
    case "isVisible":
      /// 获取窗口可见状态
      result(wManager.isVisible())
      break
    case "isMaximized":
      /// 获取窗口最大化状态
      result(wManager.isMaximized())
      break
    case "maximize":
      /// 最大化窗口
      wManager.maximize()
      result(nil)
      break
    case "unmaximize":
      /// 还原窗口大小
      wManager.unmaximize()
      result(nil)
      break
    case "isMinimized":
      /// 获取窗口最小化状态
      result(wManager.isMinimized())
      break
    case "minimize":
      /// 最小化窗口
      wManager.minimize()
      result(nil)
      break
    case "restore":
      /// 从最小化状态恢复窗口
      wManager.restore()
      result(nil)
      break
    case "getSize":
      /// 获取窗口大小
      let size: NSSize = wManager.getSize()
      result(["width": size.width, "height": size.height])
      break
    case "setSize":
      /// 设置窗口大小
      wManager.setSize(args: args)
      result(nil)
      break
    case "getMinSize":
      /// 获取窗口最小尺寸
      result(wManager.getMinSize())
      break
    case "setMinSize":
      /// 设置窗口最小尺寸
      wManager.setMinSize(args: args)
      result(nil)
      break
    case "getMaxSize":
      /// 获取窗口最大尺寸
      result(wManager.getMaxSize())
      break
    case "setMaxSize":
      /// 设置窗口最大尺寸
      wManager.setMaxSize(args: args)
      result(nil)
      break
    case "getScreenSize":
      /// 获取屏幕尺寸
      let size: NSSize = wManager.getScreenSize()
      result(["width": size.width, "height": size.height])
      break
    case "getPosition":
      /// 获取窗口位置，支持全局坐标和本地坐标
      let position: [String: Any] = wManager.getPosition(args: args)!
      let global: Bool = args["global"] as? Bool ?? false
      if global {
        result(["globalX": position["globalX"], "globalY": position["globalY"], "x": position["x"], "y": position["y"]])
      } else {
        result(["x": position["x"], "y": position["y"]])
      }
      break
    case "setPosition":
      /// 设置窗口位置
      wManager.setPosition(args: args)
      result(nil)
      break
    case "center":
      /// 将窗口居中显示
      wManager.center(args: args)
      result(nil)
      break
    case "getBounds":
      /// 获取窗口边界信息
      let rect = wManager.getBounds(args: args)
      result(["x": rect.origin.x, "y": rect.origin.y, "width": rect.size.width, "height": rect.size.height])
      break
    case "setBounds":
      /// 设置窗口边界
      wManager.setBounds(args: args)
      result(nil)
      break
    case "getTitle":
      /// 获取窗口标题
      result(wManager.getTitle())
      break
    case "setTitle":
      /// 设置窗口标题
      wManager.setTitle(args: args)
      result(true)
      break
    case "getAnimationBehavior":
      /// 获取窗口动画行为
      result(wManager.getAnimationBehavior())
      break
    case "setAnimationBehavior":
      /// 设置窗口动画行为
      wManager.setAnimationBehavior(args: args)
      result(nil)
      break
    case "setAsFrameless":
      /// 设置窗口为无边框样式
      wManager.setAsFrameless()
      result(nil)
      break
    case "getTitleBarStyle":
      /// 获取标题栏样式
      result(wManager.getTitleBarStyle())
      break
    case "setTitleBarStyle":
      /// 设置标题栏样式
      wManager.setTitleBarStyle(args: args)
      result(nil)
      break
    case "getOpacity":
      /// 获取窗口透明度
      result(wManager.getOpacity())
      break
    case "setOpacity":
      /// 设置窗口透明度
      wManager.setOpacity(args: args)
      result(nil)
      break
    case "addListener":
      /// 添加窗口事件监听器
      wManager.listener = true
      result(nil)
      break
    case "removeListener":
      /// 移除窗口事件监听器
      wManager.listener = false
      result(nil)
      break
    case "getMousePoint":
      /// 获取鼠标位置
      result(wManager.getMousePoint())
      break
    case "addPanListener":
      /// 添加平移事件监听器
      result(wManager.addPanListener())
      break
    case "removePanListener":
      /// 移除平移事件监听器
      wManager.removePanListener()
      result(nil)
      break
    case "addHoverListener":
      /// 添加悬停事件监听器
      let eventid: Int64 = args["eventid"] as! Int64
      wManager.addHoverListener(eventid)
      result(nil)
      break
    case "removeHoverListener":
      /// 移除悬停事件监听器
      let eventid: Int64 = args["eventid"] as! Int64
      wManager.removeHoverListener(eventid)
      result(nil)
      break
    case "addPrePanListener":
      /// 添加预平移事件监听器
      let eventid: Int64 = args["eventid"] as! Int64
      wManager.addPrePanListener(eventid)
      result(nil)
      break
    case "removePrePanListener":
      /// 移除预平移事件监听器
      let eventid: Int64 = args["eventid"] as! Int64
      wManager.removePrePanListener(eventid)
      result(nil)
      break
    case "emit":
      /// 发送窗口事件
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
