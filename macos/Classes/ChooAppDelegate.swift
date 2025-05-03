//
//  ChooAppDelegate.swift
//  choo_window_manager
//
//  Created by 龚文硕 on 2025/5/3.
//

import Cocoa
import FlutterMacOS

open class ChooAppDelegate: FlutterAppDelegate {
  open override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }
}
