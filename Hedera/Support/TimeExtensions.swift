import Foundation

public extension Int{
    var seconds : TimeInterval {
        return TimeInterval(self)
    }
    var minutes : TimeInterval {
        return (self * 60).seconds
    }
    var hours : TimeInterval {
        return  (self * 60).minutes
    }
    var days : TimeInterval {
        return (self * 24).hours
    }
    var weeks : TimeInterval {
        return (self * 7).days
    }
    var months : TimeInterval {
        return (self * 30).days
    }
}


public extension Double{
    var seconds : TimeInterval {
        return TimeInterval(self)
    }
    var minutes : TimeInterval {
        return (self * 60).seconds
    }
    var hours : TimeInterval {
        return  (self * 60).minutes
    }
    var days : TimeInterval {
        return (self * 24).hours
    }
    var weeks : TimeInterval {
        return (self * 7).days
    }
    var months : TimeInterval {
        return (self * 30).days
    }
}





extension Date{
    static var now : Date {
        return Date()
    }

    static var today: Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date())
    }

    static var tommorow: Date {
        return .today + 1.days
    }

    static var yesterday: Date {
        return .today - 1.days
    }
}
