//
//  ProfileViewcontroller.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation
import CoreData
import UIKit

class ProfileViewcontroller: UIViewController {
    
    // MARK: -  IBOutlets 
                  
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblFollowers : UILabel!
    @IBOutlet var lblNavTitle : UILabel!
    @IBOutlet var lblFollowing : UILabel!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblCompany : UILabel!
    @IBOutlet var lblBlog : UILabel!
    @IBOutlet var txtNotes : UITextView!

    
    // MARK: -  Variables 
    var strName = ""
    var objProfile : UserProfileModel?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // flush data
        lblFollowing.text = ""
        lblFollowers.text = ""
        lblBlog.text = ""
        lblCompany.text = ""
        lblName.text = ""
        txtNotes.text = ""
        
        
        lblNavTitle.text = strName
        txtNotes.layer.borderWidth = 0.5
        txtNotes.layer.borderColor = UIColor.lightGray.cgColor
        txtNotes.layer.cornerRadius = 4
        txtNotes.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(
                                   self,
                                   selector: #selector(self.loadOfflineData),
            name: NSNotification.Name(rawValue: "InternetConnectionError"),
                                   object: nil)

        callProfileAPI()
    }
    
    //MARK: - User list api call -
    func callProfileAPI() {
        
        showLoader()
        
        let param : String = "\(strName)"
        Network.shared.request(router: .getUserProfile(body: param)) { (result: Result<UserProfileModel, ErrorType>) in
            
            hideLoader()
            
                guard let res = try? result.get() else {
                    return
                }

            self.objProfile = res
            
            
            self.setData()
        }
    }

    
    // MARK: -  load offline data with predicate 
    @objc func loadOfflineData()
    {
        
        hideLoader()
        showToastMessage(message: Messages.noInternetConnection)
        
        var name = ""
        var blog = ""
        var login = ""
        var company = ""
        var img = Data()
        var note = ""
        var followers = ""
        var following = ""
        
        var predicate: NSPredicate = NSPredicate()
        predicate = NSPredicate(format: "login contains[c] '\(strName)'")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Profile")
        fetchRequest.predicate = predicate
        do {
            let result = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
                        
            for data in result {
                print("data----------\(data)")
                if strName == data.value(forKey: "login") as! String
                {
                    name = data.value(forKey: "name") as! String
                    login = data.value(forKey: "login") as! String
                    note = data.value(forKey: "note") as! String
                    blog = data.value(forKey: "blog") as! String
                    company = data.value(forKey: "company") as! String
                    following = data.value(forKey: "following") as! String
                    followers = data.value(forKey: "followers") as! String
                    img =  data.value(forKey: "avatar_url") as! Data

                    break
                }
            }


        } catch let error as NSError {
            print("Could not fetch. \(error)")
        }

        
        lblName.text = name
        lblBlog.text = blog
        lblCompany.text = company
         
        if followers == ""{
            lblFollowers.text = ""
        }else{
            lblFollowers.text = "Followers: \(followers)"
        }
        
        if following == ""{
            lblFollowing.text = ""
        }else{
            lblFollowing.text = "Followings: \(following)"
        }
        
        txtNotes.text = note

        DispatchQueue.main.async { /// execute on main thread
            self.imgUser.image = UIImage(data: (img) as Data)

        }
    }
    
    // MARK: -  Fetch profile data from coredate 
    private func loadProfileList() -> [Profile] {

        let context = objAppDelegate.persistentContainer.viewContext

        // 1
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()

        do {
            // 3
            let userlist = try context.fetch(request)
            
            return userlist
        }  catch {
            fatalError("This was not supposed to happen")
        }

        return []
    }

    
    // MARK: -  Store offline profile data 
    func storeOfflineData(data:Data){
            

        //We need to create a context from this container
        let managedContext = objAppDelegate.persistentContainer.viewContext
        

            let user = Profile(context: managedContext)

//                 3
            user.login = objProfile?.login ?? ""
            user.blog = objProfile?.blog ?? ""
            user.company = objProfile?.company ?? ""
            user.name = objProfile?.name ?? ""
            user.followers = "\(objProfile?.followers ?? 0)"
            user.following = "\(objProfile?.following ?? 0)"
            user.type  = objProfile?.type ?? ""
        
        if let imageData = imgUser.image?.pngData() {
            user.avatar_url = imageData
        }
    
            user.note = txtNotes.text
        
        objAppDelegate.saveContext()
    }

    
    // MARK: -  set Online data
    func setData()
    {
        lblName.text = objProfile?.name
        lblBlog.text = objProfile?.blog
        lblCompany.text = objProfile?.company
        
        if objProfile?.following != 0{
            lblFollowing.text = "Followings: \(objProfile?.following ?? 0)"
        }else{
            lblFollowing.text = ""
        }
        
        if objProfile?.followers != 0{
            lblFollowers.text = "Followers: \(objProfile?.followers ?? 0)"
        }else{
            lblFollowers.text = ""
        }

        downloadImageAsync(strURL: objProfile?.avatar_url ?? "")
        
    }
    
    // MARK: -  download asynchornous image
    func downloadImageAsync(strURL:String)
    {
        if let url = URL(string: strURL) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.imgUser.image = UIImage(data: data)
                    self.storeOfflineData(data:data)
                }
            }
            
            task.resume()
        }else{
            self.imgUser.image = UIImage(named: "ic_user")
        }
    }

    // MARK: -  button back click
    @IBAction func btnBack(_ sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: -  button save click
    @IBAction func btnSave(_ sender:UIButton)
    {
        updateProfileData()
    }
    
    //MARK: update data with textview note data
    func updateProfileData() {
        
        var managedContext:NSManagedObjectContext!

        managedContext = objAppDelegate.persistentContainer.viewContext

            let entity = NSEntityDescription.entity(forEntityName: "Profile", in: managedContext)
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = entity
        let predicate = NSPredicate(format: "(login = %@)", strName)
            request.predicate = predicate
            do {
                let results =
                    try managedContext.fetch(request)
                let objectUpdate = results[0] as! NSManagedObject
                objectUpdate.setValue(txtNotes.text!, forKey: "note")
                do {
                    try managedContext.save()
                    
                    loadOfflineData()
                }catch let error as NSError {
                    showToastMessage(message: error.description)
                }
            }
            catch let error as NSError {
                showToastMessage(message: error.description)
            }

        }
}
