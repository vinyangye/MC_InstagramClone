//
//  DateExtension.swift
//  MCIns
//
//  Created by Charles Huang on 19/10/18.
//  Copyright © 2018 MCgroup. All rights reserved.
//

import Foundation

extension Date {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
}
