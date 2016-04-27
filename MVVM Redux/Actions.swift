//
//  Actions.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 4/27/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import Foundation


func presentAddPaybackScreen(inout state: State) {
	state.navigationState.viewControllerStack.append(.DetailViewController)
	state.detailState = DetailState()
}

func deletePayback(index index: Int) -> (inout state: State) -> Void {
	return { state in
		state.paybackCollection.removeAtIndex(index)
	}
}

// MARK: Detail View Actions
func cancelAddPayback(inout state: State) {
	state.navigationState.viewControllerStack.popLast()
	state.detailState = nil
}

func setCurrentFirstResponder(responderField: DetailState.ResponderField) -> (inout state: State) -> Void {
	return { state in
		state.detailState?.currentFirstResponder = responderField
	}
}

func update(responderField responderField: DetailState.ResponderField, text: String) -> (inout state: State) -> Void {
	return { state in
		state.detailState?.updateField(.NameField, text: text)
	}
}

func setNextResponder(inout state: State) {
	if let currentFirstResponder = state.detailState?.currentFirstResponder {
		switch currentFirstResponder {
		case .NameField:
			state.detailState?.currentFirstResponder = .AmountField
		case .AmountField:
			state.detailState?.currentFirstResponder = nil
		}
	}
}

func savePayback(inout state: State) {
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

func exitedErrorAlert(inout state: State) {
	state.navigationState.shouldDisplayAlert = nil
}
