//
//  BaseMessageCell.swift
//  ViewControllerAccessoryView
//
//  Created by Augray on 17/08/20.
//  Copyright © 2020 vj. All rights reserved.
//

import UIKit

class BaseMessageCell: UICollectionViewCell {
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var messageView: UIView! {
        didSet {
            messageView?.layer.cornerRadius = 10
            messageView?.layer.masksToBounds = true
        }
    }
}
