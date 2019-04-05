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
import SPPermission
import Loaf

// Need to organize/review

class LivePhotoViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let isAllowedLibrary = SPPermission.isAllow(.photoLibrary)
        if isAllowedLibrary == true {
            savePhotoToLibrary()
        } else {
            SPPermission.Dialog.request(with: [.photoLibrary], on: self)
            if isAllowedLibrary == true {
                savePhotoToLibrary()
            }
        }
    }
    
    fileprivate var isPlayingHint = false
    var image: UIImage?
    var imageURL: URL?
    var videoURL: URL?
    var urlArray : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView.delegate = self
        livePhotoView.isHidden = true
        saveBarButton.isEnabled = false
        setupRecognizers()
        activityIndicatorView.type = NVActivityIndicatorType.circleStrokeSpin
        activityIndicatorView.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        startDownload(from: urlArray) { [weak self] success in
            if success {
                self?.makeLivePhotoFromItems()
            } else {
                self?.showErrorMessage()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeItem(itemName: "IMG", fileExtension: "JPG")
        removeItem(itemName: "MOVE", fileExtension: "MOV")
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
        let TapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        livePhotoView.addGestureRecognizer(longTapRecognizer)
        livePhotoView.addGestureRecognizer(TapRecognizer)
    }
    
    @objc func handleLongPress(recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            self.livePhotoView.startPlayback(with: .full)
        }
    }
    @objc func handleTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            self.navigationController?.navigationBar.isHidden = !(self.navigationController?.navigationBar.isHidden)!
            self.toolBar.isHidden = !self.toolBar.isHidden
        }
    }
    
    
    private func makeLivePhotoFromItems() {
        guard let imageURL = self.imageURL, let videoURL = self.videoURL, let _ = self.image else { return }
        LivePhoto.generate(from: imageURL, videoURL: videoURL, progress: { percent in }, completion: { [weak self] livePhoto, resources in
            self?.livePhotoView.livePhoto = livePhoto
            self?.activityIndicatorView.stopAnimating()
            self?.livePhotoView.isHidden = false
            self?.saveBarButton.isEnabled = true
            self?.livePhotoView.startPlayback(with: .full)
        })
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
    
    
    func savePhotoToLibrary() {
        guard let imageURL = self.imageURL, let videoURL = self.videoURL, let _ = self.image else { return }
        LivePhoto.generate(from: imageURL, videoURL: videoURL, progress: { percent in }, completion: { _, resources in
            guard let resources = resources else { return }
            
            LivePhoto.saveToLibrary(resources, completion: { (success) in
                if success {
                    print("Saved")
                    DispatchQueue.main.async {
                        Loaf("Wallpaper Saved", state: .success,presentingDirection: .left, dismissingDirection: .vertical, sender: self).show()
                    }
                } else {
                    print("Not saved")
                    DispatchQueue.main.async {
                        Loaf("An error has occured", state: .error , sender: self).show()
                    }
                }
            })
        })
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

