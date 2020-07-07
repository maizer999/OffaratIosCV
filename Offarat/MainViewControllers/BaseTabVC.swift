//
//  BaseTabVC.swift
//  Offarat
//
//  Created by Aira on 2/20/20.
//  Copyright © 2020 DL. All rights reserved.
//

import UIKit
import Alamofire

import DropDown
class BaseTabVC: UIViewController {
    
    var titleView: UIView!
    var searchTextField:BorderTextField!
    
    let searchImage    = UIImage(named: "search_icon")!
    let menuImage  = UIImage(named: "filter icon")!
    
    let sortImage = UIImage(named: "ic_sort")!
    
    var menuButton: UIBarButtonItem!
    var searchButton: UIBarButtonItem!
    var sortButton: UIBarButtonItem!
    
    @objc func didTapMenuButton()  {
        onTriggerMenuButton()
    }
    
    func onTriggerMenuButton(){
        //        openClose()
    }
    
    @objc func didTapSearchButton()  {
        isSearchOn = !isSearchOn
        onTriggerSearchButton()
    }
    
    func onTriggerSearchButton() {
        //
    }
    
    func onClickItem(_ index: Int) {
        //
    }
    
    var isSearchOn: Bool = false {
        didSet{
            searchButton.image = isSearchOn ?  #imageLiteral(resourceName: "text_clear") : #imageLiteral(resourceName: "search_icon")
            
            titleView?.isHidden = !isSearchOn
            searchTextField.text = nil
        }
    }
    
    @objc func didTapSortButton() {
        
        let dropDown = DropDown()
        
        dropDown.anchorView = view // UIView or UIBarButtonItem
        
        dropDown.dataSource = ["" , "Cheapest".localizedValue(), "Expensive".localizedValue(), "Nearest".localizedValue(),"Newest".localizedValue()]
        DropDown.appearance().cellHeight = 60
        dropDown.show()
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            
            switch index {
            case 1:
                self.onTriggerByCheapest()
            case 2:
                self.onTriggerByExpensive()
            case 3:
                self.onTriggerByNearest()
            case 4:
                self.onTriggerByNewest()
                
            default:
                print("")
            }
            
        }
        
    }
    
    func onTriggerByCheapest() {
        ////
    }
    
    func onTriggerByExpensive() {
        ///
    }
    
    func onTriggerByNearest() {
        ///
    }
    
    func onTriggerByNewest() {
        ///
    }
    
    var isMenuOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapSearchButton))
        sortButton = UIBarButtonItem(image: sortImage, style: .plain, target: self, action: #selector(didTapSortButton))
        if #available(iOS 11.0, *) {
            sortButton.tintColor = UIColor(named: "mainBlue")
        } else {
            // Fallback on earlier versions
        }
        //        self.navigationItem.rightBarButtonItems = [searchButton, sortButton]
        
        //        menuButton = UIBarButtonItem(image: menuImage,  style: .plain, target: self, action: #selector(didTapMenuButton))
        //        self.navigationItem.leftBarButtonItem = menuButton
        addSlideMenuButton()
        
        let width = UIScreen.main.bounds.width - 165
        titleView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: 40))
        titleView.backgroundColor = .clear
        searchTextField = BorderTextField(frame: CGRect.init(x: 4, y: 2, width: width-8, height: 36))
        titleView.addSubview(searchTextField)
        navigationItem.titleView = titleView
        searchTextField.placeholder = Search.localizedValue()
        titleView.clipsToBounds = true
        
        isMenuOn = false
        isSearchOn = false
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButton.ButtonType.system)
        btnShowMenu.setImage(UIImage(named: "menu_icon"), for: .normal)
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(onSlideMenuButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    @objc func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuVC = self.storyboard!.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        menuVC.btnMenu = sender
        menuVC.slideDelegate = self
        menuVC.itemDelegate = self
        self.view.addSubview(menuVC.view)
        self.addChild(menuVC)
        menuVC.view.layoutIfNeeded()
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
        }, completion:nil)
    }
    
}

extension BaseTabVC: SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        switch(index){
        case 0:
            print("Home\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("Home")
            
            break
        case 1:
            print("Play\n", terminator: "")
            
            self.openViewControllerBasedOnIdentifier("PlayVC")
            
            break
        default:
            print("default\n", terminator: "")
        }
    }
}

extension BaseTabVC: MenuVCDelegate {
    func onClickSubCategory(_ index: Int) {
        onClickItem(index)
    }
}

//extension BaseTabVC: JMDropMenuDelegate {
//
//    func didSelectRow(at index: Int, title: String!, image: String!) {
//        print(index)
//        switch index {
//        case 0:
//            self.onTriggerByName()
//            break
//        case 1:
//            self.onTriggerByPrice()
//            break
//        case 2:
//            self.onTriggerByLocation()
//            break
//        default:
//            print("selected none")
//            break
//        }
////        self.listUTV.reloadData()
//    }
//
//}
