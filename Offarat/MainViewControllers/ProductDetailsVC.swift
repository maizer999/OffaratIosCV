//
//  ProductDetailsVC.swift
//  Offarat
//
//  Created by Dulal Hossain on 2/11/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit

struct SlideModel {
    var image:String?
}

class ProductDetailsVC: UIViewController {
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    fileprivate let itemsPerRow: CGFloat = 1

    @IBOutlet weak var detailsTitleLabel: UILabel!
    @IBOutlet weak var fromTitleLabel: UILabel!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var detailLB: UILabel!
    @IBOutlet weak var fromDateLB: UILabel!
    @IBOutlet weak var favoriteUB: UIButton!
    @IBOutlet weak var markUIMG: UIImageView!
    @IBOutlet weak var productTitleUL: UILabel!
    
    var product: ProductModel?
    let sm1 = SlideModel(image: "")
    
    var images: [SlideModel] = []

    func reload(){
        self.galleryCollectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
          print("view ProductDetailsVC")
//        images = [sm1,sm1,sm1]
        markUIMG.isHidden = true
        
        images.removeAll()
        if !(product?.subImgUrl.isEmpty)! {
            for i in 0...(product?.subImgUrl.count)! - 1 {
                var sm = SlideModel()
                sm.image = APIManager.serverUrl + "uploads/" + (product?.subImgUrl[i])!
                
                images.append(sm)
            }
        }
        
        favoriteUB.isSelected = product?.favorite == "1" ? true : false
        
        detailLB.text = product?.details_en
        fromDateLB.text = product!.startDate + " ~ \n" + product!.endDate
        
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        galleryCollectionView.isPagingEnabled = true

        galleryCollectionView?.delegate = self
        galleryCollectionView?.dataSource = self

        setBackButton()
        guard let product = product else {
            return
        }
        fill(product)
        
        self.title = LocalizationSystem.shared.getLanguage() == "en" ? product.details_en : product.details_ar
        self.productTitleUL.text = LocalizationSystem.shared.getLanguage() == "en" ? product.name : product.name_ar
        
        reload()
        
        incrementOfferByID()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func fill(_ product: ProductModel) {
        detailsTitleLabel.text = details.localizedValue()
        fromTitleLabel.text = from.localizedValue()
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton){
       showShareController()
    }
    
    @IBAction func favoriteButtonAction(_ sender: UIButton){
        let status = product!.favorite == "0" ? "1" : "0"
        self.set_favorite_offer(statu: status, product: product!)
    }
    
    func incrementOfferByID() {
        APIManager.apiConnection(param: ["offer_id": product!.id], url: "mobIncreaseOfferView", method: .post, success: {(json) in
            print(json["staus"].stringValue)
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
                    product.favorite = product.favorite == "0" ? "1" : "0"
                self.favoriteUB.isSelected = product.favorite == "1" ? true : false
            } else {
                self.showToast(message: "Server Error")
            }
        })
    }

    @IBAction func locationButtonAction(_ sender: UIButton){
        UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/?ll=\(product!.latitude),\(product!.longitude)")! as URL)
    }
    
    @IBAction func callButtonAction(_ sender: UIButton){
        if let url = NSURL(string: "tel://\(product!.phoneNumber)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.openURL(url as URL)
        }
    }
}

extension ProductDetailsVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell: GalleryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        let info: SlideModel = images[indexPath.row]
        cell.filledPageInfo(slide: info)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let   cell = collectionView.cellForItem(at: indexPath) as! GalleryCell

        
        let img =  images[indexPath.row].image ?? ""
        
        let vc = (UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: "ProcessImageController") as! ProcessImageController)
        vc.setImage(image: img)

             self.navigationController?.pushViewController(vc, animated: true)
        
        
        // delegate?.didPressonGallery(control: self, info: info)
        //self.removeFromSuperview()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // let paddingSpace = 1 * (itemsPerRow + 1)
        // let availableWidth = (UIScreen.main.bounds.width - 40)
        //let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension ProductDetailsVC: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
