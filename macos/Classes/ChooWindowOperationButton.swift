import Cocoa

public let StringToButtonType: [String: NSWindow.ButtonType] = [
  "close": .closeButton,
  "miniaturize": .miniaturizeButton,
  "zoom": .zoomButton,
]

private let IndexToButtonTypes: [Int: NSWindow.ButtonType] = [
  0: .closeButton,
  1: .miniaturizeButton,
  2: .zoomButton,
]

private let ButtonTypesToIndex: [Int: NSWindow.ButtonType] = [
  0: .closeButton,
  1: .miniaturizeButton,
  2: .zoomButton,
]

private class SetInterval {
  private var isRunning = false
  private var nextDeadline: DispatchTime = .now()
  private let interval: TimeInterval
  private let callback: () -> Void
  private let queue: DispatchQueue
  
  init(interval: TimeInterval, queue: DispatchQueue = .main, callback: @escaping () -> Void) {
      self.interval = interval
      self.callback = callback
      self.queue = queue
  }
  
  func start() {
      guard !isRunning else { return }
      
      isRunning = true
      nextDeadline = .now() + interval
      scheduleNext()
  }
  
  func pause() {
      isRunning = false
  }
  
  func resume() {
    guard !isRunning else { return }
    
    isRunning = true
    // 计算剩余时间，确保间隔准确
    let remaining = max(
        Int64(nextDeadline.uptimeNanoseconds) - Int64(DispatchTime.now().uptimeNanoseconds),
        0
    )
    nextDeadline = .now() + Double(remaining) / 1_000_000_000
    scheduleNext()
  }
  
  func stop() {
      isRunning = false
  }
  
  private func scheduleNext() {
      guard isRunning else { return }
      
      queue.asyncAfter(deadline: nextDeadline) { [weak self] in
          guard let self = self, self.isRunning else { return }
          
          self.callback()
          self.nextDeadline = .now() + self.interval
          self.scheduleNext()
      }
  }
  
  deinit {
//      stop()
  }
}

private class ChooWindowOperationAnchor: NSObject {
  private var topAnchor: NSLayoutConstraint
  private var leftAnchor: NSLayoutConstraint
  private var widthAnchor: NSLayoutConstraint
  public var heightAnchor: NSLayoutConstraint

  private var contentWidthAnchor: NSLayoutConstraint
  private var contentHeightAnchor: NSLayoutConstraint
  private var contentCenterAnchor: NSLayoutConstraint

  private var closeBtnLeftAnchor: NSLayoutConstraint
  private var closeBtnCenterAnchor: NSLayoutConstraint
  private var closeBtnWidthAnchor: NSLayoutConstraint
  private var closeBtnHeightAnchor: NSLayoutConstraint

  private var miniBtnLeftAnchor: NSLayoutConstraint
  private var miniBtnCenterAnchor: NSLayoutConstraint
  private var miniBtnWidthAnchor: NSLayoutConstraint
  private var miniBtnHeightAnchor: NSLayoutConstraint

  private var zoomBtnLeftAnchor: NSLayoutConstraint
  private var zoomBtnCenterAnchor: NSLayoutConstraint
  private var zoomBtnWidthAnchor: NSLayoutConstraint
  private var zoomBtnHeightAnchor: NSLayoutConstraint

  public let constraints: [NSLayoutConstraint]

  public var width: CGFloat {
    let spacing = self.spacing
    let width = self.btnSize.width
    return width * 3 + spacing * 2
  }

  public var top: CGFloat {
    get {
      return topAnchor.constant
    }
    set {
      topAnchor.constant = newValue
    }
  }

  public var left: CGFloat {
    get {
      return leftAnchor.constant
    }
    set {
      leftAnchor.constant = newValue
    }
  }

  public var height: CGFloat {
    get {
      return heightAnchor.constant
    }
    set {
      heightAnchor.constant = newValue
    }
  }

  public var spacing: CGFloat {
    get {
      return miniBtnLeftAnchor.constant
    }
    set {
      [miniBtnLeftAnchor, zoomBtnLeftAnchor].forEach {
        $0.constant = newValue
      }
      widthAnchor.constant = width
      contentWidthAnchor.constant = width
    }
  }

