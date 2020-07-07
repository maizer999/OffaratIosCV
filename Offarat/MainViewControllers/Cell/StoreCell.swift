//
//  StoreCell.swift
//  Offarat
//
//  Created by Dulal Hossain on 2/11/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit

class StoreCell: UITableViewCell, StoryboardIdentifier {

    @IBOutlet weak var favoriteUIV: UIImageView!
    @IBOutlet weak var nameUL: UILabel!
    
    var store = StoreModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initWithStore(store: StoreModel) {
        self.store = store
        favoriteUIV.isHidden = store.favorite_date == "" ? true : false
        nameUL.text = LocalizationSystem.shared.getLanguage() == "en" ? store.name : store.name_ar
//        nameUL.text = store.name
        let lang = LocalizationSystem.shared.getLanguage()
        nameUL.text = lang == "en" ? store.name : store.name_ar
    }
    
}
