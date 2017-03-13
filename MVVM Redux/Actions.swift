//
//  Actions.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 4/27/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import Foundation


func presentAddPaybackScreen(_ state: inout State) {
	state.navigationState.viewControllerStack.append(.DetailViewController)
	state.detailState = DetailState()
}

func presentEditPaybackScreen(index: Int) -> MainStore.Action {
	return { state in
		state.navigationState.viewControllerStack.append(.DetailViewController)
		state.detailState = DetailState(presenting: state.paybackCollection.paybacks[index])
	}
}

func deletePayback(index: Int) -> MainStore.Action {
	return { state in
		state.paybackCollection.removeAtIndex(index)
	}
}

// MARK: Detail View Actions
func cancelAddPayback(_ state: inout State) {
	_ = state.navigationState.viewControllerStack.popLast()
	state.detailState = nil
}

func setCurrentFirstResponder(_ responderField: DetailState.ResponderField) -> (_ state: inout State) -> Void {
	return { state in
		state.detailState?.currentFirstResponder = responderField
	}
}

func update(responderField: DetailState.ResponderField, text: String) -> (_ state: inout State) -> Void {
	return { state in
		state.detailState?.updateField(responderField, text: text)
	}
}

func setNextResponder(_ state: inout State) {
	if let currentFirstResponder = state.detailState?.currentFirstResponder {
		switch currentFirstResponder {
		case .nameField:
			state.detailState?.currentFirstResponder = .amountField
		case .amountField:
			state.detailState?.currentFirstResponder = nil
		}
	}
}

func savePayback(_ state: inout State) {
	guard let detailState = state.detailState else { return }
	if detailState.nameFieldValid == false {
		state.navigationState.shouldDisplayAlert = Alert(message: "Name field invalid.")
	}
	else if detailState.amountFieldValid == false {
		state.navigationState.shouldDisplayAlert = Alert(message: "Amount field invalid.")
	}
	else {
		let firstName = Array(detailState.nameComponents[0 ..< (detailState.nameComponents.count - 1)]).joined(separator: " ")
		let lastName = detailState.nameComponents.last!
		let amount = (detailState.amountField as NSString).doubleValue
		if let paybackID = detailState.payback?.id {
			let paybackIndex = state.paybackCollection.paybacks.index(where: {$0.id == paybackID })!
			state.paybackCollection.paybacks[paybackIndex] = Payback(id: paybackID, firstName: firstName, lastName: lastName, amount: amount)
		}
		else {
			state.paybackCollection.addPaybackWithFirstName(firstName, lastName: lastName, amount: amount)
		}
		_ = state.navigationState.viewControllerStack.popLast()
	}
}

func exitedErrorAlert(_ state: inout State) {
	state.navigationState.shouldDisplayAlert = nil
}
