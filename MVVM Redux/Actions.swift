//
//  Actions.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 4/27/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import Foundation


enum Action {
	case presentAddPaybackScreen
	case deletePayback(index: Int)
	case cancelAddPayback
	case setCurrentFirstResponder(responderField: DetailState.ResponderField)
	case update(responderField: DetailState.ResponderField, text: String)
	case setNextResponder
	case savePayback
	case exitedErrorAlert
}

func reducer(state: State, action: Action) -> State {
	var newState = state
	newState.detailState = detailReducer(state: state.detailState, action: action)
	newState.navigationState = navigationReducer(state: state.navigationState, action: action)
	newState.paybackCollection = paybackReducer(state: state.paybackCollection, action: action)
	
	switch action {
	case .savePayback:
		if state.detailState!.nameFieldValid == false {
			newState.navigationState.shouldDisplayAlert = Alert(message: "Name field invalid.")
		}
		else if state.detailState!.amountFieldValid == false {
			newState.navigationState.shouldDisplayAlert = Alert(message: "Amount field invalid.")
		}
		else {
			if let detailState = newState.detailState {
				let firstName = Array(detailState.nameComponents[0 ..< (detailState.nameComponents.count - 1)]).joined(separator: " ")
				let lastName = detailState.nameComponents.last!
				let amount = (detailState.amountField as NSString).doubleValue
				newState.paybackCollection.addPaybackWithFirstName(firstName, lastName: lastName, amount: amount)
				_ = newState.navigationState.viewControllerStack.popLast()
			}
		}
	case .cancelAddPayback:
		newState.detailState = nil
		_ = newState.navigationState.viewControllerStack.popLast()
	default:
		break
	}
	return newState
}

func detailReducer(state: DetailState?, action: Action) -> DetailState? {
	var newState = state
	switch action {
	case .presentAddPaybackScreen:
		newState = DetailState()
	case .setCurrentFirstResponder(let responderField):
		newState?.currentFirstResponder = responderField
	case .update(let (responderField, text)):
		newState?.updateField(responderField, text: text)
	case .setNextResponder:
		if let currentFirstResponder = state?.currentFirstResponder {
			switch currentFirstResponder {
			case .nameField:
				newState?.currentFirstResponder = .amountField
			case .amountField:
				newState?.currentFirstResponder = nil
			}
		}
	default:
		break
	}
	return newState
}

func navigationReducer(state: NavigationState, action: Action) -> NavigationState {
	var newState = state
	switch action {
	case .presentAddPaybackScreen:
		newState.viewControllerStack.append(.DetailViewController)
	case .exitedErrorAlert:
		newState.shouldDisplayAlert = nil
	default:
		break
	}
	return newState
}

func paybackReducer(state: PaybackCollection, action: Action) -> PaybackCollection {
	var newState = state
	switch action {
	case .deletePayback(let index):
		newState.removeAtIndex(index)
	default:
		break
	}
	return newState
}
