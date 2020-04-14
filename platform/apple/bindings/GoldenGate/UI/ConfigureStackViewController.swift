//
//  ConfigureStackViewController.swift
//  GoldenGate-iOS
//
//  Created by Marcel Jackwerth on 6/25/18.
//  Copyright © 2018 Fitbit. All rights reserved.
//

#if os(iOS)

import RxSwift
import UIKit

public protocol ConfigureStackViewControllerViewModel {
    var supportsCustomPortUrl: Observable<Bool> { get }
    var customPortUrl: Observable<URL?> { get }
    func setCustomPortUrl(_ url: URL?)
}

/// Allows selecting one standard stack configuration
/// or a custom one.
class ConfigureStackViewController: ComboBoxViewController<StackDescriptor> {
    public var childViewModel: ConfigureStackViewControllerViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add a button in the top right corner
        let customRightBarButtonItem = UIBarButtonItem(title: "Custom", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = customRightBarButtonItem

        childViewModel.supportsCustomPortUrl
            .asDriver(onErrorJustReturn: false)
            .drive(customRightBarButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)

        customRightBarButtonItem.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.enterCustomConfiguration()
            })
            .disposed(by: disposeBag)
    }

    func enterCustomConfiguration() {
        guard let childViewModel = self.childViewModel else { return }
        let controller = UIAlertController(title: "Custom Config", message: nil, preferredStyle: .alert)

        controller.addTextField { textField in
            _ = childViewModel.customPortUrl
                .take(1)
                .map { $0?.description }
                .takeUntil(textField.rx.deallocated)
                .bind(to: textField.rx.text)

            textField.placeholder = "//SFO-M-ABCDEF.local:5683"
        }

        controller.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let textField = controller.textFields?.first as UITextField?

            guard
                let urlString = textField?.text,
                let url = URL(string: urlString)
            else {
                LogBindingsWarning("Failed to parse URL: \(textField?.text ?? "")")
                return
            }

            childViewModel.setCustomPortUrl(url)
        })

        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(controller, animated: true)
    }
}

#endif