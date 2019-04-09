//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseDatabase
import CoreLocation

typealias Loginhandler = (_ msg:String?) -> Void //closure

class User: NSObject {
    
    //MARK: Properties
    let name: String
    let email: String
    let id: String
    var profilePic: UIImage?
  
    
    //MARK: Inits
    init(name: String, email: String, id: String, profilePic: UIImage?) {
        self.name = name
        self.email = email
        self.id = id
        self.profilePic = profilePic
    }
  
    struct loginErrorCode {
        static let INVALID_EMAIL = "Invalid Email"
        static let UNVERIFIED_PHONENUMBER = "Mobile number is not Verified"
        static let WRONG_PASSWORD = "Wrong Password"
        static let PROBLEM_CONNECTING = "Problem Connecting to Databases "
        static let USER_NOT_FOUND = "User Not Found"
        static let EMAIL_ALREADY_USED = "Email Already used Try Another One"
        static let WEAK_PASSWORD = "Password should be alteast 6 characters long"
        static let SOMETHING_WENT_WRONG = "Something went wrong try Again"
        static let INVALID_CUSTOM_TOKEN = "Validation error with the custom token."
        static let CUSTOM_TOKEN_MISMATCH = "Service account and the API key belong to different projects."
        static let INVALID_CREDENTIAL = "Supplied credential is invalid. This could happen if it has expired or it is malformed."
        static let USER_DISABLE = "User's account is disabled."
        static let OPERATION_NOT_ALLOWED = "Email and password accounts are not enabled. Enable them in the Auth section of the Firebase console."
        static let TOO_MANY_REQUESTS = "Request has been blocked after an abnormal number of requests have been made from the caller device to the Firebase Authentication servers. Retry again after some time."
        static let ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL = "This account is already present with different credential"
        static let REQUIRES_RECENT_LOGIN = "Updating a user’s email is a security sensitive operation that requires a recent login from the user. This error indicates the user has not signed in recently enough. To resolve, reauthenticate the user by invoking reauthenticateWithCredential:completion: on FIRUser."
        static let PROVIDER_ALREADY_LINKED  = "Attempt to link a provider of a type already linked to this account."
        static let NO_SUCH_PROVIDER = "Attempt to unlink a provider that is not linked to the account."
        static let INVALID_USER_TOKEN = "The signed-in user's refresh token, that holds session information, is invalid. You must prompt the user to sign in again on this device."
        static let NETWORK_ERROR = "Network error occurred during the operation"
        static let USER_TOKEN_EXPIRED = "The current user’s token has expired, for example, the user may have changed account password on another device. You must prompt the user to sign in again on this device."
        static let INVALID_API_KEY = "Application has been configured with an invalid API key."
        static let USER_MISMATCH = "An attempt was made to reauthenticate with a user which is not the current user."
        static let CREDENTIAL_ALREADY_IN_USE = "An attempt to link with a credential that has already been linked with a different Firebase account."
        static let APP_NOT_AUTHORIZED = "App is not authorized to use Firebase Authentication with the provided API Key. go to the Google API Console and check under the credentials tab that the API key you are using has your application’s bundle ID whitelisted."
        static let EXPIRED_ACTION_CODE = "Action code is Expired"
        static let INVALID_ACTION_CODE = "Action code is Invalid"
        static let INVALID_MESSAGE_PAYLOAD = "Message payload is not valid"
        static let INVALID_SENDER = "Sender is not valid"
        static let INVALID_RECIPIENT_EMAIL = "r]Recipient mail is not valid"
        static let KEYCHAIN_ERROR = "Error in keychain"
        static let INTERNAL_ERROR = "Some internal Error"
        
    }//errorCodes
    
    class func handleErrors(err: NSError ,loginHandler:Loginhandler){
        
