//
//  LoginViewController+Handlers.swift
//  gameofchats
//
//  Created by Raghu Sairam on 23/10/18.
//  Copyright © 2018 Raghu Sairam. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleProfileImageChange() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                print(error!)
                print("Failed to login")
                return
            }
            self.messageController?.fetchUserAndSetNavigationTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, authenticationError) in
            if authenticationError != nil {
                print(authenticationError!)
                print("Error in user creation")
                return
            }
            
            guard let uid = authResult?.user.uid else {
                print("Error while downcasting user uid")
                return
            }
            
            let uniqueImageName = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profileImages/\(uniqueImageName).jpg")
            
            if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) {
               
                storageRef.putData(uploadData, metadata: nil, completion: { (storageMetaData, storageError) in
                    if storageError != nil {
                        print(storageError!)
                        return
                    }
                    
                    storageRef.downloadURL(completion: { (url, downloadError) in
                        if downloadError != nil {
                            print(downloadError!)
                            return
                        }
                        guard let downloadUrl = url?.absoluteString else {
                            print("Error while downcasting url to absoluteString")
                            return
                        }
                        let values = ["name" : name, "email": email, "password": password,"profileImageUrl":downloadUrl]
                        self.registerUserIntoDataBaseWithUid(uid: uid, values: values)
                    })
                })
            }
        }
    }
    
    private func registerUserIntoDataBaseWithUid(uid: String, values: [String: Any]){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let usersNode = ref.child("users").child(uid)
        
        usersNode.updateChildValues(values, withCompletionBlock: { (errorUploadDataIntoDB, ref) in
            if errorUploadDataIntoDB != nil {
                print(errorUploadDataIntoDB!)
                return
            }
            
            if self.messageController != nil {
                let user = User()
                user.setValuesForKeys(values)
                self.messageController!.setupNavigationBarAndTitle(user)
            }
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
}
