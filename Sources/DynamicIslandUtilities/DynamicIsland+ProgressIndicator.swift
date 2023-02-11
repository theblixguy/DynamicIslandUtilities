//
//  DynamicIsland+ProgressIndicator.swift
//  DynamicIslandUtilities
//
//  Created by Suyash Srijan on 01/10/2022.
//

import UIKit

extension DynamicIsland {
  public final class ProgressIndicator {
    private let progressIndicatorImpl: DynamicIslandProgressIndicatorImplementation
    
    init () {
      progressIndicatorImpl = .init()
      progressIndicatorImpl.add(toContext: window)
    }
    
    /// The window that this progress indicator is attached to.
    /// By default, it's added to the key window (or the first window
    /// of the first scene), but you can change that by assigning a
    /// different window to this property.
    public var window: UIWindow = Self.getMainWindow() {
      didSet {
        progressIndicatorImpl.changeContext(to: window)
      }
    }
    
    /// The current progress of the progress indicator, between 0 and 100.
    /// - Note: This requires `isProgressIndeterminate` to be set to `false`
    public var progress: Double {
      get { progressIndicatorImpl.progress }
      set { progressIndicatorImpl.progress = newValue }
    }
    
    /// The color of the progress indicator. The default value is `UIColor.red`.
    public var progressColor: UIColor {
      get { progressIndicatorImpl.progressColor }
      set { progressIndicatorImpl.progressColor = newValue }
    }
    
    /// Whether the progress indicator should show indeterminate progress (this is useful when you don't know
    /// how long something is going to take). The default value is `true`.
    public var isProgressIndeterminate: Bool {
      get { progressIndicatorImpl.isProgressIndeterminate }
      set { progressIndicatorImpl.isProgressIndeterminate = newValue }
    }
    
    /// Shows an indeterminate progress animation indicator on the dynamic island.
    /// - Note: This requires `isProgressIndeterminate` to be set to `true`.
    public func showIndeterminateProgressAnimation() {
      progressIndicatorImpl.showIndeterminateProgressAnimation()
    }
    
    /// Hides the progress indicator on the dynamic island.
    public func hideProgressIndicator() {
      progressIndicatorImpl.hideProgressIndicator()
    }
    
    private static func getMainWindow() -> UIWindow {
      lazy var keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }!
      
      if #available(iOS 13.0, *) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first ?? keyWindow
      }
      
      return keyWindow
    }
  }
}
