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

	var paybacks: [Payback] = []

}


extension MasterState {
    
    init(dictionary: [String: AnyObject]) {
        let paybackDicts = dictionary["paybacks"]! as! [[String: AnyObject]]
        paybacks = paybackDicts.map { Payback(dictionary: $0) }
    }

	var dictionary: [String: AnyObject] {
		return [
			"paybacks": paybacks.map { $0.dictionary }
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
