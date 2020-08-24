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

            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                userModel.setValuesForKeys(fchild.value as! [String:Any])
                self.users.append(userModel)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func makeTableView() {
        tableView.rowHeight = 50
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
    
    func makeImageViewInCell(url: URL?) -> UIImageView {
        let imageView = UIImageView()
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data)
                    imageView.layer.cornerRadius = imageView.frame.size.width/2
                    imageView.clipsToBounds = true
                }
            }
        }.resume()
        return imageView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let imageView = makeImageViewInCell(url: URL(string: self.users[indexPath.row].profileImageURL!))
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(20)
            make.width.height.equalTo(50)
        }
        
        let label = UILabel()
        cell.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(imageView.snp.right).offset(20)
        }
        label.text = self.users[indexPath.row].userName
        
        
        
        return cell
    }
    

}
