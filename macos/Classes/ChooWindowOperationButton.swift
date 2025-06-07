import Cocoa

class ChooWindowOperationButtonManager: NSView {
  // private var _enabled: Bool = false
  // private var _window: NSWindow
  // private var _titlebarView: NSView?
  // private var trackingArea: NSTrackingArea?
  // private var closeBtn: NSButton
  // private var miniBtn: NSButton
  // private var zoomBtn: NSButton
  // private var _x: CGFloat = 0 { didSet { updateLayoutIfNeeded() } }
  // private var _y: CGFloat = 0 { didSet { updateLayoutIfNeeded() } }
  // private var _height: CGFloat = 500 { didSet { updateLayoutIfNeeded() } }
  // private var _spacing: CGFloat = 0 { didSet { updateLayoutIfNeeded() } }
  // private var _hover: Bool = false
  // private var layoutConstraints: [NSLayoutConstraint] = []
  // private var positionConstraints: [NSLayoutConstraint] = []
  // override var window: NSWindow? { _window }
  // override var isFlipped: Bool { true }
  // public var enabled: Bool {
  //   get { _enabled }
  //   set {
  //     _enabled = newValue
  //     newValue ? enableCustomButtons() : restoreSystemButtons()
  //   }
  // }
  // public var x: CGFloat {
  //   get { _x }
  //   set { _x = newValue }
  // }
  // public var y: CGFloat {
  //   get { _y }
  //   set { _y = newValue }
  // }
  // public var height: CGFloat {
  //   get { _height }
  //   set { _height = newValue }
  // }
  // public var spacing: CGFloat {
  //   get { _spacing }
  //   set { _spacing = newValue }
  // }
  // init(_ window: NSWindow) {
  //   self._window = window
  //   self.closeBtn = NSWindow.standardWindowButton(.closeButton, for: window.styleMask)!
  //   self.miniBtn = NSWindow.standardWindowButton(.miniaturizeButton, for: window.styleMask)!
  //   self.zoomBtn = NSWindow.standardWindowButton(.zoomButton, for: window.styleMask)!
  //   super.init(frame: .zero)
  //   translatesAutoresizingMaskIntoConstraints = false
  // }
  // required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  // private func enableCustomButtons() {
  //   [
  //     window!.standardWindowButton(.closeButton)!,
  //     window!.standardWindowButton(.miniaturizeButton)!, window!.standardWindowButton(.zoomButton)!,
  //   ].forEach { $0.isHidden = true }
  //   [closeBtn, miniBtn, zoomBtn].forEach { addSubview($0) }
  //   updateLayoutIfNeeded()
  //   window?.contentView?.addSubview(self)
  //   updateLayoutIfNeeded()
  //   trackingArea = NSTrackingArea(
  //     rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self,
  //     userInfo: nil)
  //   addTrackingArea(trackingArea!)
  // }
  // private func restoreSystemButtons() {
  //   for view in self.subviews { view.removeFromSuperview() }
  //   self.removeFromSuperview()
  //   if let trackingArea = trackingArea { self.removeTrackingArea(trackingArea) }
  //   [
  //     window!.standardWindowButton(.closeButton)!,
  //     window!.standardWindowButton(.miniaturizeButton)!, window!.standardWindowButton(.zoomButton)!,
  //   ].forEach { $0.isHidden = false }
  // }
  // private func updateLayoutIfNeeded() {
  //   NSLayoutConstraint.deactivate(layoutConstraints)
  //   NSLayoutConstraint.deactivate(positionConstraints)
  //   [closeBtn, miniBtn, zoomBtn].forEach {
  //     $0.removeConstraints($0.constraints)
  //     $0.translatesAutoresizingMaskIntoConstraints = false
  //   }
  //   let buttons = [closeBtn, miniBtn, zoomBtn]
  //   var previousButton: NSButton? = nil
  //   var constraints: [NSLayoutConstraint] = []
  //   for (index, button) in buttons.enumerated() {
  //     if index == 0 {
  //       constraints.append(contentsOf: [
  //         button.leftAnchor.constraint(equalTo: self.leftAnchor, constant: spacing),
  //         button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
  //       ])
  //     } else if let prev = previousButton {
  //       constraints.append(contentsOf: [
  //         button.leftAnchor.constraint(equalTo: prev.rightAnchor, constant: spacing),
  //         button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
  //       ])
  //     }
  //     previousButton = button
  //   }
  //   let totalWidth =
  //     buttons.map { $0.frame.width }.reduce(0, +) + CGFloat(buttons.count + 1) * spacing
  //   constraints.append(contentsOf: [
  //     widthAnchor.constraint(equalToConstant: totalWidth),
  //     heightAnchor.constraint(equalToConstant: height),
  //   ])
  //   NSLayoutConstraint.activate(constraints)
  //   layoutConstraints = constraints
  //   if let window = self.window, let contentView = window.contentView {
  //     let posConstraints = [
  //       self.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: x),
  //       self.topAnchor.constraint(equalTo: contentView.topAnchor, constant: y),
  //     ]
  //     NSLayoutConstraint.activate(posConstraints)
  //     positionConstraints = posConstraints
  //   }
  //   self.layoutSubtreeIfNeeded()
  // }
  // private func updateTrackingArea() {
  //   if let trackingArea = trackingArea { self.removeTrackingArea(trackingArea) }
  //   trackingArea = NSTrackingArea(
  //     rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self,
  //     userInfo: nil)
  //   addTrackingArea(trackingArea!)
  // }
  // override func mouseEntered(with event: NSEvent) {
  //   _hover = true
  //   closeBtn.needsDisplay = true
  //   miniBtn.needsDisplay = true
  //   zoomBtn.needsDisplay = true
  // }
  // override func mouseExited(with event: NSEvent) {
  //   _hover = false
  //   closeBtn.needsDisplay = true
  //   miniBtn.needsDisplay = true
  //   zoomBtn.needsDisplay = true
  // }
  // @objc func _mouseInGroup(_ sender: Any) -> Bool { return _hover }