        if let errCode = AuthErrorCode(rawValue: err.code){
            
            switch errCode{
            case .userNotFound:
                loginHandler(loginErrorCode.USER_NOT_FOUND)
                break
            case .invalidEmail:
                loginHandler(loginErrorCode.INVALID_EMAIL)
                break
            case .invalidCustomToken:
                loginHandler(loginErrorCode.INVALID_CUSTOM_TOKEN)
                break
            case .customTokenMismatch:
                loginHandler(loginErrorCode.CUSTOM_TOKEN_MISMATCH)
                break
            case .invalidCredential:
                loginHandler(loginErrorCode.INVALID_CREDENTIAL)
                break
            case .userDisabled:
                loginHandler(loginErrorCode.USER_DISABLE)
                break
            case .operationNotAllowed:
                loginHandler(loginErrorCode.OPERATION_NOT_ALLOWED)
                break
            case .emailAlreadyInUse:
                loginHandler(loginErrorCode.EMAIL_ALREADY_USED)
                break
            case .wrongPassword:
                loginHandler(loginErrorCode.WRONG_PASSWORD)
                break
            case .tooManyRequests:
                loginHandler(loginErrorCode.TOO_MANY_REQUESTS)
                break
            case .accountExistsWithDifferentCredential:
                loginHandler(loginErrorCode.ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL)
                break
            case .requiresRecentLogin:
                loginHandler(loginErrorCode.REQUIRES_RECENT_LOGIN)
                break
            case .providerAlreadyLinked:
                loginHandler(loginErrorCode.PROVIDER_ALREADY_LINKED)
                break
            case .noSuchProvider:
                loginHandler(loginErrorCode.NO_SUCH_PROVIDER)
                break
            case .invalidUserToken:
                loginHandler(loginErrorCode.INVALID_USER_TOKEN)
                break
            case .networkError:
                loginHandler(loginErrorCode.NETWORK_ERROR)
                break
            case .userTokenExpired:
                loginHandler(loginErrorCode.USER_TOKEN_EXPIRED)
                break
            case .invalidAPIKey:
                loginHandler(loginErrorCode.INVALID_API_KEY)
                break
            case .userMismatch:
                loginHandler(loginErrorCode.USER_MISMATCH)
                break
            case .credentialAlreadyInUse:
                loginHandler(loginErrorCode.CREDENTIAL_ALREADY_IN_USE)
                break
            case .weakPassword:
                loginHandler(loginErrorCode.WEAK_PASSWORD)
                break
            case .appNotAuthorized:
                loginHandler(loginErrorCode.APP_NOT_AUTHORIZED)
                break
            case .expiredActionCode:
                loginHandler(loginErrorCode.EXPIRED_ACTION_CODE)
                break
            case .invalidActionCode:
                loginHandler(loginErrorCode.INVALID_ACTION_CODE)
                break
            case .invalidMessagePayload:
                loginHandler(loginErrorCode.INVALID_MESSAGE_PAYLOAD)
                break
            case .invalidSender:
                loginHandler(loginErrorCode.INVALID_SENDER)
                break
            case .invalidRecipientEmail:
                loginHandler(loginErrorCode.INVALID_RECIPIENT_EMAIL)
                break
            case .keychainError:
                loginHandler(loginErrorCode.KEYCHAIN_ERROR)
                break
            case .internalError:
                loginHandler(loginErrorCode.INTERNAL_ERROR)
                break
            default:
                loginHandler(loginErrorCode.SOMETHING_WENT_WRONG)
                break
            }
            
        }
    }//HandleError func
    
    
    class func registerUser(withName:String,email:String,password:String,phoneNumber: String ,profilePic:UIImage,location: Dictionary<String, Any>,loginHandler: Loginhandler?){
        let sv = UIViewController.displaySpinner(onView: (UIApplication.topViewController()?.view)!)
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error == nil{
                let values: [String: Any] = ["name": withName, "email": email,"phoneNumber": phoneNumber, "location":location]
                Database.database().reference(fromURL: "https://chatmodule-2a4da.firebaseio.com/").child("users").child((user?.user.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (error, _) in
                    if error == nil {
                        UIViewController.removeSpinner(spinner: sv)
                        let userInfo = ["email" : email, "password" : password]
                        UserDefaults.standard.set(user?.user.uid, forKey: "currentUser")
                        UserDefaults.standard.set(userInfo, forKey: "userInformation")
                        
                        loginHandler!(nil)
                        
                        
                    }
                    else{
                        UIViewController.removeSpinner(spinner: sv)
                        
                        self.handleErrors(err: error! as NSError, loginHandler: loginHandler!)
                    }
                })
            }
            else{
                UIViewController.removeSpinner(spinner: sv)
                
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler!)
                
            }
            
        }
    }//Register User
    
    class func loginUser(email: String, password: String, loginHandler: Loginhandler?) {
        let sv = UIViewController.displaySpinner(onView: (UIApplication.topViewController()?.view)!)
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            UserDefaults.standard.set(user?.user.uid, forKey: "currentUser")
            if error == nil {
                guard let status = Auth.auth().currentUser?.isEmailVerified else{
                    return
                }
                if status == false {
                    UIViewController.removeSpinner(spinner: sv)
                    loginHandler!(nil)
                }else{
                    UIViewController.removeSpinner(spinner: sv)
                    loginHandler!("Email is not verified")
                }
                
                
            } else {
                UIViewController.removeSpinner(spinner: sv)
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler!)
            }
        }
    }//Login User
    
    
    class func downloadAllUsers(completion: @escaping (User) -> Swift.Void) {
        let currentUserId = UserDefaults.standard.string(forKey: "currentUser")
        Database.database().reference(fromURL: realTimeDataBaseReference).child("users").observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            if currentUserId != id {
            let data = snapshot.value as! [String: Any]
            print("\(data)")
            if let credentials = data["credentials"] as? [String: Any] {
                let name = credentials["name"]!
                let email = credentials["email"]!
                if credentials["profilePicLink"] != nil{
                    let link = URL.init(string: credentials["profilePicLink"]! as! String)
                    URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                        if error == nil {
                            let profilePic = UIImage.init(data: data!)
                            let user = User.init(name: name as! String, email: email as! String, id: id, profilePic: profilePic!)
                            completion(user)
                        }
                    }).resume()

                }else{
                    let user = User.init(name: name as! String, email: email as! String, id: id, profilePic: nil)
                    completion(user)
                }
            }
        }
        })
    
    }//Download all users
    
    class func info(forUserID: String, completion: @escaping (User) -> Swift.Void) {
         Database.database().reference(fromURL: realTimeDataBaseReference).child("users").child(forUserID).child("credentials").observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: Any] {
                let name = data["name"] as? String
                let email = data["email"] as? String
                if data["profilePicLink"] != nil {
                let pic = data["profilePicLink"] as? String
                let link = URL.init(string: pic!)
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profilePic = UIImage.init(data: data!)
                        let user = User.init(name: name!, email: email!, id: forUserID, profilePic: profilePic!)
                        completion(user)
                    }
                }).resume()
                }else{
                    let user = User.init(name: name!, email: email!, id: forUserID, profilePic: nil)
                    completion(user)
                }
            }
        })
    }//Info
    
    class func checkUserVerification(completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().currentUser?.reload(completion: { (_) in
            let status = (Auth.auth().currentUser?.isEmailVerified)!
            completion(status)
        })
    }//Check user verification
    
}





