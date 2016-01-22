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
		unsubscribe = mainStore.subscribe { [unowned self] state in
			guard let detailState = state.detailState else { return }
			
			self.nameField.text = detailState.nameField
			self.amountField.text = detailState.amountField
			self.resultLabel.text = detailState.label
			
			self.programaticallyBecomingFirstResponder = true
			switch detailState.currentFirstResponder {
			case .Some(.NameField):
				self.nameField.becomeFirstResponder()
			case .Some(.AmountField):
				self.amountField.becomeFirstResponder()
			case .None:
				self.view.endEditing(true)
			}
			self.programaticallyBecomingFirstResponder = false
		}
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
	
	var unsubscribe: Store<State>.Unsubscriber = { }
	var programaticallyBecomingFirstResponder = false

}
