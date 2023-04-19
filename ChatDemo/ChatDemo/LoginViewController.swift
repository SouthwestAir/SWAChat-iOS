//
//  LoginViewController.swift
//  ChatDemo
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var iconZoom: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUsername(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Blur effect for the large avatar icon in the background
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurEffectView, aboveSubview: iconZoom)
    }
    
    @IBAction func refreshUsername(_ sender: Any) {
        avatarLabel.text = MockUsernameGenerator.shared.generateAvatar()
        usernameLabel.text = MockUsernameGenerator.shared.generateUsername()
        
        if let avatarImage = avatarLabel.text?.toImage() {
            iconZoom.image = avatarImage
        }
    }
    
    @IBAction func enterChat(_ sender: Any) {
        ChatManager.shared.createUser(avatar: avatarLabel.text, username: usernameLabel.text) {
            self.performSegue(withIdentifier: "enterChatSegue", sender: self)
        }
    }

}
