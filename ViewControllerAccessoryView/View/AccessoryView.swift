//
//  AccessoryView.swift
//  ViewControllerAccessoryView
//
//  Created by Augray on 17/08/20.
//  Copyright © 2020 vj. All rights reserved.
//

import UIKit

class AccessoryView: UIView {
    var sendBtnCalled: ((String?) -> Void)?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBAction func sendBtnAction() {
        sendBtnCalled?(textField.text)
        textField.text = ""
    }
}

extension AccessoryView {
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "AccessoryView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
