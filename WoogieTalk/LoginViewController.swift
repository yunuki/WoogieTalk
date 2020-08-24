//
//  LoginViewController.swift
//  WoogieTalk
//
//  Created by woogie on 2020/08/23.
//  Copyright © 2020 woogie. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try! Auth.auth().signOut()
        // Do any additional setup after loading the view.
        color = remoteConfig["splash_themecolor"].stringValue
        loginButton.backgroundColor = UIColor(hex: color)
        signUpButton.backgroundColor = UIColor(hex: color)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let mainVC = self.storyboard?.instantiateViewController(identifier: "MainViewTabBarController") as! UITabBarController
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, err) in
            if err != nil {
                let alert = UIAlertController(title: "error", message: err.debugDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func signUpButtonTapped(_ sender: Any) {
        let signUpVC = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
         self.present(signUpVC, animated: true, completion: nil)
        
    }


}
