//
//  DetailViewController.swift
//  LiveWallpapers
//
//  Created by Daniel on 4/7/19.
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

class DetailViewController: UIViewController,PHLivePhotoViewDelegate {
    
    @IBOutlet weak var liveView: PHLivePhotoView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let isAllowedLibrary = SPPermission.isAllowed(.photoLibrary)
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
        clearDirectory()
        if liveView == liveView {
        activityIndicatorView.type = NVActivityIndicatorType.circleStrokeSpin
            activityIndicatorView.startAnimating()
            liveView.delegate = self
            liveView.isHidden = true
            saveBarButton.isEnabled = false
            setupRecognizers()
        }
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
        clearDirectory()
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
    
    func clearDirectory() {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for fileURL in fileURLs {
                if fileURL.pathExtension == "MOV" || fileURL.pathExtension == "JPG"  {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch  { print(error) }
    }
    
    func setupRecognizers() {
        let TapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        liveView.addGestureRecognizer(TapRecognizer)
    }

    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            self.navigationController?.navigationBar.isHidden = !(self.navigationController?.navigationBar.isHidden)!
            self.toolBar.isHidden = !self.toolBar.isHidden
        }
    }

    
    private func makeLivePhotoFromItems() {
        guard let imageURL = self.imageURL, let videoURL = self.videoURL, let _ = self.image else { return }
        LivePhoto.generate(from: imageURL, videoURL: videoURL, progress: { percent in }, completion: { [weak self] livePhoto, resources in
            self?.liveView.livePhoto = livePhoto
            self?.liveView.startPlayback(with: .full)
            self?.liveView.isHidden = false
            self?.activityIndicatorView.stopAnimating()
            self?.saveBarButton.isEnabled = true
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

extension DetailViewController {
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingHint = (playbackStyle == .hint)
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        isPlayingHint = (playbackStyle == .hint)
    }
}

