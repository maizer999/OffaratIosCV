//
//  FavoriteVC.swift
//  Darahem
//
//  Created by Dulal Hossain on 11/9/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit

enum SegmentType {
    case offers
    case stores
}

class FavoriteVC: BaseTabVC {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!

    var products:[ProductModel]   = []
    var stores                    = [StoreModel]()
    var filterProductsItems       :[ProductModel] = []
    var filterstoresItems         :[StoreModel] = []
    
    
        
    var segmentType:SegmentType = .offers{
        didSet{
            view.backgroundColor = segmentType == .offers ? Color.gray_xlight : .white
        }
    }
    
    override func onTriggerSearchButton()  {
             super.searchTextField.delegate = self
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProducts()
    }
    
    override func viewDidLoad() {
        print("View FavoriteVC")
        
        super.viewDidLoad()
        
//        navigationItem.setRightBarButtonItems([ super.sortButton , super.searchButton] as? [UIBarButtonItem], animated: false)
        
//        let editImage    = UIImage(named: "search_icon")!
//        let searchImage  = UIImage(named: "filter icon")!
//
//        let editButton   = UIBarButtonItem(image: editImage,  style: .plain, target: self, action: #selector(didTapEditButton))
//        let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapSearchButton))
//
//        navigationItem.rightBarButtonItems = [editButton, searchButton,editButton]
        
        tableview.register(UINib.init(nibName: ProductCell.sbIdentifier, bundle: Bundle.main), forCellReuseIdentifier: ProductCell.sbIdentifier)
        tableview.delegate = self
        tableview.dataSource = self
        segmentType = .offers
    }
    
//
//    override func onTriggerSearchButton()  {
//           super.searchTextField.delegate = self
//       }
//
//       override func onTriggerByCheapest() {
//           sortBy = "1"
//           loadFilterdProducts()
//       }
//
//
//       override func onTriggerByExpensive() {
//           sortBy = "2"
//           loadFilterdProducts()
//
//       }
//
//
//       override func onTriggerByNearest() {
//           sortBy = "3"
//           loadFilterdProducts()
//
//       }
//
//       override func onTriggerByNewest() {
//           sortBy = "4"
//           loadFilterdProducts()
//
//       }
//
//
//
//    override func onTriggerByName() {
//        if segmentType == .offers {
//            loadProducts()
//        } else if segmentType == .stores {
//            loadStores()
//        }
//    }
//
//    override func onTriggerByPrice() {
//        if segmentType == .offers {
//            loadProducts()
//        } else if segmentType == .stores {
//            loadStores()
//        }
//    }
    
//    override func onTriggerByLocation() {
//        if segmentType == .offers {
//            loadProducts()
//        } else if segmentType == .stores {
//            loadStores()
//        }
//    }
    
    override func onClickItem(_ index: Int) {
        super.onClickItem(index)
        print("\(index)")
        MyApplication.supCategory = ""
        MyApplication.subCategory = "\(index)"
        let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "CategoryListVC") as! CategoryListVC)
        vc.company = ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    @objc func didTapEditButton()  {
//        
//    }
//    
//    @objc func didTapSearchButton()  {
//        
//    }
    
    func loadProducts() {
        let params: [String : String] = [
            "user_id" : MyApplication.userID
            ]
        
        APIManager.apiConnection(param: params, url: "mobgetFavoriteOffers", method: .post, success: {(json) in
            let ret = json["status"].intValue
            self.products.removeAll()
            if ret == 1 {
                let jsonAry = json["data"].arrayValue;
                for item in jsonAry {
                    let product = ProductModel()
                    product.initWithJson(data: item)
                    product.favorite = "1"
                    self.products.append(product)
                }
            } else {
                self.showToast(message: json["message"].stringValue)
            }
            self.tableview.reloadData()
        })
    }
    
    func loadStores() {
        let params: [String : String] = [
            "user_id" : MyApplication.userID
            ]
        
        APIManager.apiConnection(param: params, url: "mobgetFavoriteStores", method: .post, success: {(json) in
            let ret = json["status"].intValue
            self.stores.removeAll()
            if ret == 1 {
                let jsonAry = json["data"].arrayValue;
                for item in jsonAry {
                    let store = StoreModel()
                    store.initWithJson(data: item)
                    self.stores.append(store)
                }
            } else {
                self.showToast(message: json["message"].stringValue)
            }
            self.tableview.reloadData()
        })
    }
    
    @IBAction func changeSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            segmentType = .offers
            loadProducts()
        } else {
            segmentType = .stores
            loadStores()
        }
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
    
}

extension FavoriteVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentType == .offers ? products.count : stores.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return segmentType == .offers ? 318.0 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentType == .offers{
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
        
        let cell: StoreCell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreCell
        cell.initWithStore(store: stores[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if segmentType == .stores { return }
        let vc:ProductDetailsVC = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC)
        vc.product = products[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension FavoriteVC: StoreDelegate {
    func onClickStoreNameDelegate(product: ProductModel) {
        let vc:StoreVC = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "StoreVC") as! StoreVC)
        vc.storeID = product.store_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



extension FavoriteVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.products.removeAll()
        if textField.text == "" {
            self.products = self.filterProductsItems
        } else {
            for category in self.filterProductsItems {
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
