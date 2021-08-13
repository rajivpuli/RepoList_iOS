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
    var isPrevRequestCompleted = true
    
    func callSearchAPI(query name: String, isNewRequest: Bool) {
        searchText = name
        if isNewRequest {
            cancelRequest()
            loadOfflineData(query: searchText)
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
        APIManager.shared.requestHTTPHeaders.add(value: TOKEN,
                                                    forKey: SearchAPIQueryKeys.accessToken.rawValue)
        APIManager.shared.requestHTTPHeaders.add(value: "rajivpuli",
                                                    forKey: SearchAPIQueryKeys.userAgent.rawValue)
        
        APIManager.shared.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            self.isPrevRequestCompleted = true
            self.noMoreRecords.value = false
            if results.error == nil{
                if results.response?.httpStatusCode == 200{
                    if let data = results.data {
                        let decoder = JSONDecoder()
                        do{
                            guard let response = try? decoder.decode(GithubRepoResponse.self, from: data) else { return }
                            self.totalCount = response.totalCount
                            self.pageNumber += 1
                            if isNewRequest {
                                self.repoList = response.items ?? []
                                UserDefaultHelper.shared.add(value: self.searchText, forKey: searchKeyForUserDefault)
                                DBHelper.shared.removeRepoListData()
                                DBHelper.shared.insertRepo(data: self.repoList)
                            } else {
                                if self.repoList.count == 10 {
                                    DBHelper.shared.insertRepo(data: response.items?.suffix(5) ?? [])
                                }
                                self.repoList.append(contentsOf: response.items ?? [])
                            }
                            self.repoListData.value = self.repoList
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
    
    func loadOfflineData(query: String) {
        if let savedKey = UserDefaultHelper.shared.getValue(forKey: searchKeyForUserDefault), savedKey == query {
            let localData = DBHelper.shared.getRepoList()
            self.repoList = localData
            self.repoListData.value = self.repoList
        } else {
//            self.repoList = []
//            self.repoListData.value = self.repoList
        }
    }
    
    func loadMorePages() {
        if totalCount > repoList.count && isPrevRequestCompleted {
            isPrevRequestCompleted = false
//            self.noMoreRecords.value = false
            self.callSearchAPI(query: searchText, isNewRequest: false)
        } else {
            self.noMoreRecords.value = true
        }
    }
    
    func cancelRequest() {
        pageNumber = 1
        APIManager.shared.cancelPrevRequest()
    }
    
    func clearData() {
        pageNumber = 1
        APIManager.shared.cancelPrevRequest()
        self.repoList = []
        self.repoListData.value = self.repoList
        self.noMoreRecords.value = false
    }
    
}
