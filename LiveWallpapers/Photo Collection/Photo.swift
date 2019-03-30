//
//  Photo.swift
//  LiveWallpapers
//
//  Created by apple on 30/03/2019.
//  Copyright © 2019 DAN. All rights reserved.
//

import Foundation


struct DataFromURL {
    let photo: [Photo]
//    let links: Links
//    let meta: Meta
}

struct Photo: Decodable {
    
    //let id: String?
    let image: String?
    let movie: String?
    
    
    init?(json: [String: Any]) {
        
        //let id = json["id"] as? String
        let image = json["image_path"] as? String
        let movie = json["movie_path"] as? String
        
        //self.id = id
        self.image = image
        self.movie = movie
    }
    
    static func getArray(from jsonArray: Any) -> [Photo]? {
        
        guard let jsonArray = jsonArray as? Array<[String: Any]> else { return nil }
        return jsonArray.compactMap { Photo(json: $0) }
        
    }
}
