import Foundation
import UIKit

final class GUIController: NSObject, SelDateViewControllerDelegate, ListViewControllerDelegate, DetailsViewControllerDelegate {
    var window: UIWindow!
    weak var navigationController: UINavigationController!

    func initRootComponents() {
        let selDateViewController = SelDateViewController(minMonth: AppConfig.minMonth, maxMonth: AppConfig.maxMonth())
        selDateViewController.delegate = self
        let rootNC = UINavigationController(rootViewController: selDateViewController)
        rootNC.navigationBar.isTranslucent = false
        navigationController = rootNC
        window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.green
        window.rootViewController = rootNC
        window.makeKeyAndVisible()
    }

    func openDocInBrowser(doc: Document) {
        guard let url = doc.webUrl else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func dateSelected(_: SelDateViewController, monthInfo: MonthInfo) {
        let listViewController = ListViewController(monthInfo: monthInfo)
        listViewController.delegate = self

        let url = AppConfig.jsonURL(monthInfo: monthInfo)

        print(url)

        navigationController?.pushViewController(listViewController, animated: true)

        DispatchQueue.global().async {
            listViewController.loadResult(result: DocumentsLoader.load(url: url))
        }
    }

    func itemTapped(_: ListViewController, doc: Document) {
        openDocInBrowser(doc: doc)
    }

    func itemDetailsTapped(_: ListViewController, doc: Document) {
        print(doc)
        let detailsViewController = DetailsViewController(document: doc)
        detailsViewController.delegate = self
        navigationController?.pushViewController(detailsViewController, animated: true)
    }

    func openButtonTapped(_: DetailsViewController, document: Document) {
        openDocInBrowser(doc: document)
    }
}
