//
//  PhotoDetailViewController.swift
//  PhotoViewer
//
//  Created by Paul McCartney on 2017/12/15.
//  Copyright © 2017年 Satsuki Hashiba. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotoDetailViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    
    private var imageURL: URL!

    static func instantiate(imageURL: URL) -> PhotoDetailViewController {
        let sb = UIStoryboard(name: "PhotoDetail", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! PhotoDetailViewController
        vc.imageURL = imageURL
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}

private extension PhotoDetailViewController {
    func configure() {
        self.navigationController?.navigationBar.topItem?.title = ""
        
        imageView.af_setImage(withURL: imageURL)
    }
}
