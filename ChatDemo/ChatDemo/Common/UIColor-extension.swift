//
//  UIColor-extension.swift
//  SWA Open Source
//
//  These are the colors/style guide for Southwest's open source initiative
//  They are based on a historical palette ("retro colors") that we used in the past

import UIKit

extension UIColor {
    static let SWAPrimary = UIColor.rgb(0x6387bb)       // light blue
    static let SWASecondary = UIColor.rgb(0x00597b)     // dark blue
    static let SWASuccess = UIColor.rgb(0x76a314)       // green
    static let SWAWarning = UIColor.rgb(0xfec456)       // yellow
    static let SWAError = UIColor.rgb(0xf4202f)         // red
    static let SWANeutral = UIColor.rgb(0xb7b5ba)       // gray
    static let SWADark = UIColor.rgb(0x23282c)          // black
    static let SWALight = UIColor.white                 // white
    
    // Modified from https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
    static func rgb(_ rgbValue: Int) -> UIColor! {
        return UIColor(
            red: CGFloat((Float((rgbValue & 0xff0000) >> 16)) / 255.0),
            green: CGFloat((Float((rgbValue & 0x00ff00) >> 8)) / 255.0),
            blue: CGFloat((Float((rgbValue & 0x0000ff) >> 0)) / 255.0),
            alpha: 1.0)
    }
}
