//
//  ContributorsResponseModel.swift
//  Repo List
//
//  Created by Rajiv Puli on 11/08/21.
//

import Foundation

// MARK: - ContributorsResponseModel -
class ContributorsResponseModel: Codable {
    let login: String?
    let id: Int?
    let nodeID: String?
    let avatarURL: String?
    let url, htmlURL: String?
    let gistsURL: String?
    let reposURL: String?
    
    enum CodingKeys: String, CodingKey {
        case login, id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case url
        case htmlURL = "html_url"
        case gistsURL = "gists_url"
        case reposURL = "repos_url"
    }
}
