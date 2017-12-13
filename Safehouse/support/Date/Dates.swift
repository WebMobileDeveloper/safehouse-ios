//
//  Dates.swift
//  Safehouse
//
//  Created by Mobile on 11/13/17.
//  Copyright © 2017 Delicious. All rights reserved.
//

import Foundation
let calendar = Calendar(identifier: .gregorian)

struct CalendarComponentAmount {
    let component: Calendar.Component
    let amount: Int
}

infix operator +: AdditionPrecedence
extension Date {
    
    static func +(date: Date, componentAmount: CalendarComponentAmount) -> Date {
        return calendar.date(byAdding: componentAmount.component,
                             value: componentAmount.amount,
                             to: date)!
    }
}

extension Int {
    
    var years: CalendarComponentAmount {
        return CalendarComponentAmount(component: .year, amount: self)
    }
    
    var months: CalendarComponentAmount {
        return CalendarComponentAmount(component: .month, amount: self)
    }
    
    var days: CalendarComponentAmount {
        return CalendarComponentAmount(component: .day, amount: self)
    }
    
    var hours: CalendarComponentAmount {
        return CalendarComponentAmount(component: .hour, amount: self)
    }
    
    var minutes: CalendarComponentAmount {
        return CalendarComponentAmount(component: .minute, amount: self)
    }
    
    var seconds: CalendarComponentAmount {
        return CalendarComponentAmount(component: .second, amount: self)
    }
}
