# Choo Window Manager

一个用于 Flutter 应用的窗口管理器插件，提供对 macOS 窗口行为的精细控制，包括窗口的尺寸、位置、事件监听以及各种窗口样式设置。

## 安装

在 `pubspec.yaml` 文件中添加以下依赖：

```yaml
dependencies:
  choo_window_manager: ^latest_version
```

然后运行 `flutter pub get`。

## 使用

### WindowManagerEvent 抽象类

`WindowManagerEvent` 是一个抽象类，提供了处理窗口相关事件的接口。你需要实现这个抽象类来监听窗口事件。

#### 静态方法

- `static void addListener(WindowManagerEvent instance)`
  - **描述**: 添加窗口事件监听器。
  - **参数**:
    - `instance`: 要添加的事件监听器实例，通常为实现了 `WindowManagerEvent` 抽象类的对象。
  - **用法**:
    ```dart
    WindowManagerEvent.addListener(this);
    ```
  - **注意**: 若首次添加，将通知原生端注册监听。

- `static void removeListener(WindowManagerEvent instance)`
  - **描述**: 移除窗口事件监听器。
  - **参数**:
    - `instance`: 要移除的事件监听器实例。
  - **用法**:
    ```dart
    WindowManagerEvent.removeListener(this);
    ```
  - **注意**: 若移除后无监听器，将通知原生端注销监听。

- `static void addPanListener(WindowManagerEvent instance)`
  - **描述**: 添加拖拽事件监听器。
  - **参数**:
    - `instance`: 要添加的拖拽事件监听器实例。
  - **用法**:
    ```dart
    WindowManagerEvent.addPanListener(this);
    ```
  - **注意**: 仅允许一个拖拽监听器存在。若已存在拖拽监听器，将抛出 `AssertionError`。

- `static void removePanListener(WindowManagerEvent instance)`
  - **描述**: 移除拖拽事件监听器。
  - **参数**:
    - `instance`: 要移除的拖拽事件监听器实例。
  - **用法**:
    ```dart
    WindowManagerEvent.removePanListener(this);
    ```

- `static void addPrePanListener(WindowManagerEvent instance)`
  - **描述**: 添加预拖拽事件监听器。
  - **参数**:
    - `instance`: 要添加的预拖拽事件监听器实例。
  - **用法**:
    ```dart
    WindowManagerEvent.addPrePanListener(this);
    ```

- `static void removePrePanListener(WindowManagerEvent instance)`
  - **描述**: 移除预拖拽事件监听器。
  - **参数**:
    - `instance`: 要移除的预拖拽事件监听器实例。
  - **用法**:
    ```dart
    WindowManagerEvent.removePrePanListener(this);
    ```

- `static void addHoverListener(WindowManagerEvent instance)`
  - **描述**: 添加悬停事件监听器。
  - **参数**:
    - `instance`: 要添加的悬停事件监听器实例。
  - **用法**:
    ```dart
    WindowManagerEvent.addHoverListener(this);
    ```

- `static void removeHoverListener(WindowManagerEvent instance)`
  - **描述**: 移除悬停事件监听器。
  - **参数**:
    - `instance`: 要移除的悬停事件监听器实例。
  - **用法**:
    ```dart
    WindowManagerEvent.removeHoverListener(this);
    ```

#### 实例属性

- `String get eventid`
  - **描述**: 获取事件监听器的唯一标识符。
  - **返回值**: 事件监听器的唯一标识符，类型为 `String`。

#### 回调方法 (需要实现)

- `void onResize(Size size)`
  - **描述**: 窗口尺寸变化回调。
  - **参数**:
    - `size`: 新的窗口尺寸。

- `void onMove(GlobalOffset offset)`
  - **描述**: 窗口移动回调。
  - **参数**:
    - `offset`: 新的窗口全局/局部坐标。

- `void onPan(Offset offset)`
  - **描述**: 拖拽事件回调。
  - **参数**:
    - `offset`: 拖拽时的全局坐标。

