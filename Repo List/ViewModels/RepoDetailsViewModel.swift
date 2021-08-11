//
//  RepoDetailsViewModel.swift
//  Repo List
//
//  Created by Rajiv Puli on 11/08/21.
//

import Foundation

class RepoDetailsViewModel: NSObject {
    
    var repoObj: Item?
    
    var contributorsData: Observable<[ContributorsResponseModel]?> = Observable(nil)
    var errorMessage: Observable<String?> = Observable(nil)
    
    var contributorsList: [ContributorsResponseModel] = []
    
    func getContributors() {
        
        guard let url = URL(string: repoObj?.contributorsURL ?? "") else{ return }
        APIManager.shared.clearAllParameters()
        
        APIManager.shared.urlQueryParameters.addInt(value: 1,
                                                    forKey: SearchAPIQueryKeys.page.rawValue)
        APIManager.shared.urlQueryParameters.add(value: TOKEN,
                                                    forKey: SearchAPIQueryKeys.accessToken.rawValue)
        
        APIManager.shared.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            if results.error == nil{
                if results.response?.httpStatusCode == 200{
                    if let data = results.data {
                        let decoder = JSONDecoder()
                        do{
                            do {
                                let decodedResponse = try JSONDecoder().decode([ContributorsResponseModel].self, from: data)
                              } catch let jsonError as NSError {
                                print("JSON decode failed: \(jsonError.localizedDescription)")
                              }

                            guard let response = try? decoder.decode([ContributorsResponseModel].self, from: data) else { return }
                            self.contributorsList = response
                            self.contributorsData.value = self.contributorsList
                        }
                    }
                }
                else{
                    self.errorMessage.value = "\(results.response?.httpStatusCode ?? 0)"
                }
            }
            else {
                self.errorMessage.value = results.error?.localizedDescription
            }
        }
    }
    
}
