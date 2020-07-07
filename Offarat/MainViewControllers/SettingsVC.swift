//
//  SettingsVC.swift
//  Offarat
//
//  Created by Dulal Hossain on 2/11/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit

enum SelectedLanguage{
    case english
    case arabic
}

class SettingsVC: BaseTabVC {
    
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var englishCheckBox: UIImageView!
    @IBOutlet weak var arabicCheckBox: UIImageView!

    @IBOutlet weak var offerSwitch: UISwitch!
    @IBOutlet weak var storeSwitch: UISwitch!
    @IBOutlet weak var notificationContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var notificationTitleLabel: UILabel!
    
    @IBOutlet weak var languageTitleLabel: UILabel!
    
    @IBOutlet weak var englishTitleLabel: UILabel!
    
    @IBOutlet weak var arabicTitleLabel: UILabel!

    @IBOutlet weak var logoutTitleLabel: UILabel!
    
    @IBOutlet weak var notificationmeContainerView: UIView!
    @IBOutlet weak var notificationOfferLabel: UILabel!
    @IBOutlet weak var notificaitonStoreLabel: UILabel!
    
    var selectedLanguage:SelectedLanguage = .english{
        didSet{
            let si = UIImage.init(named: "ticket_icon")!
            englishCheckBox.image = selectedLanguage == .english ? si:nil
            arabicCheckBox.image = selectedLanguage == .arabic ? si:nil
        }
    }
    var notificationEnabled:Bool = false{
        didSet{
            notificationContainerHeight.constant = notificationEnabled ? 126:0
        }
    }
    
    var offerSwitchValue = false
    var storeSwitchValue = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View SettingsVC")
//        notificationEnabled = false
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationController?.navigationBar.isHidden = true
        let lang = LocalizationSystem.shared.getLanguage()
        selectedLanguage = lang == "en" ? .english:.arabic
        setLocalizedText()
        
        initData()
        initUISettingView()
    }
    
    func initUISettingView() {
        notificationSwitch.isOn = notificationEnabled
        offerSwitch.isOn = offerSwitchValue
        storeSwitch.isOn = storeSwitchValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }
    
    override func onTriggerSearchButton()  {
        //
    }
    
    override func onClickItem(_ index: Int) {
        super.onClickItem(index)
        print("\(index)")
        MyApplication.supCategory = ""
        MyApplication.subCategory = "\(index)"
        let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "CategoryListVC") as! CategoryListVC)
        vc.company = ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func initData() {
        APIManager.apiConnection(param: ["" : ""], url: "mobgetUserInfo/" + MyApplication.userID, method: .post, success: {(json) in
            let data = json["data"].arrayValue
            let settingdata = data[0]
            let strNotify = settingdata["isNotify"].stringValue
            let strAddOffer = settingdata["notify_newOffer"].stringValue
            let strEndOffer = settingdata["notify_EndOffer"].stringValue
            let strLanguage = settingdata["language"]
            
            self.notificationEnabled = strNotify != "0" ? true : false
            self.storeSwitchValue = strAddOffer != "0" ? true : false
            self.offerSwitchValue = strEndOffer != "0" ? true : false
            
            self.initUISettingView()
        })
    }
    
    func setLocalizedText() {
        notificationTitleLabel.text = notificaions.localizedValue()
        languageTitleLabel.text = Language.localizedValue()
            englishTitleLabel.text = English.localizedValue()
        arabicTitleLabel.text = Arabic.localizedValue()
        logoutTitleLabel.text = LogOut.localizedValue()
        notificationOfferLabel.text = notificaions_offer.localizedValue()
        notificaitonStoreLabel.text = notificaions_store.localizedValue()
    }
    
    @IBAction func notificationAction(_ sender: UISwitch){
        notificationEnabled = !notificationEnabled
        onChangeUISetting()
    }
    
    @IBAction func notificationOfferAction(_ sender: UISwitch) {
        offerSwitchValue = !offerSwitchValue
        
        onChangeUISetting()
    }
    @IBAction func notificationStoreAction(_ sender: UISwitch) {
        storeSwitchValue = !storeSwitchValue
        onChangeUISetting()
    }
    
    func onChangeUISetting() {
        var str_notify: String = "0"
        if(notificationEnabled) {
            str_notify = "1"
        }
        var str_newOffer: String = "0"
        if storeSwitchValue {
            str_newOffer = "1"
        }
        var str_endOffer = "0"
        if offerSwitchValue {
            str_endOffer = "1"
        }
        var str_language = "0"
        if LocalizationSystem.shared.getLanguage() == "ar" {
            str_language = "1"
        }
        
        let param: [String: String] = [
            "user_id": MyApplication.userID,
            "isNotify": str_notify,
            "notify_EndOffer": str_endOffer,
            "notify_newOffer": str_newOffer,
            "language": str_language
        ]
        
        APIManager.apiConnection(param: param, url: "mobchangeUserSetting", method: .post, success: {(json) in
            let data = json["data"]
            let strNotify = data["isNotify"].stringValue
            let strAddOffer = data["notify_newOffer"].stringValue
            let strEndOffer = data["notify_EndOffer"].stringValue
            let strLanguage = data["language"]
            
            self.notificationEnabled = strNotify != "0" ? true : false
            self.storeSwitchValue = strAddOffer != "0" ? true : false
            self.offerSwitchValue = strEndOffer != "0" ? true : false
            
            self.initUISettingView()
        })
    }
    
    @IBAction func setEnglishLanguage(_ sender: UIButton){
        selectedLanguage = .english
        let lang = LocalizationSystem.shared.getLanguage()
        if lang != "en" {
            LocalizationSystem.shared.setLanguage(languageCode: "en")
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
//            Presenter.shared.setTabbarAsRoot(4)
        }
//        viewDidLoad()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabbarController") as! HomeTabbarController
        vc.selectedIndex = 4
        let appDlg = UIApplication.shared.delegate as? AppDelegate
        appDlg?.window?.rootViewController = vc
//        tabBarController?.view.semanticContentAttribute = .forceLeftToRight
//        tabBarController?.tabBar.semanticContentAttribute = .forceLeftToRight
//        for viewController in tabBarController!.viewControllers! {
//            viewController.view.semanticContentAttribute = .forceLeftToRight
//        }
    }
    
    @IBAction func setArabicLanguage(_ sender: UIButton){
        selectedLanguage = .arabic
        let lang = LocalizationSystem.shared.getLanguage()

        if lang != "ar" {
            LocalizationSystem.shared.setLanguage(languageCode: "ar")
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
//            Presenter.shared.setTabbarAsRoot(4)
        }
//        setLocalizedText()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabbarController") as! HomeTabbarController
        vc.selectedIndex = 4
        let appDlg = UIApplication.shared.delegate as? AppDelegate
        appDlg?.window?.rootViewController = vc
        
//        tabBarController?.view.semanticContentAttribute = .forceRightToLeft
//        tabBarController?.tabBar.semanticContentAttribute = .forceRightToLeft
//        for viewController in tabBarController!.viewControllers! {
//            viewController.view.semanticContentAttribute = .forceRightToLeft
//        }
    }
    
    @IBAction func logout(_ sender: UISwitch){
//        Presenter.shared.logOut()
        MyApplication.userID = ""
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
}