- `void onHover(Offset offset)`
  - **描述**: 悬停事件回调。
  - **参数**:
    - `offset`: 悬停时的全局坐标。

- `void onShow()`
  - **描述**: 窗口显示回调。

- `void onHide()`
  - **描述**: 窗口隐藏回调。

- `void onFocus()`
  - **描述**: 窗口获得焦点回调。

- `void onBlur()`
  - **描述**: 窗口失去焦点回调。

- `void onMinimize()`
  - **描述**: 窗口最小化回调。

- `void onMaximize()`
  - **描述**: 窗口最大化回调。

- `void onRestore()`
  - **描述**: 窗口还原回调。

- `void onWillEnterFullScreen()`
  - **描述**: 即将进入全屏回调。

- `void onDidEnterFullScreen()`
  - **描述**: 已进入全屏回调。

- `void onWillLeaveFullScreen()`
  - **描述**: 即将离开全屏回调。

- `void onDidLeaveFullScreen()`
  - **描述**: 已离开全屏回调。

- `void changeTitle(String title)`
  - **描述**: 窗口标题改变回调。
  - **参数**:
    - `title`: 新的窗口标题。

- `Future<bool> onWillClose()`
  - **描述**: 窗口关闭前回调。
  - **返回值**: `Future<bool>`，返回 `false` 可阻止关闭。

- `void onClose()`
  - **描述**: 窗口关闭回调。

- `Future<bool> onKeyboard(KeyboardEvent event)`
  - **描述**: 键盘事件回调。
  - **参数**:
    - `event`: 键盘事件对象。
  - **返回值**: `Future<bool>`，返回 `false` 则不再传递事件。

- `Future<dynamic> onEvent(int id, String method, {dynamic arguments, required dynamic delivery})`
  - **描述**: 通用事件回调。
  - **参数**:
    - `id`: 发送消息的窗口ID。
    - `method`: 事件方法名。
    - `arguments`: 事件参数。
    - `delivery`: 上一监听器的返回值。
  - **返回值**: 可自定义返回值，用于事件链传递。

### ChooWindowManager 类

`ChooWindowManager` 类用于管理应用窗口的生命周期、事件分发及与原生窗口的通信。

#### 静态属性

- `static late ChooWindowManager current`
  - **描述**: 当前窗口管理器实例，便于全局访问和操作。

#### 静态方法

- `static Future<int> createWindow(Map<String, dynamic>? args)`
  - **描述**: 创建新窗口。
  - **参数**:
    - `args`: 新窗口参数，可选。
  - **返回值**: 新窗口的唯一标识符 `id`。

#### 多窗口管理

`ChooWindowManager` 提供了强大的多窗口管理能力，允许您在应用中创建、关闭和销毁多个独立的窗口。每个窗口都有其独立的生命周期和事件处理。

**创建新窗口**：
使用 `ChooWindowManager.createWindow` 方法可以创建一个新的窗口实例。您可以传递 `args` 参数来为新窗口配置初始属性，例如窗口的尺寸、位置、标题等。该方法会返回新创建窗口的唯一 `id`，您可以使用这个 `id` 来对特定窗口进行操作。

**关闭窗口**：
通过 `ChooWindowManager.closeWindow(int windowId)` 方法，您可以根据窗口的 `id` 精确关闭某个窗口。如果需要关闭多个窗口，可以使用 `ChooWindowManager.closeWindows({List<int>? ids})` 方法，传入一个 `id` 列表。如果不传入 `ids`，则会关闭所有当前打开的窗口。

**销毁所有窗口**：
`ChooWindowManager.destroy()` 方法用于销毁所有由插件管理的窗口。这通常在应用程序退出时调用，以确保所有窗口资源都被正确释放。

**窗口间通信**：


