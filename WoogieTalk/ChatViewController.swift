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

    var uid: String?
    var chatRoomUid: String?
    var destinationUid: String?
    var comments: [ChatModel.Comment] = []
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = Auth.auth().currentUser?.uid
        checkChatRoom(completion: nil) //채팅방 db 존재 유무 체크
        // Do any additional setup after loading the view.
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
        Database.database().reference().child("chatRooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value)
    }
    
    func checkChatRoom(completion: (()->Void)?) {
        Database.database().reference().child("chatRooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: .value) { (dataSnapShot) in
            for item in dataSnapShot.children.allObjects as! [DataSnapshot] {
                if let chatRoomDic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatRoomDic)
                    if chatModel?.users[self.destinationUid!] == true {
                        self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        self.getMessageList()
                    }
                }
            }
            if let completion = completion {
                completion()
            }
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
        }
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.textLabel?.text = self.comments[indexPath.row].message
        return cell
    }
    
    
}
