//
//  SystemCapability.swift
//  DiscoverMovie
//
//  Created by willsborKang on 2019/3/16.
//  Copyright © 2019 willsborKang. All rights reserved.
//

import Foundation

private var currentSystemUtils: SystemUtils = SystemProvider.shared

func setSystemUtils(_ utils: SystemUtils?) {
    if let utils = utils {
        currentSystemUtils = utils
    } else {
        currentSystemUtils = SystemProvider.shared
    }
}

protocol SystemCapability {}

extension SystemCapability {
    var systemUtils: SystemUtils {
        return currentSystemUtils
    }
}

protocol SystemUtils {
    func getRegion() -> String
    func getLanguage() -> String
    func currentDate() -> Date
}

extension SystemProvider: SystemUtils {}
