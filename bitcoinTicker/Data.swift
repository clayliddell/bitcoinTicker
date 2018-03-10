//
//  Data.swift
//  bitcoinTicker
//
//  Created by Clay Liddell on 3/6/18.
//  Copyright © 2018 Clay Liddell. All rights reserved.
//

import Foundation
import Disk

struct DataManagement {
    
    static func downloadCoins()
    {
        do {
            let url = URL(string: JSON.pages["coins"]!["list"]!)
            let data = try Data(contentsOf: url!)
            let request = try JSONDecoder().decode(CoinListService.self, from: data)
            
            let content = request.Data.List.sorted { (Int($0.id)!) < (Int($1.id)!) }
            
            try Disk.save(content, to: .caches, as: "coins.json")
        } catch let error as NSError {
            print("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
    static func downloadPrices(fromSymbols: [String]? = nil, toSymbols: [String]? = nil)
    {
        do {
            let defaults = UserDefaults.standard
            
            var urlFromSymbols = [String]()
            
            if let fromSymbols = fromSymbols {
                urlFromSymbols[0] = fromSymbols.joined(separator: ",")
            } else if let coins = retrieveCoins() {
                var i = 0
                urlFromSymbols.append("")
                for coin in coins {
                    if let symbol = coin.symbol {
                        if !(urlFromSymbols[i].count + symbol.count < 300) {
                            urlFromSymbols[i] = String(urlFromSymbols[i].dropLast())
                            urlFromSymbols.append("")
                            i += 1
                        }
                        urlFromSymbols[i] += symbol + ","
                    }
                }
                urlFromSymbols[i] = String(urlFromSymbols[i].dropLast())
            } else {
                urlFromSymbols.append("")
            }
            var urlToSymbols : String
            
            if let toSymbols = toSymbols {
                urlToSymbols = toSymbols.joined(separator: ",")
            } else {
                urlToSymbols = defaults.string(forKey:"nativeCurrency")!
            }
            
            var urlString : String
            var url : URL
            var data : Data
            var request : CoinConversionListService
            var coinConversions = [String : CoinConversion]()
            
            for fsyms in urlFromSymbols {
                urlString = JSON.pages["price"]!["currentPrice"]! + "fsyms=\(fsyms)&tsyms=\(urlToSymbols)"
                url = URL(string: urlString)!
                data = try Data(contentsOf: url)
                request = try JSONDecoder().decode(CoinConversionListService.self, from: data)
                for (symbol, conversion) in request.List {
                    coinConversions[symbol] = conversion
                }
            }
            
            var coins : [Coin]
            
            if !Disk.exists("coins.json", in: .caches)
            {
                downloadCoins()
            }
            
            coins = try Disk.retrieve("coins.json", from: .caches, as: [Coin].self)
            
            for i in 0..<coins.count {
                if let conversion = coinConversions[coins[i].symbol!] {
                    coins[i].price = conversion
                }
            }
            
            try Disk.save(coins, to: .caches, as: "coins.json")
        } catch let error as NSError {
            print("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
    static func downloadImages()
    {
        do {
            var coins : [Coin]
            
            if !Disk.exists("coins.json", in: .caches)
            {
                downloadCoins()
            }
            
            coins = try Disk.retrieve("coins.json", from: .caches, as: [Coin].self)
            
            for coin in coins {
                if let image = downloadImage(forCoin: coin), let symbol = coin.symbol {
                    try Disk.save(image, to: .caches, as: "images/" + symbol + ".png")
                }
            }
            
        } catch let error as NSError {
            print("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
    static func downloadImage(forCoin coin: Coin) -> UIImage?
    {
        var image : UIImage?
        
        if let imgUrl = coin.imgUrl, let url = URL(string: JSON.pages["coins"]!["image"]! + imgUrl), let data = try? Data(contentsOf: url){
            image = UIImage(data: data)
        }
        
        return image
    }
    
    static func retrieveCoins() -> [Coin]?
    {
        var coins : [Coin]?
        
        do {
            if !Disk.exists("coins.json", in: .caches) {
                downloadCoins()
            }
            coins = try Disk.retrieve("coins.json", from: .caches, as: [Coin].self)
        } catch let error as NSError {
            print("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
        
        return coins
    }
}
