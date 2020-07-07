//
//
//  Created by Dulal Hossain on 4/2/17.
//  Copyright © 2017 DL. All rights reserved.
//

import UIKit
import SwiftyJSON

class CategoryModel: Codable, Equatable {
    
    static func == (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id = 0
    var name = ""
    var name_ar = ""
    var imgUrl = ""
    var isExpand = false
    var subCategories = [SubCategoryModel]()
    
    func initWithJson(data json: JSON) {
        id = json["id"].intValue
        name = json["name_en"].stringValue
        name_ar = json["name_ar"].stringValue
        imgUrl = json["image_url"].stringValue
        
        let subAry = json["subCategories"].arrayValue
        for subJson in subAry {
            let subItem = SubCategoryModel()
            subItem.initWithJson(data: subJson)
            subCategories.append(subItem)
        }
    }
}

class SubCategoryModel: Codable {
    
    var id = 0
    var name = ""
    var name_ar="";
    var img_url="";
    
    func initWithJson(data json: JSON) {
        id = json["id"].intValue
        name = json["name_en"].stringValue
        name_ar = json["name_ar"].stringValue
        img_url = json["image_url"].stringValue
    }
}

class ProductModel: Codable {
    
    var id = ""
    var name = ""
    var name_ar = ""
    var imgUrl = ""
    var store_id = ""
    var favorite = ""
    var category_id = ""

    var offer = ""
    var startDate = ""
    var endDate = ""
    var webAddress = ""
    var phoneNumber = ""
    var latitude = ""
    var longitude = ""
    var subImgUrl = [String]()
    
    var details_en = ""
    var details_ar = ""
    
    func initWithJson(data json: JSON) {
        id = json["id"].stringValue
        name = json["name_en"].stringValue
        name_ar = json["name_ar"].stringValue
        imgUrl = json["image_url"].stringValue
        store_id = json["store_id"].stringValue
        favorite = json["is_favorite"].stringValue
        category_id = json["category_id"].stringValue
        
        offer = json["is_favorite"].stringValue
        startDate = json["from_date"].stringValue
        endDate = json["to_date"].stringValue
        webAddress = ""
//        let jsonData = json["store_data"]
        phoneNumber = json["phone"].stringValue
        latitude = json["latitude"].stringValue
        longitude = json["longitude"].stringValue
        details_ar = json["details_ar"].stringValue
        details_en = json["details_en"].stringValue
        
        if !json["Images"].arrayValue.isEmpty {
            for i in 0...json["Images"].arrayValue.count - 1 {
                subImgUrl.append((json["Images"].arrayValue[i])["image_url"].stringValue)
            }
        }
    }
}

class StoreModel: Codable {
    var id = "";
    var name = "";
    var name_ar = "";
    var imgUrl = "";
    var location = "";
    var location_ar = "";
    
    var latitude = "";
    var longitude = "";
    var contact = "";
    var email = "";
    var created_date = "";
    var favorite_date = "";
    
    func initWithJson(data json: JSON) {
        id = json["id"].stringValue
        name = json["name_en"].stringValue
        name_ar = json["name_ar"].stringValue
        imgUrl = json["thumbnail"].stringValue
        location = json["location"].stringValue
        location_ar = json["location_ar"].stringValue
        
        latitude = json["address_Lat"].stringValue
        longitude = json["address_long"].stringValue
        contact = json["phone"].stringValue
        email = json["email"].stringValue
        created_date = json["created_date"].stringValue
        favorite_date = json["fav_created_date"].stringValue
    }
}
