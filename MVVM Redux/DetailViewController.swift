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

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		unsubscribe = mainStore.subscribe(self)
	}

	override func viewWillDisappear(animated: Bool) {
		unsubscribe()
		super.viewWillDisappear(animated)
	}
	
	@IBAction func cancelAction(sender: UIBarButtonItem) {
		mainStore.dispatch(DetailAction.Cancel)
	}
	
	@IBAction func nameFieldDidBegin(sender: AnyObject) {
		guard !programaticallyBecomingFirstResponder else { return }
		mainStore.dispatch(DetailAction.EditingDidBegin(.NameField))
	}
	
	@IBAction func nameFieldChanged(sender: UITextField) {
		mainStore.dispatch(DetailAction.EditingChanged(.NameField, sender.text))
	}
	
	@IBAction func nameFieldDidEndOnExit(sender: AnyObject) {
		mainStore.dispatch(DetailAction.DidEndOnExit(.NameField))
	}

	@IBAction func amountFieldDidBegin(sender: UITextField) {
		guard !programaticallyBecomingFirstResponder else { return }
		mainStore.dispatch(DetailAction.EditingDidBegin(.AmountField))
	}
	
	@IBAction func amountFieldChanged(sender: UITextField) {
		mainStore.dispatch(DetailAction.EditingChanged(.AmountField, sender.text))
	}
	
	@IBAction func amountFieldDidEndOnExit(sender: UITextField) {
		mainStore.dispatch(DetailAction.DidEndOnExit(.AmountField))
	}
	
	@IBAction func doneAction(sender: UIBarButtonItem) {
		mainStore.dispatch(DetailAction.Done)
	}
	
	var unsubscribe: MainStore.Unsubscriber = { }
	var programaticallyBecomingFirstResponder = false

}

extension DetailViewController: StateObserver {

	func updateWithState(state: State) {
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
}
