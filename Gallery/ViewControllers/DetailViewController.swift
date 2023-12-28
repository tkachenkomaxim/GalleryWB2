
import UIKit

class CityDetailViewController: UIViewController {
    
    // MARK: Private
    
    private var isOriginal = true
    private var activityView: UIActivityIndicatorView?
    private var imageWithChangedColors: UIImage?
    
    // MARK: Private
    
    var imageOriginal: UIImage?
    
    // MARK: Outlets
    
    @IBOutlet var detailImageView: UIImageView!

    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: Actions
    
    @IBAction func changeColorTapped(_ sender: Any) {
        guard let image = imageOriginal else {  return }
        
        if isOriginal && imageWithChangedColors != nil {
            
            self.detailImageView.image = imageWithChangedColors
        } else if !isOriginal {
            
            self.detailImageView.image = imageOriginal
        } else {
            
            showActivityIndicator()
            
            let serialQueue = DispatchQueue(label: "serialQueue", qos: .userInitiated)
            
            serialQueue.async {
                let imageCopy = image
                
                let img = ColorChanger.replaceColor(image: imageCopy)
                
                DispatchQueue.main.async {
                    self.imageWithChangedColors = img
                    self.detailImageView.image = self.imageWithChangedColors ?? UIImage()
                    self.hideActivityIndicator()
                }
            }
        }
        
        isOriginal = !isOriginal
    }
    
    // MARK: Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showActivityIndicator()
        
        detailImageView.image = imageOriginal
        
        hideActivityIndicator()
    }
    
    // MARK: Helpers
    
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.detailImageView.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
        }
    }

}