- `static Future<bool> closeWindow(int windowId)`
  - **描述**: 关闭指定窗口。
  - **参数**:
    - `windowId`: 要关闭的窗口 `id`。
  - **返回值**: `true` 如果关闭成功，否则 `false`。

- `static Future<bool> closeWindows({List<int>? ids})`
  - **描述**: 关闭一个或多个窗口。
  - **参数**:
    - `ids`: 要关闭的窗口 `id` 列表，可选。如果为空，则关闭所有窗口。
  - **返回值**: `true` 如果全部关闭成功，否则 `false`。

- `static Future<void> destroy()`
  - **描述**: 销毁所有窗口。

#### 构造函数

- `ChooWindowManager.ready(ChooWindowOptions options, void Function(ChooWindowManager window) callback)`
  - **描述**: 初始化窗口管理器并注册回调。
  - **参数**:
    - `options`: 窗口初始化参数。
    - `callback`: 初始化完成后的回调函数，返回窗口实例。

### `ChooWindowOptions`

`ChooWindowManager.ready` 方法的 `options` 参数，用于配置窗口的初始参数。

- `id`: `int` - 窗口的唯一标识符。用于在系统中唯一识别该窗口。通常由系统自动生成或开发者指定。
- `center`: `bool` - 窗口是否居中显示。设置为true时，窗口将在屏幕中央打开。如果设置了 `offset`，则此参数会被忽略且实际为 `false`。默认值为 `true`。
- `size`: `Size` - 窗口的初始大小。指定窗口打开时的宽度和高度。默认值为 `800x628`。
- `minSize`: `Size?` - 窗口的最小尺寸限制。设置窗口可调整的最小宽度和高度。如果未设置，则窗口可调整到任意大小。
- `maxSize`: `Size?` - 窗口的最大尺寸限制。设置窗口可调整的最大宽度和高度。如果未设置，则窗口可调整到任意大小。
- `offset`: `Offset?` - 窗口的初始位置偏移量。指定窗口打开时相对于屏幕左上角的位置。如果设置了此参数，`center` 将被视为 `false`。
- `title`: `String?` - 窗口的标题文本。显示在窗口的标题栏中。如果未设置，则显示默认标题。
- `opacity`: `double?` - 窗口的透明度。取值范围为 `0.0` (完全透明) 到 `1.0` (完全不透明)。如果未设置，则窗口完全不透明。
- `animationBehavior`: `WindowAnimationBehavior?` - 窗口的动画效果。指定窗口打开和关闭时的动画效果。如果未设置，则使用默认动画。
- `titleBarStyle`: `WindowTitleVisibility?` - 窗口标题栏的显示样式。控制标题栏是否显示。如果未设置，则显示默认标题栏。
- `buttonOptions`: `WindowButtonOptions?` - 窗口按钮的配置选项。
  - `enabledButtons`: `List<WindowButtonType>` - 启用的按钮类型列表。默认为 `[WindowButtonType.close, WindowButtonType.miniaturize, WindowButtonType.zoom]`。实际操作中，会禁用未在此列表中的按钮。
  - `hiddenButtons`: `List<WindowButtonType>` - 隐藏的按钮类型列表。默认为空列表 `[]`。此列表中的按钮将被隐藏。
  - `height`: `double?` - 按钮区域的高度。如果设置，则会调用 `ChooWindowManager.current.setWindowButtonRegionHeight`。
  - `regionPosition`: `WindowButtonRegionPosition?` - 按钮区域的位置。如果设置，则会调用 `ChooWindowManager.current.setWindowButtonRegionPosition`。
  - `buttonSize`: `Size?` - 按钮的尺寸。如果设置，则会调用 `ChooWindowManager.current.setWindowButtonSize`。
  - `spacing`: `double?` - 按钮之间的间距。如果设置，则会调用 `ChooWindowManager.current.setWindowButtonSpacing`。

#### 实例属性

- `final int id`
  - **描述**: 当前窗口的唯一标识符。

