//
//  CategoryListVC.swift
//  Offarat
//
//  Created by JinYZ on 12/9/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit

class CategoryListVC: BaseTabVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var products:         [ProductModel] = []
    var filterItems      :[ProductModel] = []

    var company = ""
//    var product = ProductModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("view CategoryListVC")
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.layer.zPosition = 10
       navigationItem.setRightBarButtonItems([ super.sortButton , super.searchButton] as? [UIBarButtonItem], animated: false)

        
        if company == "" {
            loadProductsWithCategory()
//            navigationItem.title = "By Category"
        } else {
//            navigationItem.title = "By Company"
            loadProductsWithCompany()
        }
        
        tableView.register(UINib.init(nibName: ProductCell.sbIdentifier, bundle: Bundle.main), forCellReuseIdentifier: ProductCell.sbIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func onTriggerSearchButton()  {
              super.searchTextField.delegate = self
         }
    
    func loadProductsWithCategory() {
//        let params: [String : String] = [
//            "user_id" : MyApplication.userID,
//            "cat_id" : MyApplication.supCategory,
//            "sub_cat_id" : MyApplication.subCategory
//            ]
        let params: [String: String] = [
//            "user_id": MyApplication.userID,
            "category_id": MyApplication.supCategory
        ]
        APIManager.apiConnection(param: params, url: "mobgetOfferCategory", method: .post, success: {(json) in
            let ret = json["status"].intValue
            self.products.removeAll()
            if ret == 1 {
                let jsonAry = json["data"].arrayValue;
                for item in jsonAry {
                    let product = ProductModel()
                    product.initWithJson(data: item)
                    self.products.append(product)
                    self.filterItems.append(product)
                }
            } else {
                self.showToast(message: json["message"].stringValue)
            }
            self.tableView.reloadData()
        })
    }
    
    func loadProductsWithCompany() {
        let params: [String : String] = [
            "company_name" : company
            ]
        
        APIManager.apiConnection(param: params, url: "User/get_hot_offers_with_comapny_name", method: .post, success: {(json) in
            let ret = json["status"].intValue
            self.products.removeAll()
            if ret == 1 {
                let jsonAry = json["data"].arrayValue;
                for item in jsonAry {
                    let product = ProductModel()
                    product.initWithJson(data: item)
                    self.products.append(product)
                    self.filterItems.append(product)
                }
            } else {
                self.showToast(message: json["message"].stringValue)
            }
            self.tableView.reloadData()
        })
    }
    
    func set_favorite_offer(statu: String, category_id: String, offer_id: String){
        let params: [String : String] = [
        "user_id" : MyApplication.userID,
        "offer_id" : category_id,
        "is_favorite" : statu
        ]
        
        APIManager.apiConnection(param: params, url: "User/select_favorite_offer", method: .post, success: {(json) in
            let ret = json["status"].intValue
            if ret == 1 {
                self.showToast(message: json["message"].stringValue)
                self.onEventResetList(offer_id: offer_id)
            } else {
                self.showToast(message: "Server Error")
            }
        })
    }
    
    func onEventResetList(offer_id: String) {
        for product in products {
            if product.id == offer_id {
                product.favorite = product.favorite == "0" ? "1" : "0"
            }
        }
        tableView.reloadData()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CategoryListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 318.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell: ProductCell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.fill(products[indexPath.row])
        cell.shareAction = { product in
            self.showShareController()
        }
        cell.locationAction = { prodcut in
            MyApplication.openMap(latitude: prodcut.latitude, longitude: prodcut.longitude)
        }
        cell.callAction = { product in
            MyApplication.callAction(phoneNumber: product.phoneNumber)
        }
        cell.favoriteAction = { product in
            let status = product.favorite == "0" ? "1" : "0"
            self.set_favorite_offer(statu: status, category_id: product.category_id, offer_id: product.id)
        }
        cell.companyAction = { product in
            let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "CategoryListVC") as! CategoryListVC)
            vc.company = product.store_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        cell.delegate = self
        return cell
    }
    
}

extension CategoryListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc:ProductDetailsVC = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC)
        vc.product = products[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension CategoryListVC: StoreDelegate {
    func onClickStoreNameDelegate(product: ProductModel) {
        let vc:StoreVC = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "StoreVC") as! StoreVC)
        vc.storeID = product.store_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



extension CategoryListVC: UITextFieldDelegate {
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.products.removeAll()
        if textField.text == "" {
            self.products = self.filterItems
        } else {
            for category in self.filterItems {
                if LocalizationSystem.shared.getLanguage() == "en" {
                    if ((category.name).lowercased()).contains(((textField.text)?.lowercased())!) {
                        self.products.append(category)
                    }
                } else if LocalizationSystem.shared.getLanguage() == "ar" {
                    if ((category.name_ar).lowercased()).contains(((textField.text)?.lowercased())!) {
                        self.products.append(category)
                    }
                }
                
            }
        }
        self.tableView.reloadData()
    }
}
