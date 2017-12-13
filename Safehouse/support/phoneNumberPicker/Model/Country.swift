//
//  Country.swift
//  PhoneNumberPicker
//
//  Created by Hugh Bellamy on 06/09/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

import Foundation

public func ==(lhs: Country, rhs: Country) -> Bool {
    return lhs.countryCode == rhs.countryCode
}

open class Country: NSObject {
    open static var emptyCountry: Country { return Country(countryCode: "", phoneExtension: "", isMain: true) }
    
    open static var currentCountry: Country {
        if let countryCode = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String {
            return Countries.countryFromCountryCode(countryCode)
        }
        return Country.emptyCountry
    }
    
    open var countryCode: String
    open var phoneExtension: String
    open var isMain: Bool
    
    public init(countryCode: String, phoneExtension: String, isMain: Bool) {
        self.countryCode = countryCode
        self.phoneExtension = phoneExtension
        self.isMain = isMain
    }
    
    @objc open var name: String {
        return (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode) ?? "Invalid country code"
    }
}
