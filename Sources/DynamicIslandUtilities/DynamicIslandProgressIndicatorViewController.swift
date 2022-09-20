//
//  DynamicIslandProgressIndicatorViewController.swift
//  DynamicIslandUtilities
//
//  Created by Suyash Srijan on 18/09/2022.
//

import UIKit

/// A view controller that provides a progress indicator that shows progress around the dynamic island cutout.
open class DynamicIslandProgressIndicatorViewController: UIViewController {
    private let progressLayer: CAShapeLayer = CAShapeLayer()
    private let backgroundLayer: CAShapeLayer = CAShapeLayer()
    
    private enum State {
        case ready
        case animating
    }
    
    private var state: State = .ready
    
    @Clamped(between: 0...100) fileprivate var progress: Double {
        didSet {
            precondition(hasDynamicIsland,
                         "Cannot show dynamic island progress animation on a device that does not support it!")
            precondition(!isProgressIndeterminate,
                         "Cannot set progress manually when isProgressIndeterminate == true!")
            if isProgressIndicatorHidden {
                showProgressIndicator()
                state = .animating
            }
            progressLayer.strokeEnd = progress / 100
        }
    }
    
    fileprivate var progressColor: UIColor = .red {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
            backgroundLayer.strokeColor = progressColor.cgColor
        }
    }
    
    fileprivate var isProgressIndeterminate = true {
        didSet {
            resetProgressIndicator()
        }
    }
    
    /// Provides access to a configuration type to access the progress bar and show/hide progress.
    public lazy var dynamicIslandProgressIndicatorConfiguration: DynamicIslandProgressIndicatorConfiguration = {
        return .init(controller: self)
    }()
    
    private var isProgressIndicatorHidden: Bool {
        return progressLayer.isHidden && backgroundLayer.isHidden
    }
    
    /// Returns whether this device supports the Dynamic Island.
    /// This returns `true` for iPhone 14 Pro and iPhone Pro Max, otherwise returns `false`.
    public var hasDynamicIsland: Bool {
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
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        createAndAddDynamicIslandBorderLayers()
    }
    
    
    fileprivate func showIndeterminateProgressAnimation() {
        precondition(hasDynamicIsland,
                     "Cannot show dynamic island progress animation on a device that does not support it!")
        precondition(isProgressIndeterminate,
                     "Cannot show indeterminate progress when isProgressIndeterminate == false!")
        precondition(state == .ready,
                     "Cannot show animation because progress indicator is already animating!")
        
        resetProgressIndicator()
        showProgressIndicator()
        progressLayer.add(indeterminateAnimationMain(), forKey: nil)
        backgroundLayer.add(indeterminateAnimationPartialTail(), forKey: nil)
        state = .animating
    }
    
    fileprivate func showProgressIndicator() {
        progressLayer.isHidden = false
        backgroundLayer.isHidden = false
    }
    
    fileprivate func hideProgressIndicator() {
        progressLayer.isHidden = true
        backgroundLayer.isHidden = true
        resetProgressIndicator()
        state = .ready
    }
    
    fileprivate func resetProgressIndicator() {
        progressLayer.removeAllAnimations()
        backgroundLayer.removeAllAnimations()
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 1
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 0
    }
    
    private func createAndAddDynamicIslandBorderLayers() {
        let dynamicIslandPath = UIBezierPath(roundedRect: DynamicIsland.rect,
                                             byRoundingCorners: [.allCorners],
                                             cornerRadii: CGSize(width: DynamicIsland.cornerRadius,
                                                                 height: DynamicIsland.cornerRadius))
        
        progressLayer.path = dynamicIslandPath.cgPath
        backgroundLayer.path = dynamicIslandPath.cgPath
        
        if #available(iOS 16.0, *) {
            progressLayer.cornerCurve = .continuous
        }
        progressLayer.lineCap = .round
        progressLayer.fillRule = .evenOdd
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 1
        progressLayer.lineWidth = 5
        
        if #available(iOS 16.0, *) {
            backgroundLayer.cornerCurve = .continuous
        }
        backgroundLayer.lineCap = .round
        backgroundLayer.fillRule = .evenOdd
        backgroundLayer.strokeColor = progressColor.cgColor
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 0
        backgroundLayer.lineWidth = 5
        backgroundLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(progressLayer)
        view.layer.addSublayer(backgroundLayer)
    }
    
    private func indeterminateAnimationMain() -> CAAnimationGroup {
        let animationStart = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        animationStart.values = [0, 0, 0.75]
        animationStart.keyTimes = [0, 0.25, 1]
        animationStart.duration = 2
        
        let animationEnd = CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animationEnd.values = [0, 0.25, 1]
        animationEnd.keyTimes = [0, 0.25, 1]
        animationEnd.duration = 2
        
        let group = CAAnimationGroup()
        group.duration = 2
        group.repeatCount = .infinity
        group.animations = [animationStart, animationEnd]
        return group
    }
    
    private func indeterminateAnimationPartialTail() -> CAAnimationGroup {
        let animationStart = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        animationStart.fromValue = 0.75
        animationStart.toValue = 1
        animationStart.duration = 0.5
        
        let animationEnd = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animationEnd.fromValue = 1
        animationEnd.toValue = 1
        animationEnd.duration = 0.5
        
        let group = CAAnimationGroup()
        group.duration = 2
        group.repeatCount = .infinity
        group.animations = [animationStart, animationEnd]
        return group
    }
}

/// A configuration object that allows you to tweak the properties of the dynamic island progress indicator
/// and show/hide the progress.
public final class DynamicIslandProgressIndicatorConfiguration {
    private unowned var controller: DynamicIslandProgressIndicatorViewController
    
    /// The current progress of the progress indicator, between 0 and 100.
    /// - Note: This requires `isProgressIndeterminate` to be set to `false`
    public var progress: Double {
        get { controller.progress }
        set { controller.progress = newValue }
    }
    
    /// The color of the progress indicator. The default value is `UIColor.red`.
    public var progressColor: UIColor {
        get { controller.progressColor }
        set { controller.progressColor = newValue }
    }
    
    /// Whether the progress indicator should show indeterminate progress (this is useful when you don't know
    /// how long something is going to take). The default value is `true`.
    public var isProgressIndeterminate: Bool {
        get { controller.isProgressIndeterminate }
        set { controller.isProgressIndeterminate = newValue }
    }
    
    fileprivate init(controller: DynamicIslandProgressIndicatorViewController) {
        self.controller = controller
    }
    
    /// Shows an indeterminate progress animation indicator on the dynamic island.
    /// - Note: This requires `isProgressIndeterminate` to be set to `true`.
    public func showIndeterminateProgressAnimation() {
        controller.showIndeterminateProgressAnimation()
    }
    
    /// Hides the progress indicator on the dynamic island.
    public func hideProgressIndicator() {
        controller.hideProgressIndicator()
    }
}

/// A property wrapper that clamps a value between a specified range.
@propertyWrapper
fileprivate struct Clamped<Value: Comparable> {
    private var value: Value
    private let range: ClosedRange<Value>
    
    init(between range: ClosedRange<Value>) {
        self.value = range.lowerBound
        self.range = range
    }
    
    var wrappedValue: Value {
        get { value }
        set { value = min(max(range.lowerBound, newValue), range.upperBound) }
    }
}
