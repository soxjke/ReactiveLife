//
//  ViewController.swift
//  ReactiveSearch
//
//  Created by petr on 3/3/17.
//  Copyright © 2017 CocoaHeadsUkraine. All rights reserved.
//

import UIKit
import CoreLocation
import ReactiveCocoa
import ReactiveSwift

class ViewController: UIViewController {

    private let geocoder: CLGeocoder = CLGeocoder()
    fileprivate var placemarks: [CLPlacemark]? = nil
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        searchTextField.reactive.continuousTextValues.skipNil()
            .debounce(1, on: QueueScheduler()).observeValues { [weak self] (string) in
            self?.geocoder.geocodeAddressString(string) { (placemarks, error) in
                DispatchQueue.main.async { [weak self] in
                    self?.placemarks = placemarks
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placemarks?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MyCell")
        cell = cell ?? UITableViewCell(style: .default, reuseIdentifier: "MyCell")
        cell?.imageView?.image = UIImage(named: "icLocation")
        cell?.textLabel?.text = placemarks?[indexPath.row].formattedAddress
        return cell!
    }
}

extension ViewController: UITableViewDelegate {}

extension CLPlacemark {
    var formattedAddress : String {
        get {
            var result = ""
            cast(addressDictionary?["FormattedAddressLines"]) { (addressLines: NSArray) in
                result = addressLines.componentsJoined(by: ", ")
            }
            return result
        }
    }
}
