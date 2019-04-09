//
//  ChatModuleViewController.swift
//  D3RealTimeChatModule
//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.

import UIKit
import Firebase
import MaterialComponents


class ChatModuleViewController: UIViewController {
    
   
    var tableView: UITableView!
    var items = [Conversation]()
    var selectedUser: User?
    fileprivate func setupChatView() {
        
        self.view.backgroundColor = #colorLiteral(red: 0.9749622941, green: 0.2864883542, blue: 0.2989505529, alpha: 1)
      
        self.tableView = UITableView()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.safeTopAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
     
    }
    
    override func viewDidLoad() {
       super.viewDidLoad()
        self.title = "Chats"
          self.navigationController!.navigationBar.barStyle = .black
         self.navigationController!.navigationBar.isTranslucent = true
         self.navigationController!.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
         self.navigationController!.navigationBar.barTintColor = #colorLiteral(red: 0.9749622941, green: 0.2864883542, blue: 0.2989505529, alpha: 1)
        
           self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "ic_NewChat"), style: .plain, target: self, action: #selector(handleNewConversation)), animated: false)

        if checkUserLoginStatus(){
           setupChatView()
            self.fetchData()
        }
    }
    
    @objc private func handleNewConversation(){
        let vc = ContactList()
        //self.tabBarController.m
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func addNewContactsForLoggedInUser(contacts: [User]){
        let currentUserUid = UserDefaults.standard.string(forKey: "currentUser")
        var newContacts = [String:Any]()
        for contact in contacts {
            newContacts[contact.id] = true
        }
        Database.database().reference(fromURL: realTimeDataBaseReference).child("users/\(currentUserUid!)").child("Contacts").updateChildValues(newContacts)
    }
    
    
  
    
    //Downloading conversations
    func fetchData() {
        Conversation.showConversations { (conversations) in
            self.items = conversations
            self.items.sort{ $0.lastMessage.timestamp > $1.lastMessage.timestamp }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                for conversation in self.items {
                    if conversation.lastMessage.isRead == false {
                        break
                    }
                }
            }
        }
    }//Downloading conversations
    
    fileprivate func checkUserLoginStatus() -> Bool {
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(performLogout), with: nil, afterDelay: 0)
            return false
        }
        return true
    }
    
    
    
    @objc func performLogout(){
        
        do{
            try Auth.auth().signOut()
        }catch let logoutError {
            print(logoutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "Login") as! Login
        loginVC.modalPresentationStyle = .currentContext
        present(loginVC, animated: true, completion: nil)
    }
   
    
}
extension ChatModuleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        if self.items[indexPath.row].user.profilePic != nil {
            cell.profilePIc.image = self.items[indexPath.row].user.profilePic
        }
        cell.Username.text = self.items[indexPath.row].user.name
        let messageDate = Date.init(timeIntervalSince1970: TimeInterval(self.items[indexPath.row].lastMessage.timestamp))
        let dataformatter = DateFormatter.init()
        dataformatter.timeStyle = .short
        let date = dataformatter.string(from: messageDate)
        cell.timeStamp.text = date
        switch self.items[indexPath.row].lastMessage.type {
        case .text:
            let message = self.items[indexPath.row].lastMessage.content as! String
            cell.lastMessage.text = message
        
        default:
            cell.lastMessage.text = "Media"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let Chat = storyBoard.instantiateViewController(withIdentifier: "Chat") as! Chat
        Chat.currentUser = self.items[indexPath.row].user
        self.navigationController?.pushViewController(Chat, animated: true)
        
      
    }
    
    
    
    
}

