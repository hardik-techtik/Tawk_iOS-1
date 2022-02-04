//
//  CoreDataManageObject.swift
//  TAWKIOSTask
//
//  Created by Hardik on 04/02/22.
//

import Foundation
import CoreData


@objc(Userlist)

final class Userlist: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var login, type, node_id: String
    @NSManaged var avatar_url : Data
}
extension Userlist {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Userlist> {
        return NSFetchRequest<Userlist>(entityName: "Userlist")
    }
}



@objc(Profile)

final class Profile: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var login, type,company, blog, name, note,followers, following: String
    @NSManaged var avatar_url : Data
}

extension Profile {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }
}
