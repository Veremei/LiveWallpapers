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

class LivePhotoViewController: UIViewController {

    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    fileprivate var isPlayingHint = false

    var image: UIImage!
    var imageURL: URL!
    var videoURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        livePhotoView.delegate = self
        setupRecognizers()
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
    
    
    
    
    
    
    
    func createFolder() {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let dataPath = documentsDirectory.appendingPathComponent("FilesFolder")!
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
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