  private var _window: NSWindow?
  private var _enabled: Bool = false
  private var _spacing: CGFloat = 6
  private var _height: CGFloat = 28
  private var _point: CGPoint = .zero

  private var _btnSize: CGFloat = 14

  private var buttons: [NSButton?] = []

  public override var isFlipped: Bool { true }
  public override var window: NSWindow? {
    return _window
  }

  public var enabled: Bool {
    get { return _enabled }
    set {
      _enabled = newValue
      if _enabled {
        show()
      } else {
        hide()
      }
    }
  }

  public var spacing: CGFloat {
    return _spacing
  }

  public var width: CGFloat {
    var width: CGFloat = 0
    buttons.forEach {
      if let button = $0 {
        width += button.frame.width
      }
    }
    return width + spacing * CGFloat(buttons.count - 1)
  }

  init(_ window: NSWindow) {
    _window = window
    buttons.append(contentsOf: [
      NSWindow.standardWindowButton(.closeButton, for: window.styleMask),
      NSWindow.standardWindowButton(.miniaturizeButton, for: window.styleMask),
      NSWindow.standardWindowButton(.zoomButton, for: window.styleMask),
    ])
    super.init(frame: .zero)
    translatesAutoresizingMaskIntoConstraints = false
    buttons.forEach {
      if let button = $0 {
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
      }
    }
  }

  private func show() {
    let closeBtn = window?.standardWindowButton(.closeButton)
    let miniBtn = window?.standardWindowButton(.miniaturizeButton)
    let zoomBtn = window?.standardWindowButton(.zoomButton)
    [closeBtn, miniBtn, zoomBtn].forEach {
      if let button = $0 {
        button.isHidden = true
      }
    }
    wantsLayer = true
    layer?.backgroundColor = NSColor.blue.cgColor
    window?.contentView?.addSubview(self)
    updateFrame()
  }

  private func hide() {
    let closeBtn = window?.standardWindowButton(.closeButton)
    let miniBtn = window?.standardWindowButton(.miniaturizeButton)
    let zoomBtn = window?.standardWindowButton(.zoomButton)
    [closeBtn, miniBtn, zoomBtn].forEach {
      if let button = $0 {
        button.isHidden = false
      }
    }
    self.removeFromSuperview()
  }

  private var lastActivatedConstraints: [NSLayoutConstraint] = []
  private func updateFrame(_ positionConstraint: [NSLayoutConstraint] = []) {
    var buttonConstraint: [NSLayoutConstraint] = []
    removeConstraints(constraints)
    NSLayoutConstraint.deactivate(lastActivatedConstraints)

    buttons.forEach {
      let index = buttons.firstIndex(of: $0)!
      if let button = $0 {

        buttonConstraint.append(contentsOf: [
          button.leftAnchor.constraint(
            equalTo: index == 0 ? leftAnchor : (buttons[index - 1]?.rightAnchor ?? leftAnchor),
            constant: index == 0 ? 0 : spacing),
          button.centerYAnchor.constraint(equalTo: centerYAnchor),
          button.widthAnchor.constraint(
            equalToConstant: _btnSize),
          button.heightAnchor.constraint(
            equalToConstant: _btnSize),
        ])
        // button.needsDisplay = true
        button.layoutSubtreeIfNeeded()
      }
    }

    let topAnchor = self.topAnchor.constraint(
      equalTo: window!.contentView!.topAnchor, constant: _point.y)

    var constraint: [NSLayoutConstraint] = [
      widthAnchor.constraint(equalToConstant: width),
      heightAnchor.constraint(equalToConstant: 28),
      leftAnchor.constraint(equalTo: window!.contentView!.leftAnchor, constant: _point.x),
      topAnchor,
    ]

    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      topAnchor.constant = 0
      // self.layoutSubtreeIfNeeded()
    }

    constraint.append(contentsOf: positionConstraint)
    constraint.append(contentsOf: buttonConstraint)
    NSLayoutConstraint.activate(constraint)
    lastActivatedConstraints = constraint
    // needsDisplay = true
    layoutSubtreeIfNeeded()

  }

  public func setPosition(_ point: CGPoint) {
    _point = point
    updateFrame()
    //    print(self.constraints)

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
