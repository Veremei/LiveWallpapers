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

struct Links {
    let first: String?
    let last: String?
    let prev: String?
    let next: String?
    
    
    init?(json: [String: Any]) {
        
        let first = json["first"] as? String
        let last = json["last"] as? String
        let prev = json["prev"] as? String
        let next = json["next"] as? String
        
        //self.id = id
        self.first = first
        self.last = last
        self.prev = prev
        self.next = next
    }
    
//    static func getArray(from jsonArray: Any) -> [Photo]? {
//        guard let jsonArray = jsonArray as? Array<[String: Any]> else { return nil }
//        return jsonArray.compactMap { Photo(json: $0) }
//    }
    
}



struct Meta {
    let current_page: String?
    let from: String?
    let last_page: String?
    let path: String?
    let per_page: String?
    let to: String?
    let total: String?

    
    init?(json: [String: Any]) {
        
        let current_page = json["current_page"] as? String
        let from = json["from"] as? String
        let last_page = json["last_page"] as? String
        let path = json["path"] as? String
        let per_page = json["per_page"] as? String
        let to = json["to"] as? String
        let total = json["total"] as? String
        
        self.current_page = current_page
        self.from = from
        self.last_page = last_page
        self.path = path
        self.per_page = per_page
        self.to = to
        self.total = total
    }
    
//    static func getMeta(from jsonArray: Any) -> [Meta]? {
//        guard let jsonArray = jsonArray as? Array<[String: Any]> else { return nil }
//        return jsonArray.compactMap { Meta(json: $0) }
//    }
}

