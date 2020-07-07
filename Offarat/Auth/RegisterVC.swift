//
//  RegisterVC.swift
//  Offarat
//
//  Created by JinYZ on 12/9/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {

    @IBOutlet weak var usernameUL: BorderTextField!
    @IBOutlet weak var passwordUL: BorderTextField!
    @IBOutlet weak var emailUL: BorderTextField!
    @IBOutlet weak var phoneUL: BorderTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func onClickBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickRegisterUB(_ sender: Any) {
        let nameST = usernameUL.text
        if nameST == "" {
            self.showToast(message: "Please enter some words.")
            return
        }
        let passST = passwordUL.text
        if passST == "" {
            self.showToast(message: "Please enter some words.")
            return
        }
        let emailST = emailUL.text
        if emailST == "" || !(emailST?.contains("@"))! || !(emailST?.contains("."))! {
            self.showToast(message: "The email is wrong.")
            return
        }
        let phoneST = phoneUL.text
        if phoneST?.count != 10 {
            self.showToast(message: "The phone number is wrong.")
            return
        }
        
        let params: [String : String] = [
            "name" : nameST!,
            "email" : emailST!,
            "password" : passST!,
            "profile_image" : "",
            "login_type" : "1",
            "player_id" : "",
            "mobile" : phoneST!
            ]
        
        APIManager.apiConnection(param: params, url: "mob-reg", method: .post, success: {(json) in
            let ret = json["status"].intValue
            if ret == 1 {
//                self.showToast(message: "Register Success!")
                self.showToast(message: json["message"].stringValue)
            } else {
                self.showToast(message: "Register is failed!")
            }
        })
    }
    
}
