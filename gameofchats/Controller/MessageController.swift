//
//  ViewController.swift
//  gameofchats
//
//  Created by Raghu Sairam on 21/10/18.
//  Copyright © 2018 Raghu Sairam. All rights reserved.
//

import UIKit
import Firebase


class CustomTitleView :  UIView
{
    override var intrinsicContentSize: CGSize {
        get {
            //...
            return UILayoutFittingExpandedSize
            // return UILayoutFittingExpandedSize
        }
    }
}

class MessageController: UITableViewController {

    var messages = [Message]()
    var messageDictionary = [String : Message]()
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        //observeMessages()
        
        //observeUserMessages()
        
        
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            
            let messageRef = Database.database().reference().child("user-messages").child(uid).child(userId)
            
            messageRef.observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                let messageReference = Database.database().reference().child("messages").child(messageId)
                
                messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String : Any] {
                        let message = Message()
                        message.setValuesForKeys(dictionary)
                        
                        if let chatPartnerId = message.chatPartnerId() {
                            self.messageDictionary[chatPartnerId] = message
                            self.messages = Array(self.messageDictionary.values)
                            _ = self.messages.sorted(by: { (message1, message2) -> Bool in
                                return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
                            })
                        }
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                        
                    }
                    
                }, withCancel: nil)
                
            }, withCancel: nil)
            
            
            
            
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
    @objc func handleNewMessage() {
        let newMessage = NewMessageController()
        newMessage.messageController = self
        let navigation = UINavigationController(rootViewController: newMessage)
        present(navigation, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        //user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetNavigationTitle()
        }
    }
    
    func fetchUserAndSetNavigationTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error occurred while assiging Auth uid")
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavigationBarAndTitle(user)
            }
        }, withCancel: nil)
    }
    
    func setupNavigationBarAndTitle(_ user: User) {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        let titleView = CustomTitleView()
        titleView.isUserInteractionEnabled = true
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.isUserInteractionEnabled = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        
        containerView.addSubview(profileImageView)
        
        //need x,y,width & height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.isUserInteractionEnabled = true
        titleView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        containerView.addSubview(nameLabel)

        //need x,y,width & height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sampleCode)))
        
    }
    
    @objc func sampleCode() {
        print("123")
    }
    
    @objc func showChatControllerForUser(_ user: User) {
        let layout = UICollectionViewFlowLayout()
        let chatLogController = ChatLogController(collectionViewLayout: layout)
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    

    //this is logout function
    @objc func handleLogout(){
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("error while loggint out")
            print(error)
        }
        
        
        let loginController = LoginController()
        //this will bring up the login screen
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.message = self.messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user)
            
        }, withCancel: nil)
    }
}


