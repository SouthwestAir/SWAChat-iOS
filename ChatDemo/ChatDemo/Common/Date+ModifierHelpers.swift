//
//  Date+ModifierHelpers.swift
//  SWA Open Source
//

import Foundation

// MARK: - Date Helpers and Modifiers

extension Date {
    
// Usage
//    let dateAt3AM = Date().dateAt(hours: 3, minutes: 0)
//    let tomorrowAt3AM = dateAt3AM.dayAfter.dateAt(hours: 3, minutes: 0)
//    let yesterdayAt3AM = dateAt3AM.dayBefore.dateAt(hours: 3, minutes: 0)
//    let now = Date()
//    var operationalDate = Date().operationalDate
//    operationalDate.airportCode = "DAL"
//
//    print(now.shortDateForPost, operationalDate.shortDateForPost, dateAt3AM, tomorrowAt3AM, yesterdayAt3AM)
    
    public var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    public var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    public var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    public var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    public var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    public var isFirstDayOfMonth: Bool {
        return dayBefore.month != month
    }
    
    public func dateAt(hours: Int, minutes: Int, timeZone: String? = nil) -> Date {
        
        let tz = timeZone ?? "America/Chicago"
        
        // TODO: Fix force unwrap
        let timeZone: TimeZone = TimeZone(identifier: tz) ?? TimeZone.current
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        
        //get the month/day/year components for today's date.
        var dateComponents = calendar.dateComponents( [.year, .month, .day], from: self)
        
        //Create an NSDate for the specified time today.
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        
        let newDate = calendar.date(from: dateComponents)!
        //newDate.airportCode = self.airportCode
        
        return newDate
    }
}
