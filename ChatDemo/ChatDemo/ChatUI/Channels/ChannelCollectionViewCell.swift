//
//  ChannelCollectionViewCell.swift
//  ChatDemo
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var halfView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        circleView.layer.cornerRadius = 12 //circleView.frame.width / 2
    }

}