  public var btnSize: CGSize {
    get {
      return CGSize(width: closeBtnWidthAnchor.constant, height: closeBtnHeightAnchor.constant)
    }
    set {
      [closeBtnWidthAnchor, miniBtnWidthAnchor, zoomBtnWidthAnchor].forEach {
        $0.constant = newValue.width
      }
      [closeBtnHeightAnchor, miniBtnHeightAnchor, zoomBtnHeightAnchor].forEach {
        $0.constant = newValue.height
      }
      contentHeightAnchor.constant = newValue.height
      widthAnchor.constant = width
      contentWidthAnchor.constant = width

    }
  }

  init(_ window: NSWindow, box: NSView, content: NSView, closeBtn: ImitateButton, miniBtn: ImitateButton, zoomBtn: ImitateButton) {
    topAnchor = box.topAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: 0)
    leftAnchor = box.leftAnchor.constraint(equalTo: window.contentView!.leftAnchor, constant: 0)
    widthAnchor = box.widthAnchor.constraint(equalToConstant: 0)
    heightAnchor = box.heightAnchor.constraint(equalToConstant: 0)
    
    contentHeightAnchor = content.heightAnchor.constraint(equalToConstant: 0)
    contentWidthAnchor = content.widthAnchor.constraint(equalToConstant: 0)
    contentCenterAnchor = content.centerYAnchor.constraint(equalTo: box.centerYAnchor)

    closeBtnLeftAnchor = closeBtn.leftAnchor.constraint(equalTo: box.leftAnchor, constant: 0)
    closeBtnCenterAnchor = closeBtn.centerYAnchor.constraint(equalTo: box.centerYAnchor)
    closeBtnWidthAnchor = closeBtn.widthAnchor.constraint(equalToConstant: 0)
    closeBtnHeightAnchor = closeBtn.heightAnchor.constraint(equalToConstant: 0)
    
    miniBtnLeftAnchor = miniBtn.leftAnchor.constraint(equalTo: closeBtn.rightAnchor, constant: 0)
    miniBtnCenterAnchor = miniBtn.centerYAnchor.constraint(equalTo: box.centerYAnchor)
    miniBtnWidthAnchor = miniBtn.widthAnchor.constraint(equalToConstant: 0)
    miniBtnHeightAnchor = miniBtn.heightAnchor.constraint(equalToConstant: 0)
    
    zoomBtnLeftAnchor = zoomBtn.leftAnchor.constraint(equalTo: miniBtn.rightAnchor, constant: 0)
    zoomBtnCenterAnchor = zoomBtn.centerYAnchor.constraint(equalTo: box.centerYAnchor)
    zoomBtnWidthAnchor = zoomBtn.widthAnchor.constraint(equalToConstant: 0)
    zoomBtnHeightAnchor = zoomBtn.heightAnchor.constraint(equalToConstant: 0)

    constraints = [
      topAnchor, leftAnchor, widthAnchor, heightAnchor,
      contentWidthAnchor, contentHeightAnchor, contentCenterAnchor,
      closeBtnLeftAnchor, closeBtnCenterAnchor, closeBtnWidthAnchor, closeBtnHeightAnchor,
      miniBtnLeftAnchor, miniBtnCenterAnchor, miniBtnWidthAnchor, miniBtnHeightAnchor,
      zoomBtnLeftAnchor, zoomBtnCenterAnchor, zoomBtnWidthAnchor, zoomBtnHeightAnchor,
    ]
  }
}

class ImitateButtonView: NSView {
  
  override func hitTest(_ point: NSPoint) -> NSView? {
    return nil
  }

  init() {
    super.init(frame: .zero)
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}

class ImitateButtonIconView: NSImageView {
  
  override func hitTest(_ point: NSPoint) -> NSView? {
    return nil
  }

  init(image: NSImage) {
    super.init(frame: .zero)
    self.image = image
    wantsLayer = true
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}

class ImitateContent: NSView {
  
  private var _callback: (_ type: NSEvent.EventType) -> Void
  private var mouseEvent: Any?
//  private var dragged: Bool = true
  
  init(_ callback: @escaping (_ type: NSEvent.EventType) -> Void) {
    _callback = callback
    super.init(frame: .zero)
    wantsLayer = true
    layer?.backgroundColor = NSColor.red.cgColor.copy(alpha: 0.01)
  }
  
  required init?(coder: NSCoder) {
    _callback = {
      type in
      print(type)
    }
    super.init(coder: coder)
  }
  
