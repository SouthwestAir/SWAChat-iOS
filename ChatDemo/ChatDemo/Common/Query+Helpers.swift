//
//  Query+Helpers.swift
//  SWA Open Source
//

import Foundation
import FirebaseFirestore

extension Query {
    
    public func whereField(_ field: String, isDateInToday date: Date, timeZone: String = "America/Chicago") -> Query {
        
        let start: Date
        let end: Date
        
        let selfAtMidnight = date.dateAt(hours: 0, minutes: 0)
        //selfAtMidnight.airportCode = date.airportCode
        
        let selfAt3AM = date.dateAt(hours: 3, minutes: 0)
        //selfAt3AM.airportCode = date.airportCode
        
        // Between 12:00am today and 3:00am today
        if date >= selfAtMidnight && date < selfAt3AM {
            start =  selfAt3AM.dayBefore.dateAt(hours: 3, minutes: 0)
            end =  selfAt3AM
        } else {
            start =  selfAt3AM
            end =  selfAt3AM.dayAfter.dateAt(hours: 3, minutes: 0)
        }
        
        return whereField(field, isGreaterThan: start).whereField(field, isLessThan: end)
    }
}
