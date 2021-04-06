//
//  LinearGradientView.swift
//  OWOWKit
//
//  Created by Luc Pernot on 20/02/2020.
//  Copyright © 2020 OWOW. All rights reserved.

import Foundation
import UIKit

@IBDesignable public class LinearGradientView : UIView {
    
    /// The leading/top color depending on the `Orientation`.
    @IBInspectable public var startColor: UIColor = .clear { didSet { setNeedsDisplay() } }
    
    /// The Trailing/bottom color depending on `Orientation`
    @IBInspectable public var endColor: UIColor = .clear { didSet { setNeedsDisplay() } }
    
    /// Direction of the gradient. Horizontal by default.
    public var orientation: Orientation = .horizontal
    
    /// To make `Orientation` work with interface builder.
    @IBInspectable public var isHorizontal: Bool {
        get {
            return orientation == .horizontal
        }
        set {
            orientation = newValue ? .horizontal : .vertical
        }
    }
    
    /// For determining on which direction the gradient should be drawn.
    public enum Orientation {
        case horizontal, vertical
    }
    
    /// 🌷
    public init(startcolor: UIColor, endcolor: UIColor, orientation: Orientation) {
        startColor = startcolor
        endColor = endcolor
        self.orientation = orientation
        
        super.init(frame: .zero)
        self.setup()
    }
    
    /// 🌷
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    /// 🖼
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure()
            return
        }
        
        let gradientColors = [startColor, endColor].map { $0.cgColor }
        
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: gradientColors as CFArray,
            locations: nil) else {
                assertionFailure()
                return
        }
        
        switch orientation {
        case .vertical:
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: bounds.midX, y: bounds.minY),
                end: CGPoint(x: bounds.midX, y: bounds.maxY),
                options: []
            )
            
        case .horizontal:
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: bounds.minX, y: bounds.midY),
                end: CGPoint(x: bounds.maxX, y: bounds.midY),
                options: []
            )
        }
    }
    
    /// Configuration for the view
    private func setup() {
        self.backgroundColor = .clear
    }
}
