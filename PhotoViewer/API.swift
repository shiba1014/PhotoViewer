//
//  FlickrAPI.swift
//  PhotoViewer
//
//  Created by Paul McCartney on 2017/12/14.
//  Copyright © 2017年 Satsuki Hashiba. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import SWXMLHash

class Client: NSObject {
    static let shared = Client()
    func request(method: HTTPMethod = .get, api: API, encoding: ParameterEncoding = URLEncoding.default, headers: [String:String]? = nil) -> SignalProducer<Data, NSError> {
        
        return SignalProducer { observer, lifetime in
            guard let url = URL(string: api.baseURL) else { return observer.sendCompleted() }
            Alamofire.request(url, method: method, parameters: api.parameters, encoding: encoding, headers: headers).response{ response in
                if let error = response.error { return observer.send(error: error as NSError) }
                if let data = response.data {
                    observer.send(value: data)
                }
                observer.sendCompleted()
            }
        }
    }
}

protocol API {
    var baseURL: String { get }
    var parameters: [String: Any] { get }
}

enum FlickrAPI: API {
    case interestingPhotos(count: Int, page: Int)
    
    static let apiKey = "ea6dbbd4596e3988934cfb8d54a5327d"
    
    var baseURL: String {
        return "https://api.flickr.com/services/rest"
    }
    
    var parameters: [String : Any] {
        var params = ["api_key": FlickrAPI.apiKey]
        switch self {
        case .interestingPhotos(let count, let page):
            params["method"] = "flickr.interestingness.getList"
            params["per_page"] = count.description
            params["extras"] = "url_s"
            params["page"] = page.description
            return params
        }
    }
}
