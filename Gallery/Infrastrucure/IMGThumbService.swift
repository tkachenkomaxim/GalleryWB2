//
//  IMGThumbService.swift
//  Gallery
//
//  Created by Maksym Tkachenko on 26.12.2023.
//

import Foundation
import UIKit

class IMGThumbService {
    
    // MARK: Public
    
    func createThumbnailFor(
        img: UIImage,
        scaleTo scaleValue: CGFloat,
        completion: @escaping (_ thumbnail: UIImage?) -> Void
    ) {
        return DispatchQueue.global(qos: .background).async {
            // Get the image data.
            guard let imageData = img.jpegData(compressionQuality: 1) else {
                completion(nil)
                return
            }
            
            // Create an image source object using the image data.
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil) else {
                completion(nil)
                return
            }
            
            // Specify the thumbnail size.
            let thumbnailSize = max(img.size.width, img.size.height) * scaleValue
            
            // Create a dictionary with the minimum recommended options.
            let options = [
                kCGImageSourceThumbnailMaxPixelSize: thumbnailSize,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true
            ] as CFDictionary
            
            // Generate the thumbnail.
            guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) else {
                completion(nil)
                return
            }
            
            // Create a UIImage representation of the thumbnail
            // and pass it to the completion handler.
            completion(UIImage(cgImage: thumbnail))
        }
    }
}
