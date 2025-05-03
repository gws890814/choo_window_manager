//
//  ChooAppDelegate.swift
//  choo_window_manager
//
//  Created by 龚文硕 on 2025/5/3.
//

import Cocoa
import FlutterMacOS

/// ChooAppDelegate 是应用程序的主要代理类
/// 
/// 该类继承自FlutterAppDelegate，负责处理应用程序级别的事件和行为。
/// 主要功能包括：
/// - 控制应用程序的生命周期
/// - 处理应用程序关闭逻辑
/// - 确保即使所有窗口关闭，应用程序仍然保持运行
open class ChooAppDelegate: FlutterAppDelegate {
  /// 控制应用程序在最后一个窗口关闭后是否应该终止
  /// 
  /// 重写此方法以确保应用程序在所有窗口关闭后仍然继续运行，
  /// 这对于多窗口应用程序特别重要，因为用户可能需要在关闭所有窗口后重新创建新窗口。
  /// 
  /// - Parameter sender: 发送此消息的NSApplication实例
  /// - Returns: 返回false表示应用程序不应在最后一个窗口关闭后终止
  open override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }
}
