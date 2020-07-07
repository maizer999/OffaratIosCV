//
//  MyApplication.swift
//  Offarat
//
//  Created by JinYZ on 12/8/19.
//  Copyright © 2019 DL. All rights reserved.
//

import UIKit
import Kingfisher

class MyApplication: NSObject {
    
    static var userID = ""
    static var sortStr = ""
    static var supCategory = ""
    static var subCategory = ""
    static var allCategories = [CategoryModel]()
    
    static func callAction(phoneNumber : String){
        if let url = NSURL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    static func openMap(latitude : String, longitude: String){       UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/?ll=\(latitude),\(longitude)")! as URL)
    }
    
}

extension UIViewController {
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}

extension UIImageView {
    
    func onShowImgWithUrl(link: String ) {
        let processor = DownsamplingImageProcessor(size: frame.size)
            |> RoundCornerImageProcessor(cornerRadius: 0)
        kf.indicatorType = .activity
        kf.setImage(
            with: URL(string: link),
            placeholder: UIImage(named: "ico_avatar"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
    
}
