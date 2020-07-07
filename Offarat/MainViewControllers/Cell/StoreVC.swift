//
//  StoreVC.swift
//  Offarat
//
//  Created by Aira on 3/15/20.
//  Copyright © 2020 DL. All rights reserved.
//

import UIKit

class StoreVC: UIViewController {

    @IBOutlet weak var storeProductTV: UITableView!
    
    var storeID = ""
    var products: [ProductModel] = []
    override func viewDidLoad() {
           print("view StoreVC")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(storeID)
        initData()
        storeProductTV.register(UINib.init(nibName: ProductCell.sbIdentifier, bundle: Bundle.main), forCellReuseIdentifier: ProductCell.sbIdentifier)
        storeProductTV.dataSource = self
        storeProductTV.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initData() {
        
        let param: [String: String] = [
            "store_id": self.storeID
        ]
        
        APIManager.apiConnection(param: param, url: "mobgetStoreOffers", method: .post, success: {(json) in
            let ret = json["status"].intValue
            self.products.removeAll()
            if ret == 1 {
                let jsonArr = json["data"].arrayValue
                for item in jsonArr {
                    let product = ProductModel()
                    product.initWithJson(data: item)
                    self.products.append(product)
                }
            }
            self.storeProductTV.reloadData()
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
        storeProductTV.reloadData()
    }

}

extension StoreVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
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
        
        return cell
    }
    
    
}

extension StoreVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 318.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc:ProductDetailsVC = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC)
        vc.product = products[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
