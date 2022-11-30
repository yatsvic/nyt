import Foundation
import UIKit

final class MonthPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    var min: MonthInfo = .init(year: 0, month: 0)
    var max: MonthInfo = .init(year: 0, month: 0)
    var row: MonthInfo = .init(year: 0, month: 0)

    func countMonths() -> Int {
        var m = 12
        if row.year == 0 {
            m -= min.month - 1
        } else if row.year == max.year - min.year {
            m = max.month
        }
        return m
    }

    func countYears() -> Int {
        return max.year - min.year + 1
    }

    func monthString(row mr: Int) -> String {
        let r = row.year == 0 ? mr + min.month - 1 : mr
        return DateFormatter().standaloneMonthSymbols[r]
    }

    func yearString(row yr: Int) -> String {
        return String(min.year + yr)
    }

    init(minMonth min: MonthInfo, maxMonth max: MonthInfo) {
        super.init(frame: CGRectZero)
        delegate = self
        dataSource = self
        self.min = min
        self.max = max
        row = MonthInfo(year: 0, month: 0)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func select(monthInfo mi: MonthInfo, animated: Bool) {
        row = MonthInfo(year: mi.year - min.year, month: mi.month - 1)
        selectRow(row.year, inComponent: 0, animated: animated)
        selectRow(row.month, inComponent: 1, animated: animated)
    }

    func selected() -> MonthInfo {
        return MonthInfo(
            year: row.year + min.year,
            month: row.year == 0 ? min.month + row.month : row.month + 1
        )
    }

    func refreshMonths() {
        if row.month >= countMonths() {
            row = row.with(month: countMonths() - 1)
        }
        reloadComponent(1)
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return countYears()
        case 1: return countMonths()
        default: return 0
        }
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return yearString(row: row)
        case 1: return monthString(row: row)
        default: return ""
        }
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            self.row = self.row.with(year: row)
            refreshMonths()
        case 1: self.row = self.row.with(month: row)
        default: break
        }
        print("\(yearString(row: self.row.year)) \(monthString(row: self.row.month))")
    }
}
