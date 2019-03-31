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
    
    let semaphore = DispatchSemaphore(value: 1)
    
    var image: UIImage?
    var imageURL: URL?
    var videoURL: URL?
    
    var urlArray : [String] = []
    
    
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
                self?.showErrorMessage()
            }
        }
    }
    
    
    func startDownload(from array: [String],completionHandler: @escaping (Bool) -> ()) {
        var downloads = 0 {
            didSet {
                if downloads == 2 {
                    completionHandler(true)
                }
            }
        }
        
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
                .downloadProgress { (progress) in
                }.responseData { (data) in
                    switch data.result {
                    case .success:
                        downloads += 1
                    case .failure:
                        completionHandler(false)
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
    
    
    func popThisView() {
        self.dismiss(animated: false, completion: nil)
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    
    func showErrorMessage() {
        let alertController = UIAlertController(title: "Loading error",
                                                message: "Try again",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{ (alertOKAction) in
            self.popThisView()
        }))
        self.present(alertController, animated: true, completion: nil)
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

