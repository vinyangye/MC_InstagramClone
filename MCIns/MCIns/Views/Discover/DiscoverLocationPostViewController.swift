//
//  DiscoverLocationPostViewController.swift
//  MCIns
//
//  Created by ye yang on 21/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import MapKit

class DiscoverLocationPostViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var place: PostLocation?
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        setupBasic()
        setupNavi()
        loadLocationPost()
    }
    
    func setupNavi() {
        navigationItem.title = place?.name
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
    
    func setupMap() {
        if place!.longitude != "" && place!.latitude != ""{
            let longtitude = Double(place!.longitude)
            let latitude = Double(place!.latitude)
            let center:CLLocation = CLLocation(latitude: latitude!, longitude: longtitude!)
            let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpanMake(0.05, 0.05)
            let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate,
                                                                      span: currentLocationSpan)
            self.mapView.setRegion(currentRegion, animated: true)
            
            
            let objectAnnotation = MKPointAnnotation()
            
            objectAnnotation.coordinate = CLLocation(latitude: latitude!, longitude: longtitude!).coordinate
            
            objectAnnotation.title = place?.name
            
            if place?.address != "" {
                objectAnnotation.subtitle = place?.address
            }

            self.mapView.addAnnotation(objectAnnotation)
        }
    }
    func loadLocationPost() {
        PostUtility.loadDiscoverLocationPost(location: place!) { (post) in
            self.posts.insert(post, at: 0)
            self.collectionView.reloadData()
        }
    }
    
    func zoomMapFitAnnotations() {
        var zoomRect = MKMapRectNull
        for annotation in mapView.annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0)
            if (MKMapRectIsNull(zoomRect)) {
                zoomRect = pointRect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, pointRect)
            }
        }
        self.mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: true)
    }

}

extension DiscoverLocationPostViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
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
