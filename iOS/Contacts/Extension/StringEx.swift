//
//  StringEx.swift
//  Contacts
//
//  Created by TonnyLi on 23/05/20.
//  Copyright © 2020 tonnysunm. All rights reserved.
//

import Foundation

extension String {
    
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        if #available(iOS 11.0, *) {
            formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        } else {
            formatter.formatOptions =  [.withInternetDateTime]
        }
        return formatter
    }()
    
    private static let systemTimeZoneFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()
    
    var localDateString: String? {
        var trimmedIsoString: String
        if #available(iOS 11.0, *) {
            trimmedIsoString = self
        }else {
            trimmedIsoString = self.replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
        }
        
        guard let date = Self.iso8601Formatter.date(from: trimmedIsoString) else { return nil }
        
        return Self.systemTimeZoneFormatter.string(from: date)
    }
}
