

import UIKit

protocol StoreDelegate {
    func onClickStoreNameDelegate(product: ProductModel)
}

class ProductCell: UITableViewCell, StoryboardIdentifier {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameUL: UILabel!
//    @IBOutlet weak var offerTitleLabel: UILabel!
    @IBOutlet weak var fromTitleLabel: UILabel!
    @IBOutlet weak var favoriteUB: UIButton!
    @IBOutlet weak var phoneUB: UIButton!
    @IBOutlet weak var fromDateLB: UILabel!
    
    var product = ProductModel()
    var delegate: StoreDelegate?
    
    var shareAction:((_ model: ProductModel)->Void)?
    var favoriteAction:((_ model: ProductModel)->Void)?
    var callAction:((_ model: ProductModel)->Void)?
    var locationAction:((_ model: ProductModel)->Void)?
    var companyAction:((_ model: ProductModel)->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapStoreName))
        nameUL.isUserInteractionEnabled = true
        nameUL.addGestureRecognizer(gesture)
    }

    @objc func onTapStoreName() {
        self.delegate?.onClickStoreNameDelegate(product: product)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fill(_ product: ProductModel) {
        self.product = product

        let lang = LocalizationSystem.shared.getLanguage()
        nameUL.text = lang == "en" ? product.name : product.name_ar
//        if !product.subImgUrl.isEmpty {
//            productImageView.onShowImgWithUrl(link: product.imgUrl != "" ? APIManager.serverUrl + "uploads/" + product.imgUrl : APIManager.serverUrl + "uploads/" + product.subImgUrl[0])
//        }
        if product.imgUrl == "" && !product.subImgUrl.isEmpty{
            productImageView.onShowImgWithUrl(link: APIManager.serverUrl + "uploads/" + product.subImgUrl[0])
        } else if product.imgUrl != "" {
            productImageView.onShowImgWithUrl(link: APIManager.serverUrl + "uploads/" + product.imgUrl)
        }
//        offerTitleLabel.text = offer.localizedValue()
        fromTitleLabel.text = from.localizedValue()
        favoriteUB.isSelected  = product.favorite == "1" ? true : false
        phoneUB.isHidden = product.phoneNumber == "" ? true : false
        fromDateLB.text = product.startDate + " ~ \n" + product.endDate
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton){
         if let hand = shareAction{
            hand(product)
        }
    }
    
    @IBAction func favoriteButtonAction(_ sender: UIButton){
        if let hand = favoriteAction{
            hand(product)
        }
    }
    
    @IBAction func locationButtonAction(_ sender: UIButton){
        if let hand = locationAction{
            hand(product)
        }
    }
    
    @IBAction func callButtonAction(_ sender: UIButton){
        if let hand = callAction{
            hand(product)
        }
    }
    
    @IBAction func companyButtonAction(_ sender: Any) {
        if let hand = companyAction{
            hand(product)
        }
    }
}


