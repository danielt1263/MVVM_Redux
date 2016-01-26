//
//  ReduxMaster.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/20/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import BasicRedux


enum MasterAction: Action {

	case AddItem
	case DeleteItem(index: Int)

}


struct MasterState {

	private (set) var paybacks: [Payback] = []

	mutating func addPaybackWithFirstName(firstName: String, lastName: String, amount: Double) {
		let payback = Payback(id: uniqueId++, firstName: firstName, lastName: lastName, amount: amount)
		paybacks.append(payback)
	}
	
	private var uniqueId = 0

}


extension MasterState {
    
    init(dictionary: [String: AnyObject]) {
        let paybackDicts = dictionary["paybacks"]! as! [[String: AnyObject]]
        paybacks = paybackDicts.map { Payback(dictionary: $0) }
		uniqueId = dictionary["uniqueId"]! as! Int
    }

	var dictionary: [String: AnyObject] {
		return [
			"paybacks": paybacks.map { $0.dictionary },
			"uniqueId": uniqueId
		]
	}
}


func masterReducer(var state: State, action: Action) -> State {
	guard let action = action as? MasterAction else { return state }
	switch action {

	case .AddItem:
		state.navigationState.viewControllerStack.append(.DetailViewController)
		state.detailState = DetailState()

	case .DeleteItem(let index):
		state.masterState.paybacks.removeAtIndex(index)
	}
	return state
}
