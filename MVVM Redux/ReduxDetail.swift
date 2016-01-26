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
    enum ResponderField: Int {
		case NameField = 0
		case AmountField = 1
	}
	
	private (set) var currentFirstResponder: ResponderField?
	private (set) var nameField: String = ""
	private (set) var amountField: String = ""
	
	var label: String {
		return nameField + "\n" + amountField
	}
	
	private var nameFieldValid: Bool {
		return nameComponents.count >= 2
	}
	
	private var amountFieldValid: Bool {
		let value = (amountField as NSString).doubleValue
		return value.isNormal && value > 0
	}

	private var nameComponents: [String] {
		return nameField.componentsSeparatedByString(" ").filter { !$0.isEmpty }
	}

	private mutating func updateField(responderField: ResponderField, text: String?) {
		switch responderField {
		case .NameField:
			nameField = text ?? ""
		case .AmountField:
			amountField = text ?? ""
		}
	}

	private mutating func updateCurrentFirstResponder(responderField: ResponderField) {
		switch responderField {
		case .NameField:
			currentFirstResponder = .AmountField
		case .AmountField:
			currentFirstResponder = nil
		}
	}

}

extension DetailState {
    
    init(dictionary: [String: AnyObject]) {
		if let responder = dictionary["currentFirstResponder"] as? Int {
			currentFirstResponder = ResponderField(rawValue: responder)
		}
        nameField = dictionary["nameField"] as! String
        amountField = dictionary["amountField"] as! String
    }
	
	var dictionary: [String: AnyObject] {
		var result: [String: AnyObject] = [
			"nameField": nameField,
			"amountField": amountField
		]
		if let responder = currentFirstResponder {
			result["currentFirstResponder"] = responder.rawValue
		}
		return result
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
			if let detailState = state.detailState {
				let firstName = Array(detailState.nameComponents[0 ..< (detailState.nameComponents.count - 1)]).joinWithSeparator(" ")
				let lastName = detailState.nameComponents.last!
				let amount = (detailState.amountField as NSString).doubleValue
				state.masterState.addPaybackWithFirstName(firstName, lastName: lastName, amount: amount)
				state.navigationState.viewControllerStack.popLast()
			}
		}
	}
	return state
}
