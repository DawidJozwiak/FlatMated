//
//  MessageModel.swift
//  FlatmateSeeker
//
//  Created by Dawid Jóźwiak on 07/11/2021.
//

import Foundation
import Firebase
import MessageKit

struct MessageModel : MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
