//
//  MenuVC.swift
//  iCheckVehicles
//
//  Created by Dulal Hossain on 8/8/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

protocol MenuVCDelegate {
    func onClickSubCategory(_ index : Int)
}

class MenuVC: UIViewController {
    
    /**
    *  Transparent button to hide menu
    */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
        
    /**
    *  Menu button which was tapped to display the menu
    */
    var btnMenu : UIButton!
    
    /**
    *  Delegate of the MenuVC
    */
    var slideDelegate : SlideMenuDelegate?
    var itemDelegate : MenuVCDelegate?

    @IBOutlet weak var allCategoryTitleLabel: UILabel!
    @IBOutlet weak var menuTableView: UITableView!
    
    var catagories:[CategoryModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.reloadData()
        menuTableView.register(UINib.init(nibName: "MenuFooterCell", bundle: Bundle.main), forCellReuseIdentifier: "MenuFooterCell")
        allCategoryTitleLabel.text = AllCategory.localizedValue()
        
        menuTableView.tableFooterView = UIView()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.catagories = MyApplication.allCategories
        self.menuTableView.reloadData()
    }
    
    @IBAction func allCategoryAction(_ sender: UIButton) {
    }
    
    @IBAction func onCloseMenuClick(_ button: UIButton!){
        btnMenu.tag = 0
        
        if (self.slideDelegate != nil && button != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }
            slideDelegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParent()
        })
    }
    
}

extension MenuVC: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return catagories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = catagories[section]
        let isExpnd = sec.isExpand
        if !(isExpnd) {
            return 0
        }
        return  isExpnd ? sec.subCategories.count : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subCat = catagories[indexPath.section].subCategories[indexPath.row]
        let cell: MenuTableCell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell", for: indexPath) as! MenuTableCell
        
        cell.filled(subCat)
        return cell
    }
    
}

extension MenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onCloseMenuClick(nil)
        
        let subCat = catagories[indexPath.section].subCategories[indexPath.row]
        MyApplication.supCategory = "\(catagories[indexPath.section].id)"
        MyApplication.subCategory = "\(subCat.id)"
//        self.itemDelegate?.onClickSubCategory(subCat.id)
        
        let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "CategoryListVC") as! CategoryListVC)
                vc.company = ""
//        MyApplication.subCategory.products[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: MenuHeaderView = MenuHeaderView.fromNib()
        headerView.headerTap = { [weak self] in
            let supCategory = self?.catagories[section]
            if (supCategory?.subCategories.count)! > 0 {
                if let expnd = supCategory?.isExpand, expnd == true{
                    supCategory?.isExpand = false
                    tableView.reloadSections([section], with: .automatic)
                    return
                } else {
                    for cate in self!.catagories {
                        cate.isExpand = false
                    }
                    supCategory?.isExpand = true
                    tableView.reloadData()
                }
            } else {
                self!.onCloseMenuClick(nil)
                
                MyApplication.supCategory = "\(supCategory!.id)"
                MyApplication.subCategory = ""
                
                self!.itemDelegate?.onClickSubCategory(supCategory!.id)
            }
        }
        headerView.fill(catagories[section])
        return headerView
    }
    
}