  override func viewDidMoveToWindow() {
    
    if window != nil {
      mouseEvent = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { event in
        let screenLocation = NSEvent.mouseLocation
        let windowFrame = self.window!.frame
        let windowLocation = NSPoint(
          x: screenLocation.x - windowFrame.origin.x,
          y: screenLocation.y - windowFrame.origin.y
        )
        let frame = CGRect(
          x: self.superview!.frame.origin.x - 5,
          y: windowFrame.size.height - self.frame.origin.y - self.frame.height - 5,
          width: self.frame.width + 10,
          height: self.frame.height + 10
        )
//        if event.type == .leftMouseDragged {
//          if !self.dragged || frame.contains(windowLocation) {
//            self.dragged = false
//            return nil
//          }
//          return event
//        }
//        
//        if event.type == .leftMouseUp {
//          self.dragged = true
//        }
        
        self._callback(frame.contains(windowLocation) ? .mouseEntered : .mouseExited)
        return event
      }
    } else {
      NSEvent.removeMonitor(mouseEvent!)
      mouseEvent = nil
    }

  }
  
}

class ImitateButton: NSView {
  private static var imageCache: [String:NSImage] = [:]
  private static let buttonIconImageMap: [NSWindow.ButtonType: String] = [
    .closeButton: "close",
    .miniaturizeButton: "mini",
    .zoomButton: "fullscreen",
  ]
  
  public static let buttonColorMap: [NSWindow.ButtonType: CGColor] = [
    .closeButton: NSColor(srgbRed: 255 / 255, green: 96 / 255, blue: 86 / 255, alpha: 1).cgColor,
    .miniaturizeButton: NSColor(srgbRed: 254 / 255, green: 188 / 255, blue: 46 / 255, alpha: 1).cgColor,
    .zoomButton: NSColor(srgbRed: 40 / 255, green: 200 / 255, blue: 64 / 255, alpha: 1).cgColor,
  ]
  
  public static let buttonDisableColor = NSColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.25).cgColor

  private let _window: NSWindow
  private var trackingArea: NSTrackingArea?
  private var _isEnabled: Bool = true
  
  public var isEnabled: Bool {
    get { _isEnabled }
    set {
      _isEnabled = newValue
      windowButton?.isEnabled = newValue
      setBackgroundColorState(newValue)
    }
  }

  private var _buttonConstraints: [String: NSLayoutConstraint] = [:]
  private var _iconConstraints: [String: NSLayoutConstraint] = [:]
  private var _backgroundConstraints: [String: NSLayoutConstraint] = [:]

  private var _buttonType: NSWindow.ButtonType
  private var dispatchInterval: SetInterval?
  
  public var buttonType: NSWindow.ButtonType { _buttonType }

  private var _iconName: String? {
    return ImitateButton.buttonIconImageMap[buttonType]
  }
  
  public var iconName: String? {
    get {
      ImitateButton.buttonIconImageMap[buttonType]
    }
    set {
      if let icon = newValue {
        iconView?.image = getImage(icon)
      }
    }
  }

  private var _round: CGFloat = 0
  public var round: CGFloat {
    get { _round }
    set {
      _round = newValue
      layer?.cornerRadius = newValue
    }
  }

  private var _windowButton: NSButton? = nil
  public var windowButton: NSButton? {
    if let windowButton = _windowButton {
      return windowButton
    } else {
      if ImitateButton.buttonIconImageMap.keys.contains(buttonType) {
        _windowButton = NSWindow.standardWindowButton(buttonType, for: _window.styleMask)
        _windowButton?.translatesAutoresizingMaskIntoConstraints = false
        _windowButton?.alphaValue = 0.01
        _windowButton?.imagePosition = .imageOverlaps

      }
      return _windowButton
    }
  }

  private var _iconView: ImitateButtonIconView? = nil
  public var iconView: ImitateButtonIconView? {
    if let iconView = _iconView {
      return iconView
    } else {
      if let iconName = _iconName {
        let image = getImage(iconName)
        let view = ImitateButtonIconView(image: image!)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alphaValue = 0
        _iconView = view
      }
      return _iconView
    }
  }

  private var _backgroundView: ImitateButtonView? = nil
  public var backgroundView: ImitateButtonView {
    if let backgroundView = _backgroundView {
      return backgroundView
    } else {
      _backgroundView = ImitateButtonView()
      _backgroundView?.wantsLayer = true
      _backgroundView?.translatesAutoresizingMaskIntoConstraints = false
      _backgroundView?.alphaValue = 0
      _backgroundView?.layer?.backgroundColor = NSColor.white.cgColor
    }
    return _backgroundView!
  }

