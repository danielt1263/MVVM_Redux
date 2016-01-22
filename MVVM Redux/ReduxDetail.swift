//
//  ReduxDetail.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/19/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import BasicRedux


enum DetailAction: Action {
	case EditingDidBegin(DetailState.ResponderField)
	case EditingChanged(DetailState.ResponderField, String?)
	case DidEndOnExit(DetailState.ResponderField)
	case Cancel
	case Done
}

struct DetailState {
	enum ResponderField {
		case NameField
		case AmountField
	}
	
	var currentFirstResponder: ResponderField?
	var nameField: String = ""
	var amountField: String = ""
	var label: String {
		return nameField + "\n" + amountField
	}
	
	var nameFieldValid: Bool {
		return nameComponents.count >= 2
	}
	
	var amountFieldValid: Bool {
		let value = (amountField as NSString).doubleValue
		return value.isNormal && value > 0
	}

	var payback: Payback {
		guard nameFieldValid && amountFieldValid else { fatalError("Can't create payback.") }
		let firstName = Array(nameComponents[0..<nameComponents.count - 1]).joinWithSeparator(" ")
		let lastName = nameComponents.last!
		let amount = (amountField as NSString).doubleValue
		return Payback(firstName: firstName, lastName: lastName, amount: amount)
	}

	mutating func updateField(responderField: ResponderField, text: String?) {
		switch responderField {
		case .NameField:
			nameField = text ?? ""
		case .AmountField:
			amountField = text ?? ""
		}
	}

	mutating func updateCurrentFirstResponder(responderField: ResponderField) {
		switch responderField {
		case .NameField:
			currentFirstResponder = .AmountField
		case .AmountField:
			currentFirstResponder = nil
		}
	}

	private var nameComponents: [String] {
		return nameField.componentsSeparatedByString(" ").filter { !$0.isEmpty }
	}
}

func detailReducer(var state: State, action: Action) -> State {
	guard let action = action as? DetailAction else { return state }
	switch action {

	case .EditingDidBegin(let responderField):
		state.detailState?.currentFirstResponder = responderField

	case .EditingChanged(let (responderField, text)):
		state.detailState?.updateField(responderField, text: text)

	case .DidEndOnExit(let responderField):
		state.detailState?.updateCurrentFirstResponder(responderField)

	case .Cancel:
		state.navigationState.viewControllerStack.popLast()
		state.detailState = nil

	case .Done:
		if state.detailState!.nameFieldValid == false {
			state.navigationState.shouldDisplayAlert = Alert(message: "Name field invalid.")
		}
		else if state.detailState!.amountFieldValid == false {
			state.navigationState.shouldDisplayAlert = Alert(message: "Amount field invalid.")
		}
		else {
			state.createPayback()
		}
	}
	return state
}
