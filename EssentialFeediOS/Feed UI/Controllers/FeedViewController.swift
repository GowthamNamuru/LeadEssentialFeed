//
//  FeedViewController.swift
//  
//
//  Created by Gowtham Namuru on 18/03/25.
//

import UIKit
import LeadEssentialFeed

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    var tableModel: [FeedImageCellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var viewIsAppearing: ((FeedViewController) -> Void)?
    public var refreshController: FeedRefreshViewController?

    convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = refreshController?.view
        tableView.prefetchDataSource = self

        viewIsAppearing = { vc in
            vc.refreshController?.refresh()
            vc.viewIsAppearing = nil
        }
    }

    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        viewIsAppearing?(self)
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(forRowAt: indexPath)
        return cellController.view()
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellController = cellController(forRowAt: indexPath)
            cellController.preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        tableModel[indexPath.row].cancelLoad()
    }
}
