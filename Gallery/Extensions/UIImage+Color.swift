//
//  UIImage+Color.swift
//  Gallery
//
//  Created by Maksym Tkachenko on 26.12.2023.
//

import Foundation
import UIKit

class ColorChanger {
    
    static func replaceColor(image: UIImage) -> UIImage {
        
        // Allocate bitmap in memory with the same width and size as source image
        let imageRef = image.cgImage!
        let width = imageRef.width
        let height = imageRef.height
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width;
        let bitsPerComponent = 8
        let bitmapByteCount = bytesPerRow * height
        
        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapByteCount)
        
        let context = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpace(name: CGColorSpace.genericRGBLinear)!,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        
        
        let rc = CGRect(x: 0, y: 0, width: width, height: height)
        
        // Draw source image on created context
        context!.draw(imageRef, in: rc)
        
        // Prepare to iterate over image pixels
        var byteIndex = 0
        
        while byteIndex < bitmapByteCount {
            
            // Get color of current pixel
            let red = CGFloat(rawData[byteIndex + 0]) / 255
            let green = CGFloat(rawData[byteIndex + 1]) / 255
            let blue = CGFloat(rawData[byteIndex + 2]) / 255
            let alpha = CGFloat(rawData[byteIndex + 3]) / 255
            
            // Red
            //rawData[byteIndex + 0] = r2
            // Green
            rawData[byteIndex + 1] = UInt8(blue * 255)
            // Blue
            rawData[byteIndex + 2] = UInt8(green * 255)
            // Alpha
           // rawData[byteIndex + 3] = a2
            
            
            byteIndex = byteIndex + 4;
        }
        
        // Retrieve image from memory context
        let imgref = context!.makeImage()
        let result = UIImage(cgImage: imgref!)
        
        // Clean up a bit
        rawData.deallocate()
        
        return result
    }
}
