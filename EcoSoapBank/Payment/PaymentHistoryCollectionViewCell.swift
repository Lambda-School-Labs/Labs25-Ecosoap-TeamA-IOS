//
//  PaymentHistoryCollectionViewCell.swift
//  EcoSoapBank
//
//  Created by Christopher Devito on 8/31/20.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit


class PaymentHistoryCollectionViewCell: UICollectionViewCell {
    private enum Padding {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
    }

    var payment: Payment? {
        didSet { updateContent() }
    }

    var isExpanded = false {
        didSet { updateLayout() }
    }

    private let dateFormatter = configure(DateFormatter()) {
        $0.dateStyle = .medium
    }

    // MARK: - Subviews

    private lazy var rootStack = UIStackView(axis: .horizontal, alignment: .firstBaseline, distribution: .fill, spacing: Padding.tiny)
    private lazy var mainStack = UIStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: Padding.small)
    private lazy var duePaidStack = UIStackView(axis: .horizontal, alignment: .firstBaseline, distribution: .fillEqually, spacing: Padding.small)
    private lazy var detailStack = UIStackView(axis: .horizontal, alignment: .firstBaseline, distribution: .fillEqually, spacing: Padding.small)
    private lazy var invoiceStack = UIStackView(axis: .horizontal, alignment: .lastBaseline, distribution: .fillEqually, spacing: Padding.small)

    private lazy var invoicePeriodLabel = configure(UILabel()) {
        $0.font = .muli(typeface: .bold)
    }
    private lazy var amountDueLabel = contentLabel()
    private lazy var amountPaidLabel = contentLabel()
    private lazy var paymentDateLabel = contentLabel()
    private lazy var paymentMethodLabel = contentLabel()
    private lazy var invoiceCodeLabel = contentLabel()
    private lazy var invoiceButton = configure(UIButton()) {
        $0.setAttributedTitle(
            NSAttributedString(string: "Open invoice", attributes: [
                .font: UIFont.muli(style: .body, typeface: .semiBold),
                .foregroundColor: UIColor.esbGreen]),
            for: .normal)
        $0.tintColor = .esbGreen
        $0.setTitleColor(.esbGreen, for: .normal)
        $0.addTarget(self, action: #selector(openInvoice(_:)), for: .touchUpInside)
        $0.titleLabel?.lineBreakMode = .byWordWrapping
        $0.titleLabel?.numberOfLines = 0
        $0.contentHorizontalAlignment = .leading
    }
    private lazy var disclosureIndicator = configure(UIImageView(systemName: "chevron.right")) {
        $0.preferredSymbolConfiguration = .init(textStyle: .body, scale: .small)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .secondarySystemBackground

        constrainNewSubviewToSafeArea(rootStack,
                                      sides: [.top, .leading, .trailing],
                                      constant: Padding.medium)
        bottomAnchor.constraint(equalTo: rootStack.bottomAnchor, constant: Padding.large)
            .isActive = true
        [mainStack, disclosureIndicator]
            .forEach(rootStack.addArrangedSubview(_:))

        mainStack.addArrangedSubview(invoicePeriodLabel)

        // Due/Paid
        [labeledStack(
            caption: "Amount Due",
            content: iconStack(image: dollarSign(.systemOrange), label: amountDueLabel)),
         labeledStack(
            caption: "Amount Paid",
            content: iconStack(image: dollarSign(.esbGreen), label: amountPaidLabel))
        ].forEach(duePaidStack.addArrangedSubview(_:))
        mainStack.addArrangedSubview(duePaidStack)

        // Details row 1
        [labeledStack(caption: "Paid", content: paymentDateLabel),
         labeledStack(caption: "Method", content: paymentMethodLabel)
        ].forEach(detailStack.addArrangedSubview(_:))
        mainStack.addArrangedSubview(detailStack)

        // Details row 2
        [labeledStack(caption: "Invoice", content: invoiceCodeLabel), invoiceButton]
            .forEach(invoiceStack.addArrangedSubview(_:))
        mainStack.addArrangedSubview(invoiceStack)

        // Divider
        configure(UIView()) {
            $0.backgroundColor = .tertiaryLabel
            constrainNewSubview($0, to: [.bottom, .trailing])
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 0.5),
                $0.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                            constant: Padding.medium)
            ])
        }

        updateLayout()
    }

    // MARK: - Update

    private func updateContent() {
        guard let payment = payment,
            let invoicePeriodStartDate = payment.invoicePeriodStartDate,
            let invoicePeriodEndDate = payment.invoicePeriodEndDate
            else { return }

        amountDueLabel.text = dollarString(payment.amountDue as NSNumber)
        amountPaidLabel.text = dollarString(payment.amountPaid as NSNumber)
        invoicePeriodLabel.text = "\(dateFormatter.string(from: invoicePeriodStartDate)) — \(dateFormatter.string(from: invoicePeriodEndDate))"
        paymentDateLabel.text = dateFormatter.string(from: payment.date)
        paymentMethodLabel.text = "\(payment.paymentMethod)"
        invoiceCodeLabel.text = payment.invoiceCode
    }

    private func updateLayout() {
        self.disclosureIndicator.transform = self.isExpanded ?
            CGAffineTransform(rotationAngle: .pi / 2)
            : .identity
        self.detailStack.isHidden = !self.isExpanded
        self.invoiceStack.isHidden = !self.isExpanded
    }

    @objc private func openInvoice(_ sender: Any?) {
        if let urlString = payment?.invoice, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Subview factory

extension PaymentHistoryCollectionViewCell {
    private func dollarString(_ amount: NSNumber) -> String {
        String(NumberFormatter.forDollars.string(from: amount)?.dropFirst() ?? "n/a"[...])
    }
    
    private func contentLabel() -> UILabel {
        configure(UILabel()) {
            $0.font = .muli(typeface: .regular)
        }
    }

    private func captionLabel(_ text: String) -> UILabel {
        configure(UILabel()) {
            $0.text = text.uppercased()
            $0.font = .muli(style: .caption1)
            $0.textColor = .secondaryLabel
        }
    }

    private func labeledStack(caption: String, content: UIView) -> UIStackView {
        configure(UIStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 0)) {
            [captionLabel(caption), content].forEach($0.addArrangedSubview(_:))
        }
    }

    private func iconStack(image: UIImageView, label: UILabel) -> UIStackView {
        configure(UIStackView(axis: .horizontal, alignment: .firstBaseline, distribution: .fill, spacing: 0)) {
            [image, label].forEach($0.addArrangedSubview(_:))
        }
    }

    private func dollarSign(_ color: UIColor) -> UIImageView {
        configure(UIImageView(systemName: "dollarsign.circle.fill")) {
            $0.preferredSymbolConfiguration = .init(weight: .light)
            $0.tintColor = color
            $0.widthAnchor.constraint(equalTo: $0.heightAnchor).isActive = true
        }
    }
}
