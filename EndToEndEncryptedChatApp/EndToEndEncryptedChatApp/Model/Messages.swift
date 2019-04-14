//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.


import Foundation
import UIKit
import Firebase

class Message: NSObject {
    
    //MARK: Properties
    var owner: MessageOwner
    var type: MessageType
    var content: Any
    var timestamp: Int
    var isRead: Bool
    var image: UIImage?
     var toID: String?
     var fromID: String?
    
    
    var pValue: Int?
    var gValue: Int?
    let currentUserId = Auth.auth().currentUser?.uid
    var diffieHelman = DeffieHelmanKeyExchange()

    
    //MARK: Methods
     class func downloadAllMessages(forUserID: String, completion: @escaping (Message) -> Swift.Void) {
      
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference(fromURL: realTimeDataBaseReference).child("users").child(currentUserID).child("conversations").child(forUserID).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference(fromURL: realTimeDataBaseReference).child("conversations").child(location).observe(.childAdded, with: { (snap) in
                        if snap.exists() {
                            let receivedMessage = snap.value as! [String: Any]
                            let messageType = receivedMessage["type"] as! String
                            var type = MessageType.text
                            switch messageType {
                            case "photo":
                                type = .photo
                                
                            default: break
                            }
                            let content = receivedMessage["content"] as! String
                            let fromID = receivedMessage["fromID"] as! String
                         let toID = receivedMessage["toID"] as! String
                            let timestamp = receivedMessage["timestamp"] as! Int
                            
                            if fromID == currentUserID {
                                let message = Message.init(type: type, content: content, owner: .receiver, timestamp: timestamp, isRead: true, toID: toID, fromID: fromID)
                                message.toID = toID
                                message.fromID = fromID
                                completion(message)
                            } else {
                                let message = Message.init(type: type, content: content, owner: .sender, timestamp: timestamp, isRead: true, toID: toID, fromID: fromID)
                                message.toID = toID
                                message.fromID = fromID
                                completion(message)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func downloadImage(indexpathRow: Int, completion: @escaping (Bool, Int) -> Swift.Void)  {
        if self.type == .photo {
            let imageLink = self.content as! String
            let imageURL = URL.init(string: imageLink)
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                if error == nil {
                    self.image = UIImage.init(data: data!)
                    completion(true, indexpathRow)
                }
            }).resume()
        }
    }
    
    class func markMessagesRead(forUserID: String)  {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference(fromURL: realTimeDataBaseReference).child("users").child(currentUserID).child("conversations").child(forUserID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference(fromURL: realTimeDataBaseReference).child("conversations").child(location).observeSingleEvent(of: .value, with: { (snap) in
                        if snap.exists() {
                            for item in snap.children {
                                let receivedMessage = (item as! DataSnapshot).value as! [String: Any]
                                let fromID = receivedMessage["fromID"] as! String
                                if fromID != currentUserID {
                                    Database.database().reference(fromURL: realTimeDataBaseReference).child("conversations").child(location).child((item as! DataSnapshot).key).child("isRead").setValue(true)
                                }
                            }
                        }
                    })
                }
            })
        }
    }
    
    func downloadLastMessage(fromId: String,forLocation: String, completion: @escaping () -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference(fromURL: realTimeDataBaseReference).child("conversations").child(forLocation).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    for snap in snapshot.children {
                        let receivedMessage = (snap as! DataSnapshot).value as! [String: Any]
                        let encryptedContent = receivedMessage["content"]! as! String
                        self.timestamp = receivedMessage["timestamp"] as! Int
                        let messageType = receivedMessage["type"] as! String
                        self.fromID = receivedMessage["fromID"] as? String
                        self.toID = receivedMessage["toID"] as? String
                        self.isRead = receivedMessage["isRead"] as! Bool
                        var type = MessageType.text
                        switch messageType {
                        case "text":
                            type = .text
                        case "photo":
                            type = .photo
                            
                        default: break
                        }
                        self.type = type
                        if currentUserID == self.fromID {
                            self.owner = .receiver
                        } else {
                            self.owner = .sender
                        }
                        self.decryptTextMessageFor(withEncryptedText: encryptedContent, completionHandler: {
                            completion()
                        })
                    }
                }
            })
        }
    }
    
    class func send(message: Message, toID: String, completion: @escaping (Bool) -> Swift.Void)  {
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            switch message.type {
                
            case .photo:
                let image = message.content as! UIImage
                
                let imageData = image.jpegData(compressionQuality: 0.5)
                let child = UUID().uuidString
                
                let storageRef = Storage.storage().reference().child("messagePics").child(child)
                
                storageRef.putData(imageData!, metadata: nil, completion: { (metadata, err) in
                    if err == nil {
                        storageRef.downloadURL(completion: { (url, error) in
                            if error == nil{
                                guard let path = url?.absoluteString else{
                                    return
                                }
 
                                //               } Storage.storage().reference().child("messagePics").child(child).put(imageData!, metadata: nil, completion: { (metadata, error) in
                                //                    if error == nil {
                                //                        let path = metadata?.downloadURL()?.absoluteString
                                let values = ["type": "photo", "content": path, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                                Message.uploadMessage(withValues: values, toID: toID, completion: { (status) in
                                    completion(status)
                                })
                            }
                        })
                        
                    }
                })
            case .text:
                
                let values = ["type": "text", "content": message.content, "fromID": currentUserID, "toID": toID, "timestamp": message.timestamp, "isRead": false] as [String : Any]
                
                Message.uploadMessage(withValues: values, toID: toID, completion: { (status) in
                    completion(status)
                })
            }
        }
    }
    
    class func uploadMessage(withValues: [String: Any], toID: String, completion: @escaping (Bool) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference(fromURL: realTimeDataBaseReference).child("users").child(currentUserID).child("conversations").child(toID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String: String]
                    let location = data["location"]!
                    Database.database().reference(fromURL: realTimeDataBaseReference).child("conversations").child(location).childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                } else {
                    Database.database().reference(fromURL: realTimeDataBaseReference).child("conversations").childByAutoId().childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        let data = ["location": reference.parent!.key]
                        Database.database().reference(fromURL: realTimeDataBaseReference).child("users").child(currentUserID).child("conversations").child(toID).updateChildValues(data as [AnyHashable : Any])
                        Database.database().reference(fromURL: realTimeDataBaseReference).child("users").child(toID).child("conversations").child(currentUserID).updateChildValues(data as [AnyHashable : Any])
                        completion(true)
                    })
                }
            })
        }
    }
    
    //MARK: Inits
    init(type: MessageType, content: Any, owner: MessageOwner, timestamp: Int, isRead: Bool, toID: String?, fromID: String?) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
    }
}

