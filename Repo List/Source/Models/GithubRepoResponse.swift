//
//  GithubRepoResponse.swift
//  Repo List
//
//  Created by Rajiv Puli on 10/08/21.
//

import Foundation

class GithubRepoResponse: Decodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Item]?
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

// MARK: - Item
class Item: NSObject, Decodable {
    var id: Int? = nil
    var name: String? = nil
    var fullName: String? = nil
    var owner: Owner? = nil
    var htmlURL: String? = nil
    var contributorsURL: String? = nil
    var createdAt: String? = nil
    var updatedAt: String? = nil
    var pushedAt: String? = nil
    var itemDescription: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case owner
        case htmlURL = "html_url"
        case contributorsURL = "contributors_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pushedAt = "pushed_at"
        case itemDescription = "description"
    }
    
}

// MARK: - Owner
class Owner: NSObject, Decodable {
    var login: String? = nil
    var id: Int? = nil
    var avatarURL: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarURL = "avatar_url"
    }
}
