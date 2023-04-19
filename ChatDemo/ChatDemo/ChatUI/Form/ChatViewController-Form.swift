//
//  ChatViewController-Form.swift
//  ChatDemo
//

import UIKit

// MARK: - FORM

extension ChatViewController {
    
    func setupForm() {
        usernameLabel?.text = "\(ChatManager.shared.avatar ?? "") \(ChatManager.shared.username ?? "")"
    }
    
    // MARK: - IBAction for Chat Form
    
    func sendMessage(_ sender: Any, message: String? = nil) {
        let messageText: String = message ?? messageText.text ?? ""
        if let username = ChatManager.shared.username,
           let avatar = ChatManager.shared.avatar {
            
            let message = SWAMessagingMessage(userId: avatar, displayName: username, content: messageText)
            currentChatRoom?.addMessage(message: message)
            
            self.messageText.text = ""
            self.messageText.resignFirstResponder()
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        sendMessage(self, message: nil)
    }
    
}

// MARK: - Text Field Delegate

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == messageText {
            sendMessage(textField)
        }
        return false
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 200.0
        let duration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.5
        
        self.typeViewBottomConstraint.constant = typeViewBottomDefaultOffset - (keyboardHeight - 49)
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        let duration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.5
        
        self.typeViewBottomConstraint.constant = typeViewBottomDefaultOffset // or change according to your logic
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}
