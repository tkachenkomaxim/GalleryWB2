//
//  IMGManager.swift
//  Gallery
//
//  Created by Maksym Tkachenko on 26.12.2023.
//

import Foundation
import UIKit

class IMGManager {
    
    // MARK: Private
    
    private var imgStoreManager: IMGStoreManager
    private var imgThumbService: IMGThumbService
    private let queId = "swQueue"
    
    private var imgKeys: [Int] = [Int]()
    private let dataKey = "myGallery123"
    private var workQueue: DispatchQueue?
    
    private (set) var images: [Image] = [Image]()
    
    private var onImageChanges: () -> ()
    
    // MARK: Lifecycle
    
    init(onImageChanges: @escaping () -> ()) {
        
        workQueue = DispatchQueue(label: queId,
                     qos: .default,
                     attributes: .concurrent)
        
        self.onImageChanges = onImageChanges
        
        imgStoreManager = IMGStoreManager()
        imgThumbService = IMGThumbService()
        
        if let savedDataKey = UserDefaults.standard.array(forKey: dataKey) as? [Int]  {
            imgKeys = savedDataKey
        }
        
        readAllFiles()
    }
    
    // MARK: Public
    
    func selectedFile(image: UIImage) {
        
        let hash = image.hashValue
        
        imgThumbService.createThumbnailFor(img: image, scaleTo: 0.25) { [weak self] thumbnail in
            
            guard let self else { return }
            
            let isSavedThumb = self.imgStoreManager.saveImage(image: thumbnail ?? UIImage(), forKey: String(hash))
            
            let isSavedOriginal = self.imgStoreManager.saveImage(image: image, forKey: keyForThumb(hash: hash))
            
            
            if isSavedThumb && isSavedOriginal {
                self.imgKeys.append(hash)
                
                UserDefaults.standard.set(self.imgKeys, forKey: self.dataKey)
            }
            
            self.images.append(Image(image: image, key: hash))
            self.onImageChanges()
        }
    }
    
    func getFullSizeImageFor(imgKey: Int) -> UIImage? {
        
        if let img = imgStoreManager.getSavedImage(named: keyForThumb(hash: imgKey)) {
            return img
        }
        
        return nil
    }
    
    func readAllFiles() {
        var imgs = [Image]()
        
        workQueue?.async { [weak self] in
            guard let self else { return }
            for key in self.imgKeys {
                if let img = self.imgStoreManager.getSavedImage(named: String(key)) {
                    imgs.append(Image(image: img, key: key))
                }
            }
            
            self.images = imgs
            
            self.onImageChanges()
        }
    }
    
    // MARK: Private Helpers
    
    private func keyForThumb(hash: Int) -> String {
        return String(hash) + "OR"
    }
}