  init(type: NSWindow.ButtonType, window: NSWindow) {
    _buttonType = type
    _window = window
    super.init(frame: .zero)
    wantsLayer = true
    translatesAutoresizingMaskIntoConstraints = false
    layer?.backgroundColor = ImitateButton.buttonColorMap[type]
    

    if let windowButton = windowButton {
      addSubview(windowButton)
    }

    addSubview(backgroundView)

    if let iconView = iconView {
      addSubview(iconView)
    }
    
    initConstraints()
  }

  required init?(coder: NSCoder) {
    _buttonType = .toolbarButton
    _window = NSWindow()
    super.init(coder: coder)
  }
  
  public func setBackgroundColorState(_ state: Bool) {
    if !state {
      layer?.backgroundColor = ImitateButton.buttonDisableColor
    } else {
      layer?.backgroundColor = ImitateButton.buttonColorMap[buttonType]
    }
  }
  
  private func getImage(_ iconName: String) -> NSImage? {
    if let image = ImitateButton.imageCache[iconName] {
      return image
    }
    let mainBundle = Bundle(for: Self.self)
    if let resourceBundleURL = mainBundle.url(
      forResource: "choo_window_manager", withExtension: "bundle")
    {
      if let resourceBundle = Bundle(url: resourceBundleURL) {
        if let imagePath = resourceBundle.url(forResource: iconName, withExtension: "svg") {
          let image = NSImage(contentsOf: imagePath)!
          ImitateButton.imageCache[iconName] = image
          return image
        }
      }
    }
    return nil
  }

  private func initConstraints() {
    _backgroundConstraints.merge([
      "l": backgroundView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
      "t": backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
      "w": backgroundView.widthAnchor.constraint(equalToConstant: 0),
      "h": backgroundView.heightAnchor.constraint(equalToConstant: 0),
    ]) {
      (item, index) in item
    }
    if let iconView = iconView {
      _iconConstraints.merge([
        "cx": iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
        "cy": iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
        "w": iconView.widthAnchor.constraint(equalToConstant: 0),
        "h": iconView.heightAnchor.constraint(equalToConstant: 0),
      ]) {
        (item, index) in item
      }
    }
    if let windowButton = windowButton {
      _buttonConstraints.merge([
        "cx": windowButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        "cy": windowButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        "w": windowButton.widthAnchor.constraint(equalToConstant: 0),
        "h": windowButton.heightAnchor.constraint(equalToConstant: 0),
      ]) {
        (item, index) in item
      }
    }
  }

  override func resizeSubviews(withOldSize oldSize: NSSize) {
    let width = frame.size.width
    let height = frame.size.height

    round = (width > height ? width : height) / 2

    _backgroundConstraints["w"]?.constant = width
    _backgroundConstraints["h"]?.constant = width

    _iconConstraints["w"]?.constant = (width > height ? height : width) * 0.66
    _iconConstraints["h"]?.constant = (width > height ? height : width) * 0.66

    _buttonConstraints["w"]?.constant = width // * 1.5
    _buttonConstraints["h"]?.constant = height // * 1.5
    layoutSubtreeIfNeeded()
    addTrackingArea()
  }
    
  private func containsMouseLocation() -> Bool {
    // 获取鼠标在屏幕坐标系中的位置
    let mouseLocation = NSEvent.mouseLocation
    
    // 将屏幕坐标转换为窗口坐标
    guard let window = self.window else { return false }
    let windowRect = window.convertFromScreen(NSRect(origin: mouseLocation, size: .zero))
    let windowPoint = windowRect.origin
    
    // 将窗口坐标转换为视图坐标
    let viewPoint = self.convert(windowPoint, from: nil)
    
    // 检查点是否在视图边界内
    return self.bounds.contains(viewPoint)
  }

  private func addTrackingArea() {
    if let existingTrackingArea = trackingArea {
      self.removeTrackingArea(existingTrackingArea)
    }
    trackingArea = NSTrackingArea(
      rect: self.bounds,
      options: [.activeInKeyWindow, .mouseMoved, .mouseEnteredAndExited],
      owner: self,
      userInfo: nil
    )
    self.addTrackingArea(trackingArea!)
  }

  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    var constraints: [NSLayoutConstraint] = []
    constraints.append(contentsOf: _backgroundConstraints.values)
    constraints.append(contentsOf: _iconConstraints.values)
    constraints.append(contentsOf: _buttonConstraints.values)
    if window != nil {
      NSLayoutConstraint.activate(constraints)
      addTrackingArea()
    } else {
      if let existingTrackingArea = trackingArea {
        self.removeTrackingArea(existingTrackingArea)
        trackingArea = nil
      }
      NSLayoutConstraint.deactivate(constraints)
    }
  }
  
