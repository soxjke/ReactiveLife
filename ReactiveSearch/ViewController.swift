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

    public var action : Action<(String, SearchProvider), [SearchResult], NSError>? = nil
    public var provider: SearchProvider? = nil
    
    fileprivate var searchResults: MutableProperty<[SearchResult]> = MutableProperty<[SearchResult]>([])
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
    }
    
    private func setupBindings() {
        searchResults <~
        searchTextField.reactive.continuousTextValues
            .skipNil()
            .debounce(1, on: QueueScheduler())
            .map { [provider] (address) -> (String, SearchProvider) in return (address, provider!) }
            .map(action!.apply)
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
        return searchResults.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MyCell")
        cell = cell ?? UITableViewCell(style: .default, reuseIdentifier: "MyCell")
        cell?.imageView?.image = searchResults.value[indexPath.row].image
        cell?.textLabel?.text = searchResults.value[indexPath.row].title
        return cell!
    }
}
