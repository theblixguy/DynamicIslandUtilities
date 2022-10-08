//
//  DynamicIslandProgressIndicator.swift
//  DynamicIslandUtilities
//
//  Created by Suyash Srijan on 18/09/2022.
//

import UIKit

final class DynamicIslandProgressIndicatorImplementation: UIView {
  private let tailLayer: CAShapeLayer = CAShapeLayer()
  private let partialTailLayer: CAShapeLayer = CAShapeLayer()
  private var currentContext: UIWindow!
  
  private enum State {
    case ready
    case animating
  }
  
  private var state: State = .ready
  
  private var isProgressIndicatorHidden: Bool {
    return tailLayer.isHidden && partialTailLayer.isHidden
  }
  
  @Clamped(between: 0...100) var progress: Double {
    didSet {
      requiresIndeterminateProgress(equalTo: false)
      if isProgressIndicatorHidden {
        requiresState(equalTo: .ready)
        showProgressIndicator()
        state = .animating
      }
      tailLayer.strokeEnd = progress / 100
    }
  }
  
  var progressColor: UIColor = .red {
    didSet {
      tailLayer.strokeColor = progressColor.cgColor
      partialTailLayer.strokeColor = progressColor.cgColor
    }
  }
  
  var isProgressIndeterminate = true {
    didSet {
      resetProgressIndicator()
    }
  }
  
  func add(toContext context: UIWindow) {
    requiresState(equalTo: .ready)
    currentContext = context
    createAndAddDynamicIslandBorderLayers()
    currentContext.addSubview(self)
    currentContext.bringSubviewToFront(self)
  }
  
  func changeContext(to newContext: UIWindow) {
    requiresState(equalTo: .ready)
    removeIndicator()
    add(toContext: newContext)
  }
  
  
  func showIndeterminateProgressAnimation() {
    requiresIndeterminateProgress(equalTo: true)
    requiresState(equalTo: .ready)
    
    resetProgressIndicator()
    showProgressIndicator()
    tailLayer.add(mainTailAnimation(), forKey: nil)
    partialTailLayer.add(partialTailAnimation(), forKey: nil)
    state = .animating
  }
  
  func hideProgressIndicator() {
    tailLayer.isHidden = true
    partialTailLayer.isHidden = true
    resetProgressIndicator()
    state = .ready
  }
  
  fileprivate func showProgressIndicator() {
    tailLayer.isHidden = false
    partialTailLayer.isHidden = false
  }
  
  fileprivate func resetProgressIndicator() {
    tailLayer.removeAllAnimations()
    partialTailLayer.removeAllAnimations()
    tailLayer.strokeStart = 0
    tailLayer.strokeEnd = 1
    partialTailLayer.strokeStart = 0
    partialTailLayer.strokeEnd = 0
  }
  
  private func removeIndicator() {
    resetProgressIndicator()
    removeFromSuperview()
    tailLayer.removeFromSuperlayer()
    partialTailLayer.removeFromSuperlayer()
    currentContext = nil
  }
  
  private func requiresIndeterminateProgress(equalTo value: Bool) {
    precondition(isProgressIndeterminate == value,
                 "isProgressIndeterminate must be set to '\(value)'!")
  }
  
  private func requiresState(equalTo value: State) {
    let message: String
    switch (value, state) {
    case (.ready, .animating):
      message = "Cannot show animation because progress indicator is already animating!"
      // Handle other cases here if we require them.
    default:
      message = ""
    }
    precondition(state == value, message)
  }
  
  private func createAndAddDynamicIslandBorderLayers() {
    let dynamicIslandPath = UIBezierPath(roundedRect: DynamicIsland.rect,
                                         byRoundingCorners: [.allCorners],
                                         cornerRadii: CGSize(width: DynamicIsland.cornerRadius,
                                                             height: DynamicIsland.cornerRadius))
    
    tailLayer.path = dynamicIslandPath.cgPath
    partialTailLayer.path = dynamicIslandPath.cgPath
    
    if #available(iOS 16.0, *) {
      tailLayer.cornerCurve = .continuous
    }
    tailLayer.lineCap = .round
    tailLayer.fillRule = .evenOdd
    tailLayer.strokeColor = progressColor.cgColor
    tailLayer.strokeStart = 0
    tailLayer.strokeEnd = 1
    tailLayer.lineWidth = 5
    
    if #available(iOS 16.0, *) {
      partialTailLayer.cornerCurve = .continuous
    }
    partialTailLayer.lineCap = .round
    partialTailLayer.fillRule = .evenOdd
    partialTailLayer.strokeColor = progressColor.cgColor
    partialTailLayer.strokeStart = 0
    partialTailLayer.strokeEnd = 0
    partialTailLayer.lineWidth = 5
    partialTailLayer.fillColor = UIColor.clear.cgColor
    
    layer.addSublayer(tailLayer)
    layer.addSublayer(partialTailLayer)
  }
  
  private func mainTailAnimation() -> CAAnimationGroup {
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
  
  private func partialTailAnimation() -> CAAnimationGroup {
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

/// A property wrapper that clamps a value between a specified range.
@propertyWrapper
struct Clamped<Value: Comparable> {
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
