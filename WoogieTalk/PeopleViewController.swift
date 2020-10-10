//
//  PeopleViewController.swift
//  WoogieTalk
//
//  Created by woogie on 2020/08/24.
//  Copyright © 2020 woogie. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class PeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var users: [UserModel] = []
    let tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeTableView()
        Database.database().reference().child("users").observe(.value) { (snapshot) in
            self.users.removeAll()

            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                userModel.setValuesForKeys(fchild.value as! [String:Any])
                if userModel.uid == myUid {
                    continue
                }
                self.users.append(userModel)
            }
            DispatchQueue.main.async {
                self.users = self.users.sorted(by: {$0.userName! < $1.userName!})
                self.tableView.reloadData()
            }
        }
    }
    
    func makeTableView() {
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PeopleViewTableCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PeopleViewTableCell
        
        let imageView = cell.imageview!
        
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(20)
            make.width.height.equalTo(50)
        }
        
        URLSession.shared.dataTask(with: URL(string: users[indexPath.row].profileImageURL!)!) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data)
                    imageView.layer.cornerRadius = imageView.frame.size.width / 2
                    imageView.clipsToBounds = true
                }
            }
        }
        
        let label = cell.label!
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(imageView.snp.right).offset(20)
        }
        label.text = self.users[indexPath.row].userName
        
        
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let chatVC = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as? ChatViewController
        chatVC?.destinationUid = self.users[indexPath.row].uid
        self.navigationController?.pushViewController(chatVC!, animated: true)
    }

}

class PeopleViewTableCell: UITableViewCell {
    var imageview: UIImageView! = UIImageView()
    var label: UILabel! = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(imageview)
        self.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
