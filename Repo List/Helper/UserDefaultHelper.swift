//
//  UserDefaultHelper.swift
//  Repo List
//
//  Created by Rajiv Puli on 12/08/21.
//

import Foundation

class UserDefaultHelper: NSObject{
    
    static let shared = UserDefaultHelper()
    
    private override init(){}
    
    private let defaults = UserDefaults.standard
    
    func add(value val:String, forKey key:String){
        defaults.set(val, forKey: key)
    }
    
    func addAny(value val:Any, forKey key:String){
        defaults.set(val, forKey: key)
    }
    
    func getValue(forKey key:String) -> String?{
        return defaults.string(forKey: key)
    }
    
    func getValueAsAny(forKey key:String) -> Any?{
        return defaults.value(forKey: key)
    }
    
    func remove(of key:String){
        defaults.removeObject(forKey: key)
    }
}
