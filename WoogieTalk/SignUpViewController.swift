//
//  SignUpViewController.swift
//  WoogieTalk
//
//  Created by woogie on 2020/08/24.
//  Copyright © 2020 woogie. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        color = remoteConfig["splash_themecolor"].stringValue
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        signUpButton.backgroundColor = UIColor(hex: color)
    }
    
    @objc func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    @IBAction func signUpButtonTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let image = imageView.image {
            if email == "" || password == "" || name == "" {
                let alert = UIAlertController(title: "경고", message: "모두 입력하세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil )
            } else {
                self.dismiss(animated: true) {
                    Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
                        if let uid = user?.user.uid {
                            guard let imageData = UIImage.jpegData(image)(compressionQuality: 0.1) else {return}
                            let imageRef = Storage.storage().reference().child("userImages/\(uid).jpg")
                            imageRef.putData(imageData, metadata: nil) { (metadata, err) in
                                imageRef.downloadURL { (url, err) in
                                    let imageURL = url?.absoluteString
                                    let values = ["userName":name, "profileImageURL":imageURL]
                                    Database.database().reference().child("users").child(uid).setValue(values)
                                }
                            }
                        }
                    }
                }
                
            }
        }
    }
}
