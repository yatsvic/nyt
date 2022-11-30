import Foundation
import UIKit

protocol ListViewControllerDelegate: AnyObject {
    func itemTapped(_ sender: ListViewController, doc: Document)
    func itemDetailsTapped(_ sender: ListViewController, doc: Document)
}

struct SectionData {
    let title: String
    let items: [Document]

    // create title for day number
    private static func title(day: Int) -> String {
        return (day == 0) ? "?" : String(day)
    }

    // split large list to show in sections grouped by day
    static func sortedSectionList(documents docs: [Document]) -> [SectionData] {
        // use UTC calendar in order to not get 1 april from 31 march in different time zones
        var cal = Calendar(identifier: Calendar.Identifier.gregorian)
        if let utc = TimeZone(identifier: "UTC") {
            cal.timeZone = utc
        }
        let sects = Dictionary(grouping: docs, by: { doc -> Int in
            doc.pubDate.map { cal.component(.day, from: $0) } ?? 0
        })
        .sorted { $0.0 < $1.0 }
        .map { SectionData(title: SectionData.title(day: $0.0), items: $0.1) }
        return sects
    }
}

final class ListViewController: UITableViewController {
    weak var delegate: ListViewControllerDelegate?

    var infoLabel: UILabel!
    private var caption: String!

    var state = State.loading
    enum State {
        case loading
        case empty
        case data([SectionData])
        case error(String)
    }

    init(monthInfo mi: MonthInfo) {
        let monthSymbols = DateFormatter().standaloneMonthSymbols?[mi.month - 1] ?? String(mi.month)
        caption = "\(monthSymbols) \(mi.year)"
        infoLabel = UILabel()
        infoLabel.textAlignment = .center
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.numberOfLines = 0
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = caption
        setup()
    }

    private func setup() {
        var progress = false
        var infoText: String?
        switch state {
        case .loading:
            progress = true
            infoText = NSLocalizedString("Loading...\n(It can take up to 20 sec)", comment: "load progress")
        case let .error(message):
            infoText = message
        case .empty:
            infoText = NSLocalizedString("Empty", comment: "list")
        case _: break
        }
        if progress {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            let barButton = UIBarButtonItem(customView: activityIndicator)
            navigationItem.rightBarButtonItem = barButton
            activityIndicator.startAnimating()
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        if let text = infoText {
            infoLabel?.text = text
            tableView?.backgroundView = infoLabel
        } else {
            tableView?.reloadData()
            tableView?.backgroundView = nil
        }
    }

    override public func numberOfSections(in _: UITableView) -> Int {
        switch state {
        case let .data(sections): return sections.count
        case _: return 0
        }
    }

    override public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case let .data(sections): return sections[section].items.count
        case _: return 0
        }
    }

    private func getTableCell(tableView: UITableView) -> UITableViewCell {
        let cellId = "cell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId) {
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
            cell.accessoryType = .detailButton
            return cell
        }
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getTableCell(tableView: tableView)
        switch state {
        case let .data(sections):
            let section: SectionData = sections[indexPath.section]
            let doc = section.items[indexPath.row]
            cell.textLabel?.text = doc.headline?.main
            cell.detailTextLabel?.text = doc.byline?.original
        case _:
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
        }
        return cell
    }

    override public func sectionIndexTitles(for _: UITableView) -> [String]? {
        switch state {
        case let .data(sections):
            let temp = sections.map { $0.title }
            return temp
        case _: return nil
        }
    }

    override public func tableView(_: UITableView, sectionForSectionIndexTitle title: String, at _: Int) -> Int {
        switch state {
        case let .data(sections): return sections.firstIndex { $0.title == title } ?? 0
        case _: return 0
        }
    }

    override public func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch state {
        case let .data(sections): return sections[section].title
        case _: return nil
        }
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch state {
        case let .data(sections):
            let section = sections[indexPath.section]
            let doc = section.items[indexPath.row]
            delegate?.itemTapped(self, doc: doc)
        case _: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override public func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch state {
        case let .data(sections):
            let section = sections[indexPath.section]
            let doc = section.items[indexPath.row]
            delegate?.itemDetailsTapped(self, doc: doc)
        case _: break
        }
    }

    func loadResult(result: LoadResult) {
        switch result {
        case let .success(docs):
            let sectionList = SectionData.sortedSectionList(documents: docs)
            DispatchQueue.main.async {
                self.state = sectionList.isEmpty ? .empty : .data(sectionList)
                self.setup()
            }

        case let .failure(err):
            DispatchQueue.main.async {
                self.state = .error(String(format: NSLocalizedString("Error occured:\n %@", comment: "load error"), "\(err.message)"))
                self.setup()
            }
        }
    }
}
