//
//  LoginVC.swift
//  Offarat
//
//  Created by Dulal Hossain on 2/11/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
//import GoogleSignIn

class LoginVC: UIViewController {
    
    @IBOutlet weak var skipButton:BorderButton!
    @IBOutlet weak var loginButton:BorderButton!
    @IBOutlet weak var signupButton:BorderButton!
    @IBOutlet weak var facebookLoginButton:UIButton!
    @IBOutlet weak var googleLoginButton:BorderButton!
    @IBOutlet weak var languageButton:BorderButton!
    
    @IBOutlet weak var userNameTextField:BorderTextField!
    @IBOutlet weak var passwordTextField:BorderTextField!
    
    @IBOutlet weak var facebookLabel: UILabel!
    @IBOutlet weak var googleLabel: UILabel!
    
    let loginManager:LoginManager = LoginManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let  isLoggedIn = UserDefaults.standard.bool(forKey : "isLoggedIn")
        
        if isLoggedIn {
            let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "HomeTabbarController") as! HomeTabbarController)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
        

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillLocalizaitonInfo()
    }
    
    func fillLocalizaitonInfo() {
        
        userNameTextField.placeholder = username.localizedValue()
        passwordTextField.placeholder = password.localizedValue()
        skipButton.setTitle(skip.localizedValue(), for: .normal)
        loginButton.setTitle(login.localizedValue(), for: .normal)
        languageButton.setTitle(language_arabic.localizedValue(), for: .normal)
        signupButton.setTitle(signup.localizedValue(), for: .normal)
        facebookLabel.text = login_facebook.localizedValue()
        googleLabel.text = login_google.localizedValue()
    }
    
    @IBAction func loginAction(_ sender: UIButton){
        let params: [String : String] = [
            "email" : userNameTextField.text!,
            "password" : passwordTextField.text!
        ]
        
        APIManager.apiConnection(param: params, url: "moblogin", method: .post, success: {(json) in
            let ret = json["status"].intValue
            if ret == 1 {
                let response = json["data"];
                MyApplication.userID = response["Id"].stringValue
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "HomeTabbarController") as! HomeTabbarController)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            } else {
                self.showToast(message: json["message"].stringValue)
            }
        })
    }
    
    @IBAction func skipAction(_ sender: UIButton){
        MyApplication.userID = "0"
        let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "HomeTabbarController") as! HomeTabbarController)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func googleLoginAction(_ sender: UIButton){
        //        GIDSignIn.sharedInstance().delegate=self
        ////        GIDSignIn.sharedInstance().uiDelegate=self
        //        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func facebookLoginAction(_ sender: UIButton){
        loginManager.logIn(permissions: ["email"], from: self) { (result, error) in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")){
                        self.getFBUserData()
                    }
                    
                }
            }
        }
    }
    
    @IBAction func languageChangeAction(_ sender: UIButton){
        let lang = LocalizationSystem.shared.getLanguage()
        fillLocalizaitonInfo()
        LocalizationSystem.shared.setLanguage(languageCode: lang == "en" ? "ar":"en")
        let newlang = LocalizationSystem.shared.getLanguage()
        UIView.appearance().semanticContentAttribute = lang == "en" ?   .forceRightToLeft : .forceLeftToRight
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let appDlg = UIApplication.shared.delegate as? AppDelegate
        appDlg?.window?.rootViewController = vc
        //        Presenter.shared.setLoginAsRoot()
    }
    
    func getFBUserData(){
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    print(result as Any)
                    guard let accessToken = AccessToken.current else {
                        print("Failed to get access token")
                        return
                    }
                    let result = result as! [String: Any]
                    let params = [
                        "name": result["name"] as! String,
                        "email": result["email"] as! String,
                        "fbid": result["id"] as! String,
                        "access_token": accessToken.tokenString,
                        "device_token": UUID().uuidString,
                        "device_type": "iphone"
                    ]
                    
                    APIManager.apiConnection(param: params, url: "mobfblogin", method: .post, success: {(json) in
                        let ret = json["status"].intValue
                        if ret == 1 {
                            let response = json["data"];
                            MyApplication.userID = response["Id"].stringValue
                            
                            //                        Presenter.shared.setTabbarAsRoot()
                        } else {
                            self.showToast(message: json["message"].stringValue)
                        }
                    })
                    
                }
                else {
                    print(error?.localizedDescription as Any)
                    
                }
            })
        }
    }
}

//extension LoginVC: GIDSignInDelegate {
//    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if (error == nil) {
//          // Perform any operations on signed in user here.
//          let userId = user.userID                  // For client-side use only!
//          let idToken = user.authentication.idToken // Safe to send to the server
//          let fullName = user.profile.name
//          let givenName = user.profile.givenName
//          let familyName = user.profile.familyName
//          let email = user.profile.email
//          
////          let params = [
////              "name": fullName,
////              "email": email,
////              "fbid": result["id"] as! String,
////              "access_token": accessToken.tokenString,
////              "device_token": UUID().uuidString,
////              "device_type": "iphone"
////          ]
//        } else {
//          print("\(error.localizedDescription)")
//        }
//    }
//}
