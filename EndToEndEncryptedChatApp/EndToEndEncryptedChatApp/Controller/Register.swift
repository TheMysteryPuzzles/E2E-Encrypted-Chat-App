//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.

import UIKit
import NKVPhonePicker
import CoreLocation

class Register: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet weak var countryCodeTxtField: NKVPhonePickerTextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var lastNametxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var confirmPassTxtField: UITextField!
    fileprivate var currentVC: UIViewController!
    
    var locationManager = CLLocationManager()
    var latitude = Double()
    var longitude = Double()
    var position = Dictionary<String,Any>()
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = true
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.9749622941, green: 0.2864883542, blue: 0.2989505529, alpha: 1)
        self.setUpLocation()
        self.hideKeyboardWhenTappedAround()
        self.addBackButton()
        SetUpGestures()
        SetUpDefaultTextFieldProperties()
        SetUpDefaultButtonProperties()
        SetUpImageProperties()
        setupCountryCodeFlag()
        self.setUpLocation()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.view.endEditing(true)
      
        self.navigationItem.title = "Register"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }//Setting Status bar Color
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == countryCodeTxtField
        {
            return false; //do not show keyboard nor cursor
        }
        return true
    }
    
    
    func profileTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(tap)
        
    }//Tap on Profile image
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        showActionSheet(vc: self)
    }//Show action Sheet
    
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.allowsEditing = true
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }//Camera
    
    func photoLibrary()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.allowsEditing = true
            myPickerController.sourceType = .photoLibrary
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
        
    }//photoLibrary
    
    func showActionSheet(vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
    }//Action Sheet
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }//Image Cancel
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let image = info[.editedImage] as? UIImage {
            userImage.image = image
        }else{
            print("Something went wrong")
        }
        currentVC.dismiss(animated: true, completion: nil)
    }//Pick
    
    
    
    @objc func LoginVC(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let Login = storyBoard.instantiateViewController(withIdentifier: "Login") as! Login
        self.navigationController?.pushViewController(Login, animated: true)
    }//Move to Login View Controller
    
    func LoginGesture(){
        let registerGesture = UITapGestureRecognizer(target: self, action: #selector(LoginVC))
        loginView.isUserInteractionEnabled = true
        loginView.addGestureRecognizer(registerGesture)
    }//Add gesture to login View
    
    func SetUpDefaultTextFieldProperties(){
        self.firstNameTxtField.delegate = self
        self.lastNametxtField.delegate = self
        self.phoneTxtField.delegate = self
        self.emailTxtField.delegate = self
        self.passwordTxtField.delegate = self
        self.confirmPassTxtField.delegate = self
        self.countryCodeTxtField.delegate = self
        self.firstNameTxtField.cornerRadius(value: 5)
        self.firstNameTxtField.setLeftPaddingPoints(10)
        self.lastNametxtField.cornerRadius(value: 5)
        self.lastNametxtField.setLeftPaddingPoints(10)
        self.phoneTxtField.cornerRadius(value: 5)
        self.phoneTxtField.setLeftPaddingPoints(10)
        self.countryCodeTxtField.cornerRadius(value: 5)
        self.emailTxtField.cornerRadius(value: 5)
        self.emailTxtField.setLeftPaddingPoints(10)
        self.passwordTxtField.cornerRadius(value: 5)
        self.passwordTxtField.setLeftPaddingPoints(10)
        self.confirmPassTxtField.cornerRadius(value: 5)
        self.confirmPassTxtField.setLeftPaddingPoints(10)
    }//set Up textfields
    
    func setupCountryCodeFlag(){
        countryCodeTxtField.phonePickerDelegate = self
        countryCodeTxtField.flagView.insets.left = 25
        countryCodeTxtField.favoriteCountriesLocaleIdentifiers = ["RU", "ER", "JM"]
        countryCodeTxtField.shouldScrollToSelectedCountry = false
        countryCodeTxtField.flagSize = CGSize(width: 25, height: 40)
        countryCodeTxtField.enablePlusPrefix = true
        
        // Setting initial custom country
        let country = Country.country(for: NKVSource(countryCode: "US"))
        countryCodeTxtField.country = country
    }//Flag Setup
    
    func SetUpDefaultButtonProperties(){
        self.registerBtn.roundCorner()
    }//set Up Buttons
    
    func SetUpImageProperties(){
        self.userImage.circleImage()
    }
    func SetUpGestures(){
        LoginGesture()
        profileTapGesture()
    }//Gesture Setup Method
    
    func setUpLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }//Setting up the Location Services
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("user latitude = \((location?.coordinate.latitude)!)")
        print("user longitude = \((location?.coordinate.longitude)!)")
        self.latitude = (location?.coordinate.latitude)!
        self.longitude = (location?.coordinate.longitude)!
        position = ["latitude": self.latitude,"longitude":self.longitude]
        
       
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }//Error in location Fetching
    
    
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        self.view.endEditing(true)
         if firstNameTxtField.text!.count <= 0 || (firstNameTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Please enter your first name.", vc: self)
        }
        else if firstNameTxtField.text!.count <= 2 || (firstNameTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "First name at least 3 characters long.", vc: self)
        }
        else if lastNametxtField.text!.count <= 0 || (lastNametxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Please enter your last name", vc: self)
        }
        else if lastNametxtField.text!.count <= 2 || (lastNametxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Last name at least 3 characters long.", vc: self)
        }
        else if countryCodeTxtField.text!.count <= 0 || (countryCodeTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Please select your country code", vc: self)
        }
        else if phoneTxtField.text!.count <= 0 || (phoneTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Please enter your mobile number", vc: self)
        }
        else if phoneTxtField.text!.count <= 4 || (phoneTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "At least 5 numbers", vc: self)
        }
        else if passwordTxtField.text!.count <= 0 || (passwordTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Please enter your password.", vc: self)
        }
        else if (passwordTxtField.text?.count)! < 8{
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Password atleast 8 characters long.", vc: self)
        }
        else if confirmPassTxtField.text!.count <= 0 || (confirmPassTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Please enter confirm password.   ", vc: self)
        }
        else if passwordTxtField.text != confirmPassTxtField.text{
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Your password does not match with confirm password.", vc: self)
        }
        else if emailTxtField.text!.count <= 0 || (emailTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Please enter your email.", vc: self)
        }
        else if emailTxtField.text!.count <= 4 || (emailTxtField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Email at least 5 characters long.", vc: self)
        }
        else if !ProjectManager.sharedInstance.isEmailValid(email: emailTxtField.text!) {
            ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: "Please enter a valid email address", vc: self)
        }
        else{
            register()
        }
    }//Register Button
    
    
    func register(){
        User.registerUser(withName: firstNameTxtField.text! + " " + lastNametxtField.text!, email: emailTxtField.text!, password: passwordTxtField.text!, phoneNumber: "+" + countryCodeTxtField.text! +  phoneTxtField.text!, profilePic: userImage.image!, location: position, loginHandler: {(Loginhandler) in
            if Loginhandler == nil{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let Login = storyboard.instantiateViewController(withIdentifier: "Login") as! Login
                let alert = UIAlertController(title: "Verification", message: "A verification mail has been sent to your registered mail id please verify the email.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (result) in
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }else{
                ProjectManager.sharedInstance.showAlertwithTitle(title: "Error", desc: Loginhandler!, vc: self)
            }
            
        })
    }//Register
    

}
