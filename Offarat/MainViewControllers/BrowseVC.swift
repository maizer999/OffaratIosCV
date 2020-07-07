//
//  BrowseVC.swift
//
//
//  Created by Dulal Hossain on 11/9/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit

class BrowseVC: BaseTabVC {
    
    @IBOutlet weak var tableview: UITableView!
    
    var products         :[ProductModel] = []
    var filterItems      :[ProductModel] = []
    var sortBy            = "1"
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if MyApplication.sortStr == "" {
            loadProducts()
        } else {
            loadProductsWithSort()
        }
    }
    
    override func viewDidLoad() {
        print("View BrowseVC")
        super.viewDidLoad()
        
        navigationItem.setRightBarButtonItems([ super.sortButton , super.searchButton] as? [UIBarButtonItem], animated: false)
        
        tableview.register(UINib.init(nibName: ProductCell.sbIdentifier, bundle: Bundle.main), forCellReuseIdentifier: ProductCell.sbIdentifier)
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    override func onTriggerSearchButton()  {
        super.searchTextField.delegate = self
    }
    
    override func onTriggerByCheapest() {
        sortBy = "1"
        loadFilterdProducts()
    }
    
    
    override func onTriggerByExpensive() {
        sortBy = "2"
        loadFilterdProducts()
        
    }
    
    
    override func onTriggerByNearest() {
        sortBy = "3"
        loadFilterdProducts()
        
    }
    
    override func onTriggerByNewest() {
        sortBy = "4"
        loadFilterdProducts()
        
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
    
    func loadProducts() {
        let params: [String : String] = [
            "user_id" : MyApplication.userID
        ]
        
        APIManager.apiConnection(param: params, url: "mobgetAllOffers", method: .post, success: {(json) in
            let ret = json["status"].intValue
            self.products.removeAll()
            self.filterItems.removeAll()
            
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
            self.tableview.reloadData()
        })
    }
    
    
    func loadFilterdProducts() {
        let params: [String : String] = [
            "user_id" : MyApplication.userID ,
            "long_add" : "" ,
            "lat_add" : "" ,
            "filter_By" : sortBy
        ]
        
        APIManager.apiConnection(param: params, url: "mobofferSearch", method: .post, success: {(json) in
            let ret = json["status"].intValue
            self.products.removeAll()
            self.filterItems.removeAll()
            
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
            self.tableview.reloadData()
        })
    }
    
    
    
    func loadProductsWithSort() {
        let params: [String : String] = [
            "user_id" : MyApplication.userID,
            "sort_by" : MyApplication.sortStr
        ]
        
        APIManager.apiConnection(param: params, url: "User/get_offers_bychepest_nearest", method: .post, success: {(json) in
            let ret = json["status"].intValue
            self.products.removeAll()
            self.filterItems.removeAll()
            
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
            self.tableview.reloadData()
        })
    }
    
    func set_favorite_offer(statu: String, product: ProductModel){
        let params: [String : String] = [
            "user_id" : MyApplication.userID,
            "offer_id" : product.id,
            "store_id" : product.store_id,
            "other" : "change fav status",
            "favType" : "2"
        ]
        
        APIManager.apiConnection(param: params, url: "mobSetFavorite", method: .post, success: {(json) in
            let ret = json["status"].intValue
            if ret == 1 {
                self.showToast(message: json["message"].stringValue)
                self.onEventResetList(offer_id: product.id)
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
        tableview.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

extension BrowseVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
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
            self.set_favorite_offer(statu: status, product: product)
        }
        cell.companyAction = { product in
            let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "CategoryListVC") as! CategoryListVC)
            vc.company = product.store_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc:ProductDetailsVC = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC)
        vc.product = products[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension BrowseVC: StoreDelegate {
    func onClickStoreNameDelegate(product: ProductModel) {
        let vc:StoreVC = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "StoreVC") as! StoreVC)
        vc.storeID = product.store_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



extension BrowseVC: UITextFieldDelegate {
    
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
        self.tableview.reloadData()
    }
}
