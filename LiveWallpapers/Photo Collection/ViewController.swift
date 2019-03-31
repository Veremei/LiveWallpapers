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
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        let photo = photos[indexPath.item]
        
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.collectionView.frame.width / 3, height: self.collectionView.frame.height / 6 * 5)
//
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
}
//extension
