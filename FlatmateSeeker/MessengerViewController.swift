//
//  MessengerViewController.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 07/11/2021.
//

import UIKit
import MessageKit
import Foundation
import InputBarAccessoryView
import Firebase


class MessengerViewController: MessagesViewController {

    private var chatId = ""
    private var recieverId = ""
    private var recieverName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    init(chatId: String, recieverId: String, recieverName: String){
        super.init(nibName: nil, bundle: nil)
        self.chatId = chatId
        self.recieverId = recieverId
        self.recieverName = recieverName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
