import 'dart:math';

import 'package:flutter/widgets.dart';

enum WindowAnimationBehavior { none, alertPanel, documentWindow, utilityWindow }

extension WindowAnimationBehaviorExtension on WindowAnimationBehavior {
  static WindowAnimationBehavior? fromString(String? colorString) {
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
        return null;
    }
  }
}

enum WindowTitleVisibility { hidden, visible }

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

class ChooWindowOptions {
  final int id;
  final bool center;
  final Size size;
  final Size? minSize;
  final Size? maxSize;
  final Offset? offset;
  final String? title;
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
    this.animationBehavior,
    this.titleBarStyle,
  }) : center = offset == null ? (center ?? true) : false;
}
