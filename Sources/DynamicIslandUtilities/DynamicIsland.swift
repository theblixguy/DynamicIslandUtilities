//
//  DynamicIsland.swift
//  DynamicIslandUtilities
//
//  Created by Suyash Srijan on 19/09/2022.
//

import UIKit

/// A type that information about the Dynamic Island as well as functionality around it such as a progress indicator.
/// - Note: The information provided (such as size) is for a static island, not one that is expanded (while a live activity is running for example).
public enum DynamicIsland {
  
  /// An object hat provides a progress indicator that shows progress around the dynamic island cutout.
  public static let progressIndicator: ProgressIndicator = {
    precondition(DynamicIsland.isAvailable,
                 "Cannot show dynamic island progress indicator on a device that does not support it!")
    return .init()
  }()
  
  /// The size of the Dynamic Island cutout.
  public static let size: CGSize = {
    return .init(width: 126.0, height: 37.33)
  }()
  
  /// The starting position of the Dynamic Island cutout.
  public static let origin: CGPoint = {
    return .init(x: UIScreen.main.bounds.midX - size.width / 2, y: 11)
  }()
  
  /// A rect that has the size and position of the Dynamic Island cutout.
  public static let rect: CGRect = {
    return .init(origin: origin, size: size)
  }()
  
  /// The corner radius of the Dynamic Island cutout.
  public static let cornerRadius: Double = {
    return size.width / 2
  }()
  
  /// Returns whether this device supports the Dynamic Island.
  /// This returns `true` for iPhone 14 Pro and iPhone Pro Max, otherwise returns `false`.
  public static let isAvailable: Bool = {
    if #unavailable(iOS 16) {
      return false
    }
    
#if targetEnvironment(simulator)
    let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
#else
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
#endif
    
    return identifier == "iPhone15,2" || identifier == "iPhone15,3"
  }()
}
