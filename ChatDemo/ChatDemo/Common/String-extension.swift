//
//  String-extension.swift
//  SWA Open Source
//

import UIKit

extension String {
    // Modified from: https://stackoverflow.com/questions/38809425/convert-apple-emoji-string-to-uiimage

    func toImage() -> UIImage? {
        let size = CGSize(width: 60, height: 60)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 50)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
