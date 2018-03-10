//
//  JSONClass.swift
//  bitcoinTicker
//
//  Created by Clay Liddell on 3/6/18.
//  Copyright © 2018 Clay Liddell. All rights reserved.
//

import Foundation

struct JSON {
    static func decodeFromURL(urlString: String) -> [Coin]?
    {
        var content : [Coin]?
        if let url = URL(string: urlString)
        {
            do {
                let data = try Data(contentsOf: url)
                let request = try JSONDecoder().decode(CoinListService.self, from: data)
                let list = request.Data.List
                content = list.sorted { (Int($0.id)!) < (Int($1.id)!) }
            } catch { // FAIL
                print("Error failed to retrieve data from provided URL: ", urlString)
            }
        } else // BAD URL
        {
            print("Error: Bad URL: ", urlString)
            content = nil
        }
        return content;
    }
    
    static let pages: [String:[String:String]] = [
        "price":
            ["currentPrice": "https://min-api.cryptocompare.com/data/pricemulti?",
             "priceHistDay": "https://min-api.cryptocompare.com/data/histoday?",
             "priceHistHour": "https://min-api.cryptocompare.com/data/histohour?",
             "priceHistMinute": "https://min-api.cryptocompare.com/data/histominute?"],
        "coins":
            ["list": "https://www.cryptocompare.com/api/data/coinlist",
             "image": "https://www.cryptocompare.com"]
    ]
    static let rates: [String:[String:Int]] = ["day": ["limit":96, "aggregate":15], "7 day": ["limit":84, "aggregate":2], "month": ["limit":30, "aggregate":1], "year":["limit":52, "aggregate":7]]
    
    static let parameters: [String:[String:String]] = ["price":["fromSymbols": "fsyms=", "toSymbols": "tsyms=", "exchange": "e="]]
}
