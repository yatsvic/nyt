import Foundation
import UIKit

protocol DetailsViewControllerDelegate: AnyObject {
    func openButtonTapped(_ sender: DetailsViewController, document: Document)
}

final class DetailsViewController: UITableViewController {
    struct Section {
        let title: String
        let content: (Document) -> String
    }

    static let sections: [Section] = [
        Section(title: "Headline", content: { $0.headline?.main ?? "" }),
        Section(title: "Original", content: { $0.byline?.original ?? "" }),
        Section(title: "Publication Date", content: { $0.pubDate.map { $0.ISO8601Format() } ?? "" }),
        Section(title: "Source", content: { $0.source ?? "" }),
        Section(title: "Abstract", content: { $0.abstract ?? "" }),
        Section(title: "Snippet", content: { $0.snippet ?? "" }),
    ]

    weak var delegate: DetailsViewControllerDelegate?

    private static let CellId: String = "cell"

    private let doc: Document

    init(document doc: Document) {
        self.doc = doc
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        doc = Document(abstract: nil, headline: nil, byline: nil, pubDate: nil, snippet: nil, source: nil, webUrl: nil)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 32.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: DetailsViewController.CellId)
        navigationItem.title = doc.headline?.main ?? NSLocalizedString("Document Details", comment: "details caption")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(openButtonTapped(sender:)))
    }

    @objc func openButtonTapped(sender _: UIBarButtonItem) {
        delegate?.openButtonTapped(self, document: doc)
    }

    override public func numberOfSections(in _: UITableView) -> Int {
        return DetailsViewController.sections.count
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailsViewController.CellId, for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.frame = cell.bounds
        cell.textLabel?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cell.textLabel?.text = DetailsViewController.sections[indexPath.section].content(doc)
        return cell
    }

    override public func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DetailsViewController.sections[section].title
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