  override func mouseEntered(with event: NSEvent) {
    if !isEnabled {
      return
    }
    if let dispatchInterval = dispatchInterval {
      dispatchInterval.stop()
      dispatchInterval.resume()
    } else {
      dispatchInterval = SetInterval(interval: 0.2) {
        self.windowButton?.state = .mixed
        if NSEvent.pressedMouseButtons & (1 << 0) != 0 && self.containsMouseLocation() {
          self.backgroundView.alphaValue = 0.3
        } else if self.backgroundView.alphaValue == 0.3 {
          self.backgroundView.alphaValue = 0
          self.windowButton?.state = .off
        }
      }
      dispatchInterval?.start()
    }
    super.mouseEntered(with: event)
  }
  
  override func mouseExited(with event: NSEvent) {
    if NSEvent.pressedMouseButtons & (1 << 0) != 0 {
      return
    }
    dispatchInterval?.stop()
    backgroundView.alphaValue = 0
    windowButton?.state = .off
  }

}

class ChooWindowOperationButtonManager: NSView {

  private var _window: NSWindow?
  private var _enabled: Bool = false

  private var _left: CGFloat? = nil
  private var _top: CGFloat = 0
  private var _height: CGFloat = 28
  private var _spacing: CGFloat = 8
  private var _size: CGSize = CGSize(width: 12, height: 12)

  private var trackingArea: NSTrackingArea?

  public var buttons: [ImitateButton] = []
  private var contentView: ImitateContent?

  private var anchor: ChooWindowOperationAnchor!
  private var monitorEvent: Any?

  private var _isEnter: Bool = false

  public var isEnter: Bool {
    _isEnter
  }

  public override var isFlipped: Bool { true }
  public override var window: NSWindow? {
    return _window
  }

  public var enabled: Bool {
    get { return _enabled }
    set {
      _enabled = newValue
      newValue ? show() : hide()
    }
  }

  public var top: CGFloat {
    get { return _top }
    set {
      _top = newValue
      anchor.top = _top
    }
  }

  public var left: CGFloat? {
    get { return _left ?? _spacing }
    set {
      _left = newValue
      anchor.left = newValue ?? _spacing
    }
  }

  public var height: CGFloat {
    get { return _height }
    set {
      _height = newValue
      anchor.height = _height
    }
  }

  public var spacing: CGFloat {
    get { return _spacing }
    set {
      _spacing = newValue
      anchor.spacing = newValue
      if _left == nil {
        anchor.left = newValue
      }
      layoutSubtreeIfNeeded()
    }
  }
  public var btnSize: CGSize {
    get { return _size }
    set {
      _size = newValue
      anchor.btnSize = newValue
      layoutSubtreeIfNeeded()
    }
  }

  public var width: CGFloat {
    return anchor.width
  }

  init(_ window: NSWindow) {
    _window = window
    buttons.append(contentsOf: [
      ImitateButton(type: .closeButton, window: _window!),
      ImitateButton(type: .miniaturizeButton, window: _window!),
      ImitateButton(type: .zoomButton, window: _window!),
    ])
    
    super.init(frame: .zero)
    
    contentView = ImitateContent() { type in
      var alphaValue: CGFloat = 0
      window.isMovable = false
      if (type == .mouseEntered) {
        alphaValue = 0.5
        window.isMovable = true
      }
      self.buttons.forEach { button in
        if !button.isEnabled { return }
        button.iconView?.alphaValue = alphaValue
        if !window.isKeyWindow && !window.isMainWindow {
          button.layer?.backgroundColor = type == .mouseEntered ? ImitateButton.buttonColorMap[button.buttonType] : ImitateButton.buttonDisableColor
        }
        button.windowButton?.state = .off
      }
    }

    anchor = ChooWindowOperationAnchor(
      window,
      box: self,
      content: contentView!,
      closeBtn: buttons[0],
      miniBtn: buttons[1],
      zoomBtn: buttons[2]
    )
    
    translatesAutoresizingMaskIntoConstraints = false

    buttons.forEach { button in
      button.translatesAutoresizingMaskIntoConstraints = false
      contentView!.addSubview(button)
    }
    
    contentView!.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(contentView!)
  }