- `Map<String, dynamic> get args`
  - **描述**: 获取当前窗口的参数（如 `id`），便于方法调用时传参。

### ChooCurrentWindowManager 扩展

`ChooCurrentWindowManager` 扩展为 `ChooWindowManager` 实例提供了便捷的窗口操作方法。

- `Future<void> show()`
  - **描述**: 显示窗口，使窗口可见。

- `Future<void> hide()`
  - **描述**: 隐藏窗口，使窗口不可见。

- `Future<void> focus()`
  - **描述**: 使窗口获得焦点，将窗口置于前台并激活。

- `Future<void> blur()`
  - **描述**: 使窗口失去焦点，将窗口置于后台并取消激活状态。

- `Future<void> close({bool force = false})`
  - **描述**: 关闭窗口。
  - **参数**:
    - `force`: 是否强制关闭，若为 `true` 则忽略 `onWillClose` 回调直接关闭，默认为 `false`。

- `Future<bool> isVisible()`
  - **描述**: 检查窗口是否可见。
  - **返回值**: `true` 如果窗口可见，否则 `false`。

- `Future<bool> isMaximized()`
  - **描述**: 检查窗口是否最大化。
  - **返回值**: `true` 如果窗口处于最大化状态，否则 `false`。

- `Future<void> maximize()`
  - **描述**: 最大化窗口，将窗口扩展到最大可用尺寸。

- `Future<void> unmaximize()`
  - **描述**: 取消窗口最大化，将窗口从最大化状态还原。

- `Future<bool> isMinimized()`
  - **描述**: 检查窗口是否最小化。
  - **返回值**: `true` 如果窗口处于最小化状态，否则 `false`。

- `Future<void> minimize()`
  - **描述**: 最小化窗口，将窗口最小化到任务栏。

- `Future<void> restore()`
  - **描述**: 还原窗口，将窗口从最小化或最大化状态还原到正常状态。

- `Future<Size> getSize()`
  - **描述**: 获取窗口尺寸。
  - **返回值**: 窗口的当前尺寸 `Size`。

- `Future<void> setSize(Size size, {bool animate = false})`
  - **描述**: 设置窗口尺寸。
  - **参数**:
    - `size`: 要设置的窗口尺寸。
    - `animate`: 是否使用动画效果，默认为 `false`。

- `Future<Size> getMinSize()`
  - **描述**: 获取窗口最小尺寸。
  - **返回值**: 窗口允许的最小尺寸 `Size`。

- `Future<void> setMinSize(Size size)`
  - **描述**: 设置窗口最小尺寸。
  - **参数**:
    - `size`: 要设置的最小尺寸。

- `Future<Size> getMaxSize()`
  - **描述**: 获取窗口最大尺寸。
  - **返回值**: 窗口允许的最大尺寸 `Size`。

- `Future<void> setMaxSize(Size size)`
  - **描述**: 设置窗口最大尺寸。
  - **参数**:
    - `size`: 要设置的最大尺寸。

- `Future<Offset> getPosition()`
  - **描述**: 获取窗口位置。
  - **返回值**: 窗口的当前位置 `Offset`。

- `Future<void> setPosition(Offset offset)`
  - **描述**: 设置窗口位置。
  - **参数**:
    - `offset`: 要设置的窗口位置。

- `Future<void> center()`
  - **描述**: 将窗口居中。

- `Future<String> getTitle()`
  - **描述**: 获取窗口标题。
  - **返回值**: 窗口的当前标题 `String`。

- `Future<void> setTitle(String title)`
  - **描述**: 设置窗口标题。
  - **参数**:
    - `title`: 要设置的标题。

- `Future<void> setOpacity(double opacity)`
  - **描述**: 设置窗口透明度。
  - **参数**:
    - `opacity`: 透明度值，范围 `0.0` 到 `1.0`。

