//
//  PaymentHistoryViewController.swift
//  EcoSoapBank
//
//  Created by Christopher Devito on 8/31/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit

class PaymentHistoryViewController: UIViewController {

    // MARK: - Properties
    var paymentController: PaymentController?
    private lazy var paymentCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout())
    private var payments: [Payment] = [] {
        didSet {
            self.paymentCollectionView.reloadData()
        }
    }
    
    private let refreshControl = UIRefreshControl()

    var isExpanded: IndexPath?
    let cellIdentifier = "PaymentCell"
    
    // MARK: - Initialization methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        refreshPayments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshControl.bounds = CGRect(
            x: refreshControl.bounds.origin.x,
            y: -UIRefreshControl.topPadding,
            width: refreshControl.bounds.size.width,
            height: refreshControl.bounds.size.height
        )
    }
    
    func setupCollectionView() {
        view.addSubview(paymentCollectionView)
        paymentCollectionView.dataSource = self
        paymentCollectionView.delegate = self
        paymentCollectionView.translatesAutoresizingMaskIntoConstraints = false
        paymentCollectionView.register(PaymentHistoryCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        paymentCollectionView.backgroundColor = UIColor.tableViewCellBackground
        
        NSLayoutConstraint.activate([
            paymentCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            paymentCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            paymentCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paymentCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        refreshControl.addTarget(self, action: #selector(refreshControlDidTrigger(_:)), for: .valueChanged)
        paymentCollectionView.refreshControl = refreshControl
    }

    private func compositionalLayout() -> UICollectionViewLayout {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [NSCollectionLayoutItem(layoutSize: size)])
        let section = NSCollectionLayoutSection(group: group)
        // Match table view leading padding, add space for refresh control
        section.contentInsets = .init(top: UIRefreshControl.topPadding, leading: 3, bottom: 0, trailing: 0)
       
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func refreshPayments() {
        guard let controller = paymentController else { return }
        refreshControl.beginRefreshing()
        controller.fetchPaymentsForSelectedProperty(completion: { [weak self] result in
            switch result {
            case .success(let payments):
                var sortedPayments: [Payment] = payments
                sortedPayments.sort {
                    guard let date0 = $0.invoicePeriodEndDate, let date1 = $1.invoicePeriodEndDate else { return false }
                    return date0 > date1
                }
                DispatchQueue.main.async {
                    self?.payments = sortedPayments
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.presentAlert(for: error)
                }
            }
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
        })
    }

    @objc private func refreshControlDidTrigger(_ sender: UIRefreshControl) {
        refreshPayments()
    }
}

extension PaymentHistoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleExpandCell(indexPath: indexPath)
    }

    /// Method to control toggle isExpanded and reload paymentCollectionView based on the results.
    func toggleExpandCell(indexPath: IndexPath) {
        if let index = isExpanded, index == indexPath {
            isExpanded = nil
        } else {
            isExpanded = indexPath
        }
        self.paymentCollectionView.reloadData()
    }
}

extension PaymentHistoryViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        payments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath) as? PaymentHistoryCollectionViewCell
            else { return UICollectionViewCell() }
        cell.isExpanded = isExpanded == indexPath ? true : false
        cell.payment = payments[indexPath.row]

        return cell
    }
}