  private func show() {
    var buttonHiddenStatus: [NSWindow.ButtonType: Bool] = [:]
    var buttonEnabledStatus: [NSWindow.ButtonType: Bool] = [:]
    let defaultButton = [
      window?.standardWindowButton(.closeButton),
      window?.standardWindowButton(.miniaturizeButton),
      window?.standardWindowButton(.zoomButton),
    ]
    defaultButton.forEach {
      if let button = $0 {
        let index = defaultButton.firstIndex(of: button)!
        buttonHiddenStatus[IndexToButtonTypes[index]!] = button.isHidden
        buttonEnabledStatus[IndexToButtonTypes[index]!] = button.isEnabled
        button.isHidden = true
      }
    }
    buttons.forEach { button in
      let index = buttons.firstIndex(of: button)!
      button.isHidden = buttonHiddenStatus[IndexToButtonTypes[index]!] ?? false
      button.isEnabled = buttonEnabledStatus[IndexToButtonTypes[index]!] ?? true
    }
    anchor.height = height
    anchor.top = top
    anchor.left = left!
    anchor.spacing = spacing
    anchor.btnSize = btnSize
    
    monitorEvent = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {event in
      if event.modifierFlags.contains(.option) {
        self.buttons[2].iconName = "add"
      } else {
        self.buttons[2].iconName = "fullscreen"
      }
      return event
    }

    window?.contentView?.addSubview(self)
    NSLayoutConstraint.activate(anchor.constraints)
    layoutSubtreeIfNeeded()
  }

  private func hide() {
    var buttonHiddenStatus: [NSWindow.ButtonType: Bool] = [:]
    var buttonEnabledStatus: [NSWindow.ButtonType: Bool] = [:]
    
    if let monitorEvent = monitorEvent {
      NSEvent.removeMonitor(monitorEvent)
      self.monitorEvent = nil
    }
    
    buttons.forEach { button in
      let index = buttons.firstIndex(of: button)!
      buttonHiddenStatus[IndexToButtonTypes[index]!] = button.isHidden
      buttonEnabledStatus[IndexToButtonTypes[index]!] = button.isEnabled
      button.iconView?.alphaValue = 0
    }
    self.removeFromSuperview()
    if let trackingArea = trackingArea { self.removeTrackingArea(trackingArea) }
    let defaultButtons = [
      window?.standardWindowButton(.closeButton),
      window?.standardWindowButton(.miniaturizeButton),
      window?.standardWindowButton(.zoomButton),
    ]
    defaultButtons.forEach {
      if let button = $0 {
        let index = defaultButtons.firstIndex(of: button)!
        button.isHidden = buttonHiddenStatus[IndexToButtonTypes[index]!] ?? false
        button.isEnabled = buttonEnabledStatus[IndexToButtonTypes[index]!] ?? true
      }
    }
    NSLayoutConstraint.deactivate(anchor.constraints)
  }

  public func setButtonHidden(_ types: [NSWindow.ButtonType], state: Bool) {
    if enabled {
      buttons.forEach { button in
        let index = buttons.firstIndex(of: button)!
        let type = IndexToButtonTypes[index]!

        if types.contains(type) {
          button.isHidden = state
        }
      }
    } else {
      let defaultButtons = [
        window?.standardWindowButton(.closeButton),
        window?.standardWindowButton(.miniaturizeButton),
        window?.standardWindowButton(.zoomButton),
      ]
      defaultButtons.forEach {
        if let button = $0 {
          let index = defaultButtons.firstIndex(of: button)!
          let type = IndexToButtonTypes[index]!

          if types.contains(type) {
            button.isHidden = state
          }
        }
      }
    }
  }

  public func setButtonEnabled(_ types: [NSWindow.ButtonType], state: Bool) {
    if enabled {
      buttons.forEach { button in
        let index = buttons.firstIndex(of: button)!
        let type = IndexToButtonTypes[index]!

        if types.contains(type) {
          button.isEnabled = state
        }
      }
    } else {
      let defaultButtons = [
        window?.standardWindowButton(.closeButton),
        window?.standardWindowButton(.miniaturizeButton),
        window?.standardWindowButton(.zoomButton),
      ]
      defaultButtons.forEach {
        if let button = $0 {
          let index = defaultButtons.firstIndex(of: button)!
          let type = IndexToButtonTypes[index]!

          if types.contains(type) {
            button.isEnabled = state
          }
        }
      }
    }
  }
  
  public func setWindowState(_ state: Bool) {
    buttons.forEach { button in
      if !button.isEnabled && state {
        return
      }
      button.setBackgroundColorState(state)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
