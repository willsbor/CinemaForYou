//
//  ImageManager.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/17.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class ImageManager {
    
    static let shared = ImageManager()
    
    let imageCache: NSCache<AnyObject, AnyObject>
    let urlSession: URLSession
    
    init(_ sessionConfiguration: URLSessionConfiguration = .default) {
        urlSession = URLSession(configuration: sessionConfiguration)
        imageCache = NSCache<AnyObject, AnyObject>()
        imageCache.totalCostLimit = 30
    }
    
    func loadImageURL(_ url: URL, _ completionHandler: @escaping (_ imageData: Data?) -> Void) -> URLSessionTask? {
        if let cache = imageCache.object(forKey: url.path as AnyObject), let imageData = cache as? Data {
            DispatchQueue.global().async {
                completionHandler(imageData)
            }
            return nil
        } else {
            let task = urlSession.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    completionHandler(nil)
                    return
                }
                
                guard let status = (response as? HTTPURLResponse)?.statusCode else {
                    completionHandler(nil)
                    return
                }
                
                guard status == 200 else {
                    completionHandler(nil)
                    return
                }
                
                if let data = data {
                    self.imageCache.setObject(data as AnyObject, forKey: url.path as AnyObject)
                } else {
                    print("")
                }
                
                completionHandler(data)
            }
            task.resume()
            return task
        }
    }
}
