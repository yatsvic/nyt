import Foundation
import UIKit

protocol SelDateViewControllerDelegate: AnyObject {
    func dateSelected(_ sender: SelDateViewController, monthInfo: MonthInfo)
}

final class SelDateViewController: UIViewController {
    weak var delegate: SelDateViewControllerDelegate?
    weak var monthPicker: MonthPicker!
    var minMonth = MonthInfo(year: 0, month: 0)
    var maxMonth = MonthInfo(year: 0, month: 0)

    init(minMonth min: MonthInfo, maxMonth max: MonthInfo) {
        minMonth = min
        maxMonth = max
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = NSLocalizedString("NYT Archive", comment: "main title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(goButtonTapped(sender:)))
        let picker = MonthPicker(minMonth: minMonth, maxMonth: maxMonth)
        picker.autoresizingMask = .flexibleWidth
        picker.sizeToFit()

        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.spacing = 10
        stack.frame = view.bounds
        stack.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        stack.addArrangedSubview(picker)

        monthPicker = picker
        view.addSubview(stack)
        view.backgroundColor = .white
        monthPicker.select(monthInfo: maxMonth, animated: false)
    }

    @objc func goButtonTapped(sender _: UIBarButtonItem) {
        guard let picker = monthPicker else { return }
        delegate?.dateSelected(self, monthInfo: picker.selected())
    }
}
