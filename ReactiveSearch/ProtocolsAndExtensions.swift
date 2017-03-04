//
//  ProtocolsAndExtensions.swift
//  ReactiveLife
//
//  Created by petr on 3/4/17.
//  Copyright © 2017 CocoaHeadsUkraine. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import CoreLocation
import Alamofire

protocol SearchResult {
    var image: UIImage { get }
    var title: String { get }
}

protocol SearchProvider {
    func search(string: String, completion: @escaping ([SearchResult]?, NSError?) -> ())
}

extension CLPlacemark: SearchResult {
    var image: UIImage {
        return UIImage(named: "icLocation")!
    }
    var title: String {
        var result = ""
        cast(addressDictionary?["FormattedAddressLines"]) { (addressLines: NSArray) in
            result = addressLines.componentsJoined(by: ", ")
        }
        return result
    }
}

class GithubSearchResult: SearchResult {
    var image: UIImage = UIImage(named: "icGithub")!
    var title: String = ""
}

extension CLGeocoder: SearchProvider {
    func search(string: String, completion: @escaping ([SearchResult]?, NSError?) -> ()) {
        self.geocodeAddressString(string) { (placemarks, error) in
            completion(placemarks, error as? NSError)
        }
    }
}

class GithubSearcher: SearchProvider {
    func search(string: String, completion: @escaping ([SearchResult]?, NSError?) -> ()) {
        Alamofire.request(URL(string: "https://api.github.com/search/users?q=\(string)")!).responseJSON { (response) in
            cast(response.result.value) { (dictionary: [String : Any]) in
                var searchResults: [SearchResult] = []
                cast(dictionary["items"]) { (items: [[String : Any]]) in
                    searchResults = items.map { (item) -> SearchResult in
                        let searchResult = GithubSearchResult()
                        searchResult.title = (item["login"] as? String) ?? ""
                        return searchResult
                    }
                }
                completion(searchResults, response.error as? NSError)
            }
        }
    }
}
