//
//  UserListViewcontroller.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation
import CoreData
import UIKit

class UserListViewcontroller: UIViewController {

    
    // MARK: -  IBOutlets 
    @IBOutlet var tblUserList : UITableView!
    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var headerView : UIView!
    let userlistViewModelObj = UserListViewModel()
    
    var currentPage : Int = 0
    var isLoadingList : Bool = false
    var isSearchActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        headerView.dropShadow()
        
        tblUserList.estimatedRowHeight = 100
        tblUserList.rowHeight = UITableView.automaticDimension
        
        NotificationCenter.default.addObserver(
                                   self,
                                   selector: #selector(self.setOfflineData),
            name: NSNotification.Name(rawValue: "InternetConnectionError"),
                                   object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        userlistViewModelObj.arrUserList.removeAll()
        callUserListAPI(page: currentPage)

        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        searchBar.resignFirstResponder()
    }

    //MARK: - User list api call -
    func callUserListAPI(page:Int) {
        if isSearchActive {
            return
        }
        userlistViewModelObj.getUserListFromAPI(page: page) { response in
            if self.isLoadingList == true {
                self.isLoadingList = false
            }
            DispatchQueue.main.async {
                self.tblUserList.reloadData()
            }

        }
    }
    
    func getListFromServer(_ pageNumber: Int){
        self.isLoadingList = false
        self.tblUserList.reloadData()
    }
    
    //MARK:- Load more data using pagination
    func loadMoreItemsForList(page:Int){
        if isLoadingList == true {
            callUserListAPI(page: page)
        }
    }

    // MARK: - set offline data
    @objc func setOfflineData()
    {
        hideLoader()
        showToastMessage(message: Messages.noInternetConnection)
        if userlistViewModelObj.getDataWhileOffline() {
            DispatchQueue.main.async {
                self.tblUserList.reloadData()
            }
        }
    }
}

//MARK:- UItableview delegate & datasource methods
extension UserListViewcontroller : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userlistViewModelObj.arrUserList.count == 0{
            return Utilities.showNoDataFoundLabel(tableview: self.tblUserList, strMsg: "No record found")
        }else{
            tblUserList.backgroundView = nil
            return self.userlistViewModelObj.arrUserList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListNoteTableCell", for: indexPath) as! UserListNoteTableCell
        cell.lblName.text = ""
        cell.lblDetails.text = ""
        cell.imgUser.image = nil
        
        if self.userlistViewModelObj.arrUserList.count > 0{
            let objUser = self.userlistViewModelObj.arrUserList[indexPath.row]
            cell.configureCell(objUser: objUser,index: indexPath.row)
        }
        
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if Reachability.isConnectedToNetwork(){
            //Pagination logic here
            if isLoadingList == false {
                if !(indexPath.row + 1 < self.userlistViewModelObj.arrUserList.count) {
                    self.isLoadingList = true
                    let lastIdPass = self.userlistViewModelObj.arrUserList.last?.id
                    self.loadMoreItemsForList(page: lastIdPass ?? 0)
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let obj = self.userlistViewModelObj.arrUserList[indexPath.row]
            let pVC = Utilities.viewController(name: "ProfileViewcontroller", onStoryBoared: "Main") as! ProfileViewcontroller
            pVC.strName = obj.login ?? ""
            self.navigationController?.pushViewController(pVC, animated: true)
    }
}

//MARK:- UIsearch bar delegate methods
extension UserListViewcontroller : UISearchBarDelegate
{
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.lowercased().count == 0 {
            self.userlistViewModelObj.arrUserList.removeAll()
            isSearchActive = false
            self.userlistViewModelObj.arrUserList = self.userlistViewModelObj.arrFilteredData
            tblUserList.reloadData()
            searchBar.resignFirstResponder()
            return
        }
        self.userlistViewModelObj.arrUserList.removeAll()
        isSearchActive = true
        
        let data = self.userlistViewModelObj.removeDuplicateElements(posts: self.userlistViewModelObj.arrFilteredData)
        self.userlistViewModelObj.arrUserList.removeAll()
        
        self.userlistViewModelObj.arrFilteredData = data
        self.userlistViewModelObj.arrUserList = self.userlistViewModelObj.arrFilteredData.filter({ (user) -> Bool in

                if user.login?.lowercased().range(of:searchText.lowercased()) != nil {

                    return true
                }
                return false
            })
            tblUserList.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
        
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}

