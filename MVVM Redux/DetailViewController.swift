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

	@IBAction func cancelAction(_ sender: UIBarButtonItem) {
		mainStore.dispatch(cancelAddPayback)
	}

	@IBAction func nameFieldDidBegin(_ sender: AnyObject) {
		guard !programaticallyBecomingFirstResponder else { return }
		mainStore.dispatch(setCurrentFirstResponder(.nameField))
	}

	@IBAction func nameFieldChanged(_ sender: UITextField) {
		mainStore.dispatch(update(responderField: .nameField, text: sender.text ?? ""))
	}

	@IBAction func didEndOnExit(_: AnyObject) {
		mainStore.dispatch(setNextResponder)
	}

	@IBAction func amountFieldDidBegin(_ sender: UITextField) {
		guard !programaticallyBecomingFirstResponder else { return }
		mainStore.dispatch(setCurrentFirstResponder(.amountField))
	}

	@IBAction func amountFieldChanged(_ sender: UITextField) {
		mainStore.dispatch(update(responderField: .amountField, text: sender.text ?? ""))
	}

	@IBAction func doneAction(_ sender: UIBarButtonItem) {
		mainStore.dispatch(savePayback)
	}

	private func updateWithState(_ state: State) {
		guard let detailState = state.detailState else { return }

		nameField.text = detailState.nameField
		amountField.text = detailState.amountField
		resultLabel.text = detailState.label

		programaticallyBecomingFirstResponder = true
		switch detailState.currentFirstResponder {
		case .some(.nameField):
			nameField.becomeFirstResponder()
		case .some(.amountField):
			amountField.becomeFirstResponder()
		case .none:
			view.endEditing(true)
		}
		programaticallyBecomingFirstResponder = false
	}

	private var unsubscribe: Unsubscriber?
	private var programaticallyBecomingFirstResponder = false

}

