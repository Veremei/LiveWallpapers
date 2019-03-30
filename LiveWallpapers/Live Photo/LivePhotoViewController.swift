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
import MobileCoreServices
import AVFoundation


class LivePhotoViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    fileprivate var isPlayingHint = false
    
     var image: UIImage?
     var imageURL: URL?
     var videoURL: URL?
    
    var urlArray : [String] = ["https://wallpapers.mediacube.games/files/live_photo/43d126e9-7cfc-4bc3-9eab-e92ff7f0bb98/image/IMG.JPG", "https://wallpapers.mediacube.games/files/live_photo/097d1867-54d3-47d9-9b23-2eb40bc09b8e/movie/MOVE.MOV"]
    
    var path = "file:///Users/apple/Library/Developer/CoreSimulator/Devices/891FE93C-F2DA-46A2-B009-7FBD3A536E45/data/Containers/Data/Application/3E7E5F26-26D1-42F5-8DC6-A6C47736D573/Documents/IMG.JPG"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView.delegate = self
        //        livePhotoView.isHidden = true
        setupRecognizers()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startDownload(from: urlArray) { [weak self] success in
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self?.prepareLivePhoto()
                }
                
            } else {
            }
        }
    }
    
    ///////
    func startDownload(from array: [String],completionHandler: @escaping (Bool) -> ()) {
        
        for urlString in array {
            
            let fileUrl = self.getSaveFileUrl(fileName: urlString)
            let destination: DownloadRequest.DownloadFileDestination = { [weak self] _, _ in
                
                if fileUrl.pathExtension == "JPG" {
                    DispatchQueue.main.async {
                        self?.imageURL = fileUrl
                        self?.image = UIImage(contentsOfFile: fileUrl.path)
                        print("OK")
                    }
                } else if fileUrl.pathExtension == "MOV" {
                    self?.videoURL = fileUrl
                    print("OK")

                } else {
                    completionHandler(false)
                }
                
                return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
                
            }
            
            Alamofire.download(urlString, to: destination)
                .downloadProgress { (progress) in
//                    print(progress)
                }
                .responseData { (data) in
                    switch data.result {
                    case .success:
                        print("OK!")
                    case .failure(let error):
                        print(error)
                        completionHandler(false)
                        
                    }
            }
            
        }
        completionHandler(true)
        
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
        makeLivePhotoFromItems()
    }
    
    private func makeLivePhotoFromItems() {
//        private func makeLivePhotoFromItems(completion: @escaping (PHLivePhoto) -> Void) {
        guard let imageURL = self.imageURL, let videoURL = self.videoURL, let image = self.image else { return }
//        PHLivePhoto.request(withResourceFileURLs: [imageURL, videoURL], placeholderImage: image, targetSize: CGSize.zero, contentMode: .aspectFit) {
//            (livePhoto, infoDict) -> Void in
//
//            if let canceled = infoDict[PHLivePhotoInfoCancelledKey] as? NSNumber,
//                canceled == 0,
//                let livePhoto = livePhoto
//            {
        LivePhoto.generate(from: imageURL, videoURL: videoURL, progress: { percent in }, completion: { livePhoto, resources in
            // Display the Live Photo in a PHLivePhotoView
            self.livePhotoView.livePhoto = livePhoto
            // Or save the resources to the Photo library
//            LivePhoto.saveToLibrary(resources)
//            completion(livePhoto)

        })
//            }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        removeItem(itemName: "IMG", fileExtension: "JPG")
        removeItem(itemName: "MOVE", fileExtension: "MOV")
    }
    
    func addAssetID(_ assetIdentifier: String, toImage imageURL: URL, saveTo destinationURL: URL) -> Bool {
        guard let imageDestination = CGImageDestinationCreateWithURL(destinationURL as CFURL, kUTTypeJPEG, 1, nil),
            let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
            var imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [AnyHashable : Any] else { return false }
        let assetIdentifierKey = "17"
        let assetIdentifierInfo = [assetIdentifierKey : assetIdentifier]
        imageProperties[kCGImagePropertyMakerAppleDictionary] = assetIdentifierInfo
        CGImageDestinationAddImageFromSource(imageDestination, imageSource, 0, imageProperties as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        return true
    }
    
    func metadataForAssetID(_ assetIdentifier: String) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        let keyContentIdentifier =  "com.apple.quicktime.content.identifier"
        let keySpaceQuickTimeMetadata = "mdta"
        item.key = keyContentIdentifier as (NSCopying & NSObjectProtocol)?
        item.keySpace = AVMetadataKeySpace(rawValue: keySpaceQuickTimeMetadata)
        item.value = assetIdentifier as (NSCopying & NSObjectProtocol)?
        item.dataType = "com.apple.metadata.datatype.UTF-8"
        return item
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

