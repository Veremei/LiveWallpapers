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
import NVActivityIndicatorView

class LivePhotoViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    fileprivate var isPlayingHint = false
    
    var image: UIImage?
    var imageURL: URL?
    var videoURL: URL?
    
    var urlArray : [String] = ["https://wallpapers.mediacube.games/files/live_photo/43d126e9-7cfc-4bc3-9eab-e92ff7f0bb98/image/IMG.JPG", "https://wallpapers.mediacube.games/files/live_photo/097d1867-54d3-47d9-9b23-2eb40bc09b8e/movie/MOVE.MOV"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView.delegate = self
        livePhotoView.isHidden = true
        setupRecognizers()
        activityIndicatorView.type = NVActivityIndicatorType.circleStrokeSpin
        activityIndicatorView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startDownload(from: urlArray) { [weak self] success in
            if success {
                self?.prepareLivePhoto()
            } else {
                
            }
        }
    }
    
    
    func startDownload(from array: [String],completionHandler: @escaping (Bool) -> ()) {
        
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
                } else {
                    completionHandler(false)
                }
                
                return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
                
            }
            
            Alamofire.download(urlString, to: destination)
                .downloadProgress { (progress) in }
                .responseData { (data) in
                    switch data.result {
                    case .success:
                        print("OK!")
                    case .failure(let error):
                        completionHandler(false)
                    }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completionHandler(true)
        }
    }
    
    
    func getSaveFileUrl(fileName: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let nameUrl = URL(string: fileName)
        let fileURL = documentsURL.appendingPathComponent((nameUrl?.lastPathComponent)!)
        NSLog(fileURL.absoluteString)
        return fileURL;
    }
    
    
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
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    func setupRecognizers() {
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        longTapRecognizer.minimumPressDuration = 0.2
        livePhotoView.addGestureRecognizer(longTapRecognizer)
    }
    
    @objc func handleLongPress(recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            self.livePhotoView.startPlayback(with: .full)
        }
    }
    
    func prepareLivePhoto() {
        makeLivePhotoFromItems()
    }
    
    private func makeLivePhotoFromItems() {
        guard let imageURL = self.imageURL, let videoURL = self.videoURL, let _ = self.image else { return }
        
        LivePhoto.generate(from: imageURL, videoURL: videoURL, progress: { percent in }, completion: { [weak self] livePhoto, resources in
            self?.livePhotoView.livePhoto = livePhoto
            self?.activityIndicatorView.startAnimating()
            self?.livePhotoView.isHidden = false
            self?.livePhotoView.startPlayback(with: .full)
        })
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

