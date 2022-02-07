//
//  UserListViewModel.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation
import CoreData
import UIKit

class UserListViewModel {
    
    // MARK: -  Variables 
    var arrUserList = [UserListModel]()
    var arrFilteredData = [UserListModel]()
    
    var totalPageSize = 15

    
    func removeDuplicateElements(posts: [UserListModel]) -> [UserListModel] {
        var uniquePosts = [UserListModel]()
        for post in posts {
            if !uniquePosts.contains(where: {$0.login == post.login }) {
                uniquePosts.append(post)
            }
        }
        return uniquePosts
    }
    func getDataWhileOffline() -> Bool {
        let arrList = self.loadUserList()
        for i in arrList {
            var obj = UserListModel()
            obj.login = i.login
            obj.type = i.type
            obj.node_id = i.node_id
            obj.avatar_url = nil
            obj.imgData = i.avatar_url
            self.arrUserList.append(obj)
        }
        let uniqueArray = self.removeDuplicateElements(posts: self.arrUserList)
        self.arrUserList = uniqueArray
        self.arrFilteredData = uniqueArray
        
        return true
    }
    
    
    func getUserListFromAPI(page:Int,completionHandler: @escaping ((_ response : Bool) -> Void)) {
            showLoader()
            let param : String = "\(page)&per_page=\(totalPageSize)"
            Network.shared.request(router: .getUserList(body: param)) { [self] (result: Result<[UserListModel], ErrorType>) in
                hideLoader()
                    guard let res = try? result.get() else {
                        return
                    }
                    if res.count != 0 {
                        if page == 1 {
                            self.arrUserList.removeAll()
        //                    let arrData = self.removeDuplicateElements(posts: res)
                            arrUserList = res
                            arrFilteredData = res
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                self.storeOfflineData()
                                completionHandler(true)
                            }
                        }else{
                            if res.count != 0 {
                                for i in res{
                                    print("i.login------\(String(describing: i.login))")
                                    self.arrUserList.append(i)
                                    self.arrFilteredData.append(i)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    self.storeOfflineData()
                                    completionHandler(true)
                                }
                            }else{
                                showMessage(text: Messages.somethingwentwrong)
                                completionHandler(true)
                            }
                        }
                        
                    } else {
                        showMessage(text: Messages.somethingwentwrong)
                        completionHandler(false)
                    }
            }
        }
    
}


//--------------- Core Data ---------------

extension UserListViewModel {
    
    // MARK: -  Load offline data from coredata 
    func loadUserList() -> [Userlist] {
        let context = objAppDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<Userlist> = Userlist.fetchRequest()
        do {
            let userlist = try context.fetch(request)
            return userlist
        }  catch {
            fatalError("This was not supposed to happen")
        }
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
    
    // MARK: -  Save data to coredata database 
    func saveOfflineToCoreData(data:Data, login:String, type: String,node: String) {
        let managedContext = objAppDelegate.persistentContainer.viewContext
        let user = Userlist(context: managedContext)
        user.login = login
        user.type  = type
        user.avatar_url = data
        user.node_id = node
        objAppDelegate.saveContext()
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
            fatalError("Data not clear from coredata")
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
    

}
extension UserListViewModel {
    
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
}
