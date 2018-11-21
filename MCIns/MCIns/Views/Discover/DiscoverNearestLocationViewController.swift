//
//  DiscoverNearestLocationViewController.swift
//  MCIns
//
//  Created by ye yang on 21/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import GooglePlaces

class DiscoverNearestLocationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var places = [PostLocation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        setupBasic()
        setupLocation()
    }
    
    func setupNavi() {
        navigationItem.title = "Nearest Location"
    }
    
    func setupBasic() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "PostSearchLoactionTableViewCell", bundle: nil), forCellReuseIdentifier: "PostSearchLoactionTableViewCell")
        
    }
    
    func setupLocation() {
        if CLLocationManager.locationServicesEnabled()
        {
            
            if CLLocationManager.authorizationStatus() == .denied{
                AlertViewUtility.showLocationAlertView()
                return
            }
            
            let placesClient = GMSPlacesClient()
            
            PublicUtility.showDefaultHUDView()
            
            placesClient.currentPlace { (placeLikelihoods, error) in
                
                if error != nil {
                    PublicUtility.hideHUDView()
                    print("Current Place error: \(error!.localizedDescription)")
                    AlertViewUtility.showWarningView(error!.localizedDescription)
                    return
                }
                
                if let placeLikelihoodList = placeLikelihoods{
                    for likelihood in placeLikelihoodList.likelihoods {
                        let place = likelihood.place
                        placesClient.lookUpPlaceID(place.placeID, callback: { (place, error) -> Void in
                            
                            PublicUtility.hideHUDView()
                            if place != nil {
                                
                                self.tableView.reloadData()
                                let loc = self.transformInsLocation(place: place!)
                                self.places.append(loc)
                                self.tableView.reloadData()
 
                            }
                            else{
                                AlertViewUtility.showWarningView(error!.localizedDescription)
                            }
                        })
                        
                    }
                    
                    
                }else{
                    AlertViewUtility.showWarningView("Cannot Find Current Places")
                }
                
            }
            
        }
        else
        {
            
            AlertViewUtility.showLocationPrivacyAlertView()
        }
    }
    
    func transformInsLocation(place: GMSPlace) -> PostLocation {
        let x = String(place.coordinate.longitude)
        let y = String(place.coordinate.latitude)
        var location = PostLocation()
        if let address = place.formattedAddress{
            location = PostLocation.setupLocation(name: place.name, address: address, longitude: x, latitude: y)
        }else{
            location = PostLocation.setupLocation(name: place.name, address: "", longitude: x, latitude: y)
        }
        
        return location
    }

}


extension DiscoverNearestLocationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (places.count)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostSearchLoactionTableViewCell", for: indexPath) as! PostSearchLoactionTableViewCell
        let placeData = places[indexPath.row]
        
        
        cell.textLabel!.text = placeData.name
        cell.detailTextLabel?.text = placeData.address
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "DiscoverLocationPostViewController") as! DiscoverLocationPostViewController
        vc.place = places[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}
