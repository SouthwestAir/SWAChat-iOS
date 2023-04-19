
//
//  ChatBubbleCell.swift
//  SWAChat
//

import UIKit

class ChatBubbleCell: UITableViewCell {
    
    // Data needs to be loaded in labels prior to auto cell sizing is calculated.
    var messageData: SWAMessagingMessage? {
        didSet {
            updateData()
        }
    }
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel? // optional in this case, because left has it and right doesn't
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateData() {
        
        resetData()
        
        guard let messageData = messageData else { return }
        
        // Moving this up to the tableview protocol level.
        // Marked read only needs to be done if the table view is showing.
        // messageData.markAsReadByMe()
        
        // Convert avatar emoji into an image
        // This is where we typically set the employee photo from an S3 bucket
        avatarImage.image = messageData.sender.id.toImage()
        // avatarImage?.setEmployeeImage(withID: messageData.sender.id)
        
        if messageData.request != nil {
            messageLabel?.text = messageData.request?.name()
        } else {
            messageLabel?.text = messageData.content
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if (Calendar.current.isDateInYesterday(messageData.sentDate)) {
            dateFormatter.dateFormat = "(MM/dd) HH:mm"
        }
        timeLabel?.text = dateFormatter.string(from: messageData.sentDate)
        
        var name = messageData.sender.displayName
        if let role = messageData.sender.displayRole {
            name = name + " (\(role))"
        }
        
        nameLabel?.text = name
    }
    
    func resetData() {
        avatarImage.image = nil
        messageLabel?.text = ""
        timeLabel?.text = ""
    }

}
