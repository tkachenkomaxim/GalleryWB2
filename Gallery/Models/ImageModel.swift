

import Foundation
import UIKit

struct Image {
    var thumb: UIImage
    var key: Int
    
    init(image: UIImage, key: Int) {
        self.thumb = image
        self.key = key
    }
}