- `Future<WindowEmit<T>?> emit<T>(int id, String method, [Map<String, dynamic>? arguments])`
  - **描述**: 向指定窗口发送事件。
  - **参数**:
    - `id`: 目标窗口的ID。
    - `method`: 事件方法名。
    - `arguments`: 可选的事件参数。
 - **返回值**: 事件发送结果，如果发送成功则返回 `WindowEmit` 对象，否则返回 `null`.  - **参数**:
    - `borderless`: `true` 为无边框，`false` 为有边框。

- `Future<Size> getScreenSize()`
  - **描述**: 获取屏幕尺寸。
  - **返回值**: 当前屏幕的尺寸。

- `Future<Rect> getBounds({bool global = false})`
  - **描述**: 获取窗口边界。
  - **参数**:
    - `global`: 是否使用全局坐标，默认为 `false`。
  - **返回值**: 窗口的边界矩形。

- `Future<void> setWindowButtonHidden({List<WindowButtonType> types = const [], required bool state})`
  - **描述**: 设置窗口按钮的隐藏状态。
  - **参数**:
    - `types`: 要设置的窗口按钮类型列表，默认为空列表。
    - `state`: 隐藏状态，`true` 为隐藏，`false` 为显示。

- `Future<void> setWindowButtonEnabled({List<WindowButtonType> types = const [], required bool state})`
  - **描述**: 设置窗口按钮的启用状态。
  - **参数**:
    - `types`: 要设置的窗口按钮类型列表，默认为空列表。
    - `state`: 启用状态，`true` 为启用，`false` 为禁用。

- `Future<WindowButtonRegionPosition> getWindowButtonRegionPosition()`
  - **描述**: 获取窗口按钮区域的位置。
  - **返回值**: 窗口按钮区域的位置 `WindowButtonRegionPosition`。

- `Future<void> setWindowButtonRegionPosition(WindowButtonRegionPosition position)`
  - **描述**: 设置窗口按钮区域的位置。
  - **参数**:
    - `position`: 要设置的窗口按钮区域位置。

- `Future<Size> getWindowButtonRegionSize()`
  - **描述**: 获取窗口按钮区域的尺寸。
  - **返回值**: 窗口按钮区域的尺寸 `Size`。

- `Future<void> setWindowButtonRegionHeight(double height)`
  - **描述**: 设置窗口按钮区域的高度。
  - **参数**:
    - `height`: 要设置的高度。

- `Future<double> getWindowButtonSpacing()`
  - **描述**: 获取窗口按钮之间的间距。
  - **返回值**: 窗口按钮之间的间距 `double`。

- `Future<void> setWindowButtonSpacing(double spacing)`
  - **描述**: 设置窗口按钮之间的间距。
  - **参数**:
    - `spacing`: 要设置的间距。

- `Future<Size> getWindowButtonSize()`
  - **描述**: 获取窗口按钮的尺寸。
  - **返回值**: 窗口按钮的尺寸 `Size`。

- `Future<void> setWindowButtonSize(Size size)`
  - **描述**: 设置窗口按钮的尺寸。
  - **参数**:
    - `size`: 要设置的尺寸。

- `Future<void> setBounds(Rect rect, {bool global = false, bool animate = false})`
  - **描述**: 设置窗口边界。
  - **参数**:
    - `rect`: 要设置的边界矩形。
    - `global`: 是否使用全局坐标，默认为 `false`。
    - `animate`: 是否使用动画效果，默认为 `false`。

- `Future<WindowAnimationBehavior?> getAnimationBehavior()`
  - **描述**: 获取窗口动画行为。
  - **返回值**: 当前的窗口动画行为 `WindowAnimationBehavior`。

- `Future<void> setAnimationBehavior(WindowAnimationBehavior animationBehavior)`
  - **描述**: 设置窗口动画行为。
  - **参数**:
    - `animationBehavior`: 要设置的动画行为。

