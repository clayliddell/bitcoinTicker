//
//  CoinClass.swift
//  bitcoinTicker
//
//  Created by Clay Liddell on 3/6/18.
//  Copyright © 2018 Clay Liddell. All rights reserved.
//

import Foundation
import UIKit
import Disk

struct Coin : Codable {
    let id: String
    let symbol: String?
    let imgUrl: String?
    var price: CoinConversion?
    
    var image : UIImage? {
        var image : UIImage?
        if let symbol = self.symbol {
            if !Disk.exists("images/" + symbol + ".png", in: .caches), self.imgUrl != nil {
                image = DataManagement.downloadImage(forCoin: self)
                try? Disk.save(image, to: .caches, as: "images/" + symbol + ".png")
            } else {
                image = try? Disk.retrieve("images/" + symbol + ".png", from: .caches, as: UIImage.self)
            }
        }
        
         return image
    }
    
    enum CodingKeys : String, CodingKey {
        case imgUrl = "ImageUrl"
        case symbol = "Symbol"
        case id = "SortOrder"
        case price
    }
}

struct CoinListService: Decodable {
    let Response: String?
    let Message: String?
    let BaseImageUrl: String?
    let BaseLinkUrl: String?
    let DefaultWatchlist: DefaultWatchList
    
    struct DefaultWatchList: Decodable {
        let CoinIs: String?
        let Sponsored: String?
    }
    
    var Data: CoinListData
}

struct CoinListData: Decodable {
    
    var List: [Coin]
    
    private struct CodingKeys: CodingKey {
        var intValue: Int?
        var stringValue: String
        
        init?(intValue: Int) { self.intValue = intValue; self.stringValue = "" }
        init?(stringValue: String) { self.stringValue = stringValue }
    }
    
    init(from decoder: Decoder) throws {
        self.List = [Coin]()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        for key in container.allKeys {
            try self.List.append(container.decode(Coin.self, forKey: key))
        }
    }
}

struct DynamicKey: CodingKey {
    
    var stringValue: String
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int? { return nil }
    
    init?(intValue: Int) { return nil }
    
}

extension KeyedEncodingContainer where Key == DynamicKey {
    
    mutating func encodeDynamicKeyValues(withDictionary dictionary: [String : Any]) throws {
        for (key, value) in dictionary {
            let dynamicKey = DynamicKey(stringValue: key)!
            // Following won't work:
            // let v = value as Encodable
            // try propertiesContainer.encode(v, forKey: dynamicKey)
            // Therefore require explicitly casting to the supported value type:
            switch value {
            case let v as String: try encode(v, forKey: dynamicKey)
            case let v as Int: try encode(v, forKey: dynamicKey)
            case let v as Double: try encode(v, forKey: dynamicKey)
            case let v as Float: try encode(v, forKey: dynamicKey)
            case let v as Bool: try encode(v, forKey: dynamicKey)
            default: print("Type \(type(of: value)) not supported")
            }
        }
    }
    
}

struct CoinConversionListService : Codable {
    
    var List: [String : CoinConversion]
    
    private struct CodingKeys: CodingKey {
        var intValue: Int?
        var stringValue: String
        
        init?(intValue: Int) { self.intValue = intValue; self.stringValue = "" }
        init?(stringValue: String) { self.stringValue = stringValue }
    }
    
    init(from decoder: Decoder) throws {
        self.List = [String : CoinConversion]()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        for key in container.allKeys {
            try self.List[key.stringValue] = container.decode(CoinConversion.self, forKey: key)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        for (name, conversion) in List {
            try conversion.encode(to: encoder, forKey: name)
        }
    }
}

struct CoinConversion : Codable {
    var Conversions: [String : Double]
    
    private struct CodingKeys: CodingKey {
        var intValue: Int?
        var stringValue: String
        var dictionaryValue : [String : Double]?
        
        init?(intValue: Int) { self.intValue = intValue; self.stringValue = "" }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(dictionaryValue: [String : Double], stringValue: String) { self.dictionaryValue = dictionaryValue; self.stringValue = stringValue }
        
        static func dict(_ dict: [String : Double], name: String = "") -> CodingKeys? {
            return CodingKeys(dictionaryValue: dict, stringValue: name)
        }
    }
    
    init(from decoder: Decoder) throws {
        self.Conversions = [String : Double]()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        for key in container.allKeys {
            try self.Conversions[key.stringValue] = container.decode(Double.self, forKey: key)
        }
    }
    
    func encode(to encoder: Encoder, forKey key: String) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var propertiesContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: CodingKeys.dict(Conversions, name: key)!)
        try propertiesContainer.encodeDynamicKeyValues(withDictionary: Conversions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        //var propertiesContainer = container.nestedContainer(keyedBy: DynamicKey.self, forKey: CodingKeys.dict(Conversions)!)
        try container.encodeDynamicKeyValues(withDictionary: Conversions)
    }
}
