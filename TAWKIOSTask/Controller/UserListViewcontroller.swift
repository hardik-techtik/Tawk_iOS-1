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
    

    // MARK: -  Variables 
    var arrUserList = [UserListModel]()
    var arrFilteredData = [UserListModel]()
    
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
        
        self.arrUserList.removeAll()
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
        Network.shared.request(router: .getUserList(body: param)) { (result: Result<[UserListModel], ErrorType>) in
            
            hideLoader()
            
                guard let res = try? result.get() else {
                    return
                }

               
                if page == 1 {
                    self.arrUserList.removeAll()
//                    let arrData = self.removeDuplicateElements(posts: res)
                    self.arrUserList = res
                    self.arrFilteredData = res
                    self.tblUserList.reloadData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.storeOfflineData()
                    }
                    
                }else{
                    if res.count != 0 {
                        for i in res{
                            print("i.login------\(i.login)")
                            self.arrUserList.append(i)
                            self.arrFilteredData.append(i)
                        }
                        
//                        let arrData = self.removeDuplicateElements(posts: self.arrUserList)
//                        self.arrFilteredData = arrData
//                        self.arrUserList.removeAll()
//                        self.arrUserList = arrData
                        
//                        self.arrFilteredData = self.arrUserList
                        self.tblUserList.reloadData()
//                        self.storeOfflineData()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.storeOfflineData()
                        }

                    }else{
                        self.tblUserList.reloadData()
                        showMessage(text: Messages.somethingwentwrong)
                    }
                }
        }
    }
    
    
    func removeDuplicateElements(posts: [UserListModel]) -> [UserListModel] {
        var uniquePosts = [UserListModel]()
        for post in posts {
            if !uniquePosts.contains(where: {$0.login == post.login }) {
                uniquePosts.append(post)
            }
        }
        return uniquePosts
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

        let arrList = loadUserList()
        
        for i in arrList {
            var obj = UserListModel()
            obj.login = i.login
            obj.type = i.type
            obj.node_id = i.node_id
            obj.avatar_url = nil
            
            obj.imgData = i.avatar_url
            arrUserList.append(obj)
        }
    
         arrFilteredData = arrUserList
        
        self.tblUserList.reloadData()
    }
    
    
    // MARK: -  Load offline data from coredata 
    func loadUserList() -> [Userlist] {
      
        let context = objAppDelegate.persistentContainer.viewContext

        // 1
        let request: NSFetchRequest<Userlist> = Userlist.fetchRequest()

        do {
            // 3
            let userlist = try context.fetch(request)
            
            return userlist
        }  catch {
            fatalError("This was not supposed to happen")
        }

        return []
    }
    
    // MARK: - Fetch image from url
    func fetchImageFrom(url: String,index:Int) {

        let fileName = "picked\(index).jpg"
        
        let login = arrFilteredData[index].login ?? ""
        let type = arrFilteredData[index].type ?? ""
        let node_id = arrFilteredData[index].node_id ?? ""

        DispatchQueue.global(qos: .userInitiated).async {
            if let imageURL = URL(string: url) {
                if let imageData = try? Data(contentsOf: imageURL) {
                    if let image = UIImage(data: imageData) {
                        // Now lets store it
                        self.storeImageWith(fileName: fileName, image: image,login: login,type: type, node: node_id)
                    }
                }
            }
        }
    }

    // MARK: -  Store image with data 
    func storeImageWith(fileName: String, image: UIImage, login: String, type: String, node: String) {
        if let data = image.jpegData(compressionQuality: 0.5) {
          // Using our extension here
            let documentsURL = FileManager.getDocumentsDirectory()
            let fileURL = documentsURL.appendingPathComponent(fileName)

                do {
                    try data.write(to: fileURL, options: .atomic)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.saveOfflineToCoreData(data: data, login: login, type: type, node: node)
                    }
                }
                catch {
                    print("Unable to Write Data to Disk (\(error.localizedDescription))")
                }
        }
    }
    
    // MARK: -  Save data to coredata database 
    func saveOfflineToCoreData(data:Data, login:String, type: String,node: String)
    {
        let managedContext = objAppDelegate.persistentContainer.viewContext
                
        let user = Userlist(context: managedContext)
        user.login = login
        user.type  = type
        user.avatar_url = data
        user.node_id = node
        objAppDelegate.saveContext()
    }
    
    
    // MARK: -  Store offline data 
    func storeOfflineData(){
        
        if arrFilteredData.count > 0 {
          
            for (i, element) in arrFilteredData.enumerated()
            {
                fetchImageFrom(url: element.avatar_url ?? "", index: i)
            }
        }
    }
    
    
    // MARK: -  Delete user entity table 
    func deleteEntity()
    {
        let managedObjectContext = objAppDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Userlist")

        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false

        do {
            let items = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]

            for item in items {
                managedObjectContext.delete(item)
            }

            // Save Changes
            try managedObjectContext.save()

        } catch {
            // Error Handling
            // ...
        }
        
    }

}

//MARK:- UItableview delegate & datasource methods
extension UserListViewcontroller : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrUserList.count == 0{
            return Utilities.showNoDataFoundLabel(tableview: self.tblUserList, strMsg: "No record found")
        }else{
            tblUserList.backgroundView = nil
            return arrUserList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableCell", for: indexPath) as! UserListTableCell
        
        cell.lblName.text = ""
        cell.lblDetails.text = ""
        cell.imgUser.image = nil
        
        if arrUserList.count > 0{
            let objUser = arrUserList[indexPath.row]
            cell.configureCell(objUser: objUser,index: indexPath.row)
        }
        
        cell.selectionStyle = .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if Reachability.isConnectedToNetwork(){
            //Pagination logic here
            if !(indexPath.row + 1 < self.arrUserList.count) {
                self.isLoadingList = true;
                self.loadMoreItemsForList()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = arrUserList[indexPath.row]
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
            arrUserList.removeAll()
            isSearchActive = false
            arrUserList = arrFilteredData
            tblUserList.reloadData()
            searchBar.resignFirstResponder()
            return
        }
        arrUserList.removeAll()
        isSearchActive = true
        
        let data = removeDuplicateElements(posts: arrFilteredData)
        arrUserList.removeAll()
        
        arrFilteredData = data
            arrUserList = arrFilteredData.filter({ (user) -> Bool in

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

