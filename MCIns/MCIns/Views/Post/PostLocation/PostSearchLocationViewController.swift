//
//  PostSearchLocationViewController.swift
//  MCIns
//
//  Created by ye yang on 19/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import GooglePlaces

public enum CellType {
    case
    editSearchLocationCurrentLocation,
    editSearchLocation
}

protocol locationUpdateDelegate {

    func updateLocationInfo( place: PostLocation, searchText: String)

}

class PostSearchLocationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchBar = UISearchBar()
    var searchbarText = ""
    var locationUpdateDelegate:locationUpdateDelegate?
    var locationManager:CLLocationManager?
    var firstTime = true
    var currentSearchData = [GMSPlace]()
    var recentLocation = [GMSPlace]()
    
    var cellTypes:[(String,[CellType])] =
        [
            ("Current Location",[CellType.editSearchLocationCurrentLocation]),
            ("Recent Locations",[]),
            ("Locations",[])
            
    ]
    
    var cellClasses =
        [String(describing: PostCurrentLoactionTableViewCell.self), String(describing: PostSearchLoactionTableViewCell.self)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        setupBasic()
    }
    
    func setupNavi() {
        navigationController?.navigationBar.backgroundColor = UIColor.white
        //        navigationController?.navigationBar.shadowImage = UIImage()
        searchBar.frame = CGRect(x: 0, y: 0, width: 280, height: 28)
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Search"
        searchBar.autocapitalizationType = .none
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        
        let textField = searchBar.value(forKey: "searchField") as! UITextField
        textField.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        textField.isEnabled = true
        
        let leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        
        let rightBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBtnTapped))
        navigationItem.rightBarButtonItem = rightBarItem
        
    }
    
    func setupBasic() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestWhenInUseAuthorization()
        

        if CLLocationManager.authorizationStatus() == .notDetermined{
            firstTime = true
        }else{
            firstTime = false
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        for cellClass in  cellClasses {
            tableView.register(UINib(nibName: cellClass, bundle: nil), forCellReuseIdentifier: cellClass)
        }
//        tableView.register(UINib.init(nibName: "PostCurrentLoactionTableViewCell", bundle: nil), forCellReuseIdentifier: "PostCurrentLoactionTableViewCell")
////        tableView.register(UINib.init(nibName: "PostSearchLoactionTableViewCell", bundle: nil), forCellReuseIdentifier: "PostSearchLoactionTableViewCell")
        
        if CLLocationManager.locationServicesEnabled()
        {
            if CLLocationManager.authorizationStatus() == .denied {
                
                AlertViewUtility.showLocationAlertView()
            }
        }
        else
        {
            AlertViewUtility.showLocationPrivacyAlertView()
        }
    }
    
    @objc func cancelBtnTapped(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
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
extension PostSearchLocationViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchbarText = searchText
        let placesClient = GMSPlacesClient()
        
        let location = UserUtility.userLocation.coordinate
        
        let northEast = CLLocationCoordinate2DMake(location.latitude + 0.1, location.longitude + 0.1)
        let southWest = CLLocationCoordinate2DMake(location.latitude - 0.1, location.longitude - 0.1)
        
        let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let filter = GMSAutocompleteFilter()
        
        filter.type = GMSPlacesAutocompleteTypeFilter.noFilter
        
        currentSearchData.removeAll(keepingCapacity: false)
        cellTypes[2].1.removeAll()
        
        self.tableView.reloadData()
        
        
        if searchText.count > 0 {
            
            placesClient.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: { (results, error) -> Void in
                if error != nil {
                    print("Autocomplete error \(error!) for query '\(searchText)'")
                    return
                }
                
                if let results = results {
                    for result in results {
                        if result.placeID != nil{
                            placesClient.lookUpPlaceID(result.placeID!, callback: { (place, error) -> Void in
                                if place != nil {
                                    
                                    if searchText == self.searchbarText{
                                        self.currentSearchData.append(place!)
                                        self.cellTypes[2].1.append(CellType.editSearchLocation)
                                        self.tableView.reloadData()
                                    }
                                }
                            })
                        }
                    }}
            })
        }
        
    }
    
}

extension PostSearchLocationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypes[section].1.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellTypes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellType = cellTypes[indexPath.section].1[indexPath.row]
        
        switch cellType{
            
        case .editSearchLocationCurrentLocation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCurrentLoactionTableViewCell", for: indexPath) as! PostCurrentLoactionTableViewCell
            return cell
            
        case .editSearchLocation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostSearchLoactionTableViewCell", for: indexPath) as! PostSearchLoactionTableViewCell
            let placeData = self.currentSearchData[indexPath.row]
            
            
            cell.textLabel!.text = placeData.name
            cell.detailTextLabel?.text = placeData.formattedAddress
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let cellType = cellTypes[indexPath.section].1[indexPath.row]
        
        switch cellType{
            
        case .editSearchLocationCurrentLocation:
            
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
                                    
                                    self.currentSearchData.append(place!)
                                    self.tableView.reloadData()
                                    let loc = self.transformInsLocation(place: place!)
                                    self.locationUpdateDelegate!.updateLocationInfo(place: loc, searchText: self.searchbarText)
                                    
                                    _ = self.navigationController?.popViewController(animated: true)
                                    
                                }
                                else{
                                    AlertViewUtility.showWarningView(error!.localizedDescription)
                                }
                            })
                            break
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
            
            break
            
        case .editSearchLocation:
            //locationName:String, locationAddress:String,
            
            let loc = self.transformInsLocation(place: self.currentSearchData[indexPath.row])
            self.locationUpdateDelegate!.updateLocationInfo(place: loc, searchText:self.searchbarText)
            
            self.navigationController?.popViewController(animated: true)
            
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        
        if cellTypes[section].1.count == 0 {
            return nil
        }
        
        return cellTypes[section].0
    }
    
    
}

extension PostSearchLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if firstTime{
            if status == .denied{
                PublicUtility.hideHUDView()
                AlertViewUtility.showLocationAlertView()
            }
        }
    }
}
