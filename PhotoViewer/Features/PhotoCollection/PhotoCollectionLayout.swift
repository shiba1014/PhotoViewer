//
//  PhotoCollectionLayout.swift
//  PhotoViewer
//
//  Created by Paul McCartney on 2017/12/14.
//  Copyright © 2017年 Satsuki Hashiba. All rights reserved.
//

import UIKit

protocol PhotoCollectionLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        heightForPhotoAtIndexPath indexPath: IndexPath ,
                        withWidth: CGFloat) -> CGFloat
}

class PhotoCollectionLayoutAttributes: UICollectionViewLayoutAttributes {
    var imageHeight: CGFloat = 0
    var footerHeight: CGFloat = 0
    
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! PhotoCollectionLayoutAttributes
        copy.imageHeight = imageHeight
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? PhotoCollectionLayoutAttributes {
            
            if attributes.imageHeight == imageHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}

class PhotoCollectionLayout: UICollectionViewFlowLayout {
    var delegate: PhotoCollectionLayoutDelegate?
    
    var numberOfColumns = 2
    var cellPadding = PhotoCollectionCell.space
    var cache: [PhotoCollectionLayoutAttributes] = []
    var contentHeight: CGFloat = 0
    var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    override class var layoutAttributesClass : AnyClass {
        return PhotoCollectionLayoutAttributes.self
    }
    
    override func prepare() {
        super.prepare()
        
        guard cache.isEmpty else{
            return
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let width = columnWidth - cellPadding * 2
            let photoHeight = delegate?.collectionView(collectionView!,
                                                      heightForPhotoAtIndexPath: indexPath,
                                                      withWidth: width) ?? 0
            
            let height = cellPadding + photoHeight
            
            let frame = CGRect(x: xOffset[column],
                               y: yOffset[column],
                               width: columnWidth,
                               height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let cellAttributes = PhotoCollectionLayoutAttributes(forCellWith: indexPath)
            cellAttributes.imageHeight = photoHeight
            cellAttributes.frame = insetFrame
            cache.append(cellAttributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            if column >= numberOfColumns - 1 {
                column = 0
            } else {
                column += 1
            }
        }
        
//        let footerAttributes = PhotoCollectionLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: 1))
//        cache.append(footerAttributes)
    }
    
    override var collectionViewContentSize : CGSize {
        return .init(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes:[UICollectionViewLayoutAttributes] = []
        
        for attributes in cache {
            if attributes.representedElementCategory == .cell {
                layoutAttributes.append(attributes)
            } else if attributes.representedElementCategory == .supplementaryView {
                if let supplementaryView = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: attributes.indexPath) {
                    layoutAttributes.append(supplementaryView)
                }
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache.first { attributes -> Bool in
            return attributes.indexPath == indexPath
        }
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = PhotoCollectionLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        attributes.footerHeight = 100
        attributes.frame = self.collectionView?.frame ?? .zero
        return attributes
    }
}
