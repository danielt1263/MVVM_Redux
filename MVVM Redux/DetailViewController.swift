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
		unsubscribe = mainStore.subscribe { [weak self] state in
			self?.updateWithState(state)
		}
	}

	override func viewWillDisappear(animated: Bool) {
		unsubscribe()
		super.viewWillDisappear(animated)
	}
	
	@IBAction func cancelAction(sender: UIBarButtonItem) {
		mainStore.dispatch { state in
			state.navigationState.viewControllerStack.popLast()
			state.detailState = nil
		}
	}
	
	@IBAction func nameFieldDidBegin(sender: AnyObject) {
		guard !programaticallyBecomingFirstResponder else { return }
		mainStore.dispatch { state in
			state.detailState?.currentFirstResponder = .NameField
			return
		}
	}
	
	@IBAction func nameFieldChanged(sender: UITextField) {
		mainStore.dispatch { state in
			state.detailState?.updateField(.NameField, text: sender.text)
			return
		}
	}
	
	@IBAction func nameFieldDidEndOnExit(sender: AnyObject) {
		mainStore.dispatch { state in
			state.detailState?.updateCurrentFirstResponder(.NameField)
			return
		}
	}

	@IBAction func amountFieldDidBegin(sender: UITextField) {
		guard !programaticallyBecomingFirstResponder else { return }
		mainStore.dispatch { state in
			state.detailState?.currentFirstResponder = .AmountField
			return
		}
	}
	
	@IBAction func amountFieldChanged(sender: UITextField) {
		mainStore.dispatch { state in
			state.detailState?.updateField(.AmountField, text: sender.text)
			return
		}
	}
	
	@IBAction func amountFieldDidEndOnExit(sender: UITextField) {
		mainStore.dispatch { state in
			state.detailState?.updateCurrentFirstResponder(.AmountField)
			return
		}
	}
	
	@IBAction func doneAction(sender: UIBarButtonItem) {
		mainStore.dispatch(done)
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

	private var unsubscribe: MainStore.Unsubscriber = { }
	private var programaticallyBecomingFirstResponder = false

}

private func done(inout state: State) {
	if state.detailState!.nameFieldValid == false {
		state.navigationState.shouldDisplayAlert = Alert(message: "Name field invalid.")
	}
	else if state.detailState!.amountFieldValid == false {
		state.navigationState.shouldDisplayAlert = Alert(message: "Amount field invalid.")
	}
	else {
		if let detailState = state.detailState {
			let firstName = Array(detailState.nameComponents[0 ..< (detailState.nameComponents.count - 1)]).joinWithSeparator(" ")
			let lastName = detailState.nameComponents.last!
			let amount = (detailState.amountField as NSString).doubleValue
			state.paybackCollection.addPaybackWithFirstName(firstName, lastName: lastName, amount: amount)
			state.navigationState.viewControllerStack.popLast()
		}
	}
}
