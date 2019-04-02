//
//  ViewController.swift
//  LiveWallpapers
//
//  Created by apple on 30/03/2019.
//  Copyright © 2019 DAN. All rights reserved.
//

import UIKit
import Nuke
import SPPermission

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func previousPageButton(_ sender: UIBarButtonItem) {
                    guard let linkPrev = links?.prev else {return}
        url = linkPrev
    }
    
    @IBAction func nextPageButton(_ sender: UIBarButtonItem) {
                    guard let linkNext = links?.next else {return}
        url = linkNext

    }
    
    
    
    private var photos = [Photo]()
    private var meta : Meta?
    private var links : Links?
    private var detailPhoto : Photo?
    
    private var url = "https://wallpapers.mediacube.games/api/photos?page=1" {
        didSet {
//            guard let linkNext = links?.next else {return}
//            guard let linkPrev = links?.prev else {return}
            fetchDataWithAlamofire()


        }
    }

    var cellWidth: CGFloat = UIScreen.main.bounds.width / 3 - 4
    var cellHeight: CGFloat = UIScreen.main.bounds.height / 3.5
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataWithAlamofire()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isAllowedLibrary = SPPermission.isAllow(.photoLibrary)
        if isAllowedLibrary == false {
            SPPermission.Dialog.request(with: [.photoLibrary], on: self)
        }
    }
    
    func fetchDataWithAlamofire() {
        AlamofireNetworkRequest.sendRequest(url: url) { [weak self] (photos,meta,links)  in
            self?.photos = photos
            self?.meta = meta
            self?.links = links
//            self?.downloadGroup.notify(queue: DispatchQueue.main) {
print(links)
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
//            }
            }
        }
    }
    
    private func configureCell(cell: PhotoViewCell, for indexPath: IndexPath) {
        let photo = photos[indexPath.item]
        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageUrl = URL(string: photo.image!) else { return }
            DispatchQueue.main.async {
                let options = ImageLoadingOptions(
                    transition: .fadeIn(duration: 0.7)
                )
                let request = ImageRequest(
                    url: imageUrl,
                    targetSize: CGSize(width: self.cellWidth, height: self.cellHeight),
                    contentMode: .aspectFill)
                Nuke.loadImage(with: request,options: options, into: cell.imageView)
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




extension ViewController: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        return CGSize(width: cellWidth, height: cellHeight )

    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 2, bottom: 0, right: 0)
    }
    
}

