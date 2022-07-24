//
//  ViewController.swift
//  NasaPublicApi
//
//  Created by Chandan Singh on 24/07/22.
//

import UIKit

final class NASAHomeVC: UIViewController {
    
    fileprivate var viewModel = NASAHomeVM()
    
    @IBOutlet var loader: UIActivityIndicatorView! // used for main data load
    @IBOutlet var imageLoader: UIActivityIndicatorView! // used for image load
    var favouriteButton: UIButton! // navigation bar right button to add remove favourites
    var tapGestureRecognizer: UITapGestureRecognizer! // navigation title gesture for showing date selection
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var copywriteLabel: UILabel!
    @IBOutlet var nasaImageView: UIImageView!
    @IBOutlet weak var nasaImageViewHeight: NSLayoutConstraint? // used to update imageview size based upon image aspect
    private var barButtonNeeded = true
    
// MARK: Override and public functions
    class func instanciate() -> NASAHomeVC? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(identifier: "NASAHomeVC") as? NASAHomeVC {
            return homeVC
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewModelUpdated = { [weak self] (errorMessage) in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                self.loader.stopAnimating()
                if let errorMessageRef = errorMessage {
                    self.showError(errorMessageRef)
                } else {
                    self.updateUI()
                }
            }
        }
        configureUI()
        viewModel.setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let guesture = tapGestureRecognizer  { // adding gesture in viewwill appear
            self.navigationController?.navigationBar.addGestureRecognizer(guesture)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let guesture = tapGestureRecognizer  { // date selection gesture is only available on home page not when view is re-used
            self.navigationController?.navigationBar.removeGestureRecognizer(guesture)
        }
    }
    
    // This fucntion will be used when same controller is reused from favourites list, will help same data to be load which is already cached
    func injectModelData(modelData: NASADataModel) {
        viewModel.modelData = modelData
        barButtonNeeded = false
    }
}

// MARK: Private functions
private extension NASAHomeVC {
    func configureUI() {
        if barButtonNeeded {
            self.title = Date().stringDate()
            favouriteButton = UIButton(type: .system)
            favouriteButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            favouriteButton.addTarget(self, action: #selector(addToFavouriteClicked), for: .touchUpInside)
            let rightButtonItem = UIBarButtonItem(customView: favouriteButton)
            self.navigationItem.rightBarButtonItem = rightButtonItem
            
            let letfButtonItem = UIBarButtonItem.init(barButtonSystemItem: .bookmarks, target: self, action: #selector(favouriteListClicked))
            self.navigationItem.leftBarButtonItem = letfButtonItem
            updateFavouriteIcon()
            
            tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.navigationBarTapped(_:)))
            tapGestureRecognizer.cancelsTouchesInView = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        resetData()
    }
    
    // change imageview size when device rotated
    @objc func rotated() {
        let heightRef = nasaImageView.estimatedHeight()
        nasaImageViewHeight?.constant = heightRef
    }
    
    func fetchData() {
        loader.startAnimating()
        resetData()
        viewModel.fetchData(for: self.title)
    }
    
    @objc func addToFavouriteClicked() {
        
        guard let modelDataObject = viewModel.modelData else { return }
        if NASAFavouriteManager.shared.isFavourite(fav: modelDataObject) {
            NASAFavouriteManager.shared.removeFavourite(fav: modelDataObject)
        } else {
            NASAFavouriteManager.shared.addFavourite(fav: modelDataObject)
        }
        updateFavouriteIcon()
    }
    
    @objc func favouriteListClicked() {
        if let favouriteVC = NASAFavouriteListVC.instanciate() {
            favouriteVC.delegate = self
            navigationController?.pushViewController(favouriteVC, animated: true)
        }
    }
    
    func resetData() {
        titleLabel.text = ""
        descriptionLabel.text = ""
        copywriteLabel.text = ""
        nasaImageView.image = nil
    }
    
    func updateUI() {
        if let modelData = viewModel.modelData {
            self.title = modelData.date
            titleLabel.text = modelData.title
            descriptionLabel.text = modelData.explanation
            copywriteLabel.text = "copywrite @\(modelData.copyright ?? "")"
            
            imageLoader.startAnimating()
            self.nasaImageViewHeight?.constant = 100
            nasaImageView.imageFromURL(urlString: modelData.url) {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    let heightRef = self.nasaImageView.estimatedHeight()
                    self.nasaImageViewHeight?.constant = heightRef
                    self.imageLoader.stopAnimating()
                }
            }
            if barButtonNeeded {
                updateFavouriteIcon()
            }
            
        } else {
            resetData()
        }
    }
    
    func updateFavouriteIcon() {
        guard let modelDataObject = viewModel.modelData else { return }
        if NASAFavouriteManager.shared.isFavourite(fav: modelDataObject) {
            let selectedImage = UIImage(named: "heartFilled_black")
            favouriteButton.setImage(selectedImage, for: .normal)
        } else {
            let deselectedImage = UIImage(named: "heart")
            favouriteButton.setImage(deselectedImage, for: .normal)
        }
    }
    
    func showError(_ errorMessage: String) {
        resetData()
        presentAlert(withTitle: "Error.!!", message: errorMessage, actions: [
            "Retry" : .default, "Cancel": .destructive] , completionHandler: {[weak self] (action) in
                if action.title == "Retry" {
                    self?.fetchData()
                }
            })
    }
}

// MARK: Date Picker Design and handling
private extension NASAHomeVC {
    // Action called when navigation bar is tapped anywhere
    @objc func navigationBarTapped(_ sender: UITapGestureRecognizer){
        let location = sender.location(in: self.navigationController?.navigationBar)
        let hitView = self.navigationController?.navigationBar.hitTest(location, with: nil)
        
        guard !(hitView is UIControl) else { return }
        
        showDatePicker(hitView!)
    }
    
    func showDatePicker(_ sender: UIView) {
        let datePicker = UIDatePicker()//Date picker
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.date = self.title?.toDate() ?? Date()
        let datePickerSize = CGSize(width: 320, height: 216) //Date picker size
        datePicker.frame = CGRect(x: 0, y: 0, width: datePickerSize.width, height: datePickerSize.height)
        datePicker.datePickerMode = .date
        datePicker.minuteInterval = 5
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let popoverView = UIView()
        popoverView.backgroundColor = UIColor.clear
        popoverView.addSubview(datePicker)
        
        let popoverViewController = UIViewController()
        popoverViewController.view = popoverView
        popoverViewController.view.frame = CGRect(x: 0, y: 0, width: datePickerSize.width, height: datePickerSize.height)
        popoverViewController.modalPresentationStyle = .popover
        popoverViewController.preferredContentSize = datePickerSize
        popoverViewController.popoverPresentationController?.sourceView = sender // source button
        popoverViewController.popoverPresentationController?.sourceRect = sender.bounds // source button bounds
        popoverViewController.popoverPresentationController?.delegate = self // to handle popover delegate methods
        self.present(popoverViewController, animated: true, completion: nil)
    }
    
    @objc func dateChanged(_ datePicker: UIDatePicker) {
        let selectedSringDate = datePicker.date.stringDate()
        self.title = selectedSringDate
    }
}

// MARK: PopOver delegate for DatePicker
extension NASAHomeVC: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        fetchData()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

// MARK: UIRefresh Protocol
extension NASAHomeVC: ViewRefreshRequest {
    // Fucntion to be used when favourites are deleted from favourite list VC
    func refreshUI() {
        updateUI()
    }
}
