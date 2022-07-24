//
//  NSNetwork.swift
//  NasaPublicApi
//
//  Created by Chandan Singh on 24/07/22.
//

import Foundation

final class NSNetwork {
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    func createRequest(url: URL?, httpMethod: String? = "GET") -> URLRequest? {
        guard let requestUrl = url else {
            // handle error
            return nil
        }
        // using cache policy to load from cache first
        var request = URLRequest(url: requestUrl, cachePolicy: .returnCacheDataElseLoad)
        request.httpMethod = httpMethod

        return request
    }
    
    func loadData(using request: URLRequest, with completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        
        session.dataTask(with: request) { (data, response, error) in
            if let errorRef = error {
                debugPrint(errorRef)
            }
            if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                if statusCode != 200 {
                    debugPrint("issue with response \(response)")
                }
            }
            
            if let dataRef = data, let dataString = String(data: dataRef, encoding: .utf8) {
                debugPrint(dataString)
            }
           
            
            completion(data, response as? HTTPURLResponse, error)
        }.resume()
    }
}
