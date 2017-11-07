//
//  GoogleAPIProvider.swift
//  Chatlover
//
//  Created by Mac on 07.11.2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import Foundation
import MapKit

class GoogleAPIProvider {
    static var addressBuffor: [String : String] = [:]
    
    /// Get address from location
    ///
    /// - Parameters:
    ///   - coordinate: Location from which you want to get address
    ///   - completionHandler: if success then String address, otherwise error
    class func getAddress(from coordinate: CLLocationCoordinate2D, completionHandler: @escaping (Result<String>) -> Void) {
        // Check if address is saved in buffor
        let bufforKey = "\(coordinate.latitude)/\(coordinate.longitude)"
        if let savedAddress = addressBuffor[bufforKey] {
            completionHandler(Result.success(savedAddress))
        } else { // Googl API Request
            request(urlString: "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinate.latitude),\(coordinate.longitude)&key=AIzaSyDd6740Ogb_OfXrtxbKSG2FoIeobAino8g", completionHandler: { (result) in
                switch result {
                case .success(let dict):
                    if let resultsDictArray = (dict["results"] as! NSArray).firstObject as? [String : Any], let address = resultsDictArray["formatted_address"] as? String {
                        DispatchQueue.main.async {
                            completionHandler(Result.success(address))
                        }
                    }
                case .failure(let error):
                    let apiError = APIError(localizedDescription: error.localizedDescription)
                    completionHandler(Result.failure(apiError))
                }
            }).resume()
        }
    }
}

// MARK: Helper function
extension GoogleAPIProvider {
    
    /// Wrapped request
    ///
    /// - Parameters:
    ///   - urlString: String with url
    ///   - completionHandler: Dict if success otherwise Error
    /// - Returns: URLSessionDataTask
    fileprivate class func request(urlString: String, completionHandler: @escaping (Result<[String : Any]>) -> Void) -> URLSessionDataTask {
        let url = URL(string: urlString)!
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                let apiError = APIError(localizedDescription: NSLocalizedString("_mapGoogleRequestDataError", comment: ""))
                completionHandler(Result.failure(apiError))
                return
            }
            
            do {
                let any = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let dict = any as! [String : Any]
                completionHandler(Result.success(dict))
            } catch {
                let apiError = APIError(localizedDescription: NSLocalizedString("_mapGoogleRequestParseError", comment: ""))
                completionHandler(Result.failure(apiError))
            }
        }
        return task
    }
}
