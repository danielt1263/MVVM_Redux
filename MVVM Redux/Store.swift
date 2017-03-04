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
		return result as [String : AnyObject]
	}
}

let mainStore = Store(initial: createState(), reducer: reducer, middleware: [logStateMiddleware])

typealias MainStore = Store<State, Action>

func createState() -> State {
	let url = applicationDocumentsDirectory.appendingPathComponent("state.plist")
	print(url)
	if let dictionary = NSDictionary(contentsOf: url) as? [String: AnyObject] {
		return State(dictionary: dictionary)
	}
	else {
		return State()
	}
}

func logStateMiddleware(_ next: @escaping MainStore.Dispatcher, state: @escaping () -> State) -> MainStore.Dispatcher {
	return { action in
		let url = applicationDocumentsDirectory.appendingPathComponent("state.plist")
		(state().dictionary as NSDictionary).write(to: url, atomically: true)
		next(action)
	}
}

var applicationDocumentsDirectory: URL {
	return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}
