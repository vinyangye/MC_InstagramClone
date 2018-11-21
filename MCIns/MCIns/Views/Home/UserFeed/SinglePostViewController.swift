//
//  SinglePostViewController.swift
//  MCIns
//
//  Created by Charles Huang on 19/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit

class SinglePostViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var post: Post!
    var user: InsUser!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Post"
        collectionView.register(UINib(nibName: "UserFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UserFeedCollectionViewCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let screenWidth = UIScreen.main.bounds.width
        let viewHeight = CGFloat(integerLiteral: 540)
        layout.itemSize = CGSize(width: screenWidth, height: viewHeight)
        self.collectionView.collectionViewLayout = layout

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFeedCollectionViewCell", for: indexPath) as? UserFeedCollectionViewCell {
            cell.inHomeFeed = false
            cell.post = self.post
            cell.user = self.user
            return cell
        } else{
            return UICollectionViewCell()
        }
    }
    

}
