//
//  APIManager.swift
//  Repo List
//
//  Created by Rajiv Puli on 10/08/21.
//

import Foundation

public class APIManager: NSObject{
    
    static var shared = APIManager()
    
    var task: URLSessionDataTask?
    
    private override init(){}
    
    var requestHTTPHeaders = RestEntity()
    var urlQueryParameters = RestEntity()
    var httpBodyParameters = RestEntity()
    
    var httpBody: Data?
    
    private func addURLQueryParameters(toURL url: URL) -> URL {
        if urlQueryParameters.totalValues()! > 0{
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
            
            var queryItems = [URLQueryItem]()
            
            queryItems = urlQueryParameters.allValues().map {
                URLQueryItem(name: $0, value: String(describing: $1))
            }
            
            /*for (key, value) in urlQueryParameters.allValues() {
             let item =
             
             URLQueryItem(name: key, value: String( value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
             
                queryItems.append(item)
            }*/
            urlComponents.queryItems = queryItems
            guard let updatedURL = urlComponents.url else { return url }
            return updatedURL
        }
        return url
    }
    
    private func getHttpBody() -> Data? {
        guard let contentType = requestHTTPHeaders.value(forKey: "Content-Type") else { return nil }
        if contentType.contains("application/json") {
            do{
                return try? JSONSerialization.data(withJSONObject: httpBodyParameters.allValues(), options: [])
            } catch{
                print(error.localizedDescription)
            }
        } else if contentType.contains("application/x-www-form-urlencoded") {
            let bodyString = httpBodyParameters.allValues().map { "\($0)=\(String(describing: ($1 as AnyObject).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))" }.joined(separator: "&")
            return bodyString.data(using: .utf8)
        } else {
            return httpBody
        }
    }
    
    private func prepareRequest(withURL url: URL?, httpBody: Data?, httpMethod: HTTPMethod) -> URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        for (header, value) in requestHTTPHeaders.allValues() {
            request.setValue((value as! String), forHTTPHeaderField: header)
        }
        request.httpBody = httpBody
        return request
    }
    
    func makeRequest(toURL url: URL,
                     withHttpMethod httpMethod: HTTPMethod,
                     completion: @escaping (_ result: Results) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            let targetURL = self?.addURLQueryParameters(toURL: url)
            let httpBody = self?.getHttpBody()
            guard let request = self?.prepareRequest(withURL: targetURL, httpBody: httpBody, httpMethod: httpMethod) else
            {
                completion(Results(withError: CustomError.failedToCreateRequest))
                return
            }
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.timeoutIntervalForRequest = REQUEST_TIME_OUT
            let session = URLSession(configuration: sessionConfiguration)
            self?.task = session.dataTask(with: request) { (data, response, error) in
                completion(Results(withData: data,
                                   response: Response(fromURLResponse: response),
                                   error: error))
            }
            self?.task?.resume()
        }
    }
    
    private func getData(fromURL url: URL, completion: @escaping (_ data: Data?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sessionConfiguration = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfiguration)
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                guard let data = data else { completion(nil); return }
                completion(data)
            })
            task.resume()
        }
    }
    
    func clearAllParameters(){
        requestHTTPHeaders = RestEntity()
        urlQueryParameters = RestEntity()
        httpBodyParameters = RestEntity()
    }
    
    func cancelPrevRequest() {
        if task != nil {
            task?.cancel()
            task = nil
        }
    }
    
}

extension APIManager{
    enum HTTPMethod: String {
        case get
        case post
        case put
        case patch
        case delete
    }
    
    struct Response {
        var response: URLResponse?
        var httpStatusCode: Int = 0
        var headers = RestEntity()
        
        init(fromURLResponse response: URLResponse?) {
            guard let response = response else { return }
            self.response = response
            httpStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            if let headerFields = (response as? HTTPURLResponse)?.allHeaderFields {
                for (key, value) in headerFields {
                    headers.add(value: "\(value)", forKey: "\(key)")
                }
            }
        }
    }
    
    struct Results {
        var data: Data?
        var response: Response?
        var error: Error?
        
        init(withData data: Data?, response: Response?, error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }
        
        init(withError error: Error) {
            self.error = error
        }
    }
    
    enum CustomError: Error {
        case failedToCreateRequest
    }
    
    struct RestEntity {
        
        private var values: [String:Any] = [:]
        
        mutating func add(value: String, forKey key: String){
            values[key] = value
        }
        
        mutating func addAny(value: Any, forKey key: String){
            values[key] = value
        }
        
        mutating func addInt(value: Int, forKey key: String){
            values[key] = value
        }
        
        mutating func remove(forKey: String){
            values.removeValue(forKey: forKey)
        }
        
        func value(forKey: String) -> String? {
            if let val = values[forKey]{
                return (val as! String)
            }
            return nil
        }
        
        func allValues() -> [String:Any]{
            return values
        }
        
        func totalValues() -> Int? {
            return values.count
        }
        
        mutating func append(value:[String:Any]){
            values.merge(value) { (current, _) in current }
        }
        
    }
}

extension APIManager.CustomError: LocalizedError {
    public var localizedDescription: String {
        switch self {
        case .failedToCreateRequest: return NSLocalizedString("Unable to create the URLRequest object", comment: "")
        }
    }
}
