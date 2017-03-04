//
//  TableViewController.swift
//  ReactiveLife
//
//  Created by petr on 3/4/17.
//  Copyright © 2017 CocoaHeadsUkraine. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import CoreLocation

final class TableViewController: UITableViewController {
    let geocoder = CLGeocoder()
    let githubSearcher = GithubSearcher()
    let action: Action<(String, SearchProvider), [SearchResult], NSError> = Action({ (searchTerm, provider) -> SignalProducer<[SearchResult], NSError> in
        return SignalProducer<[SearchResult], NSError>({ (observer, disposable) in
            provider.search(string: searchTerm) { (results, error) in
                if let results = results {
                    observer.send(value: results)
                }
                if let error = error {
                    observer.send(error: error as NSError)
                }
                observer.sendCompleted()
            }
        })
    })
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        if (indexPath.row == 0) {
            viewController.provider = geocoder
        }
        else if (indexPath.row == 1) {
            viewController.provider = githubSearcher
        }
        viewController.action = action
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
