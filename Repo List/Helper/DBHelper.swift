//
//  DBHelper.swift
//  Repo List
//
//  Created by Rajiv Puli on 11/08/21.
//

import Foundation
import CoreData
import UIKit

public class DBHelper: NSObject {
    
    static var shared = DBHelper()
    private var managedContext: NSManagedObjectContext!
    
    private override init() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            managedContext = appDelegate.persistentContainer.viewContext
        }
    }
    
    func instantiate() {}
    
    func insertRepo(data: [Item]) {
        if let repoListEntity = NSEntityDescription.entity(forEntityName: "RepoList", in: managedContext) {
            for obj in data {
                let repo = NSManagedObject(entity: repoListEntity, insertInto: managedContext)
                repo.setValue(obj.name, forKey: Item.CodingKeys.name.rawValue)
                repo.setValue(obj.owner?.avatarURL, forKey: Owner.CodingKeys.avatarURL.rawValue)
                repo.setValue(obj.contributorsURL, forKey: Item.CodingKeys.contributorsURL.rawValue)
                repo.setValue(obj.htmlURL, forKey: Item.CodingKeys.htmlURL.rawValue)
                repo.setValue(obj.id, forKey: Item.CodingKeys.id.rawValue)
                repo.setValue(obj.owner?.login, forKey: Owner.CodingKeys.login.rawValue)
                repo.setValue(obj.itemDescription, forKey: "repoDescription")
            }
            do {
                try managedContext.save()
            } catch let error as NSError{
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
    
    func getRepoList() -> [Item]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RepoList")
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [RepoList] {
                var response = [Item]()
                for obj in result {
                    let responseItem = Item()
                    responseItem.name = obj.name
                    responseItem.owner = .init()
                    responseItem.owner?.avatarURL = obj.avatar_url
                    responseItem.owner?.login = obj.login
                    responseItem.contributorsURL = obj.contributors_url
                    responseItem.htmlURL = obj.html_url
                    responseItem.id = Int(obj.id)
                    responseItem.itemDescription = obj.repoDescription
                    response.append(responseItem)
                }
                return response
            }
            return []
        } catch let error as NSError{
            print("Could not retrieve \(error), \(error.userInfo)")
        }
        return []
    }
    
    func removeRepoListData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RepoList")
        do {
            if let result = try managedContext.fetch(fetchRequest) as? [RepoList] {
                for obj in result {
                    managedContext.delete(obj)
                }
                try managedContext.save()
            }
        } catch let error as NSError{
            print("Could not delete \(error), \(error.userInfo)")
        }
    }
    
}
