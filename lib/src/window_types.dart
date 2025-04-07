import 'package:flutter/widgets.dart';

enum WindowAnimationBehavior { none, alertPanel, documentWindow, utilityWindow }

extension WindowAnimationBehaviorExtension on WindowAnimationBehavior {
  static WindowAnimationBehavior fromString(String? colorString) {
    switch (colorString) {
      case 'none':
        return WindowAnimationBehavior.none;
      case 'alertPanel':
        return WindowAnimationBehavior.alertPanel;
      case 'documentWindow':
        return WindowAnimationBehavior.documentWindow;
      case 'utilityWindow':
        return WindowAnimationBehavior.utilityWindow;
      default:
        return WindowAnimationBehavior.none;
    }
  }
}

enum WindowTitleVisibility { hidden, visible }

enum WindowEventType {
  resize,
  move,
  pan,
  show,
  hide,
  hover,
  focus,
  blur,
  willClose,
  close,
  minimize,
  maximize,
  restore,
  willEnterFullScreen,
  didEnterFullScreen,
  willLeaveFullScreen,
  didLeaveFullScreen,
  event,
}

extension WindowTitleVisibilityExtension on WindowTitleVisibility {
  static WindowTitleVisibility? fromString(String? colorString) {
    switch (colorString) {
      case 'hidden':
        return WindowTitleVisibility.hidden;
      case 'visible':
        return WindowTitleVisibility.visible;
      default:
        return null;
    }
  }
}

class GlobalOffset extends Offset {
  final double _globalDx;
  final double _globalDy;
  double get globalDx => _globalDx;
  double get globalDy => _globalDy;
  GlobalOffset(double globalDx, double globalDy, super.dx, super.dy)
    : _globalDx = globalDx,
      _globalDy = globalDy;

  @override
  GlobalOffset operator +(Offset other) {
    // 先处理父类的dx/dy相加
    final baseOffset = super + other;

    assert(other is GlobalOffset, "other must be GlobalOffset");

    // 同时处理globalX/Y的相加
    return GlobalOffset(
      globalDx + (other as GlobalOffset).globalDx,
      globalDy + other.globalDy,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  @override
  GlobalOffset operator -(Offset other) {
    // 先处理父类的dx/dy相加
    final baseOffset = super + other;

    assert(other is GlobalOffset, "other must be GlobalOffset");

    // 同时处理globalX/Y的相加
    return GlobalOffset(
      globalDx + (other as GlobalOffset).globalDx,
      globalDy + other.globalDy,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  @override
  GlobalOffset operator *(double operand) {
    // 先处理父类的dx/dy相加
    final baseOffset = super * operand;

    // 同时处理globalX/Y的相加
    return GlobalOffset(
      globalDx * operand,
      globalDy * operand,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  @override
  GlobalOffset operator /(double operand) {
    // 先处理父类的dx/dy相加
    final baseOffset = super / operand;

    // 同时处理globalX/Y的相加
    return GlobalOffset(
      globalDx / operand,
      globalDy / operand,
      baseOffset.dx,
      baseOffset.dy,
    );
  }

  @override
  String toString() =>
      'GlobalOffset(${globalDx.toStringAsFixed(1)}, ${globalDy.toStringAsFixed(1)}, ${dx.toStringAsFixed(1)}, ${dy.toStringAsFixed(1)})';
}

class ChooWindowOptions {
  final int id;
  final bool center;
  final Size size;
  final Size? minSize;
  final Size? maxSize;
  final Offset? offset;
  final String? title;
  final double? opacity;
  final WindowAnimationBehavior? animationBehavior;
  final WindowTitleVisibility? titleBarStyle;

  ChooWindowOptions(
    this.id, {
    bool? center,
    this.size = const Size(800, 628),
    this.minSize,
    this.maxSize,
    this.offset,
    this.title,
    this.opacity,
    this.animationBehavior,
    this.titleBarStyle,
  }) : center = offset == null ? (center ?? true) : false;
}

class WindowEmit<T> {
  final int id;
  final String method;
  T result;
  WindowEmit(this.id, this.method, {required this.result});
}
