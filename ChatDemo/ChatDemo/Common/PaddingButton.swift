//
//  PaddingButton.swift
//  SWA Open Source
//

import UIKit

@IBDesignable
public class PaddingButton: UIButton {
    @IBInspectable public var cornerRadiusValue: CGFloat = 8.0 {
        didSet {
            setUpView()
        }
    }
    open override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    public func setUpView() {
        self.layer.cornerRadius = self.cornerRadiusValue
        self.clipsToBounds = true
    }
}
