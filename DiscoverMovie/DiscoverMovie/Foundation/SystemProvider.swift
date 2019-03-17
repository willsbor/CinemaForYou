//
//  SystemProvider.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

class SystemProvider {
    static let shared = SystemProvider()
    
    func getRegion() -> String {
        let locale = Locale.current
        let countryCode = locale.regionCode
        return countryCode!
    }
    
    func getLanguage() -> String {
        let langID = Locale.preferredLanguages.first ?? "en"
        let locale = Locale(identifier: langID)
        return locale.languageCode!
    }
    
    func currentDate() -> Date {
        return Date()
    }
    
    func dispatchAfter(_ milliseconds: Int, _ handler: @escaping () -> Void) {
        let t = DispatchTime.now() + .milliseconds(milliseconds)
        DispatchQueue.global().asyncAfter(deadline: t, execute: handler)
    }
}
