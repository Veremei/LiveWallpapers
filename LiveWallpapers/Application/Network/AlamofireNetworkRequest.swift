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
//    static var onProgress: ((Double) -> ())?
//    static var completed: ((String) -> ())?
    
    static func sendRequest(url: String, completion: @escaping (_ courses: [Photo])->()) {
        
        guard let url = URL(string: url) else { return }
        
        
        request(url, method: .get).validate().responseJSON { (response) in
            
            switch response.result {
                
            case .success(let value):
                if let array = value as? JSON, let data = array["data"] as? [JSON] {
                    
                    var photos = [Photo]()
                    for dictionary in data {
                        guard let forecast = Photo(json: dictionary) else { continue }
                        photos.append(forecast)
                    }
                    print(photos)
                    completion(photos)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
//    static func downloadImage(url: String, completion: @escaping (_ image: UIImage)->()) {
//
//        guard let url = URL(string: url) else { return }
//
//        request(url).responseData { (responseData) in
//
//            switch responseData.result {
//            case .success(let data):
//                guard let image = UIImage(data: data) else { return }
//                completion(image)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
//    static func responseData(url: String) {
//
//        request(url).responseData { (responseData) in
//
//            switch responseData.result {
//            case .success(let data):
//                guard let string = String(data: data, encoding: .utf8) else { return }
//                print(string)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//
//    static func responseString(url: String) {
//
//        request(url).responseString { (responseString) in
//
//            switch responseString.result {
//            case .success(let string):
//                print(string)
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//
//    static func response(url: String) {
//
//        request(url).response { (response) in
//
//            guard
//                let data = response.data,
//                let string = String(data: data, encoding: .utf8)
//                else { return }
//
//            print(string)
//        }
//    }
    
    //    static func downloadImageWithProgress(url: String, completion: @escaping (_ image: UIImage) -> ()) {
    //
    //        guard let url = URL(string: url) else { return }
    //
    //        request(url)
    //            .validate()
    //            .downloadProgress { (progress) in
    //
    //                print("totalUnitCount: \(progress.totalUnitCount)\n")
    //                print("completedUnitCount:\(progress.completedUnitCount)\n")
    //                print("fractionCompleted:\(progress.fractionCompleted)\n")
    //                print("loclizedDescription:\(progress.localizedDescription!)\n")
    //                print("---------------------------------------------------------")
    //
    //                self.onProgress?(progress.fractionCompleted)
    //                self.completed?(progress.localizedDescription)
    //
    //            }.response { (response) in
    //
    //                guard let data = response.data, let image = UIImage(data: data) else { return }
    //
    //                DispatchQueue.main.async {
    //                    completion(image)
    //                }
    //        }
    //    }
}