- `Future<WindowTitleVisibility> getTitleStyle()`
  - **描述**: 获取标题栏样式。
  - **返回值**: 当前的标题栏可见性样式 `WindowTitleVisibility`。

- `Future<void> setTitleStyle(WindowTitleVisibility titleBarStyle)`
  - **描述**: 设置标题栏样式。
  - **参数**:
    - `titleBarStyle`: 要设置的标题栏可见性样式。

- `Future<double> getOpacity()`
  - **描述**: 获取窗口透明度。
  - **返回值**: 当前的窗口透明度，范围 `0.0` 到 `1.0`。

- `Future<Offset> getMousePoint()`
  - **描述**: 获取鼠标指针位置。
  - **返回值**: 鼠标指针的当前坐标 `Offset`。

### WindowPanWidget 组件

`WindowPanWidget` 是一个用于实现窗口拖动功能的 Flutter `widget`。它通过包裹子控件来实现拖动功能，并提供了控制拖动行为的选项。

#### 构造函数

- `const WindowPanWidget({Key? key, required this.child, this.onEnter, this.onExit, this.onHover, this.spread = false})`
  - **描述**: `WindowPanWidget` 的构造函数。
  - **参数**:
    - `key`: `widget` 的唯一标识符。
    - `child`: 要包裹的子 `widget`，通常是您希望能够拖动的 UI 元素。
    - `onEnter`: 鼠标进入 `widget` 区域时的回调函数。
    - `onExit`: 鼠标离开 `widget` 区域时的回调函数。
    - `onHover`: 鼠标在 `widget` 区域内悬停时的回调函数。
    - `spread`: 一个布尔值，默认为 `false`。当设置为 `true` 时，`child` 内部的手势将不会阻止拖动行为；当设置为 `false` 时，`child` 内部的手势会阻止拖动行为。

#### 静态方法

- `static _WindowPanState? of(BuildContext context)`
  - **描述**: 获取当前 `WindowPanWidget` 的状态实例，用于在子树中访问 `WindowPanWidget` 的状态。
  - **参数**:
    - `context`: 当前 `widget` 树的构建上下文。
  - **返回值**: `_WindowPanState` 实例，如果找不到则返回 `null`。

#### 属性

- `bool get spread`
  - **描述**: 获取或设置 `spread` 属性的值。该属性控制 `child` 内部手势是否阻止拖动。

#### 内部实现

`WindowPanWidget` 内部使用 `GestureDetector` 来处理拖动手势，并通过 `MouseRegion` 来处理鼠标进入和离开事件。它还实现了 `WindowManagerEvent` 混入，以便在拖动开始和结束时添加或移除预拖动和拖动监听器。


### ChooAppBar 组件

一个自定义的 AppBar，它允许窗口拖动，并支持双击标题栏时最大化/还原窗口。

**构造函数**:

`ChooAppBar({Key? key, required Widget child, double height = 28})`

**参数**:

- `child`: `Widget` - AppBar 中显示的内容，通常是标题文本或其他自定义 Widget。
- `height`: `double` - AppBar 的高度，默认为 `28`。此高度也会被设置为窗口按钮区域的高度。

## 类型定义

#### `enum WindowAnimationBehavior`

定义窗口打开和关闭时的动画效果。

- `none`: 无动画，窗口打开和关闭时不显示任何动画效果。
- `alertPanel`: 警告面板动画，用于显示重要警告或提示信息时的动画效果。
- `documentWindow`: 文档窗口动画，适用于文档编辑器等应用程序的窗口动画。
- `utilityWindow`: 工具窗口动画，用于工具面板或辅助窗口的动画效果。

#### `enum ModifierFlags`

定义键盘修饰键的状态。

