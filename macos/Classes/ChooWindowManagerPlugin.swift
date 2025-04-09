import Cocoa
import FlutterMacOS

public class ChooWindowManagerPlugin: NSObject, FlutterPlugin {
  public static var RegisterGeneratedPlugins:((FlutterPluginRegistry) -> Void)?
  public static func register(with registrar: FlutterPluginRegistrar) {
    _ = ChooWindowManagerPlugin(registrar)
  }
  
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
  
  private let registrar: FlutterPluginRegistrar
  private var windowId: Int64 {
    get {
      (registrar.view!.window!.contentViewController as! ChooFlutterViewController).windowId
    }
  }
    
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
  
  public func windowHandle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let methodName: String = call.method
    let args: [String: Any] = call.arguments as? [String: Any] ?? [:]
    let id = args["id"] as! Int64;
    let wManager = ChooWindowManager.windowMap[id]!
    switch methodName {
    case "flutterReady":
      result(nil)
      break
    case "windowReady":
      wManager.windowReady = true
      result(nil)
      break
    case "show":
      wManager.show()
      result(nil)
      break
    case "focus":
      wManager.focus()
      result(nil)
      break
    case "hide":
      wManager.hide()
      result(nil)
      break
    case "blur":
      wManager.blur()
      result(nil)
      break
    case "close":
      wManager.close()
      result(nil)
      break
    case "isVisible":
      result(wManager.isVisible())
      break
    case "isMaximized":
      result(wManager.isMaximized())
      break
    case "maximize":
      wManager.maximize()
      result(nil)
      break
    case "unmaximize":
      wManager.unmaximize()
      result(nil)
      break
    case "isMinimized":
      result(wManager.isMinimized())
      break
    case "minimize":
      wManager.minimize()
      result(nil)
      break
    case "restore":
      wManager.restore()
      result(nil)
      break
    case "getSize":
      let size: NSSize = wManager.getSize()
      result(["width": size.width, "height": size.height])
      break
    case "setSize":
      wManager.setSize(args: args)
      result(nil)
      break
    case "getMinSize":
      result(wManager.getMinSize())
      break
    case "setMinSize":
      wManager.setMinSize(args: args)
      result(nil)
      break
    case "getMaxSize":
      result(wManager.getMaxSize())
      break
    case "setMaxSize":
      wManager.setMaxSize(args: args)
      result(nil)
      break
    case "getScreenSize":
      let size: NSSize = wManager.getScreenSize()
      result(["width": size.width, "height": size.height])
      break
    case "getPosition":
      let position: [String: Any] = wManager.getPosition(args: args)!
      let global: Bool = args["global"] as? Bool ?? false
      if global {
        result(["globalX": position["globalX"], "globalY": position["globalY"], "x": position["x"], "y": position["y"]])
      } else {
        result(["x": position["x"], "y": position["y"]])
      }
      break
    case "setPosition":
      wManager.setPosition(args: args)
      result(nil)
      break
    case "center":
      wManager.center(args: args)
      result(nil)
      break
    case "getBounds":
      let rect = wManager.getBounds(args: args)
      result(["x": rect.origin.x, "y": rect.origin.y, "width": rect.size.width, "height": rect.size.height])
      break
    case "setBounds":
      wManager.setBounds(args: args)
      result(nil)
      break
    case "getTitle":
      result(wManager.getTitle())
      break
    case "setTitle":
      wManager.setTitle(args: args)
      result(true)
      break
    case "getAnimationBehavior":
      result(wManager.getAnimationBehavior())
      break
    case "setAnimationBehavior":
      wManager.setAnimationBehavior(args: args)
      result(nil)
      break
    case "setAsFrameless":
      wManager.setAsFrameless()
      result(nil)
      break
    case "getTitleBarStyle":
      result(wManager.getTitleBarStyle())
      break
    case "setTitleBarStyle":
      wManager.setTitleBarStyle(args: args)
      result(nil)
      break
    case "getOpacity":
      result(wManager.getOpacity())
      break
    case "setOpacity":
      wManager.setOpacity(args: args)
      result(nil)
      break
    case "addListener":
      wManager.listener = true
      result(nil)
      break
    case "removeListener":
      wManager.listener = false
      result(nil)
      break
    case "getMousePoint":
      result(wManager.getMousePoint())
      break
    case "addListenPan":
      result(wManager.addListenPan())
      break
    case "removeListenPan":
      wManager.removeListenPan()
      result(nil)
      break
    case "addListenHover":
      let eventid: Int64 = args["eventid"] as! Int64
      wManager.addListenHover(eventid)
      result(nil)
      break
    case "removeListenHover":
      let eventid: Int64 = args["eventid"] as! Int64
      wManager.removeListenHover(eventid)
      result(nil)
      break
    case "addPreListenPan":
      let eventid: Int64 = args["eventid"] as! Int64
      wManager.addPreListenPan(eventid)
      result(nil)
      break
    case "removePreListenPan":
      let eventid: Int64 = args["eventid"] as! Int64
      wManager.removePreListenPan(eventid)
      result(nil)
      break
    case "emit":
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
