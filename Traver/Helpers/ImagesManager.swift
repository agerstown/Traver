//
//  ImagesManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 6/1/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

import DFCache
import Nuke

protocol ImageLoader {
    func loadImage(withURL url: String, intoImageView imageView: UIImageView)
}

class ImagesManager: ImageLoader {
    
    static let shared: ImageLoader = ImagesManager()
    
    private let manager: Nuke.Manager
    
    func loadImage(withURL urlStr: String, intoImageView imageView: UIImageView) {
        guard let url = URL(string: urlStr) else {
            assertionFailure("asked to load image for not url convertible string \(urlStr)")
            return
        }
        manager.loadImage(with: url, into: imageView)
    }
    
    init() {
        // Create DFCache instance. It makes sense not to store data in memory cache.
        let cache = DFCache(name: "com.takeaway.CachingDataLoader", memoryCache: nil)
        
        // Create custom CachingDataLoader
        // Disable disk caching built into URLSession
        let conf = URLSessionConfiguration.default
        conf.urlCache = nil
        
        let dataLoader = CachingDataLoader(loader: Nuke.DataLoader(configuration: conf), cache: cache)
        
        // Create Manager which would utilize our data loader as a part of its
        // image loading pipeline
        manager = Manager(loader: Nuke.Loader(loader: dataLoader), cache: Nuke.Cache.shared)
        
    }
    
}

protocol DataCaching {
    func cachedResponse(for request: URLRequest) -> CachedURLResponse?
    func storeResponse(_ response: CachedURLResponse, for request: URLRequest)
}

class CachingDataLoader: DataLoading {
    private let loader: DataLoading
    private let cache: DataCaching
    private let queue = DispatchQueue(label: "com.takeaway.CachingDataLoader")
    
    public init(loader: DataLoading, cache: DataCaching) {
        self.loader = loader
        self.cache = cache
    }
    
    public func loadData(with request: Request, token: CancellationToken?, completion: @escaping (Result<(Data, URLResponse)>) -> Void) {
        queue.async { [weak self] in
            if token?.isCancelling == true {
                return
            }
            let urlRequest = request.urlRequest
            if let response = self?.cache.cachedResponse(for: urlRequest) {
                completion(.success((response.data, response.response)))
            } else {
                self?.loader.loadData(with: request, token: token) {
                    $0.value.map { self?.store($0, for: urlRequest) }
                    completion($0)
                }
            }
        }
    }
    
    private func store(_ val: (Data, URLResponse), for request: URLRequest) {
        queue.async { [weak self] in
            self?.cache.storeResponse(CachedURLResponse(response: val.1, data: val.0), for: request)
        }
    }
}

extension DFCache: DataCaching {
    func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return key(for: request).map(cachedObject) as? CachedURLResponse
    }
    
    func storeResponse(_ response: CachedURLResponse, for request: URLRequest) {
        key(for: request).map { store(response, forKey: $0) }
    }
    
    private func key(for request: URLRequest) -> String? {
        return request.url?.absoluteString
    }
}
