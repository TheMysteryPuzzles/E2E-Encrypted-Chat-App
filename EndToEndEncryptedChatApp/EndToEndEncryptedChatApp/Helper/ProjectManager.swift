//  Copyright © 2019 TheMysteryPuzzles. All rights reserved.



import UIKit

class ProjectManager: NSObject{
    
    static let sharedInstance = ProjectManager()
    
    private override init() {
        
    }

    //MARK:- EMAIL VALIDATION
    func isEmailValid(email : String) -> Bool{
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailReg)
        return emailTest.evaluate(with: email)
    }
    
    //MARK:- PASSWORD VALIDATION
    func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    
    //MARK:- Add icon in textfield at left hand side
    func customTxtFieldImageRightSide(image: UIImage,textField: UITextField){
        let customView = UIView(frame: CGRect(x: 320, y: 0, width: 55, height: 45))
        let paddigForFirst = UIView(frame: CGRect(x: 20, y: 0, width: 45, height: 45))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        paddigForFirst.addSubview(imageView)
        customView.addSubview(paddigForFirst)
        textField.rightView = customView
        textField.rightViewMode = .always
    }
    
    
    
    //MARK:- Add icon in textfield at left hand side
    func customTxtFieldImage(image: UIImage,textField: UITextField){
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 45))
        let paddigForFirst = UIView(frame: CGRect(x: 20, y: 0, width: 45, height: 45))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        paddigForFirst.addSubview(imageView)
        customView.addSubview(paddigForFirst)
        textField.leftView = customView
        textField.leftViewMode = .always
    }
    
    func showAlertwithTitle(title:String , desc:String , vc:UIViewController)  {
        let alert = UIAlertController(title: title, message: desc, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
    
}

class RoundedImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

extension UIApplication {
    class func topViewController(_ base: UIViewController? = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}




