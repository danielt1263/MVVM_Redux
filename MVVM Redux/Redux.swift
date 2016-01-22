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

	var masterState = MasterState()
	var detailState: DetailState?
	var navigationState = NavigationState()

	mutating func createPayback() {
		let payback = detailState!.payback
		masterState.paybacks.append(payback)
		navigationState.viewControllerStack.popLast()
		detailState = nil
	}

}

let mainStore = Store(state: State(), reducer: combineReducers([navigationReducer, masterReducer, detailReducer]), middleware: [])

typealias MyStore = Store<State>

func actionLogMiddleware(next: MyStore.Dispatcher, state: () -> State) -> MyStore.Dispatcher {
	return { action in
		print(action)
		next(action: action)
	}
}

func logStateMiddleware(next: MyStore.Dispatcher, state: () -> State) -> MyStore.Dispatcher {
	return { action in
		print(state())
		next(action: action)
	}
}