//
//  NASAFavouriteManager.swift
//  NasaPublicApi
//
//  Created by Chandan Singh on 24/07/22.
//

import Foundation

final class NASAFavouriteManager {
    
    static let favouritesSaveKey = "favouritesSaveKey"
    
    static let shared: NASAFavouriteManager = NASAFavouriteManager()
    private init() {
        loadFavourites()
    }
    
    private(set) var favourites: [NASADataModel] = []
    
// MARK: Private functions
    private func loadFavourites() {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: NASAFavouriteManager.favouritesSaveKey) as? Data,
           let favs = try? JSONDecoder().decode([NASADataModel].self, from: data) {
            favourites = favs
        }
    }
}

// MARK: Public functions
extension NASAFavouriteManager {
    
    func addFavourite(fav: NASADataModel) {
        if favourites.contains(where: { $0.url == fav.url }) == true {
          return
        }
        favourites.append(fav)
        
        if let data = try? JSONEncoder().encode(favourites) {
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: NASAFavouriteManager.favouritesSaveKey)
            defaults.synchronize()
        }
    }

    func removeFavourite(fav: NASADataModel) {
        
        favourites.removeAll{$0.url == fav.url}
        if let data = try? JSONEncoder().encode(favourites) {
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: NASAFavouriteManager.favouritesSaveKey)
            defaults.synchronize()
        }
    }
    
    func isFavourite(fav: NASADataModel) -> Bool {
        if favourites.contains(where: { $0.url == fav.url }) == true {
           return true
        }
        return false
    }
    
    func getCachedData(date: String) -> NASADataModel? {
        return favourites.first(where:{ $0.date == date })
    }
}
