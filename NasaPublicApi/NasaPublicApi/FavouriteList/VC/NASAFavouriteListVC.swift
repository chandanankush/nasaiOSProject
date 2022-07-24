//
//  NSFavouriteListViewController.swift
//  NasaPublicApi
//
//  Created by Chandan Singh on 24/07/22.
//

import UIKit

protocol ViewRefreshRequest: AnyObject {
    func refreshUI()
}

final class NASAFavouriteListVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    weak var delegate: ViewRefreshRequest?
    
// MARK: Override and public functions
    class func instanciate() -> NASAFavouriteListVC? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let homeVC = storyboard.instantiateViewController(identifier: "NASAFavouriteListVC") as? NASAFavouriteListVC {
            return homeVC
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if NASAFavouriteManager.shared.favourites.isEmpty {
            presentAlert(withTitle: "No Data.!", message: "No favourites found", actions: ["Cancel": .destructive] , completionHandler: {[weak self] (action) in
                    if action.title == "Cancel" {
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
        }
    }
}

// MARK: UITableViewDataSource
extension NASAFavouriteListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NASAFavouriteManager.shared.favourites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NASAFavouriteCell {
            let object = NASAFavouriteManager.shared.favourites[indexPath.row]
            cell.configureWithData(data: object)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: UITableViewDelegate
extension NASAFavouriteListVC: UITableViewDelegate {

    private func handleMoveToTrash(index: IndexPath) {
        let object = NASAFavouriteManager.shared.favourites[index.row]
        NASAFavouriteManager.shared.removeFavourite(fav: object)
        
        if NASAFavouriteManager.shared.favourites.isEmpty {
            navigationController?.popViewController(animated: true)
        } else {
            tableView.reloadData()
        }
        delegate?.refreshUI()
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Trash action
        let trash = UIContextualAction(style: .destructive,
                                       title: "Trash") { [weak self] (action, view, completionHandler) in
                                        self?.handleMoveToTrash(index: indexPath)
                                        completionHandler(true)
        }
        trash.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [trash])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let object = NASAFavouriteManager.shared.favourites[indexPath.row]
        if let instance = NASAHomeVC.instanciate() {
            instance.injectModelData(modelData: object)
            self.navigationController?.pushViewController(instance, animated: true)
        }
    }
}
