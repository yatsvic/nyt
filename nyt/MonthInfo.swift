import Foundation

struct MonthInfo {
    let year: Int
    let month: Int
    func with(year y: Int) -> MonthInfo {
        return MonthInfo(year: y, month: month)
    }

    func with(month m: Int) -> MonthInfo {
        return MonthInfo(year: year, month: m)
    }
}
