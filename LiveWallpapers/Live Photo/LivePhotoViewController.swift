//
//  LivePhotoViewController.swift
//  LiveWallpapers
//
//  Created by apple on 30/03/2019.
//  Copyright © 2019 DAN. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import Alamofire

class LivePhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    fileprivate var isPlayingHint = false
    
    var image: UIImage!
    var imageURL: URL!
    var videoURL: URL!
    
    var urlArray : [String] = ["https://wallpapers.mediacube.games/files/live_photo/43d126e9-7cfc-4bc3-9eab-e92ff7f0bb98/image/IMG.JPG", "https://wallpapers.mediacube.games/files/live_photo/097d1867-54d3-47d9-9b23-2eb40bc09b8e/movie/MOVE.MOV"]
    
    var path = "file:///Users/apple/Library/Developer/CoreSimulator/Devices/891FE93C-F2DA-46A2-B009-7FBD3A536E45/data/Containers/Data/Application/3E7E5F26-26D1-42F5-8DC6-A6C47736D573/Documents/IMG.JPG"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView.delegate = self
        //        livePhotoView.isHidden = true
        setupRecognizers()
        startDownload(from: urlArray) { _ in
            
            
        }
        
        
    }
    
    ///////
    func startDownload(from array: [String],completionHandler: @escaping (_ error: Error) -> ()) {
        
        for urlString in array {
            
            let fileUrl = self.getSaveFileUrl(fileName: urlString)
            let destination: DownloadRequest.DownloadFileDestination = { [weak self] _, _ in
                
                if fileUrl.pathExtension == "JPG" {
                    DispatchQueue.main.async {
                        self?.imageURL = fileUrl
                        self?.image = UIImage(contentsOfFile: fileUrl.path)
                    }
                } else if fileUrl.pathExtension == "MOV" {
                    self?.videoURL = fileUrl
                }
                
                return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
                
            }
            
            Alamofire.download(urlString, to: destination)
                .downloadProgress { (progress) in
                    print(progress)
                }
                .responseData { (data) in
                    switch data.result {
                    case .success:
                        print("OK!")
                    case .failure(let error):
                        print(error)
                        completionHandler(error)
                        
                    }
            }
            
        }
        
    }
    
    
    func getSaveFileUrl(fileName: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let nameUrl = URL(string: fileName)
        let fileURL = documentsURL.appendingPathComponent((nameUrl?.lastPathComponent)!)
        NSLog(fileURL.absoluteString)
        return fileURL;
    }
    //////
    
    
    func removeItem(itemName:String, fileExtension: String) {
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        let filePath = "\(dirPath)/\(itemName).\(fileExtension)"
        do {
            try fileManager.removeItem(atPath: filePath)
            print("deleted")
        } catch let error as NSError {
            print(error.debugDescription)
        }
        
    }
    
    
    func setupRecognizers() {
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        livePhotoView.addGestureRecognizer(longTapRecognizer)
    }
    
    @objc func handleLongPress(recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            print("\nClicked! Wait for it...\n")
            self.livePhotoView.startPlayback(with: .full)
        }
    }
    
    func prepareLivePhoto() {
        makeLivePhotoFromItems { (livePhoto) in
            self.livePhotoView.livePhoto = livePhoto
            print("\nReady! Click on the LivePhoto in the Assistant Editor panel!\n")
        }
    }
    
    private func makeLivePhotoFromItems(completion: @escaping (PHLivePhoto) -> Void) {
        PHLivePhoto.request(withResourceFileURLs: [imageURL, videoURL], placeholderImage: image, targetSize: CGSize.zero, contentMode: .aspectFit) {
            (livePhoto, infoDict) -> Void in
            
            if let canceled = infoDict[PHLivePhotoInfoCancelledKey] as? NSNumber,
                canceled == 0,
                let livePhoto = livePhoto
            {
                completion(livePhoto)
            }
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        removeItem(itemName: "IMG", fileExtension: "JPG")
        removeItem(itemName: "MOVE", fileExtension: "MOV")
    }
    
}

extension LivePhotoViewController: PHLivePhotoViewDelegate {
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingHint = (playbackStyle == .hint)
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingHint = (playbackStyle == .hint)
    }
}

