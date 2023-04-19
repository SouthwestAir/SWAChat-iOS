//
//  ChatViewController.swift
//  ChatDemo
//

import UIKit

class ChatViewController: UIViewController {
    
    // The Chat view UI is broken into three logical sections:
    // 1. Channels: The top bar, containing the people or groups who are able to be chatted with
    // 2. Messages: The main message area, where messages for channels will appear
    // 3. Form: The chat form (in Web 1.0 parlance), for entering text to submit to a message area

    // MARK: - IBOutlet declarations
    
    // CHANNELS area
    @IBOutlet weak var channelsCollectionView: UICollectionView!
    
    // MESSAGES area
    @IBOutlet weak var messagesTableView: UITableView!
    
    // FORM area
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var typeViewBottomConstraint: NSLayoutConstraint!
    var typeViewBottomDefaultOffset: CGFloat = 0.0
    
    // MARK: - Data management declarations
    
    // MESSAGES
    weak var currentChatRoom: SWAMessagingChannel? {
        didSet {
            messages = currentChatRoom?.messages ?? []
            messagesTableView.reloadData()
        }
    }
    
    var channels: [SWAMessagingChannel] = []
    var messages: [SWAMessagingMessage] = []
    
    var scrollTimer: Timer? // this is the timer for animating scrolling of messages
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChannels()
        setupMessages()
        setupForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNotificationObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        destroyNotificationObservers()
    }
    
    
    // MARK: - Notification Center
    
    func setupNotificationObservers() {
        // Add Notification Observers Here
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func destroyNotificationObservers() {
        // Remove Notification Observers Here
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
