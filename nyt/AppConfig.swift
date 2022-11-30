import Foundation

public enum AppConfig {
    static let minMonth = MonthInfo(year: 1852, month: 1)
    static func maxMonth() -> MonthInfo {
        let d = Date()
        let c = Calendar.current
        return MonthInfo(year: c.component(.year, from: d), month: c.component(.month, from: d))
    }

    static let nytApiKey: String = ???

    static func jsonURL(monthInfo mi: MonthInfo) -> URL {
        let stringURL = "https://api.nytimes.com/svc/archive/v1/\(mi.year)/\(mi.month).json?api-key=\(nytApiKey)"
        return URL(string: stringURL)!
    }
}
