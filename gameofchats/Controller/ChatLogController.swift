//
//  ChatLogController.swift
//  gameofchats
//
//  Created by Raghu Sairam on 24/10/18.
//  Copyright © 2018 Raghu Sairam. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import MobileCoreServices

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
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

                let message = Message(dictionary: dictionary)
                //message.setValuesForKeys(dictionary)
                
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    //need to scroll down
                    let indexpath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexpath, at: .bottom, animated: true)
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
        setupKeyboardObservers()
        
        collectionView?.keyboardDismissMode = .interactive
    }

    lazy var inputContainerView: ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    @objc func handleUploadImages() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage,kUTTypeMovie] as [String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {
            //user selected video
            handleVideoWithUrl(videoUrl)
        } else {
            //user selected image
            handleImageWithInfo(info)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoWithUrl(_ url: URL){
        let uniqueVideoName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message_videos").child(uniqueVideoName+".mov")
        let uploadTask = storageRef.putFile(from: url, metadata: nil) { (metaData, error) in
            if error != nil {
                print("Failed to upload video", error!)
                return
            }
            
                storageRef.downloadURL(completion: { (downloadurl, downloadError) in
                    if downloadError != nil {
                        print(downloadError!)
                    }
                    
                    if let videoUrl = downloadurl?.absoluteString  {
                        
                        if let thumbnailImage = self.thumbnailImageForFileUrl(url) {
                            self.uploadImagesIntoFireBase(thumbnailImage, completion: { (imageUrl) in
                                let properties:[String: Any] = ["imageUrl" : imageUrl,"imageHeight": thumbnailImage.size.height,"imageWidth": thumbnailImage.size.width, "videoUrl":videoUrl]
                                self.sendMessageWithProperties(properties)
                            })
                        }
                    }
                })
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            if let progress = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(progress)
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }
        
    }
    
    private func thumbnailImageForFileUrl(_ fileUrl:URL) -> UIImage? {
        let avAsset = AVAsset(url: fileUrl)
        let assetGenerator = AVAssetImageGenerator(asset: avAsset)
        
        do {
            let thumbnailCGImage = try assetGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    private func handleImageWithInfo(_ info:[String: Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadImagesIntoFireBase(selectedImage) { (imageUrl) in
                self.sendMessageWithUrl(imageUrl, selectedImage)
            }
        }
    }
    
    private func uploadImagesIntoFireBase(_ image: UIImage, completion:@escaping (_ imageUrl: String)->()){
        let uniqueImageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(uniqueImageName+".jpg")
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("Failed to upload image",error!)
                    return
                }
                
                ref.downloadURL(completion: { (url, downloadError) in
                    if downloadError != nil {
                        print(downloadError!)
                        return
                    }
                    if let downloadUrl = url?.absoluteString  {
                        completion(downloadUrl)
                        //self.sendMessageWithUrl(downloadUrl,image)
                    }
                })
                
            }
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {return true}
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: Notification.Name.UIKeyboardDidShow, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    @objc func keyboardDidShow(){
        if messages.count > 0 {
            let indexpath = IndexPath(item: messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexpath, at: .top, animated: true)
        }
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
    
    

    
    //MARK: Handlers
    @objc func handleSendMessages() {
        let properties:[String: Any] = ["text" : self.inputContainerView.inputTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)]
        sendMessageWithProperties(properties)
    }
    
    func sendMessageWithUrl(_ imageUrl: String, _ image: UIImage) {
        let properties:[String: Any] = ["imageUrl" : imageUrl, "imageHeight": image.size.height,"imageWidth": image.size.width]
        sendMessageWithProperties(properties)
        
    }
    
    
    
    private func sendMessageWithProperties(_ properties: [String: Any]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let fromID = Auth.auth().currentUser!.uid
        let toID = user!.id!
        let timeStamp = Int(Date().timeIntervalSince1970)
        var value:[String: Any] = ["toID": toID, "fromId" : fromID,"timeStamp" : timeStamp]
        
        properties.forEach { (k,v) in
            value[k] = v
        }
        
        childRef.updateChildValues(value) { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromID).child(toID)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId!:1])
            
            
            let receipientUserMessageRef = Database.database().reference().child("user-messages").child(toID).child(fromID)
            receipientUserMessageRef.updateChildValues([messageId!:1])
        }
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        //calculate the dynamic size of the text
        let message = messages[indexPath.row]
        if let text = message.text {
             height = estimateSizeOfText(text).height + 20
        } else if let imageHeight = message.imageHeight, let imageWidth = message.imageWidth {
            // h1 / w1 = h2 / w2
            // solve h1 = h2 / w2 * w1
            height = CGFloat(imageHeight.floatValue / imageWidth.floatValue * 200)
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
        
        cell.chatLogController = self
        
        let message = messages[indexPath.row]
        cell.message = message
        setupChatMessageCell(cell,message)
        
        if let text = message.text {
            cell.textView.text = text
            cell.bubbleWidthAnchor?.constant = estimateSizeOfText(text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil
        
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
        
        if let imageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(imageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    var startingFrame: CGRect?
    var blackBackGroundView: UIView?
    var startingImage: UIImageView?
    
    
    func performZoomForStartingImageView(startingImageView: UIImageView) {
        
        self.startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        self.startingImage = startingImageView
        
        self.startingImage?.isHidden = true
        
        let zoomingImageFrame = UIImageView(frame: startingFrame!)
        zoomingImageFrame.image = startingImageView.image
        zoomingImageFrame.isUserInteractionEnabled = true
        zoomingImageFrame.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(performZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            self.blackBackGroundView = UIView(frame: keyWindow.frame)
            
            self.blackBackGroundView?.backgroundColor = .black
            self.blackBackGroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackGroundView!)
            keyWindow.addSubview(zoomingImageFrame)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackGroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                
                
                //h2 / w2 = h1 / w1
                // h2 = h1 / w1 * w2
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageFrame.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageFrame.center = keyWindow.center
                
            }, completion: nil)
            
        }
    }
    
    @objc func performZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImage = tapGesture.view {
            
            UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImage.layer.cornerRadius = 16
                zoomOutImage.clipsToBounds = true
                zoomOutImage.frame = self.startingFrame!
                self.blackBackGroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }) { (completed:Bool) in
                zoomOutImage.removeFromSuperview()
                self.startingImage?.isHidden = false
            }
        }
    }
    
}
