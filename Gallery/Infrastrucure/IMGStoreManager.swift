//
//  IMGStoreManager.swift
//  Gallery
//
//  Created by Maksym Tkachenko on 26.12.2023.
//

import Foundation
import UIKit

class IMGStoreManager {
    
    // MARK: Private
    
    private let ext = ".jpeg"
    
    // MARK: Public
    
    func saveImage(image: UIImage, forKey: String) -> Bool {
        
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(forKey + ext)!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named + ext).path)
        }
        return nil
    }

}

