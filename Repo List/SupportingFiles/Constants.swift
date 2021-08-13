//
//  Constants.swift
//  Repo List
//
//  Created by Rajiv Puli on 10/08/21.
//

import Foundation
import UIKit

let REQUEST_TIME_OUT: TimeInterval = 20
let DELAY_TO_SEND_REQUEST: Double = 0.3
let PAGE_COUNT = 10

let searchKeyForUserDefault = "searchKey"

let repoBaseURL = "https://api.github.com/search/repositories"
let TOKEN = "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"

let imagePlaceHolder = "personPlaceHolder"


enum SearchAPIQueryKeys: String {
    case q
    case type
    case per_page
    case inKey = "in"
    case page
    case accessToken = "access_token"
    case userAgent = "User-Agent"
}

enum SearchAPIQueryValues: String {
    case name
    case Repositories
}

enum ErrorCodes: Int {
    case cancelled = -999
    case noContent = 204
    
    func getDescription() -> String{
        switch self {
        case .noContent:
            return "No content available"
        default:
            return ""
        }
    }
}

enum NetworkStatus {
    case online
    case offline
    
    func getMsg() -> String {
        switch self {
        case .online:
            return "Back online"
        case .offline:
            return "No connection"
        }
    }
    
    func getColor() -> UIColor {
        switch self {
        case .online:
            return .systemGreen
        case .offline:
            return .systemRed
        }
    }
}
