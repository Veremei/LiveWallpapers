//
//  ViewController.swift
//  LiveWallpapers
//
//  Created by apple on 30/03/2019.
//  Copyright © 2019 DAN. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var photos = [Photo]()
    private var detailPhoto : Photo?
    private let url = "https://wallpapers.mediacube.games/api/photos"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataWithAlamofire()
    }
    
    func fetchDataWithAlamofire() {
        
        AlamofireNetworkRequest.sendRequest(url: url) { (photos) in
            self.photos = photos
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    
    private func configureCell(cell: PhotoViewCell, for indexPath: IndexPath) {
        
        let photo = photos[indexPath.item]
        //        cell.imageView.image = photos.image
        
        DispatchQueue.global().async {
            guard let imageUrl = URL(string: photo.image!) else { return }
            print(imageUrl)
            guard let imageData = try? Data(contentsOf: imageUrl) else { return }
            
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: imageData)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let livePhotoVC = segue.destination as? LivePhotoViewController {
            guard let image = detailPhoto?.image,let move = detailPhoto?.movie else { return }
        livePhotoVC.urlArray = [image,move]
        }
    }
}


extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoViewCell
        
        
        configureCell(cell: cell, for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoCell = photos[indexPath.item]
        detailPhoto = photoCell
        performSegue(withIdentifier: "showSegue", sender: photoCell)
    }
}


extension ViewController: UICollectionViewDelegate {
    
    
    //
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //        let course = courses[indexPath.row]
    //
    //        courseURL = course.link
    //        courseName = course.name
    //
    //        performSegue(withIdentifier: "Description", sender: self)
    //    }
}

