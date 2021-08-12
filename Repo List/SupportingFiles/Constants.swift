//
//  Constants.swift
//  Repo List
//
//  Created by Rajiv Puli on 10/08/21.
//

import Foundation

let REQUEST_TIME_OUT: TimeInterval = 20
let repoBaseURL = "https://api.github.com/search/repositories"
let PAGE_COUNT = 10
let TOKEN = "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"


enum SearchAPIQueryKeys: String {
    case q
    case type
    case per_page
    case inKey = "in"
    case page
    case accessToken = "access_token"
}

enum SearchAPIQueryValues: String {
    case name
    case Repositories
}

enum ErrorCodes: Int {
    case cancelled = -999
}
