//
//  Error+Extension.swift
//  Repo List
//
//  Created by Rajiv Puli on 11/08/21.
//

import Foundation

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
