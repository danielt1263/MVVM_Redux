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

	override func viewDidLoad() {
		super.viewDidLoad()
		unsubscribe = mainStore.subscribe { [weak self] state in
			self?.updateWithState(state)
		}
	}

	@IBAction func cancelAction(sender: UIBarButtonItem) {
		mainStore.dispatch(cancelAddPayback)
	}

	@IBAction func nameFieldDidBegin(sender: AnyObject) {
		guard !programaticallyBecomingFirstResponder else { return }
		mainStore.dispatch(setCurrentFirstResponder(.NameField))
	}

	@IBAction func nameFieldChanged(sender: UITextField) {
		mainStore.dispatch(update(responderField: .NameField, text: sender.text ?? ""))
	}

	@IBAction func didEndOnExit(_: AnyObject) {
		mainStore.dispatch(setNextResponder)
	}

	@IBAction func amountFieldDidBegin(sender: UITextField) {
		guard !programaticallyBecomingFirstResponder else { return }
		mainStore.dispatch(setCurrentFirstResponder(.AmountField))
	}

	@IBAction func amountFieldChanged(sender: UITextField) {
		mainStore.dispatch(update(responderField: .AmountField, text: sender.text ?? ""))
	}

	@IBAction func doneAction(sender: UIBarButtonItem) {
		mainStore.dispatch(savePayback)
	}

	private func updateWithState(state: State) {
		guard let detailState = state.detailState else { return }

		nameField.text = detailState.nameField
		amountField.text = detailState.amountField
		resultLabel.text = detailState.label

		programaticallyBecomingFirstResponder = true
		switch detailState.currentFirstResponder {
		case .Some(.NameField):
			nameField.becomeFirstResponder()
		case .Some(.AmountField):
			amountField.becomeFirstResponder()
		case .None:
			view.endEditing(true)
		}
		programaticallyBecomingFirstResponder = false
	}

	private var unsubscribe: Unsubscriber?
	private var programaticallyBecomingFirstResponder = false

}

