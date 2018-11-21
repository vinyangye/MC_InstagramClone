//
//  PhotoEditView.swift
//  MCIns
//
//  Created by ye yang on 21/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Stevia

class PhotoEditView: UIView {
    
    let imageView = UIImageView()
    var collectionView: UICollectionView!
    fileprivate let collectionViewContainer: UIView = UIView()
    
    convenience init() {
        self.init(frame: CGRect.zero)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout())
        
        sv(
            imageView,
            collectionViewContainer.sv(
                collectionView
            )
        )
        
        let isIphone4 = UIScreen.main.bounds.height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0
        
        |-sideMargin-imageView.top(0)-sideMargin-|
        |-sideMargin-collectionViewContainer-sideMargin-|
        collectionViewContainer.bottom(0)
        imageView.Bottom == collectionViewContainer.Top
        |collectionView.centerVertically().height(160)|
        
        imageView.heightEqualsWidth()
        
        backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        layout.itemSize = CGSize(width: 100, height: 120)
        return layout
    }
}
