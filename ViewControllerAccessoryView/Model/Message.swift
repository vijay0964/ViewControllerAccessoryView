//
//  Message.swift
//  ViewControllerAccessoryView
//
//  Created by Augray on 17/08/20.
//  Copyright © 2020 vj. All rights reserved.
//

import Foundation

struct Message {
    var content: String
    var isOutGoing: Bool
}

extension Message {
    static var dummyMessages: [Message] {
        return [Message(content: "Hi!", isOutGoing: true),
                Message(content: "Hello!", isOutGoing: false),
                Message(content: "How are you?", isOutGoing: true),
                Message(content: "Doing Great. What's up?", isOutGoing: false),
                Message(content: "Great weekend!", isOutGoing: true),
                Message(content: "Enjoy!", isOutGoing: false),
                
                Message(content: "Hi!", isOutGoing: true),
                Message(content: "Hello!", isOutGoing: false),
                Message(content: "How are you?", isOutGoing: true),
                Message(content: "Doing Great. What's up?", isOutGoing: false),
                Message(content: "Great weekend!", isOutGoing: true),
                Message(content: "Enjoy!", isOutGoing: false),
        ]
    }
}
