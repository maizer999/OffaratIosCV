//
//  ProcessImageController.swift
//  OpenCVTest
//
//  Created by Timothy Poulsen on 11/29/18.
//  Copyright © 2018 Timothy Poulsen. All rights reserved.
//

import UIKit
import CoreImage
import AlamofireImage
import Alamofire
class ProcessImageController: UIViewController {
    
    public var source_image: UIImage? = nil
    
    var remarks = [CGRect]()
    var shownMark = [CGRect]()
    var isShownValue = [Int]()
    var imageURL = ""
    @IBOutlet weak var imgView: UIImageView!

    
    
    func setImage(image : String) {
//        imgView.image = image
        imageURL = image
//      imgView.af_setImage(withURL: url)
  //        imgView.onShowImgWithUrl(link:image)
      //  imageString = image
    }
    let picker = UIImagePickerController()
    
    @IBOutlet weak var drawCUV: CanvasUV!
    
    @IBAction func onClickSaveImage(_ sender: Any) {
        AppUtils.selectedImgs.removeAll()
        for i in 0 ..< isShownValue.count {
            let value = isShownValue[i]
            if value == 1 {
                let img = OpenCVWrapper.getImgByIndex(imgView.image!, index: Int32(i))
                AppUtils.selectedImgs.append(img)
            }
        }
        if AppUtils.selectedImgs.count > 0 {
            performSegue(withIdentifier: "main_save", sender: nil)
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(tapGestureRecognizer)
        
//
        if let url = URL(string: imageURL ) {

        imgView?.af_setImage(withURL:url, placeholderImage: nil, filter: nil , runImageTransitionIfCached: false, completion: {response in
              // do stuff when is downloaded completely.
            self.getImageRect()
            })
        }
        
        
        
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        getImageRect()
    }
    
    func getImageRect() {
        if let img = imgView?.image {
            AppUtils.all_rects.removeAll()
            
            let srcImg = OpenCVWrapper.convert(toGrayscale: img.normalized!)
            imgView.image = srcImg
            
            remarks.removeAll()
            for points in AppUtils.all_rects {
                var minX = 500000.0, maxX = 0.0, minY = 500000.0, maxY = 0.0
                for i in 0 ..< 4 {
                    let x = points[i * 2]
                    if minX > x {
                        minX = x
                    }
                    if maxX < x {
                        maxX = x
                    }
                    let y = points[i * 2 + 1]
                    if minY > y {
                        minY = y
                    }
                    if maxY < y {
                        maxY = y
                    }
                }

                let scaleX = imgView.bounds.width / img.size.width
                let scaleY = imgView.bounds.height / img.size.height
                
                let rect = CGRect(x: CGFloat(minX) * scaleX, y: CGFloat(minY) * scaleY, width: CGFloat(maxX - minX) * scaleX, height: CGFloat(maxY - minY) * scaleY)
                remarks.append(rect)
            }
            
            isShownValue.removeAll()
            for _ in remarks {
                isShownValue.append(0)
            }
            
            setSeletedImages(point: CGPoint.zero)
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let cgpoint = tapGestureRecognizer.location(in: imgView)
        
        setSeletedImages(point: cgpoint)
    }
    
    func setSeletedImages(point: CGPoint) {

        for i in 0 ..< remarks.count {
            let rect = remarks[i]
            if rect.contains(point) {
                
                
                print(" \(rect)  point  \(point)")
                
                let value = isShownValue[i]
                if value == 1 {
                    isShownValue[i] = 0
                } else {
                    isShownValue[i] = 1
                }
                break
            }
        }
        
        shownMark.removeAll()
        for i in 0 ..< remarks.count {
            let rect = remarks[i]
            if (isShownValue[i] == 1) {
                shownMark.append(rect)
            }
        }
        
        drawCUV.setRects(rects: shownMark)
    }
    
    
}
