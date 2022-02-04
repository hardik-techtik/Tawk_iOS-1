//
//  UserListModel.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation

import CoreData

struct UserListModelResponse : Codable {
    let data: [UserListModel]?
}

struct UserListModel : Codable {
    var id: Int?
    var login, avatar_url, url, html_url, followers_url, following_url, gists_url, starred_url, subscriptions_url, organizations_url, repos_url, events_url, received_events_url, type, node_id, gravatar_id: String?
    var imgData : Data?
}



struct UserProfileModelResponse : Codable {
    let data: UserProfileModel?
}

struct UserProfileModel : Codable {
    var id, followers, following: Int?
    var login, avatar_url, url, html_url, followers_url, following_url, gists_url, starred_url, subscriptions_url, organizations_url, repos_url, events_url, received_events_url, type, node_id, gravatar_id,company, blog,name, note: String?
}



// 1
@objc(Userlist)
// 2
final class Userlist: NSManagedObject {
    // 3
    @NSManaged var id: String
    @NSManaged var login, type, node_id: String
    @NSManaged var avatar_url : Data

}


extension Userlist {
    // 4
    @nonobjc class func fetchRequest() -> NSFetchRequest<Userlist> {
        return NSFetchRequest<Userlist>(entityName: "Userlist")
    }
}


// 1
@objc(Profile)
// 2
final class Profile: NSManagedObject {
    // 3
    @NSManaged var id: Int
    @NSManaged var login, type,company, blog, name, note,followers, following: String
    @NSManaged var avatar_url : Data

}


extension Profile {
    // 4
    @nonobjc class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }
}
