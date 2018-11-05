//
//  LoginController.swift
//  gameofchats
//
//  Created by Raghu Sairam on 21/10/18.
//  Copyright © 2018 Raghu Sairam. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    var messageController: MessageController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputsContainer)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainer()
        setupLoginRegisterButton()
        setupProfileImage()
        setupLoginRegisterSegementedControl()
    }

    //this property will give you statusbar color in white color 
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    let inputsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(r: 81, g: 101, b: 161)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gameofthrones_splash")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageChange)))
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //change height of input contraint when login and register is toggled
        inputsContainerHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        //logic for nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor? = nameTextField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //logic for emailTextField
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor? = emailTextField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        
        //logic for password
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor? = passwordTextField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func setupLoginRegisterSegementedControl() {
        
        //need x,y widht & height
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainer.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupProfileImage() {
       
        //need x,y widht & height for profile image
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    var inputsContainerHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor:NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func setupInputsContainer() {
        
        view.addSubview(nameTextField)
        view.addSubview(nameSeparatorView)
        view.addSubview(emailTextField)
        view.addSubview(emailSeparatorView)
        view.addSubview(passwordTextField)
        
        
        //need x,y widht & height
        inputsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerHeightAnchor = inputsContainer.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerHeightAnchor?.isActive = true
        
        
        //need x,y widht & height = Name Field
        nameTextField.topAnchor.constraint(equalTo: inputsContainer.topAnchor).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 12).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //need x,y widht & height = Name Field Separator
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        //need x,y widht & height = Email Field
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 12).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x,y widht & height = Email Field Separator
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x,y widht & height = Password Field
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainer.leftAnchor, constant: 12).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainer.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
    }
    func setupLoginRegisterButton() {
        
        
        //need x,y widht & height
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainer.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainer.widthAnchor).isActive = true
    }
}