extension Message {
    fileprivate  func decryptText(text: String, completionHangler: @escaping ()->()) {
        var idForPublicKey: String
        switch owner {
        case .sender: idForPublicKey = fromID!
        case .receiver: idForPublicKey = toID!
        }
        
        
        let currentUserId = Auth.auth().currentUser?.uid
        Database.database().reference(fromURL: "https://chatmodule-2a4da.firebaseio.com/").child("users").child(idForPublicKey + "/credentials").observeSingleEvent(of: .value) { (userSnapshot) in
            if userSnapshot.exists(){
                let userCredentials = userSnapshot.value as! [String:Any]
                let receiptPublicKey = userCredentials["publicKey"] as! Int
                let privateKey = UserDefaults.standard.integer(forKey: currentUserId!)
                let sharedSecrect = self.diffieHelman.compute_exp_modulo(primitiveRoot: receiptPublicKey, privateKey: privateKey, prime: self.pValue!)
                print("\(sharedSecrect)")
                let cryptionPassword = String(sharedSecrect)
                self.decrypt(text: text, sharedSecrect: cryptionPassword, completionHandler:{
                    completionHangler()
                })
            }
        }
    }
    
    
    func decrypt(text: String,sharedSecrect: String, completionHandler: ()->()){
        
        print("Final Shared Secret: \(sharedSecrect)")
        let salt = "foo"
        
        let generateAESKey = try? AES256Cryption.createKey(password: sharedSecrect.data(using: .utf8)!, salt: salt.data(using: .utf8)!)
        
        print("Generated Hex: \(generateAESKey?.hexString)")
        
        
        var iv: Data
        
        if UserDefaults.standard.data(forKey: "iv") == nil {
            iv = AES256Cryption.randomIv()
            UserDefaults.standard.set(iv, forKey: "iv")
        }else{
            iv = UserDefaults.standard.data(forKey: "iv")!
        }
        
        print("Final IV: \(iv)")
        
        let aes = try! AES256Cryption(key: generateAESKey!, iv: iv)
        let message = text
        let digest = message.convertToData()
        let decrypted = try! aes.decrypt(digest)
        self.content = String(decoding: decrypted, as: UTF8.self)
        completionHandler()
    }
    
    
     func decryptTextMessageFor(withEncryptedText text: String, completionHandler: @escaping ()->()){
        
        if UserDefaults.standard.value(forKey: "pValue") == nil {
            Database.database().reference(fromURL: "https://chatmodule-2a4da.firebaseio.com/").child("DHParameters").observeSingleEvent(of: .value) {
                (dhParameters) in
                if dhParameters.exists() {
                    let paramters = dhParameters.value as! [String:Int]
                    self.pValue = paramters["pValue"]!
                    self.gValue = paramters["gValue"]!
                    
                    
                    UserDefaults.standard.set(self.pValue, forKey: "pValue")
                    UserDefaults.standard.set(self.gValue, forKey: "gValue")
                    self.decryptText(text: text, completionHangler: {
                        completionHandler()
                    })
                }
            }
        }else{
            self.pValue = UserDefaults.standard.value(forKey: "pValue") as! Int
            self.gValue = UserDefaults.standard.value(forKey: "gValue") as! Int
            print("P:\(self.pValue)")
            print("G:\(self.gValue)")
            decryptText(text: text, completionHangler: {
                completionHandler()
            })
        }
        
    }
    
}

