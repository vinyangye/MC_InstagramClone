//
//  DiscoverSearchUserViewController.swift
//  MCIns
//
//  Created by ye yang on 29/9/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit
import TwicketSegmentedControl
import GooglePlaces

class DiscoverSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var controlView: UIView!
    
    
    var searchBar = UISearchBar()
    var segementedControl = TwicketSegmentedControl()
    
    let titles = ["People", "Places"]
    
    var searchbarText = ""
    var userData = [InsUser]()
    var otherData = [InsUser]() //temp
    
    var locationManager:CLLocationManager?
    var firstTime = true
    var currentSearchData = [GMSPlace]()
    var recentLocation = [GMSPlace]()
    var currentLocation = [PostLocation]()
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
        didSelect(0)
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
        segementedControl.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30)
        segementedControl.setSegmentItems(titles)
        segementedControl.delegate = self
        controlView.addSubview(segementedControl)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView?.isHidden = true
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        tableView.register(UINib.init(nibName: "DiscoverSearchPeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscoverSearchPeopleTableViewCell")
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.requestWhenInUseAuthorization()
        
        
        if CLLocationManager.authorizationStatus() == .notDetermined{
            firstTime = true
        }else{
            firstTime = false
        }
        for cellClass in  cellClasses {
            tableView.register(UINib(nibName: cellClass, bundle: nil), forCellReuseIdentifier: cellClass)
        }
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
    
    @objc func cancelBtnTapped(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupData() {
        if searchbarText.count == 0{
            userData = UserUtility.getSuggestedUser()
            tableView.reloadData()
        }else{
            userData = UserUtility.getSearchUser(searchText: searchbarText)
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupData()
        tableView.reloadData()

    }
    
    
}

extension DiscoverSearchViewController: TwicketSegmentedControlDelegate{
    
    func didSelect(_ segmentIndex: Int) {
        switch segementedControl.selectedSegmentIndex
        {
        case 0:
            
            setupData()
            
        case 1:
            
            tableView.reloadData()
            
        default:
            break;
        }
    }
}

//search
extension DiscoverSearchViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchbarText = searchText
        switch segementedControl.selectedSegmentIndex
        {
        case 0:
            setupData()
            
        case 1:
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
            
        default:
            break;
        }
        
    }
    
    
    
}

//tableview
extension DiscoverSearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segementedControl.selectedSegmentIndex
        {
        case 0:
            return userData.count
        case 1:
            return cellTypes[section].1.count
            
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch segementedControl.selectedSegmentIndex
        {
        case 0:
            return 1
        case 1:
            return cellTypes.count
            
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if segementedControl.selectedSegmentIndex == 0{
            if searchbarText.count == 0{
                let titleLabel = UILabel()
                titleLabel.text = "    Suggested"
                titleLabel.textColor = UIColor.black
                titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
                return titleLabel
            }
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if segementedControl.selectedSegmentIndex == 0{
            if searchbarText.count == 0{
                return 40
            }
        }
        return 0.01
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if segementedControl.selectedSegmentIndex == 0{
            return nil
        }else{
            if section == 0 {
                return nil
            }
            
            if cellTypes[section].1.count == 0 {
                return nil
            }
            
            return cellTypes[section].0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if segementedControl.selectedSegmentIndex == 0{
            return 0.1
        }else{
            return 10
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segementedControl.selectedSegmentIndex
        {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverSearchPeopleTableViewCell", for: indexPath) as! DiscoverSearchPeopleTableViewCell
            cell.user = userData[indexPath.row]
            return cell
        case 1:
            let cellType = cellTypes[indexPath.section].1[indexPath.row]
            
            switch cellType{
                
            case .editSearchLocationCurrentLocation:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostCurrentLoactionTableViewCell", for: indexPath) as! PostCurrentLoactionTableViewCell
                cell.postCurrentLocationLabel.text = "Nearest Location"
                return cell
                
            case .editSearchLocation:
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostSearchLoactionTableViewCell", for: indexPath) as! PostSearchLoactionTableViewCell
                let placeData = self.currentSearchData[indexPath.row]
                
                
                cell.textLabel!.text = placeData.name
                cell.detailTextLabel?.text = placeData.formattedAddress
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                return cell
            }
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        switch segementedControl.selectedSegmentIndex
        {
        case 0:
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileUserViewController") as! ProfileUserViewController
            vc.user = userData[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let cellType = cellTypes[indexPath.section].1[indexPath.row]
            
            switch cellType{
                
            case .editSearchLocationCurrentLocation:
                let vc = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "DiscoverNearestLocationViewController") as! DiscoverNearestLocationViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            case .editSearchLocation:
                //locationName:String, locationAddress:String,
                
                let loc = self.transformInsLocation(place: self.currentSearchData[indexPath.row])
                
                let vc = UIStoryboard(name: "Discover", bundle: nil).instantiateViewController(withIdentifier: "DiscoverLocationPostViewController") as! DiscoverLocationPostViewController
                vc.place = loc
                self.navigationController?.pushViewController(vc, animated: true)
                
                break
            }
            
        default:
            return
        }
        
    }
    
}


extension DiscoverSearchViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if firstTime{
            if status == .denied{
                PublicUtility.hideHUDView()
                AlertViewUtility.showLocationAlertView()
            }
        }
    }
    
    
}
