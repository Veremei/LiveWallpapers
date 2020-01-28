//
//  AlamofireNetworkRequest.swift
//  LiveWallpapers
//
//  Created by apple on 30/03/2019.
//  Copyright © 2019 DAN. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireNetworkRequest {
    typealias JSON = [String: AnyObject]
    
    static func sendRequest(url: String, completion: @escaping (_ photos: [Photo],_ meta: Meta, _ links: Links)->()) {
        
        guard let url = URL(string: url) else { return }
        
        
        request(url, method: .get).validate().responseJSON { (response) in
            
            switch response.result {
                
            case .success(let value):
                guard let array = value as? JSON,
                    let data = array["data"] as? [JSON],
                    let metaData = array["meta"] as? JSON,
                    let linksData = array["links"] as? JSON else { return }
                    
                    var photos = [Photo]()
                    let meta = Meta(json: metaData)
                    let links = Links(json: linksData)
                    
                    for dictionary in data {
                        guard let forecast = Photo(json: dictionary) else { continue }
                        photos.append(forecast)
                    }
                    print(photos)
                completion(photos,meta!,links!)
            case .failure(let error):
                print(error)
            }
        }
    }

}
