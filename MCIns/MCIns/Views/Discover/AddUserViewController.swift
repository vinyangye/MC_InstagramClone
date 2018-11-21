//
//  AddUserViewController.swift
//  MCIns
//
//  Created by ye yang on 21/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import UIKit

class AddUserViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var searchBar = UISearchBar()
    var searchbarText = ""
    var userData = [InsUser]()
    
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView?.isHidden = true
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        tableView.register(UINib.init(nibName: "DiscoverSearchPeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscoverSearchPeopleTableViewCell")
        
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

extension AddUserViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchbarText = searchText
        setupData()
    }
    
    
    
}

//tableview
extension AddUserViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchbarText.count == 0{
            let titleLabel = UILabel()
            titleLabel.text = "    Suggested"
            titleLabel.textColor = UIColor.black
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            return titleLabel
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchbarText.count == 0{
            return 40
        }
        return 0.01
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverSearchPeopleTableViewCell", for: indexPath) as! DiscoverSearchPeopleTableViewCell
        cell.user = userData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileUserViewController") as! ProfileUserViewController
        vc.user = userData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
