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
    
    let userlistViewModelObj = UserListViewModel()
    
    var currentPage : Int = 1
    var isLoadingList : Bool = false
    var totalPageSize = 10
    var isSearchActive = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        showLoader()
        
        let param : String = "\(page)&per_page=\(totalPageSize)"
        Network.shared.request(router: .getUserList(body: param)) { [self] (result: Result<[UserListModel], ErrorType>) in
            
            hideLoader()
            
                guard let res = try? result.get() else {
                    return
                }

               
                if page == 1 {
                    self.userlistViewModelObj.arrUserList.removeAll()
//                    let arrData = self.removeDuplicateElements(posts: res)
                    userlistViewModelObj.arrUserList = res
                    userlistViewModelObj.arrFilteredData = res
                    self.tblUserList.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.userlistViewModelObj.storeOfflineData()
                    }
                    
                }else{
                    if res.count != 0 {
                        for i in res{
                            print("i.login------\(i.login)")
                            self.userlistViewModelObj.arrUserList.append(i)
                            self.userlistViewModelObj.arrFilteredData.append(i)
                        }
                        self.tblUserList.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.userlistViewModelObj.storeOfflineData()
                        }
                    }else{
                        self.tblUserList.reloadData()
                        showMessage(text: Messages.somethingwentwrong)
                    }
                }
        }
    }
    
    
    
    
    
    func getListFromServer(_ pageNumber: Int){
        self.isLoadingList = false
        self.tblUserList.reloadData()
    }
    
    //MARK:- Load more data using pagination
    func loadMoreItemsForList(){
        currentPage += 1
        callUserListAPI(page: currentPage)
    }

    // MARK: - set offline data
    @objc func setOfflineData()
    {
        hideLoader()
        showToastMessage(message: Messages.noInternetConnection)
        let arrList = self.userlistViewModelObj.loadUserList()
        for i in arrList {
            var obj = UserListModel()
            obj.login = i.login
            obj.type = i.type
            obj.node_id = i.node_id
            obj.avatar_url = nil
            obj.imgData = i.avatar_url
            self.userlistViewModelObj.arrUserList.append(obj)
        }
        self.userlistViewModelObj.arrFilteredData = self.userlistViewModelObj.arrUserList
        self.tblUserList.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableCell", for: indexPath) as! UserListTableCell
        
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
            if !(indexPath.row + 1 < self.userlistViewModelObj.arrUserList.count) {
                self.isLoadingList = true;
                self.loadMoreItemsForList()
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

