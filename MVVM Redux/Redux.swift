//
//  Redux.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/16/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import Foundation
import BasicRedux


struct State {

	var detailState: DetailState?
	var navigationState = NavigationState()

	var paybackCollection = PaybackCollection()
	
}

extension State {
	
	init(dictionary: [String: AnyObject]) {
		if let detail = dictionary["detailState"] as? [String: AnyObject] {
			detailState = DetailState(dictionary: detail)
		}
		navigationState = NavigationState(dictionary: dictionary["navigationState"] as! [String: AnyObject])
		paybackCollection = PaybackCollection(dictionary: dictionary["paybackCollection"] as! [String: AnyObject])
	}

	var dictionary: [String: AnyObject] {
		var result = [
			"navigationState": navigationState.dictionary,
			"paybackCollection": paybackCollection.dictionary
		]
		if let detailState = detailState {
			result["detailState"] = detailState.dictionary
		}
		return result
	}
}


let mainStore = Store(state: createState(), reducer: combineReducers([navigationReducer, masterReducer, detailReducer]), middleware: [logStateMiddleware])

typealias MyStore = Store<State>

func createState() -> State {
	let url = applicationDocumentsDirectory.URLByAppendingPathComponent("state.plist")
	print(url)
	if let dictionary = NSDictionary(contentsOfURL: url) as? [String: AnyObject] {
		return State(dictionary: dictionary)
	}
	else {
		return State()
	}
}

func logStateMiddleware(next: MyStore.Dispatcher, state: () -> State) -> MyStore.Dispatcher {
	return { action in
		let url = applicationDocumentsDirectory.URLByAppendingPathComponent("state.plist")
		(state().dictionary as NSDictionary).writeToURL(url, atomically: true)
		next(action: action)
	}
}

var applicationDocumentsDirectory: NSURL {
	return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
}
