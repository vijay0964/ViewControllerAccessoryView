//
//  AccessoryView.swift
//  RocketChatViewController
//
//  Created by Augray on 19/04/20.
//

import UIKit

public class CustomAccessoryView: UIView {
    var sendBtnCalled: ((String?) -> Void)?
    
    public let composerView = tap(ComposerView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    
    public let accessoryView = tap(UIView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    
    public var accessoryViewHeight: CGFloat = 0.0 {
        didSet {
            UIView.animate(withDuration: accessoryViewHeight == 0.0 ? 0.0 : 0.2) {
                self.invalidateIntrinsicContentSize()
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override var intrinsicContentSize: CGSize {
        let height = composerView.intrinsicContentSize.height + accessoryViewHeight
        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }
    
    public func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false

//        composerView.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        
        composerView.delegate = self
        
        addSubviews()
        setupConstraints()
    }

    private func addSubviews() {
        addSubview(composerView)
        addSubview(accessoryView)
    }

    // MARK: Constraints

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            //  composerView
            composerView.topAnchor.constraint(equalTo: topAnchor),
            composerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            composerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            //  accessoryView
            accessoryView.topAnchor.constraint(equalTo: composerView.bottomAnchor),
            accessoryView.bottomAnchor.constraint(equalTo: bottomAnchor),
            accessoryView.leadingAnchor.constraint(equalTo: leadingAnchor),
            accessoryView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func removeAccessoryViewSubviews() {
        guard accessoryViewHeight != 0.0 else {
            return
        }
        
        accessoryView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        accessoryViewHeight = 0.0
    }
}

extension CustomAccessoryView: ComposerViewDelegate {
    public func composerView(_ composerView: ComposerView, event: UIEvent, eventType: UIControl.Event, happenedInButton button: ComposerButton) {
        if eventType == .touchUpInside {
            if button === composerView.rightButton {
                sendBtnCalled?(composerView.textView.text)
                composerView.textView.text = ""
            }
        }
    }
}

public extension CustomAccessoryView {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === composerView && keyPath == "bounds" {
            self.invalidateIntrinsicContentSize()
            composerView.invalidateIntrinsicContentSize()
            composerView.setNeedsLayout()
            self.superview?.setNeedsLayout()
        }
    }
}
