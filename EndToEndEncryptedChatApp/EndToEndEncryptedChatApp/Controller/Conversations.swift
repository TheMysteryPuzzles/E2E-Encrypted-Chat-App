//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.

import UIKit

class Conversations: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var items = [Conversation]()
    var selectedUser: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
        // Do any additional setup after loading the view.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as? ConversationCell else{
            return UITableViewCell()
        }
        cell.profilePIc.image = self.items[indexPath.row].user.profilePic
        cell.Username.text = self.items[indexPath.row].user.name
        let messageDate = Date.init(timeIntervalSince1970: TimeInterval(self.items[indexPath.row].lastMessage.timestamp))
        let seen = self.items[indexPath.row].lastMessage.isRead
        if seen{
            
        }else{
            
        }
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
        Chat.selectedRecipient = self.items[indexPath.row].user
        self.navigationController?.pushViewController(Chat, animated: true)
    }
    
    

    
    //Downloads conversations
    func fetchData() {
        Conversation.showConversations { (conversations) in
            self.items = conversations
            self.items.sort{ $0.lastMessage.timestamp > $1.lastMessage.timestamp }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                for conversation in self.items {
                    if conversation.lastMessage.isRead == false {
                        //self.playSound()
                        break
                    }
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
