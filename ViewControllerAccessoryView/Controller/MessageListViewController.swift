//
//  MessageListViewController.swift
//  ViewControllerAccessoryView
//
//  Created by Augray on 17/08/20.
//  Copyright © 2020 vj. All rights reserved.
//

import UIKit

class MessageListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let invertedTransform = CGAffineTransform(scaleX: 1, y: -1)
    private let regularTransform = CGAffineTransform(scaleX: 1, y: 1)
    
    let accessoryView = CustomAccessoryView()
    
    fileprivate var keyboardHeight: CGFloat = 0.0
    
    var messages = Message.dummyMessages
    
    open var isInverted = true {
        didSet {
            DispatchQueue.main.async {
                if self.isInverted != oldValue {
                    self.collectionView?.transform = self.isInverted ? self.invertedTransform : self.regularTransform
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    @objc open var topHeight: CGFloat {
        if navigationController?.navigationBar.isTranslucent ?? false {
            var top = navigationController?.navigationBar.frame.height ?? 0.0
            top += UIApplication.shared.statusBarFrame.height
            return top
        }
        
        return 0.0
    }
    
    @objc open var bottomHeight: CGFloat {
        var composer = keyboardHeight
        composer += view.safeAreaInsets.bottom
        return composer
    }
    
    override var inputAccessoryView: UIView? {
        accessoryView.layoutMargins = view.layoutMargins
        accessoryView.directionalLayoutMargins = systemMinimumLayoutMargins
        return accessoryView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChatViews()
        
        startObservingKeyboard()
        
        accessoryView.sendBtnCalled = { [weak self] (text) in
            guard let text = text, !text.isEmpty, text.count > 0 else {
                return
            }
            
            let message = Message(content: text, isOutGoing: self?.randomBool() ?? true)
            self?.isInverted == true ? self?.messages.insert(message, at: 0) : self?.messages.append(message)
            self?.collectionView.reloadData()
            self?.scrollToBottom()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        becomeFirstResponder()
        
        if !isInverted {
            scrollToBottom()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingKeyboard()
    }
    
    func setupChatViews() {
        guard let collectionView = collectionView else {
            return
        }
        
        self.collectionView.register(UINib(nibName: IncomingMessageCell.identifier, bundle: nil), forCellWithReuseIdentifier: IncomingMessageCell.identifier)
        self.collectionView.register(UINib(nibName: OutgoingMessageCell.identifier, bundle: nil), forCellWithReuseIdentifier: OutgoingMessageCell.identifier)
        
        collectionView.backgroundColor = UIColor.lightGray
        
        collectionView.transform = isInverted ? invertedTransform : collectionView.transform
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.contentInsetAdjustmentBehavior = isInverted ? .never : .always
        
        collectionView.scrollsToTop = false
    }
    
    func startObservingKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_onKeyboardFrameWillChangeNotificationReceived(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    func stopObservingKeyboard() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc private func _onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification) {
        guard presentedViewController?.isBeingDismissed != false else {
            return
        }
        
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let collectionView = collectionView
            else {
                return
        }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.top)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        
        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        guard intersection.height != self.keyboardHeight else {
            return
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.keyboardHeight = intersection.height
            
            // Update contentOffset with new keyboard size
            var contentOffset = collectionView.contentOffset
            if self.isInverted {
                contentOffset.y -= intersection.height
                collectionView.contentOffset = contentOffset
                self.adjustContentSizeIfNeeded()
            } else {
                contentOffset.y = intersection.height
                collectionView.contentOffset = contentOffset
            }
        }, completion: { _ in
            UIView.performWithoutAnimation {
                self.view.layoutIfNeeded()
            }
        })
    }
    
    fileprivate func adjustContentSizeIfNeeded() {
        guard let collectionView = collectionView else { return }
        
        var contentInset = collectionView.contentInset
        
        if isInverted {
            contentInset.top = bottomHeight
            contentInset.bottom = topHeight
        } else {
            contentInset.bottom = bottomHeight
        }
        
        collectionView.contentInset = contentInset
        collectionView.scrollIndicatorInsets = contentInset
    }
}

// MARK: UICollectionViewDelegate & UICollectionViewDataSource

extension MessageListViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let message = messages[indexPath.row]
        
        if message.isOutGoing {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutgoingMessageCell.identifier, for: indexPath) as! OutgoingMessageCell
            cell.content.text = message.content
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IncomingMessageCell.identifier, for: indexPath) as! IncomingMessageCell
            cell.content.text = message.content
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.contentView.transform = isInverted ? invertedTransform : regularTransform
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 70)
    }
}

extension MessageListViewController {
    func scrollToBottom() {
        let item = isInverted == true ? 0 : messages.count - 1
        let position = isInverted == true ? UICollectionView.ScrollPosition.top : UICollectionView.ScrollPosition.bottom
        collectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: position, animated: true)
    }
    
    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
}
