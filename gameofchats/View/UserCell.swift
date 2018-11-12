//
//  UserCellTableViewCell.swift
//  gameofchats
//
//  Created by Raghu Sairam on 23/10/18.
//  Copyright © 2018 Raghu Sairam. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet{
            setupNameAndProfileImage()
            if let seconds = message?.timeStamp?.doubleValue {
                let timeStampDate = Date(timeIntervalSince1970: seconds)
                timeLabel.text = timeStampDate.getElapsedInterval()
//                let dateFormater = DateFormatter()
//                dateFormater.dateFormat = "hh:mm:ss a"
//                timeLabel.text = dateFormater.string(from: timeStampDate)
            }
            if message?.videoUrl != nil {
                self.detailTextLabel?.text = "sent a video"
                self.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 8)
            } else if message?.text == nil {
                self.detailTextLabel?.text = "sent an image"
                self.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 8)
            } else {
                self.detailTextLabel?.text = self.message?.text
            }
        }
    }
    
    func setupNameAndProfileImage() {
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    let user = User()
                    user.setValuesForKeys(dictionary)
                    self.textLabel?.text = user.name
                    self.profileImageView.loadImageUsingCacheWithUrlString(user.profileImageUrl!)
                }
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 24
        iv.layer.masksToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        
        //need x,y,width, height
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //need x,y,width, height
        timeLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
