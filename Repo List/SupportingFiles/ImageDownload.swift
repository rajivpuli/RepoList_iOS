//
//  ImageDownload.swift
//  Repo List
//
//  Created by Rajiv Puli on 11/08/21.
//


import Foundation
import UIKit
import AVKit

let imageCache = NSCache<AnyObject, AnyObject>()

// MARK: - UIImageView extension
extension UIImageView {
    
    /// This loadThumbnail function is used to download thumbnail image using urlString
    /// This method also using cache of loaded thumbnail using urlString as a key of cached thumbnail.
    func loadThumbnail(urlSting: String, placeHolder: String) {
        guard let url = URL(string: urlSting.trimmingCharacters(in: .newlines)) else { return }
        self.image = UIImage(named: placeHolder)
        
        if let imageFromCache = imageCache.object(forKey: urlSting as AnyObject) {
            self.contentMode = .scaleAspectFill
            self.image = imageFromCache as? UIImage
            return
        }
        Networking.downloadImage(url: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                guard let imageToCache = UIImage(data: data) else { return }
                imageCache.setObject(imageToCache, forKey: urlSting as AnyObject)
                DispatchQueue.main.async {
                    self.contentMode = .scaleAspectFill
                    self.image = UIImage(data: data)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.contentMode = .scaleAspectFit
                    self.image = UIImage(named: placeHolder)
                }
            }
        }
    }
}

/// Result enum is a generic for any type of value
/// with success and failure case
public enum Result<T> {
    case success(T)
    case failure(Error)
}

final class Networking: NSObject {
    
    // MARK: - Private functions
    private static func getData(url: URL,
                                completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    // MARK: - Public function
    public static func downloadImage(url: URL,
                                     completion: @escaping (Result<Data>) -> Void) {
        Networking.getData(url: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async() {
                completion(.success(data))
            }
        }
    }
}
