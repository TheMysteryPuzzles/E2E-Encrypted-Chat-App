//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.


import UIKit
import Firebase
import Photos

class Chat: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    var pValue: Int?
    var gValue: Int?
    let currentUserId = Auth.auth().currentUser?.uid
    var encryptedMessage: Data?
    var diffieHelman = DeffieHelmanKeyExchange()
    
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!

    @IBOutlet weak var bottomConstraint: UITableView!
    
     var topAnchorContraint: NSLayoutConstraint!
    
   
    
    //Show extra view
    @objc func showExtraViews(notification: NSNotification)  {
        let transform = CGAffineTransform.init(scaleX: 0.94, y: 0.94)
        self.topAnchorContraint.constant = 0
        self.navigationController?.isNavigationBarHidden = true
        if let type = notification.userInfo?["viewType"] as? ShowExtraView {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                
                if (type == .contacts || type == .profile) {
                    self.view.transform = transform
                }
            })
            switch type {
                
            case .contacts:
                break
            case .profile:
                break
            case .preview:
                break
            }
        }
    }
    
    
    //Hide Extra views
    func dismissExtraViews() {
        self.topAnchorContraint.constant = 1000
         self.navigationController?.isNavigationBarHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            
            self.view.transform = CGAffineTransform.identity
        }, completion:  { (true) in
            
          
            let vc = self.navigationController?.viewControllers.last
            vc?.inputAccessoryView?.isHidden = false
        })
    }
    override var inputAccessoryView: UIView? {
        get {
           
            self.inputBar.frame.size.height = self.barHeight
            self.inputBar.clipsToBounds = true
             print("\(self.inputBar.frame)")
            return self.inputBar
        }
    }
    
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    var items = [Message]()
    let imagePicker = UIImagePickerController()
    let barHeight: CGFloat = 50
    var selectedRecipient: User?
    var encryptedContent: Data?

    
    //MARK: Methods
    func customization() {
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = self.barHeight
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        self.navigationItem.title = self.selectedRecipient?.name
    }
    
    //Downloads messages
    func fetchData() {
        
        Message.downloadAllMessages(forUserID: self.selectedRecipient!.id, completion: {[weak weakSelf = self] (message) in
          
            message.decryptTextMessageFor(withEncryptedText: message.content as! String, completionHandler: {
                weakSelf?.items.append(message)
                weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
                DispatchQueue.main.async {
                    if let state = weakSelf?.items.isEmpty, state == false {
                        weakSelf?.tableView.reloadData()
                        weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                    }
                }
            })

        })
        Message.markMessagesRead(forUserID: self.selectedRecipient!.id)
    }
    
    //Hides current viewcontroller
    @objc func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    func composeMessage(type: MessageType, content: Any)  {
        
        let message = Message.init(type: type, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false, toID: nil, fromID: nil)
        Message.send(message: message, toID: self.selectedRecipient!.id, completion: {(_) in
        })
    }
    
    func checkLocationPermission() -> Bool {
        var state = false
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            state = true
        case .authorizedAlways:
            state = true
        default: break
        }
        return state
    }
    
    func animateExtraButtons(toHide: Bool)  {
        switch toHide {
        case true:
            //self.bottomConstraints.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        default:
           // self.bottomConstraints.constant = -50
            UIView.animate(withDuration: 0.3) {
                self.inputBar.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func showMessage(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
    }
    
    @IBAction func selectGallery(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .savedPhotosAlbum;
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func selectCamera(_ sender: Any) {
        self.animateExtraButtons(toHide: true)
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (status == .authorized || status == .notDetermined) {
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
  
    
    @IBAction func showOptions(_ sender: Any) {
        self.animateExtraButtons(toHide: false)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.count > 0 {
                
                let messageText = self.inputTextField.text!
                
                encrptAndComposeTextMessageFor(thisRecipient: self.selectedRecipient!.id, withText: messageText)
                self.inputTextField.text = ""
            }
        }
    }
    
    //MARK: NotificationCenter handlers
    @objc func showKeyboard(notification: Notification) {
     tableView.reloadData()
        if let frame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.tableView.contentInset.bottom = height
            self.tableView.scrollIndicatorInsets.bottom = height
            if self.items.count > 0 {
                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    //MARK: Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.items[indexPath.row].owner {
        case .receiver:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
            cell.clearCellData()
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as? String
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
          
            }
            return cell
        case .sender:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
            cell.clearCellData()
            cell.profilePic.image = self.selectedRecipient?.profilePic
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as! String
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
           
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.inputTextField.resignFirstResponder()
        switch self.items[indexPath.row].type {
        case .photo:
            if let photo = self.items[indexPath.row].image {
  
            }
       
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            self.composeMessage(type: .photo, content: pickedImage)
        } else {
            let pickedImage = info[.originalImage] as! UIImage
            self.composeMessage(type: .photo, content: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    

    
    //MARK: ViewController lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.inputBar.backgroundColor = UIColor.clear
        //self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(Chat.showKeyboard(notification:)), name: UIApplication.keyboardWillShowNotification, object: nil)
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        Message.markMessagesRead(forUserID: self.selectedRecipient!.id)
    }
    
    
    
    @IBAction func closeView(_ sender: Any) {
        self.dismissExtraViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchData()
        self.customization()
      //  self.customizationMapView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension Chat {
    fileprivate  func encryptText(text: String) {
        
        Database.database().reference(fromURL: "https://chatmodule-2a4da.firebaseio.com/").child("users").child((selectedRecipient?.id)! + "/credentials").observeSingleEvent(of: .value) { (userSnapshot) in
            if userSnapshot.exists(){
                let userCredentials = userSnapshot.value as! [String:Any]
                let receiptPublicKey = userCredentials["publicKey"] as! Int
                print("ReceiptPublic: \(receiptPublicKey)")
                let privateKey = UserDefaults.standard.integer(forKey: self.currentUserId!)
                print("Private: \(privateKey)")
                
                let sharedSecrect = self.diffieHelman.compute_exp_modulo(primitiveRoot: receiptPublicKey, privateKey: privateKey, prime: self.pValue!)
                print("\(sharedSecrect)")
                let cryptionPassword = String(sharedSecrect)
                self.encrypt(text: text, sharedSecrect: cryptionPassword)
            }
        }
    }
    
    
    func encrypt(text: String,sharedSecrect: String){
        
        let salt = "foo"
        let generateAESKey = try? AES256Cryption.createKey(password: sharedSecrect.data(using: .utf8)!, salt: salt.data(using: .utf8)!)
        
        var iv: Data
        if UserDefaults.standard.data(forKey: "iv") == nil {
            iv = AES256Cryption.randomIv()
            UserDefaults.standard.set(iv, forKey: "iv")
        }else{
            iv = UserDefaults.standard.data(forKey: "iv")!
        }
        let aes = try! AES256Cryption(key: generateAESKey!, iv: iv)
        let message = text
        let digest = message.data(using: .utf8)!
        self.encryptedMessage = try! aes.encrypt(digest)
        self.composeMessage(type: .text, content:  self.encryptedMessage!.hexString)
        
        
    }
    
    
    func encrptAndComposeTextMessageFor(thisRecipient recipientId: String, withText text: String){
        
        if UserDefaults.standard.value(forKey: "pValue") == nil {
            Database.database().reference(fromURL: "https://chatmodule-2a4da.firebaseio.com/").child("DHParameters").observeSingleEvent(of: .value) {
                (dhParameters) in
                if dhParameters.exists() {
                    let paramters = dhParameters.value as! [String:Int]
                    self.pValue = paramters["pValue"]!
                    self.gValue = paramters["gValue"]!
                    
                    UserDefaults.standard.set(self.pValue, forKey: "pValue")
                    UserDefaults.standard.set(self.gValue, forKey: "gValue")
                    self.encryptText(text: text)
                }
            }
        }else{
            self.pValue = UserDefaults.standard.value(forKey: "pValue") as! Int
            self.gValue = UserDefaults.standard.value(forKey: "gValue") as! Int
            encryptText(text: text)
            
        }
        
    }
    
}





extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    private static let hexAlphabet = "0123456789abcdef".unicodeScalars.map { $0 }
    
    public func hexEncodedString() -> String {
        return String(self.reduce(into: "".unicodeScalars, { (result, value) in
            result.append(Data.hexAlphabet[Int(value/16)])
            result.append(Data.hexAlphabet[Int(value%16)])
        }))
    }
    
}


extension String {
    func transformingFromHex() -> String? {
        return "&#x\(self);".applyingTransform(.toXMLHex, reverse: true)
    }
    
    func convertToData() -> Data {
        var hex = self
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
    
    
    
    
}

