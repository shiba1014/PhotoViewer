//
//  ViewController.swift
//  PhotoViewer
//
//  Created by Paul McCartney on 2017/12/14.
//  Copyright © 2017年 Satsuki Hashiba. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveSwift
import Result
import AlamofireImage

class PhotoCollectionViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var urls: [URL] = []
    private var sizes: [CGSize] = []
    private var pageCount: Int = 1
    private let indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}

private extension PhotoCollectionViewController {
    func configure() {
        let layout = PhotoCollectionLayout()
        layout.delegate = self
        layout.footerReferenceSize = .init(width: collectionView.bounds.width, height: 50)
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = UIView(frame: .zero)
        collectionView.register(UINib(nibName: PhotoCollectionCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhotoCollectionCell.identifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer")
        
        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = .gray
        self.view.addSubview(indicator)
        indicator.startAnimating()
        
        getPopularPhotos()
    }
    
    func getPopularPhotos() {
        let api = FlickrAPI.interestingPhotos(count: 100, page: pageCount)
        Client.shared.request(api: api)
            .observe(on: UIScheduler())
            .map({ data -> [(url:URL, size:CGSize)] in
                return Parser.getImageInfo(from: data)
            }).map({ [unowned self] infos -> Bool in
                var urls: [URL] = []
                var sizes: [CGSize] = []
                for info in infos {
                    urls.append(info.url)
                    sizes.append(info.size)
                }
                self.urls.append(contentsOf: urls)
                self.sizes.append(contentsOf: sizes)
                self.collectionView.reloadData()
                self.pageCount += 1
                self.indicator.stopAnimating()
                return true
            }).start()
    }
    
    func getThumbnailImage(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(UIColor.gray.cgColor)
        context!.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension PhotoCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.identifier, for: indexPath) as? PhotoCollectionCell else { return .init() }
        cell.imageView.alpha = 0
        cell.imageView.af_setImage(withURL: urls[indexPath.item], placeholderImage: getThumbnailImage(size: cell.imageView.bounds.size)) { _ in
            UIView.animate(withDuration: 1) {
                cell.imageView.alpha = 1
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            reusableView.backgroundColor = .orange
            return reusableView
        }
        return UICollectionReusableView()
    }
}

extension PhotoCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = PhotoDetailViewController.instantiate(imageURL: urls[indexPath.item])
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PhotoCollectionViewController: PhotoCollectionLayoutDelegate {
    func collectionView(_ collectionView:UICollectionView,
                        heightForPhotoAtIndexPath indexPath:IndexPath ,
                        withWidth width:CGFloat) -> CGFloat {
        let boundingRect = CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect = AVMakeRect(aspectRatio: sizes[indexPath.item], insideRect: boundingRect)
        return rect.size.height
    }
}