- `capsLock`: 大写锁定键，用于切换大写字母输入。
- `shift`: Shift键，用于输入大写字母或访问符号。
- `control`: Control键，通常用于触发系统或应用程序快捷键。
- `option`: Option键（在Windows上为Alt键），用于访问特殊字符和菜单快捷键。
- `command`: Command键（在Windows上为Windows键），用于触发系统级快捷键。
- `numericPad`: 数字小键盘键，用于输入数字和数学运算符。
- `help`: Help键，用于触发帮助功能。
- `function`: 功能键（F1-F12），用于触发特定应用程序功能。
- `deviceIndependentFlagsMask`: 设备独立标志掩码，用于表示与设备无关的修饰键状态。

#### `enum WindowButtonType`

定义窗口按钮类型。

- `close`: 关闭按钮。
- `miniaturize`: 最小化按钮。
- `zoom`: 最大化/缩放按钮。

#### `enum WindowTitleVisibility`

控制窗口标题栏的显示方式。

- `hidden`: 隐藏标题，适用于无边框窗口或自定义标题栏的场景。
- `visible`: 显示标题，默认值，显示标准窗口标题栏。

#### `enum WindowEventType`

定义窗口可能触发的各种事件。

- `resize`: 窗口大小改变事件，当用户调整窗口大小时触发。
- `move`: 窗口移动事件，当窗口位置改变时触发。
- `pan`: 窗口平移事件，通常用于触摸屏设备的拖拽操作。
- `show`: 窗口显示事件，当窗口从隐藏变为可见时触发。
- `hide`: 窗口隐藏事件，当窗口从可见变为隐藏时触发。
- `hover`: 鼠标悬停事件，当鼠标指针在窗口上悬停时触发。
- `focus`: 窗口获得焦点事件，当窗口成为活动窗口时触发。
- `blur`: 窗口失去焦点事件，当窗口不再是活动窗口时触发。
- `willClose`: 窗口即将关闭事件，在窗口关闭前触发。
- `close`: 窗口关闭事件，在窗口关闭时触发。
- `minimize`: 窗口最小化事件，当窗口被最小化时触发。
- `maximize`: 窗口最大化事件，当窗口被最大化时触发。
- `restore`: 窗口还原事件，当窗口从最小化或最大化状态恢复时触发。
- `willEnterFullScreen`: 窗口即将进入全屏模式事件。
- `didEnterFullScreen`: 窗口已进入全屏模式事件。
- `willLeaveFullScreen`: 窗口即将退出全屏模式事件。
- `didLeaveFullScreen`: 窗口已退出全屏模式事件。
- `event`: 通用窗口事件，用于处理其他未分类的窗口事件。
- `keyboard`: 键盘事件，当窗口接收到键盘输入时触发。
- `changeTitle`: 改变标题事件。

#### `class GlobalOffset extends Offset`

全局偏移量类，继承自 `Offset`，增加了全局坐标信息。

- `double get globalDx`
  - **描述**: 获取全局 X 坐标。
- `double get globalDy`
  - **描述**: 获取全局 Y 坐标。
- `GlobalOffset(double globalDx, double globalDy, double dx, double dy)`
  - **构造函数**:
    - `globalDx`: 全局 X 坐标。
    - `globalDy`: 全局 Y 坐标。
    - `dx`: 局部 X 坐标。
    - `dy`: 局部 Y 坐标。
- `GlobalOffset operator +(Offset other)`
  - **描述**: 重载加法运算符，用于计算两个 `GlobalOffset` 对象的和。
  - **参数**:
    - `other`: 要相加的另一个 `Offset` 对象，必须是 `GlobalOffset` 类型。
  - **返回值**: 一个新的 `GlobalOffset` 对象，包含相加后的全局和局部坐标。

## 示例

（待补充）

## 贡献

欢迎贡献！请遵循以下步骤：

1. Fork 本仓库。
2. 创建您的功能分支 (`git checkout -b feature/AmazingFeature`)。
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)。
4. 推送到分支 (`git push origin feature/AmazingFeature`)。
5. 提交 Pull Request。

## 许可证

本项目采用 MIT 许可证。详情请参阅 `LICENSE` 文件。
