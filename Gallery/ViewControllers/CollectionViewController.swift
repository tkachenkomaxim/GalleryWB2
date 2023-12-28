
import UIKit
import PhotosUI

class GalleryCollectionViewController: UICollectionViewController {
    
    // MARK: Private
    
    private let identifier = "showDetail"
    private let reuseId = "dataCell"
    private let queId = "sialQueue"
    
    
    private var imgManager: IMGManager?
    
    private var activityView: UIActivityIndicatorView?
    
    private var workQueue: DispatchQueue?
    
    private var detailedImage: UIImage?
    
    // MARK: Actions
    
    @IBAction func addButtonTapped(_ sender: Any) {
       var config = PHPickerConfiguration()
        config.selectionLimit = 1
        
        let phPickerVC = PHPickerViewController(configuration: config)
        phPickerVC.delegate = self
        
        present(phPickerVC, animated: true)
    }
    
    // MARK: Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        config()
    }
    
    // MARK: Private Helpers
    
    private func config() {
        
        imgManager = IMGManager() {
            DispatchQueue.main.async { [weak self] in
                self?.onImageChanges()
            }
        }
        
        workQueue = DispatchQueue(label: queId,
                     qos: .default,
                     attributes: .concurrent)
    }
    
    private func onImageChanges() {
        showUniversalLoadingView(false)
        self.collectionView.reloadData()
    }
    
    private func didSelectItem(index: Int) {
        
        showUniversalLoadingView(true)
       
        workQueue?.async {
            let image = self.imgManager?.getFullSizeImageFor(imgKey:
                                                                self.imgManager?.images[index].key ?? 0)
            
            DispatchQueue.main.async { [weak self] in

                self?.performSegue(withIdentifier: self?.identifier ?? "", sender: image)
            }
        }
    }
}

// MARK: UICollectionViewDataSource

extension GalleryCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, 
                                 numberOfItemsInSection section: Int) -> Int {
        return imgManager?.images.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, 
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! CityCollectionViewCell
    
        cell.galleryImageView.image = imgManager?.images[indexPath.row].thumb
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, 
                                 didSelectItemAt indexPath: IndexPath) {
        
        didSelectItem(index: indexPath.row)
    }

    override func prepare(for segue: UIStoryboardSegue, 
                          sender: Any?) {
        if segue.identifier == identifier {
            if let indexPaths = collectionView.indexPathsForSelectedItems,
                let image = sender as? UIImage {
                let destinationController = segue.destination as! CityDetailViewController
                
                destinationController.imageOriginal = image
                
                collectionView.deselectItem(at: indexPaths[0], animated: false)
            }
        }
        
        showUniversalLoadingView(false)
    }
}

// MARK: PHPickerViewControllerDelegate

extension GalleryCollectionViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, 
                didFinishPicking results: [PHPickerResult]) {
        
        dismiss(animated: true)
        
        showUniversalLoadingView(true)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    
                    self?.imgManager?.selectedFile(image: image)
                }
            }
        }
    }
}
