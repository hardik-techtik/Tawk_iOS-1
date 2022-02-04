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


