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
    @IBOutlet var messageLabel: UILabel!

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
        messageLabel.text = NSLocalizedString("Loading…", comment: "Employee list loading message")
        messageLabel.isHidden = false

        DataProvider.shared.getEmployees { [weak self] (employees, error) in
            guard let strongSelf = self else { return }

            strongSelf.employees = (employees ?? []).sorted(by: strongSelf.activeSortingKeyPath)
            
            DispatchQueue.main.async {
                strongSelf.reloadTableViewData()

                var errorMessage: String?
                if strongSelf.employees.isEmpty {
                    errorMessage = error == nil ? NSLocalizedString("No Employees!", comment: "Employee list, empty data message") : NSLocalizedString("Error Loading!", comment: "Employee list, error message")
                }

                strongSelf.messageLabel.text = errorMessage
                strongSelf.messageLabel.isHidden = errorMessage == nil

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
            getImage(for: urlString) { image in
                if let image = image,
                    indexPath == tableView.indexPath(for: cell) {
                    (cell as? EmployeeCell)?.profileImageView.image = image
                }
            }
        }
    }

    private func getImage(for urlString: String, completion: @escaping (_ image: UIImage?) -> Void) {
        if let image = imageCache[urlString] {
            return completion(image)
        }

        // Image not stored in local memory cache
        if let url = URL(string: urlString) {
            DataProvider.shared.getImageData(with: url) { (imageData, error) in
                DispatchQueue.main.async {
                    if let imageData = imageData,
                        let image = UIImage(data: imageData) {
                        self.imageCache[urlString] = image
                        completion(image)
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        var detailView = EmployeeDetailView(employee: employees[indexPath.row])
        detailView.delegate = self

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

    private var imageCache = ImageCache()

    @objc private func didPullToRefresh() {
        getEmployees { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    // MARK: - Sorting

    enum SortingOption: CaseIterable {
        case fullName
        case team

        var title: String {
            switch self {
            case .fullName:
                return NSLocalizedString("By Name", comment: "Sort button title")
            case .team:
                return NSLocalizedString("By Team", comment: "Sort button title")
            }
        }
    }

    @IBAction func sortTapped(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: NSLocalizedString("Sort", comment: "Action sheet title"), message: NSLocalizedString("Select an option", comment: "Action sheet message"), preferredStyle: .actionSheet)

        for option in SortingOption.allCases {
            actionSheet.addAction(UIAlertAction(title: option.title, style: .default, handler: { _ in
                self.updateSort(option)
            }))
        }

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Action sheet button"), style: .cancel, handler: nil))

        actionSheet.popoverPresentationController?.barButtonItem = sender

        present(actionSheet, animated: true)
    }

    private func updateSort(_ sort: SortingOption) {
        activeSortingOption = sort
        employees = employees.sorted(by: activeSortingKeyPath)
        reloadTableViewData()
    }

    private var activeSortingOption = SortingOption.fullName

    private var activeSortingKeyPath: KeyPath<Employee, String> {
        switch activeSortingOption {
        case .fullName:
            return \.fullName
        case .team:
            return \.team
        }
    }
}

extension EmployeeListViewController: EmployeeDetailViewDelegate {
    func didTapDone() {
        dismiss(animated: true)
    }
}

extension Sequence {
    /// Based on https://www.swiftbysundell.com/articles/the-power-of-key-paths-in-swift/
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        sorted { a, b in
            return a[keyPath: keyPath] < b[keyPath: keyPath]
        }
    }
}
