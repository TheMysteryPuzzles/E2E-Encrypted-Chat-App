
//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class Login: UIViewController,UITextFieldDelegate {
  
    @IBOutlet weak var usernameTxtField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginbtn: UIButton!
    
    
    @IBOutlet weak var newUserView: UILabel!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.9749622941, green: 0.2864883542, blue: 0.2989505529, alpha: 1)
        self.hideKeyboardWhenTappedAround()
        SetUpGestures()
        SetUpDefaultTextFieldProperties()
        SetUpDefaultButtonProperties()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        super.viewWillAppear(true)
        self.view.endEditing(true)
      
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.title = "Login"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
    }
    
    @IBAction func loginBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if usernameTxtField.text!.count <= 0 || (usernameTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Please enter your username.", vc: self)
        }
        else if usernameTxtField.text!.count <= 2 || (usernameTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Username should be atleast 3 characters long.", vc: self)
        }
        else if passwordTextField.text!.count <= 0 || (passwordTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Please enter your password", vc: self)
        }else{
            login()
        }
        
       
        
    }//Login Button
    
    func login(){
        User.loginUser(email: usernameTxtField.text!, password: passwordTextField.text!, loginHandler: {(Loginhandler) in
            if Loginhandler == nil{
                print("Logged in")
                self.navigateToUsersMap()
                
            }else{
                ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: Loginhandler!, vc: self)
            }
        })
    }
    
    
    
//    func resendOTP(loginHandler: Loginhandler?){
//        let sv = UIViewController.displaySpinner(onView: (UIApplication.topViewController()?.navigationController?.view)!)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let OTP = storyboard.instantiateViewController(withIdentifier: "OTP") as! OTP
//        let alert = UIAlertController(title: "Account Verification", message: "Registered Mobile Number with this Account is not verified.", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Verify", style: UIAlertActionStyle.default, handler: { (result) in
//            UIViewController.removeSpinner(spinner: sv)
//            self.navigationController?.pushViewController(OTP, animated: true)
//            
//        }))
//        alert.addAction(UIAlertAction(title: "Resend OTP", style: UIAlertActionStyle.default, handler: { (result) in
//            let currentUser = UserDefaults.standard.value(forKey: "currentUser") as! String
//            Database.database().reference().child("users").child(currentUser).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
//                let credentialsData = snapshot.value as! [String: Any]
//                let phoneNumber = credentialsData["phoneNumber"] as! String
//                PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
//                    if let error = error {
//                        UIViewController.removeSpinner(spinner: sv)
//                        User.handleErrors(err: error as NSError, loginHandler: loginHandler!)
//                        return
//                    }else{
//                        UIViewController.removeSpinner(spinner: sv)
//                        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
//                        loginHandler!(nil)
//                    }
//                    
//                }
//                
//                
//            })
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }//Resend OTP
    
    @objc func registerVC(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let Register = storyBoard.instantiateViewController(withIdentifier: "Register") as! Register
        self.present(Register, animated: true, completion: nil)
    }//Move to Register View Controller
    
    
    func navigateToUsersMap(){
        let vc = UINavigationController(rootViewController: ChatModuleViewController())
       present(vc, animated: true, completion: nil)
      //  self.dismiss(animated: false, completion: nil)
    }//Move to UsersMap View Controller
    
    func newUserGesture(){
        let registerGesture = UITapGestureRecognizer(target: self, action: #selector(registerVC))
        newUserView?.isUserInteractionEnabled = true
        newUserView? .addGestureRecognizer(registerGesture)
    }//Add gesture to New User View
    
    func SetUpGestures(){
        newUserGesture()
    }//Gesture Setup Method
    
    func SetUpDefaultTextFieldProperties(){
        self.usernameTxtField.delegate = self
        self.passwordTextField.delegate = self
        self.usernameTxtField.cornerRadius(value: 5)
        self.usernameTxtField.setLeftPaddingPoints(10)
        self.passwordTextField.cornerRadius(value: 5)
        self.passwordTextField.setLeftPaddingPoints(10)
    }//set Up textfields
    
    
    
    func SetUpDefaultButtonProperties(){
        self.loginbtn.roundCorner()
    }//set Up Buttons
    

}
