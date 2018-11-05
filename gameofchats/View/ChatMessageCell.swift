//
//  ChatMessageCell.swift
//  gameofchats
//
//  Created by Raghu Sairam on 31/10/18.
//  Copyright © 2018 Raghu Sairam. All rights reserved.
//

import UIKit
import Firebase

class  ChatMessageCell: UICollectionViewCell {
    
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    static var blueColor = UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "nedstark")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        
        //x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        //x,y,w,h
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor =  bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //ios 9 constraints
        //x,y,w,h
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        textView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
