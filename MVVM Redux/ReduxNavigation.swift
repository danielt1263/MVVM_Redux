//
//  ReduxNavigation.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/19/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import BasicRedux


struct NavigationState {
	
	var viewControllerStack = [ViewController.masterTableViewController]
	var shouldDisplayAlert: Alert?
    
}

extension NavigationState {
    
    init(dictionary: [String: Any]) {
		let stack = dictionary["viewControllerStack"] as! [String]
		viewControllerStack = stack.map { ViewController(rawValue: $0)! }
		if let alert = dictionary["shouldDisplayAlert"] as? [String: AnyObject] {
			shouldDisplayAlert = Alert(dictionary: alert)
		}
    }
	
	var dictionary: [String: Any] {
		var result: [String: Any] = [
			"viewControllerStack": viewControllerStack.map { $0.rawValue }
		]
		if let alert = shouldDisplayAlert {
			result["shouldDisplayAlert"] = alert.dictionary as AnyObject?
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
		return ["message": message as AnyObject]
	}
	
}


enum ViewController: String {
	case masterTableViewController = "MasterTableViewController"
	case detailViewController = "DetailViewController"
}
