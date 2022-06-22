//
//  MessengerViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 07/11/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import ProgressHUD
import Firebase
import IQKeyboardManagerSwift

class MessengerViewController: MessagesViewController, MessagesLayoutDelegate, MessagesDataSource, MessagesDisplayDelegate {

    var currentUser: Sender = Sender(senderId: "", displayName: "")
    var reciever: Sender = Sender(senderId: "", displayName: "")
    var textMessages: [String] = []
    var messages: [MessageType] = []
    var recieverId = ""
    var messagesId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        showPreviousMessages()
        ProgressHUD.dismiss()
        showPreviousMessages()
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
        setupBackgroundTouch()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    func currentSender() -> SenderType {
        currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    private func setupBackgroundTouch() {
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap(){
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    private func showPreviousMessages() {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        guard let id = Auth.auth().currentUser?.uid else { return }
        FirestoreListener.sharedInstance.getMessages(firstId: id, secondId: recieverId) { first, second in
            self.messages.removeAll()
            first?.forEach {
                self.messages.append(MessageModel(sender: self.currentUser, messageId: df.string(from: $0.value.dateValue()), sentDate: $0.value.dateValue(), kind: .text($0.key)))
            }
            second?.forEach {
                self.messages.append(MessageModel(sender: self.reciever, messageId: df.string(from: $0.value.dateValue()), sentDate: $0.value.dateValue(), kind: .text($0.key)))
            }
            self.messages = self.messages.sorted(by: {$0.sentDate < $1.sentDate })
            self.messagesCollectionView.reloadData()
        }
    }
}

extension MessengerViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        FirestoreListener.sharedInstance.saveMessage(firstId: id, secondId: recieverId, isSentByUser: true, text: text)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
}
