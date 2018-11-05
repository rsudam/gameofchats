//
//  NewMessageController.swift
//  gameofchats
//
//  Created by Raghu Sairam on 23/10/18.
//  Copyright © 2018 Raghu Sairam. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()
    var messageController:MessageController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancelNewMessage))
        fetchAllUsers()
        navigationItem.title = "New Message"
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    func  fetchAllUsers() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any] {
                let user = User()
                user.setValuesForKeys(dictionary)
                user.id = snapshot.key
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancelNewMessage() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messageController?.showChatControllerForUser(user)
        }
    }
}


