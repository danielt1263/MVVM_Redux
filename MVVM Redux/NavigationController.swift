//
//  NavigationController.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/21/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import UIKit
import BasicRedux


class NavigationController: UINavigationController, Observer {

	override func loadView() {
		super.loadView()
		let undoButton = UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undo))
		setToolbarItems([undoButton], animated: false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		mainStore.subscribe(observer: self)
	}
	
	func undo() {
		
	}
	
	func handle(state: State) {
		let navState = state.navigationState
		let currentStackCount = childViewControllers.count
		if currentStackCount > navState.viewControllerStack.count {
			for _ in 0..<(currentStackCount - navState.viewControllerStack.count) {
				popViewController(animated: true)
			}
		}
		else if currentStackCount < navState.viewControllerStack.count {
			for vc in navState.viewControllerStack[currentStackCount ..< navState.viewControllerStack.count] {
				let controller = storyboard!.instantiateViewController(withIdentifier: vc.rawValue)
				pushViewController(controller, animated: true)
			}
		}
		else if navState.viewControllerStack.last?.rawValue != childViewControllers.last?.restorationIdentifier {
			fatalError("NOT HANDLED: Attempted to go back and forward down different path")
		}
		
		if let alert = state.navigationState.shouldDisplayAlert {
			if let presentedAlert = presentedViewController as? UIAlertController {
				if alert.message != presentedAlert.message {
					fatalError("NOT HANDLED: Attempted to present alert on an alert")
				}
			}
			else {
				displayErrorAlert(alert.message)
			}
		}
		else {
			if presentedViewController is UIAlertController {
				dismiss(animated: true, completion: nil)
			}
		}
	}

	private func displayErrorAlert(_ message: String) {
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
			mainStore.dispatch(action: .exitedErrorAlert)
		})
		present(alert, animated: true, completion: nil)
	}
	
}


extension NavigationController: UIToolbarDelegate {
	
}
