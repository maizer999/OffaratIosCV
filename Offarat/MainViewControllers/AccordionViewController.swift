//
//  AccordionViewController.swift
//  Example
//
//  Created by Victor Sigler on 8/8/18.
//  Copyright © 2018 Victor Sigler. All rights reserved.
//

import UIKit
import AccordionSwift

class AccordionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var subCategories = [SubCategoryModel]()

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = "SubCategory"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension AccordionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as! CountryTableViewCell
        
        let sub = subCategories[indexPath.row]
        cell.contryLabel.text = sub.name
        cell.countryImageView.onShowImgWithUrl(link: APIManager.serverUrl + "uploads/" + sub.img_url)
        
        return cell
    }
}

extension AccordionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sub = subCategories[indexPath.row]
//        MyApplication.supCategory = ""
        MyApplication.subCategory = "\(sub.id)"
        let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "CategoryListVC") as! CategoryListVC)
        vc.company = ""
//        vc.product = MyApplication.subCategory.products[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
