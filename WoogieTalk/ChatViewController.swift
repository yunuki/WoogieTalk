//
//  ChatViewController.swift
//  WoogieTalk
//
//  Created by woogie on 2020/08/30.
//  Copyright © 2020 woogie. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var uid: String?
    var chatRoomUid: String?
    var destinationUid: String?
    var userModel: UserModel?
    var comments: [ChatModel.Comment] = []
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = Auth.auth().currentUser?.uid
        checkChatRoom(completion: nil) //채팅방 db 존재 유무 체크
        self.tabBarController?.tabBar.isHidden = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = keyboardSize.height - 20
        }
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        if chatRoomUid == nil {
            self.sendButton.isEnabled = false
            //첫 전송시 채팅방 생성
            let roomInfo = [
                "users": [
                    uid!: true,
                    destinationUid!: true
                ]
            ]
            Database.database().reference().child("chatRooms").childByAutoId().setValue(roomInfo) { (err, ref) in
                if err == nil {
                    self.checkChatRoom {
                        self.sendMessage()
                    }
                }
            }
            
        } else {
            sendMessage()
        }
        
    }
    
    func sendMessage() {
        let value: Dictionary<String,Any> = [
            "uid": uid!,
            "message": messageTextField.text!
        ]
        Database.database().reference().child("chatRooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value) { (err, ref) in
            self.messageTextField.text = ""
        }
    }
    
    func checkChatRoom(completion: (()->Void)?) {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: .value) { (dataSnapShot) in
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomDic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomDic)
                    if chatModel?.users[self.destinationUid!] == true {
                        self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        self.getDestinationInfo()
                    }
                }
            }
            if let completion = completion {
                completion()
            }
        }
    }
    func getDestinationInfo() {
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: .value) { (dataSnapShot) in
            self.userModel = UserModel()
            self.userModel?.setValuesForKeys(dataSnapShot.value as! [String:Any])
            self.getMessageList()
        }
    }
    func getMessageList() {
        Database.database().reference().child("chatRooms").child(self.chatRoomUid!).child("comments").observe(.value) { (dataSnapShot) in
            self.comments.removeAll()
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                if let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject]) {
                    self.comments.append(comment)
                }
            }
            self.tableView.reloadData()
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.comments[indexPath.row].uid == uid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            cell.messageLabel.text = self.comments[indexPath.row].message
            cell.messageLabel.numberOfLines = 0
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            cell.messageLabel.text = self.comments[indexPath.row].message
            cell.messageLabel.numberOfLines = 0
            cell.nameLabel.text = self.userModel?.userName
            let url = URL(string: (self.userModel?.profileImageURL)!)
            URLSession.shared.dataTask(with: url!) { (data, res, err) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.profileImageView.image = UIImage(data: data)
                        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
                        cell.profileImageView.clipsToBounds = true
                    }
                }
            }.resume()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
}

class DestinationMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
}
