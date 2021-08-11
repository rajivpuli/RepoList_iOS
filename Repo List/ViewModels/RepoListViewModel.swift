//
//  RepoListViewModel.swift
//  Repo List
//
//  Created by Rajiv Puli on 10/08/21.
//

import Foundation

class RepoListViewModel: NSObject {
    
    var repoListData: Observable<[Item]?> = Observable(nil)
    var errorMessage: Observable<String?> = Observable(nil)
    var noMoreRecords: Observable<Bool?> = Observable(nil)
    
    var repoList: [Item] = []
    var totalCount = 0
    var pageNumber = 1
    var searchText = ""
    var selectedRepo: Item?
    
    func callSearchAPI(query name: String, isNewRequest: Bool) {
        searchText = name
        if isNewRequest {
            cancelRequest()
        }
        
        guard let url = URL(string: repoBaseURL) else{ return }
        APIManager.shared.clearAllParameters()
        
        APIManager.shared.urlQueryParameters.add(value: name,
                                                 forKey: SearchAPIQueryKeys.q.rawValue)
        APIManager.shared.urlQueryParameters.add(value: SearchAPIQueryValues.name.rawValue,
                                                 forKey: SearchAPIQueryKeys.inKey.rawValue)
        APIManager.shared.urlQueryParameters.add(value: SearchAPIQueryValues.Repositories.rawValue,
                                                 forKey: SearchAPIQueryKeys.type.rawValue)
        APIManager.shared.urlQueryParameters.addInt(value: PAGE_COUNT,
                                                    forKey: SearchAPIQueryKeys.per_page.rawValue)
        APIManager.shared.urlQueryParameters.addInt(value: pageNumber,
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
                                let decodedResponse = try JSONDecoder().decode(GithubRepoResponse.self, from: data)
                              } catch let jsonError as NSError {
                                print("JSON decode failed: \(jsonError.localizedDescription)")
                              }

                            
                            guard let response = try? decoder.decode(GithubRepoResponse.self, from: data) else { return }
                            self.totalCount = response.totalCount
                            self.pageNumber += 1
                            if isNewRequest {
                                self.repoList = response.items ?? []
                                self.repoListData.value = self.repoList
                            } else {
                                self.repoList.append(contentsOf: response.items ?? [])
                                self.repoListData.value = self.repoList
                            }
                        }
                    }
                }
                else{
                    self.errorMessage.value = "\(results.response?.httpStatusCode ?? 0)"
                }
            }
            else {
                switch results.error?.code {
                case ErrorCodes.cancelled.rawValue:
                    break
                default:
                    self.errorMessage.value = results.error?.localizedDescription
                }
            }
        }
    }
    
    func loadMorePages() {
        if totalCount > repoList.count {
            self.noMoreRecords.value = false
            self.callSearchAPI(query: searchText, isNewRequest: false)
        } else {
//            self.noMoreRecords.value = true
        }
    }
    
    func cancelRequest() {
        pageNumber = 1
        APIManager.shared.cancelPrevRequest()
    }
    
}
