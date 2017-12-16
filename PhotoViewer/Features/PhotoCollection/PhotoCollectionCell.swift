//
//  PhotoCollectionCell.swift
//  PhotoViewer
//
//  Created by Paul McCartney on 2017/12/14.
//  Copyright © 2017年 Satsuki Hashiba. All rights reserved.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    static let identifier = "PhotoCollectionCell"
    static let space: CGFloat = 8
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHLC: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? PhotoCollectionLayoutAttributes {
            imageViewHLC.constant = attributes.imageHeight
        }
    }
}
