//
//  Flow.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/16/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import Foundation


struct AppState {
	var detailState = DetailState()
}

struct DetailState {
	
	var firstName: String = ""
	var lastName: String = ""
	var amount: Double = 0.0
	
	var resultText: String {
		return firstName + " " + lastName + "\n" + "$" + String(amount)
	}

}

enum DetailAction {
	case NameChanged(String?)
	case AmountChanged(String?)
}

private let combinedReducer = CombinedReducer([DetailReducer()])

struct DetailReducer: Reducer {
	
	typealias ReducerStateType = DetailState
	
	func handleAction(state: ReducerStateType, action: Action) -> ReducerStateType {
		var result = state
		switch action as! DetailAction {
		case .NameChanged(let newName):
			if let newName = newName {
				result.firstName = extractFirstName(newName)
				result.lastName = extractLastName(newName)
			}
			else {
				result.firstName = ""
				result.lastName = ""
			}
		case .AmountChanged(let newAmount):
			if let newAmount = newAmount, let value = Double(newAmount) {
				result.amount = value
			}
			else {
				result.amount = 0.0
			}
		}
		return result;
	}
	
}

func extractFirstName(nameText: String) -> String {
	let names = nameText.componentsSeparatedByString(" ").filter { !$0.isEmpty }
	var result = ""
	if names.count == 1 {
		result = names[0]
	}
	else if names.count > 1 {
		result = names[0..<names.count - 1].joinWithSeparator(" ")
	}
	return result
}

func extractLastName(nameText: String) -> String {
	let names = nameText.componentsSeparatedByString(" ").filter { !$0.isEmpty }
	var result = ""
	if names.count > 1 {
		result = names.last!
	}
	return result
}

let mainStore = MainStore(reducer: combinedReducer, state: DetailState())
