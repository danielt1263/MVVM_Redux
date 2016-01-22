//
//  ReduxNavigation.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/19/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import BasicRedux


enum NavigationAction: Action {
	case AlertDismissed
}

struct NavigationState {
	
	var viewControllerStack = [ViewController.MasterTableViewController]
	var shouldDisplayAlert: Alert?
}

struct Alert {
	var message: String = ""
}

enum ViewController: String {
	case MasterTableViewController = "MasterTableViewController"
	case DetailViewController = "DetailViewController"	
}

func navigationReducer(var state: State, action: Action) -> State {
	guard let action = action as? NavigationAction else { return state }
	switch action {
	case .AlertDismissed:
		state.navigationState.shouldDisplayAlert = nil
	}
	return state
}
