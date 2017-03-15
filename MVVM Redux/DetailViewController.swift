//
//  DetailViewController.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/15/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import UIKit
import BasicRedux


class DetailViewController: UIViewController {

	@IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var nameField: UITextField!
	@IBOutlet weak var amountField: UITextField!
	@IBOutlet weak var resultLabel: UILabel!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		unsubscriber = mainStore.subscribe(observer: { [weak self] in self?.handle(state: $0) }, lens: { $0.detailState })
	}
	
	@IBAction func cancelAction(_ sender: UIBarButtonItem) {
		mainStore.dispatch(action: .cancelAddPayback)
	}

	@IBAction func nameFieldDidBegin(_ sender: AnyObject) {
		guard !programaticallyBecomingFirstResponder else { return }
		mainStore.dispatch(action: .setCurrentFirstResponder(responderField: .nameField))
	}

	@IBAction func nameFieldChanged(_ sender: UITextField) {
		mainStore.dispatch(action: .update(responderField: .nameField, text: sender.text ?? ""))
	}

	@IBAction func didEndOnExit(_: AnyObject) {
		mainStore.dispatch(action: .setNextResponder)
	}

	@IBAction func amountFieldDidBegin(_ sender: UITextField) {
		guard !programaticallyBecomingFirstResponder else { return }
		mainStore.dispatch(action: .setCurrentFirstResponder(responderField: .amountField))
	}

	@IBAction func amountFieldChanged(_ sender: UITextField) {
		mainStore.dispatch(action: .update(responderField: .amountField, text: sender.text ?? ""))
	}

	@IBAction func doneAction(_ sender: UIBarButtonItem) {
		mainStore.dispatch(action: .savePayback)
	}

	func handle(state: DetailState?) {
		guard let state = state else { return }

		nameField.text = state.name
		amountField.text = state.amountField
		resultLabel.text = state.label

		programaticallyBecomingFirstResponder = true
		switch state.currentFirstResponder {
		case .some(.nameField):
			nameField.becomeFirstResponder()
		case .some(.amountField):
			amountField.becomeFirstResponder()
		case .none:
			view.endEditing(true)
		}
		programaticallyBecomingFirstResponder = false
	}

	private var programaticallyBecomingFirstResponder = false
	private var unsubscriber: Unsubscriber?

}

