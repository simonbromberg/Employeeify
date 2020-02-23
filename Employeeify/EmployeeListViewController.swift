//
//  EmployeeListViewController.swift
//  Employeeify
//
//  Created by Simon Bromberg on 2020-02-20.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit
import SwiftUI

class EmployeeListViewController: UIViewController, UITableViewDelegate {
    private var employees = [Employee]()

    @IBOutlet var tableView: UITableView!

    private var dataSource: UITableViewDiffableDataSource<Section, Employee>!

    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)

        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()
        getEmployees()
    }

    private func setUpTableView() {
        let diffableDataSource = UITableViewDiffableDataSource<Section, Employee>(tableView: tableView, cellProvider: { (tableView, indexPath, employee) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EmployeeCell
            cell.nameLabel.text = employee.fullName
            cell.teamLabel.text = employee.team
            return cell
        })
        diffableDataSource.defaultRowAnimation = .top

        dataSource = diffableDataSource
        tableView.dataSource = dataSource

        tableView.refreshControl = refreshControl
    }

    private func getEmployees(_ completion: (() -> Void)? = nil) {
        DataProvider.shared.getEmployees { [weak self] (employees, error) in
            guard let strongSelf = self else { return }

            strongSelf.employees = (employees ?? []).sorted(by: { $0.fullName < $1.fullName })
            
            DispatchQueue.main.async {
                strongSelf.reloadTableViewData()
                completion?()
            }
        }
    }

    private func reloadTableViewData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Employee>()
        snapshot.appendSections([Section.employees])
        snapshot.appendItems(employees)
        dataSource.apply(snapshot, animatingDifferences: true)
     }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let employee = employees[indexPath.row]
        if let urlString = employee.photoURLSmall {
            if let image = imageCache[urlString] {
                (cell as? EmployeeCell)?.profileImageView.image = image
                return
            }

            // Image not stored in memory cache
            if let url = URL(string: urlString) {
                DataProvider.shared.getImageData(with: url) { (imageData, error) in
                    DispatchQueue.main.async {
                        if let imageData = imageData,
                            let image = UIImage(data: imageData),
                            let cell = tableView.cellForRow(at: indexPath) as? EmployeeCell {
                            cell.profileImageView.image = image
                            self.imageCache[urlString] = image
                        }
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let detailView = EmployeeDetailView(employee: employees[indexPath.row])
        let vc = UIHostingController(rootView: detailView)

        present(vc, animated: true, completion: nil)
    }

    enum Section {
        case employees
    }

    // MARK: - Memory Caching

    /// Number of seconds to keep images in the application cache
    static let imageLifetime = Double(60 * 60 * 24 * 31)

    /// Maximum number of  images to cache before evicting earlier items to constrain the amount of space used
    static let maxImages = 512

    typealias ImageCache = Cache<String, UIImage>
    private lazy var imageCache: ImageCache = {
        return ImageCache(dateProvider: Date.init, entryLifetime: Self.imageLifetime, maximumEntryCount: Self.maxImages)
    }()

    @objc private func didPullToRefresh() {
        getEmployees { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

