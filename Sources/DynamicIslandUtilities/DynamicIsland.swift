//
//  File.swift
//  
//
//  Created by Suyash Srijan on 19/09/2022.
//

import UIKit

/// A type that provides the size, origin and rect for the Dynamic Island.
/// - Note: This only provides the values for a static island, not one that is expanded (while a live activity is running for example)
public enum DynamicIsland {
    
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
}
