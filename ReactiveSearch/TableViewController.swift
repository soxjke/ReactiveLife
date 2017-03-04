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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.row == 0) {
            let action: Action<(String, CLGeocoder), [CLPlacemark], NSError> = Action({ (address, geocoder) -> SignalProducer<[CLPlacemark], NSError> in
                return SignalProducer<[CLPlacemark], NSError>({ (observer, disposable) in
                    geocoder.geocodeAddressString(address) { (placemarks, error) in
                        if let placemarks = placemarks {
                            observer.send(value: placemarks)
                        }
                        if let error = error {
                            observer.send(error: error as NSError)
                        }
                        observer.sendCompleted()
                    }
                })
            })
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            viewController.action = action
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else if (indexPath.row == 1) {
            
        }
    }
}
