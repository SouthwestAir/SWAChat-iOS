//
//  ChatViewController-Channels.swift
//  ChatDemo
//

import UIKit

// MARK: - CHANNELS

extension ChatViewController {
    func setupChannels() {
        SWAMessagingManager.shared.messagingChannelsDelegate = self
        
        channelsCollectionView.register(UINib(nibName: "ChannelCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "channelCell")
        
        channels = SWAMessagingManager.shared.messagingApp?.conversationChannels ?? []
    }
    
    func moveMainToFirstItem() {
        let mainChannel = channels.filter { $0.name == "Main" }
        channels = channels.filter { $0.name != "Main" }
        channels.insert(contentsOf: mainChannel, at: 0)
    }
}

// MARK: - Messaging Channels Delegate

extension ChatViewController: SWAMessagingChannelsDelegate {
    func updateChannelData(channel: SWAMessagingChannel) {
        // replace item in list
        channels = channels.filter { $0.name != channel.name }
        channels.append(channel)
        moveMainToFirstItem() // just in case
        channelsCollectionView.reloadData()
    }
    
    func channelAdded(channel: SWAMessagingChannel, index: Int) {
        updateChannelData(channel: channel)
    }
    
    func channelModified(channel: SWAMessagingChannel, index: Int) {
        updateChannelData(channel: channel)
    }
    
    func unreadMessageCountDidChange(channel: SWAMessagingChannel, index: Int, count: Int) {
        print("Unread Message Count Changed Callback :: \(channel.channelId) :: \(count)")
    }
}


// MARK: - Collection View Delegate

extension ChatViewController: UICollectionViewDelegate {
    
    func selectCurrentChannel(channel: SWAMessagingChannel) {
        currentChatRoom = channel
        messages = channel.messages
        messagesTableView.reloadData()
    }
    
    func selectChannelCell(row selectedRow: Int) {
        for row in 0...(channels.count - 1) {
            if let cell = channelsCollectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? ChannelCollectionViewCell {
                if row == selectedRow {
                    cell.circleView.backgroundColor = .SWAPrimary
                    cell.halfView.backgroundColor = .SWAPrimary
                } else {
                    cell.circleView.backgroundColor = .clear
                    cell.halfView.backgroundColor = .clear
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCurrentChannel(channel: channels[indexPath.row])
        selectChannelCell(row: indexPath.row)
    }
}


// MARK: - Collection View Datasource

extension ChatViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channelCell", for: indexPath) as? ChannelCollectionViewCell else {
            fatalError("Unable to instantiate Channel cell")
        }
        
        // Make sure Main is selected first
        if channels[indexPath.row].name == "Main" &&
            currentChatRoom == nil {
            selectCurrentChannel(channel: channels[indexPath.row])
        }
        
        if channels[indexPath.row].name == currentChatRoom?.name {
            cell.circleView.backgroundColor = .SWAPrimary
            cell.halfView.backgroundColor = .SWAPrimary
        } else {
            cell.circleView.backgroundColor = .clear
            cell.halfView.backgroundColor = .clear
        }
        
        cell.iconLabel.text = self.channels[indexPath.row].channelId
        // cell.titleLabel.text = self.channels[indexPath.row].name
            
        return cell
    }
    
    
}
