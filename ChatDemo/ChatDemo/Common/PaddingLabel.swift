//
//  PaddingLabel.swift
//  SWA Open Source
//

import UIKit

// From https://spin.atomicobject.com/2017/08/04/swift-extending-uilabel/
// and
// From http://stackoverflow.com/questions/21167226/resizing-a-uilabel-to-accomodate-insets/21267507#21267507

@IBDesignable
public class PaddingLabel: UILabel {
    
    public var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top, left: -textInsets.left, bottom: -textInsets.bottom, right: -textInsets.right)
        
        return textRect.inset(by: invertedInsets)
    }
    
    open override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    open override var intrinsicContentSize: CGSize {
        
        let contentSize = super.intrinsicContentSize
        
        return contentSize
    }
}

extension PaddingLabel {
    
    @IBInspectable
    public var topInset: CGFloat {
        set { textInsets.top = newValue }
        get { return textInsets.top }
    }
    
    @IBInspectable
    public var bottomInset: CGFloat {
        set { textInsets.bottom = newValue }
        get { return textInsets.bottom }
    }
    
    @IBInspectable
    public var leftInset: CGFloat {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }
    
    @IBInspectable
    public var rightInset: CGFloat {
        set { textInsets.right = newValue }
        get { return textInsets.right }
    }
}

extension PaddingLabel {

    @IBInspectable
    var cornerRadius: CGFloat {
        set {
            clipsToBounds = true
            layer.masksToBounds = true
            layer.cornerRadius = newValue
        }
        get { return layer.cornerRadius }
    }
}
