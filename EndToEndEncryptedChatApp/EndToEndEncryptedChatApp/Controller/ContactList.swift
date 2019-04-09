//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.

import UIKit
import Firebase

class ContactList: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tableView: UITableView!
    var UsersArr = [User]()
    var selectedUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TotalUserCell.self, forCellReuseIdentifier: "TotalUserCell")
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeTopAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor)
            ])
        
        self.fetchUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.view.endEditing(true)
        self.navigationItem.title = "Users"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    //Downloads users list for Contacts View
    func fetchUsers()  {
        UsersArr.removeAll()
        if (Auth.auth().currentUser?.uid) != nil {
            self.tableView.performBatchUpdates({
                User.downloadAllUsers(completion: {(user) in
                    DispatchQueue.main.async {
                        self.UsersArr.append(user)
                        self.tableView.insertRows(at: [IndexPath(item: self.UsersArr.count-1, section: 0)], with: .none)
                    }
                })
            }, completion: nil)
        
           
        }
       
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UsersArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "TotalUserCell", for: indexPath) as! TotalUserCell
        if UsersArr[indexPath.row].profilePic != nil {
            cell.profilePic.image = UsersArr[indexPath.row].profilePic
        }
        cell.username.text = UsersArr[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected")
    
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let Chat = storyBoard.instantiateViewController(withIdentifier: "Chat") as! Chat
        Chat.currentUser = self.UsersArr[indexPath.row]
        self.navigationController?.pushViewController(Chat, animated: true)
    }
    
    
}
