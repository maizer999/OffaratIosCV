//
//  HomeVC.swift
//
//  Created by Dulal Hossain on 11/9/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit

class HomeVC: BaseTabVC {

    static let minimumSpacing = 20

    var catagories:[CategoryModel] = []
    var filterCategories: [CategoryModel] = []
    
    @IBOutlet weak var catagoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
           print("View HomeVC")
        super.viewDidLoad()
        super.navigationItem.rightBarButtonItem = super.searchButton
        catagoryCollectionView.delegate = self
        catagoryCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
        
    override func onTriggerSearchButton()  {
        super.searchTextField.delegate = self
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
        
    func loadData() {
        let params: [String : String] = [
            "user_id" : MyApplication.userID
            ]
        
        APIManager.apiConnection(param: params, url: "mobCategoriesAndSubs", method: .get, success: {(json) in
            let ret = json["status"].intValue
            if ret == 1 {
                self.catagories.removeAll()
                MyApplication.allCategories.removeAll()
                let jsonAry = json["data"].arrayValue;
                for item in jsonAry {
                    let supItem = CategoryModel()
                    supItem.initWithJson(data: item)
                    MyApplication.allCategories.append(supItem)
                }
                self.catagories = MyApplication.allCategories
                self.filterCategories = self.catagories
                self.catagoryCollectionView.reloadData()
            } else {
                self.showToast(message: json["message"].stringValue)
            }
        })
    }

}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.halfWidth(40)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatagoryCollectionCell", for: indexPath as IndexPath) as! CatagoryCollectionCell
        let wallpaper = filterCategories[indexPath.item]
        cell.fill(wallpaper)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wallpaper = catagories[indexPath.item]
        if wallpaper.subCategories.count > 0 {
            let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "AccordionViewController") as! AccordionViewController)
            MyApplication.supCategory = "\(wallpaper.id)"

            vc.subCategories = wallpaper.subCategories
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            MyApplication.supCategory = "\(wallpaper.id)"
            MyApplication.subCategory = ""
            let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "CategoryListVC") as! CategoryListVC)
            vc.company = ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension UIViewController {    
    func halfWidth(_ padding: Int = 0) -> Double{
        let screenWidth: Double = (Double(UIScreen.main.bounds.width))-Double(((padding*2) + (HomeVC.minimumSpacing)))
        return screenWidth / 2
    }
}

extension HomeVC: UITextFieldDelegate {
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.filterCategories.removeAll()
        if textField.text == "" {
            self.filterCategories = self.catagories
        } else {
            for category in self.catagories {
                if LocalizationSystem.shared.getLanguage() == "en" {
                    if ((category.name).lowercased()).contains(((textField.text)?.lowercased())!) {
                        self.filterCategories.append(category)
                    }
                } else if LocalizationSystem.shared.getLanguage() == "ar" {
                    if ((category.name_ar).lowercased()).contains(((textField.text)?.lowercased())!) {
                        self.filterCategories.append(category)
                    }
                }
                
            }
        }
        self.catagoryCollectionView.reloadData()
    }
}
