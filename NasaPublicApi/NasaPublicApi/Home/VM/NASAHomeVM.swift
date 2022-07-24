//
//  NASAHomeVM.swift
//  NasaPublicApi
//
//  Created by Chandan Singh on 24/07/22.
//

import Foundation

final class NASAHomeVM {
    
    var modelData: NASADataModel?
    var viewModelUpdated: ((String?) -> Void)?
    
// MARK: Public functions
    func setupViewModel() {
        if modelData == nil {
            fetchData(for: nil)
        } else {
            viewModelUpdated?(nil)
        }
    }
    
    func fetchData(for date: String?) {
        var fetchDate = ""
        if let dateRef = date, !dateRef.isEmpty {
            fetchDate = dateRef
        } else {
            fetchDate = Date().stringDate()
        }
        loadData(for: fetchDate)
    }
}

// MARK: Network Interactions
private extension NASAHomeVM {
    func loadData(for date: String) {
        
        var urlString = "https://api.nasa.gov/planetary/apod?api_key=Oyx6wzmVh6RBkIjyAtFz262RbOblGVXH1ucuLgww"
        urlString.append("&date=\(date)")
        
        let networkService = NSNetwork()
        let url = URL(string: urlString)
        guard let request = networkService.createRequest(url: url) else {
            self.viewModelUpdated?("Something went wrong while connecting to server.")
            return
        }
        networkService.loadData(using: request) { [weak self] (data, response, error) in
            
            guard let `self` = self else { return }
            
            self.modelData = nil
            
            if let errorRef = error {
                // looking for cached data only when error occured, same code can be used if similar handling needed elsewhere
                if let cachedObject = NASAFavouriteManager.shared.getCachedData(date: date) {
                    self.modelData = cachedObject
                    self.viewModelUpdated?(nil)
                    return
                }
                self.viewModelUpdated?(errorRef.localizedDescription)
                return
            }
            
            guard let dataRef = data else {
                self.viewModelUpdated?(error?.localizedDescription ?? "Something went wrong while fetching the data.")
                return
            }
            do {
                self.modelData = try JSONDecoder().decode(NASADataModel.self, from: dataRef)
                self.viewModelUpdated?(nil)
            } catch let errorRef {
                debugPrint(errorRef)
                self.viewModelUpdated?("Something went wrong while processing the data.")
            }
        }
    }
}
