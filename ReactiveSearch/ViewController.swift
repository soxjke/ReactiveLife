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

    private let geocoding = Action<(String, CLGeocoder), [CLPlacemark], NSError>({ (address, geocoder) -> SignalProducer<[CLPlacemark], NSError> in
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
    
    private let geocoder: CLGeocoder = CLGeocoder()
    fileprivate var placemarks: MutableProperty<[CLPlacemark]> = MutableProperty<[CLPlacemark]>([])
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        placemarks <~
        searchTextField.reactive.continuousTextValues
            .skipNil()
            .debounce(1, on: QueueScheduler())
            .map { [geocoder] (address) -> (String, CLGeocoder) in return (address, geocoder) }
            .map(geocoding.apply)
            .flatten(.latest)
            .skipError()
            .on(value: { [weak self] _ in self?.reload() })
    }
    
    private func reload() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
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
