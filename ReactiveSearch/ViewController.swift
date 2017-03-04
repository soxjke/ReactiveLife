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
import Result

class ViewController: UIViewController {

    private let geocoder: CLGeocoder = CLGeocoder()
    fileprivate var placemarks: MutableProperty<[CLPlacemark]> = MutableProperty<[CLPlacemark]>([])
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        let geocoding = Action<String, [CLPlacemark], NSError>({ (address) -> SignalProducer<[CLPlacemark], NSError> in
            return SignalProducer<[CLPlacemark], NSError>({ (observer, disposable) in
                self.geocoder.geocodeAddressString(address) { (placemarks, error) in
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
        
        let signal =
        searchTextField.reactive.continuousTextValues
            .skipNil()
            .debounce(1, on: QueueScheduler())
            .map(geocoding.apply)
            .flatten(.latest)
            .skipError()
        
        placemarks <~ signal
        
        self.placemarks.signal.observeValues { [weak self] _ in self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic) }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placemarks.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MyCell")
        cell = cell ?? UITableViewCell(style: .default, reuseIdentifier: "MyCell")
        cell?.imageView?.image = UIImage(named: "icLocation")
        cell?.textLabel?.text = placemarks.value[indexPath.row].formattedAddress
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
