class ImitateButton: NSView {
  private static let buttonIconImageMap: [NSWindow.ButtonType: String] = [
    .closeButton: "close",
    .miniaturizeButton: "mini",
    .zoomButton: "zoom",
  ]
  
  private let _window: NSWindow
  
  private var _buttonType: NSWindow.ButtonType
  public var buttonType: NSWindow.ButtonType { _buttonType }
  
  private var _iconName: String? {
    return ImitateButton.buttonIconImageMap[buttonType]
  }
  
  private var _windowButton: NSButton? = nil
  private var windowButton: NSButton? {
    if ImitateButton.buttonIconImageMap.keys.contains(buttonType) {
      _windowButton = NSWindow.standardWindowButton(buttonType, for: _window.styleMask)
    }
    return _windowButton
  }
  
  private var _buttonConstraints: [String: NSLayoutConstraint] = [:]
  private var _iconConstraints: [String: NSLayoutConstraint] = [:]
//  private var _iconConstraints: [String: NSLayoutConstraint] = [:]

  private var _iconView: NSImageView? = nil
  private var iconView: NSImageView? {
    get {
      if let iconName = _iconName {
        let mainBundle = Bundle(for: Self.self)
        if let resourceBundleURL = mainBundle.url(forResource: "choo_window_manager", withExtension: "bundle") {
          if let resourceBundle = Bundle(url: resourceBundleURL) {
            if let imagePath = resourceBundle.url(forResource: iconName, withExtension: "svg") {
              let image = NSImage(contentsOf: imagePath)!
              let view = NSImageView(image: image)
              _iconView = view
            }
          }
        }
      }
      return _iconView
    }
  }
  
  init (type: NSWindow.ButtonType, window: NSWindow) {
    _buttonType = type
    _window = window
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    _buttonType = .toolbarButton
    _window = NSWindow()
    super.init(coder: coder)
  }
  
  private func initConstraints() {
    
  }
  
  
  override func resizeSubviews(withOldSize oldSize: NSSize) {
    
  }
  
  
  override func viewDidMoveToSuperview() {
    print("ImitateButton")
  }
}
