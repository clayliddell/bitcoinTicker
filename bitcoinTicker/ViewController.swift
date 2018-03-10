//
//  ViewController.swift
//  bitcoinTicker
//
//  Created by Clay Liddell on 3/6/18.
//  Copyright © 2018 Clay Liddell. All rights reserved.
//

import UIKit
import Disk

class ViewController: UITableViewController, UISearchControllerDelegate {

    let searchController = UISearchController(searchResultsController: nil)
    let favoritesButton = UIBarButtonItem(title: "Favorites", style: .plain, target: nil, action: nil)
    let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: nil, action: nil)
    
    let defaults = UserDefaults.standard
    var coins : [Coin]?
    
    var filteredData : [Coin]? = [Coin]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Filter Coins"
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        navigationItem.leftBarButtonItem = favoritesButton
        navigationItem.rightBarButtonItem = settingsButton
        
        if !isAppAlreadyLaunchedOnce() {
            defaults.set("USD", forKey: "nativeCurrency")
            DataManagement.downloadPrices()
            DataManagement.downloadCoins()
            DataManagement.downloadImages()
        }
        
        if Disk.exists("coins.json", in: .caches), let coins = try? Disk.retrieve("coins.json", from: .caches, as: [Coin].self) {
            self.coins = coins
        }
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(), let data = filteredData {
            return data.count
        } else if let count = coins?.count {
            return count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        
        let coin : Coin?
        
        if isFiltering(){
            coin = filteredData?[indexPath.row]
        } else {
            coin = coins?[indexPath.row]
        }
        
        if let coin = coin {
            cell.textLabel?.text = coin.symbol
            
            if let nativeCurrency = defaults.string(forKey: "nativeCurrency"), let price = coin.price?.Conversions[nativeCurrency] {
                cell.detailTextLabel?.text = nativeCurrency + ": " + String(format:"%.2f", price)
            }
            
            if let coinImage = coin.image {
                cell.imageView?.image = coinImage
            }
        }
        
        return cell
    }
    
    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String) {
        filteredData = coins?.filter({( coin : Coin) -> Bool in
            
            if searchBarIsEmpty() {
                return true
            } else {
                return coin.symbol?.lowercased().contains(searchText.lowercased()) ?? false
            }
        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

}

extension ViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        searchController.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        navigationItem.leftBarButtonItem = favoritesButton
        navigationItem.rightBarButtonItem = settingsButton
        searchController.searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        tableView.reloadData()
    }
}
