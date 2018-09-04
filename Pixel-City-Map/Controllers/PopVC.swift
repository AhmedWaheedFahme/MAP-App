//
//  PopVC.swift
//  Pixel-City-Map
//
//  Created by Ahmed Waheed on 9/2/18.
//  Copyright © 2018 Ahmed Waheed. All rights reserved.
//  we make that to when we press into the pic open that image in that VC

import UIKit

class PopVC: UIViewController , UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    var passedImage : UIImage!
    
    func initData(forImage image:UIImage){
        self.passedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        doubleTap()
    }
    
    func doubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
  @objc  func screenDoubleTap(){
    dismiss(animated: true, completion: nil)
        
    }
}
