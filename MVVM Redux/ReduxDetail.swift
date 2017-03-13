//
//  ReduxDetail.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/19/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import BasicRedux


struct DetailState {
	
    enum ResponderField: Int {
		case nameField = 0
		case amountField = 1
	}

	init(presenting payback: Payback? = nil) {
		self.payback = payback
		guard let payback = payback else { return }
		self.nameField = "\(payback.firstName) \(payback.lastName)"
		self.amountField = String(payback.amount)
	}

	var payback: Payback?
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

	var nameComponents: [String] {
		return nameField.components(separatedBy: " ").filter { !$0.isEmpty }
	}

	mutating func updateField(_ responderField: ResponderField, text: String?) {
		switch responderField {
		case .nameField:
			nameField = text ?? ""
		case .amountField:
			amountField = text ?? ""
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
			"nameField": nameField as AnyObject,
			"amountField": amountField as AnyObject
		]
		if let responder = currentFirstResponder {
			result["currentFirstResponder"] = responder.rawValue as AnyObject?
		}
		return result
	}
}
