//
//  DiscoverViewController.swift
//  MCIns
//
//  Created by ye yang on 15/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit


class DiscoverViewController: UIViewController {

    var searchBar = UISearchBar()
    var posts = [Post]()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        setupBasic()
        setupDiscoverPost()
        
    }
    
    func setupDiscoverPost() {
        activityIndicator.startAnimating()
        PostUtility.loadDiscoverPost { (post) in
            self.posts.insert(post, at: 0)
//            self.posts.append(post)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.collectionView.reloadData()
        }
    }
    
    func setupNavi() {
        navigationController?.navigationBar.backgroundColor = UIColor.white
        searchBar.frame = CGRect(x: 0, y: 0, width: 340, height: 28)
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Search"
        let tap = UITapGestureRecognizer(target:self, action:#selector(searchBarTapped))
        searchBar.isUserInteractionEnabled=true
        searchBar.addGestureRecognizer(tap)
        
        let textField = searchBar.value(forKey: "searchField") as! UITextField
        textField.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        textField.isEnabled = false
        
        let leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
    }
    
    func setupBasic() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "DiscoverPostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DiscoverPostCollectionViewCell")
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let screenWidth = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: screenWidth/3 - 1 , height: screenWidth/3 - 1)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        self.collectionView.collectionViewLayout = layout
 
    }

    
    @objc func searchBarTapped() {
        let vc = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "DiscoverSearchViewController") as! DiscoverSearchViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    


}

extension DiscoverViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverPostCollectionViewCell", for: indexPath) as! DiscoverPostCollectionViewCell

        cell.post = posts[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DiscoverPostCollectionViewCell
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "SinglePostViewController") as! SinglePostViewController
        let post = cell.post
        let user = UserUtility.getLocalUserById(userId: post!.userId)
        vc.post = post
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
 
}



