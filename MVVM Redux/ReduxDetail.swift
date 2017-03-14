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
	
	var currentFirstResponder: ResponderField?
	var name: String = ""
	var amountField: String = ""
	
	var label: String {
		return name + "\n" + amountField
	}
	
	var nameFieldValid: Bool {
		return nameComponents.count >= 2
	}
	
	var amountFieldValid: Bool {
		let value = Double(amountField) ?? 0.0
		return value.isNormal && value > 0
	}

	var nameComponents: [String] {
		return name.components(separatedBy: " ").filter { !$0.isEmpty }
	}

}


extension DetailState {
    
    init(dictionary: [String: AnyObject]) {
		if let responder = dictionary["currentFirstResponder"] as? Int {
			currentFirstResponder = ResponderField(rawValue: responder)
		}
        name = dictionary["nameField"] as! String
        amountField = dictionary["amountField"] as! String
    }
	
	var dictionary: [String: AnyObject] {
		var result: [String: AnyObject] = [
			"nameField": name as AnyObject,
			"amountField": amountField as AnyObject
		]
		if let responder = currentFirstResponder {
			result["currentFirstResponder"] = responder.rawValue as AnyObject?
		}
		return result
	}
}
