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

extension NavigationState {
    
    init(dictionary: [String: AnyObject]) {
		let stack = dictionary["viewControllerStack"] as! [String]
		viewControllerStack = stack.map { ViewController(rawValue: $0)! }
		if let alert = dictionary["shouldDisplayAlert"] as? [String: AnyObject] {
			shouldDisplayAlert = Alert(dictionary: alert)
		}
    }
	
	var dictionary: [String: AnyObject] {
		var result: [String: AnyObject] = [
			"viewControllerStack": viewControllerStack.map { $0.rawValue }
		]
		if let alert = shouldDisplayAlert {
			result["shouldDisplayAlert"] = alert.dictionary
		}
		return result
	}
}


struct Alert {

	var message: String = ""

}

extension Alert {
	
	init(dictionary: [String: AnyObject]) {
		message = dictionary["message"] as! String
	}
	
	var dictionary: [String: AnyObject] {
		return ["message": message]
	}
	
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
