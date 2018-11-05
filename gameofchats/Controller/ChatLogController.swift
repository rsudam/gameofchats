//
//  ChatLogController.swift
//  gameofchats
//
//  Created by Raghu Sairam on 24/10/18.
//  Copyright © 2018 Raghu Sairam. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    var messages = [Message]()
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    var user: User? {
        didSet {
            if let title = user?.name {
                navigationItem.title = title
            }
            
            observeMessages()
        }
    }
    
    
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid).child(toId)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
    
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
    
                guard let dictionary = snapshot.value as? [String: Any] else {return}

                let message = Message()
                message.setValuesForKeys(dictionary)
                print("We trying to observe user images",message.text)
                
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
    
            }, withCancel: nil)
        }, withCancel: nil)
        
    }

    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
//        setupInputFieldView()
//        setupKeyboardObservers()
        
        collectionView?.keyboardDismissMode = .interactive
    }

    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendMessages), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(self.inputTextField)
        //x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {return true}
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        if let frameRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect, let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            containerViewBottomAnchor?.constant = -frameRect.height
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        containerViewBottomAnchor?.constant = 0
        
        if let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double {
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //this remove observer is useful when you add an keyboard observer then addObserve method will be fired in multiple factor when user revisits the same page
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: Design Items
    lazy var inputTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        tf.placeholder = "Enter message..."
        return tf
    }()

    
    //MARK: Handlers
    @objc func handleSendMessages() {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let fromID = Auth.auth().currentUser!.uid
        let toID = user!.id!
        let timeStamp = Int(Date().timeIntervalSince1970)
        let value:[String: Any] = ["text" : inputTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), "toID": toID, "fromId" : fromID,"timeStamp" : timeStamp]
        
        childRef.updateChildValues(value) { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            self.inputTextField.text = nil
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromID).child(toID)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId!:1])
            
            
            let receipientUserMessageRef = Database.database().reference().child("user-messages").child(toID).child(fromID)
            receipientUserMessageRef.updateChildValues([messageId!:1])
        }
    }
    
    //MARK: setup views
    func setupInputFieldView() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        //ios9 constraint anchors
        //x,y,w,h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .selected)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendMessages), for: .touchUpInside)
        containerView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        //x,y,w,h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    //MARK: in built methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSendMessages()
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        //calculate the dynamic size of the text
        
        if let text = messages[indexPath.row].text {
             height = estimateSizeOfText(text).height + 20
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateSizeOfText(_ text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.row]
        
        cell.textView.text = message.text
        
        setupChatMessageCell(cell,message)
        
        cell.bubbleWidthAnchor?.constant = estimateSizeOfText(message.text!).width + 32
        
        return cell
    }
    
    private func setupChatMessageCell(_ cell:ChatMessageCell, _ message:Message) {
        
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing messages
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.bubbleLeftAnchor?.isActive = false
            cell.bubbleRightAnchor?.isActive = true
            cell.profileImageView.isHidden = true
        } else {
            
            //incoming messages
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.bubbleLeftAnchor?.isActive = true
            cell.bubbleRightAnchor?.isActive = false
            cell.profileImageView.isHidden = false
            
        }
    }
    
}
