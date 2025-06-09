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

private class ChooWindowOperationAnchor: NSObject {
  private var topAnchor: NSLayoutConstraint
  private var leftAnchor: NSLayoutConstraint
  private var widthAnchor: NSLayoutConstraint
  public var heightAnchor: NSLayoutConstraint

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
    get {
      let spacing = self.spacing
      let width = self.btnSize.width
      return width * 3 + spacing * 2
    }
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
      widthAnchor.constant = width

    }
  }

  init(_ window: NSWindow, box: NSView, closeBtn: NSButton, miniBtn: NSButton, zoomBtn: NSButton) {
    topAnchor = box.topAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: 0)
    leftAnchor = box.leftAnchor.constraint(equalTo: window.contentView!.leftAnchor, constant: 0)
    widthAnchor = box.widthAnchor.constraint(equalToConstant: 0)
    heightAnchor = box.heightAnchor.constraint(equalToConstant: 0)

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
      closeBtnLeftAnchor, closeBtnCenterAnchor, closeBtnWidthAnchor, closeBtnHeightAnchor,
      miniBtnLeftAnchor, miniBtnCenterAnchor, miniBtnWidthAnchor, miniBtnHeightAnchor,
      zoomBtnLeftAnchor, zoomBtnCenterAnchor, zoomBtnWidthAnchor, zoomBtnHeightAnchor,
    ]
  }

}

class ChooWindowOperationButtonManager: NSView {
  
  private var _window: NSWindow?
  private var _enabled: Bool = false

  private var _left: CGFloat? = nil
  private var _top: CGFloat = 0
  private var _height: CGFloat = 28
  private var _spacing: CGFloat = 6
  private var _size: CGSize = CGSize(width: 14, height: 14)

  private var _hover: Bool = false
  private var trackingArea: NSTrackingArea?
  
  private var buttons: [NSButton?] = []

  private var anchor: ChooWindowOperationAnchor!

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
    get { return _left ?? _spacing}
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
      anchor.spacing = _spacing
    }
  }
  public var btnSize: CGSize {
    get { return _size }
    set {
      _size = newValue
      anchor.btnSize = _size
    }
  }

  public var width: CGFloat {
    get { return anchor.width }
  }

  init(_ window: NSWindow) {
    _window = window
    buttons.append(contentsOf: [
      NSWindow.standardWindowButton(.closeButton, for: window.styleMask),
      NSWindow.standardWindowButton(.miniaturizeButton, for: window.styleMask),
      NSWindow.standardWindowButton(.zoomButton, for: window.styleMask),
    ])
    super.init(frame: .zero)
    
    anchor = ChooWindowOperationAnchor(
      window,
      box: self,
      closeBtn: buttons[0]!,
      miniBtn: buttons[1]!,
      zoomBtn: buttons[2]!
    )
    
    translatesAutoresizingMaskIntoConstraints = false
    
    buttons.forEach {
      if let button = $0 {
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
      }
    }
  }

  private func show() {
    var buttonHiddenStatus: [NSWindow.ButtonType: Bool] = [:]
    var buttonEnabledStatus: [NSWindow.ButtonType: Bool] = [:]
    let defaultButton = [
      window?.standardWindowButton(.closeButton),
      window?.standardWindowButton(.miniaturizeButton),
      window?.standardWindowButton(.zoomButton)
    ]
    defaultButton.forEach {
      if let button = $0 {
        let index = defaultButton.firstIndex(of: button)!
        buttonHiddenStatus[IndexToButtonTypes[index]!] = button.isHidden
        buttonEnabledStatus[IndexToButtonTypes[index]!] = button.isEnabled
        button.isHidden = true
      }
    }
    buttons.forEach {
      if let button = $0 {
        let index = buttons.firstIndex(of: button)!
        button.isHidden = buttonHiddenStatus[IndexToButtonTypes[index]!] ?? false
        button.isEnabled = buttonEnabledStatus[IndexToButtonTypes[index]!] ?? true
      }
    }
//    wantsLayer = true
//    layer?.backgroundColor = NSColor.blue.cgColor
    anchor.height = height
    anchor.top = top
    anchor.left = left!
    anchor.spacing = spacing
    anchor.btnSize = btnSize
    
    window?.contentView?.addSubview(self)
    NSLayoutConstraint.activate(anchor.constraints)
    layoutSubtreeIfNeeded()

    trackingArea = NSTrackingArea(
      rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self,
      userInfo: nil)
      
    addTrackingArea(trackingArea!)
  }

  private func hide() {
    var buttonHiddenStatus: [NSWindow.ButtonType: Bool] = [:]
    var buttonEnabledStatus: [NSWindow.ButtonType: Bool] = [:]
    buttons.forEach {
      if let button = $0 {
        let index = buttons.firstIndex(of: button)!
        buttonHiddenStatus[IndexToButtonTypes[index]!] = button.isHidden
        buttonEnabledStatus[IndexToButtonTypes[index]!] = button.isEnabled
      }
    }
    self.removeFromSuperview()
    if let trackingArea = trackingArea { self.removeTrackingArea(trackingArea) }
    let defaultButtons = [
      window?.standardWindowButton(.closeButton),
      window?.standardWindowButton(.miniaturizeButton),
      window?.standardWindowButton(.zoomButton)
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

  override func mouseEntered(with event: NSEvent) {
    _hover = true
    buttons.forEach {
      if let button = $0 {
        button.needsDisplay = true
      }
    }
  }

  override func mouseExited(with event: NSEvent) {
    _hover = false
    buttons.forEach {
      if let button = $0 {
        button.needsDisplay = true
      }
    }
  }
  
  @objc func _mouseInGroup(_ sender: Any) -> Bool { return _hover }
  
  public func setButtonHidden(_ types: [NSWindow.ButtonType], state: Bool) {
    if enabled {
      buttons.forEach {
        if let button = $0 {
          let index = buttons.firstIndex(of: button)!
          let type = IndexToButtonTypes[index]!
          
          if types.contains(type) {
            button.isHidden = state
          }
        }
      }
    } else {
      let defaultButtons = [
        window?.standardWindowButton(.closeButton),
        window?.standardWindowButton(.miniaturizeButton),
        window?.standardWindowButton(.zoomButton)
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
      buttons.forEach {
        if let button = $0 {
          let index = buttons.firstIndex(of: button)!
          let type = IndexToButtonTypes[index]!
          
          if types.contains(type) {
            button.isEnabled = state
          }
        }
      }
    } else {
      let defaultButtons = [
        window?.standardWindowButton(.closeButton),
        window?.standardWindowButton(.miniaturizeButton),
        window?.standardWindowButton(.zoomButton)
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

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

