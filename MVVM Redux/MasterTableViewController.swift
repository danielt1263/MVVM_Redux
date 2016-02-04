//
//  MasterTableViewController.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/15/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import UIKit
import BasicRedux


class MasterTableViewController: UITableViewController {
	
	@IBOutlet weak var addBarButtonItem: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.rightBarButtonItem = editButtonItem()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		unsubscribe = mainStore.subscribe { [weak self] state in
			self?.updateWithState(state)
		}
	}
	
	override func viewWillDisappear(animated: Bool) {
		unsubscribe()
		super.viewWillDisappear(animated)
	}

	// MARK: - Table view data source
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

		let item = items[indexPath.row]
		cell.textLabel?.text = item.firstName + " " + String(item.lastName.characters.first!) + "."
		cell.detailTextLabel?.text = "$" + String(item.amount)

		return cell
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			mainStore.dispatch { state in
				state.paybackCollection.removeAtIndex(indexPath.row)
				return
			}
		}
	}

	@IBAction func addAction(sender: AnyObject) {
		mainStore.dispatch { state in
			state.navigationState.viewControllerStack.append(.DetailViewController)
			state.detailState = DetailState()
		}
	}
	
	private func updateWithState(state: State) {
		let newItems = state.paybackCollection.paybacks
		var arrayCompare = ArrayCompare<Payback>()
		arrayCompare.old = items
		arrayCompare.new = newItems
		arrayCompare.insertBlock = { _, at in
			self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: at, inSection: 0)], withRowAnimation: .Bottom)
		}
		arrayCompare.removeBlock = { _, from in
			self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: from, inSection: 0)], withRowAnimation: .Automatic)
		}
		arrayCompare.moveBlock = { _, from, to in
			self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: from, inSection: 0), toIndexPath: NSIndexPath(forRow: to, inSection: 0))
		}
		items = newItems
		tableView.beginUpdates()
		arrayCompare.run()
		tableView.endUpdates()
	}

	private var unsubscribe: MainStore.Unsubscriber = { }
	private var items: [Payback] = []

}

//Snagged from http://www.swift-studies.com/blog/2015/5/15/swift-coding-challenge-incremental-updates-to-views

struct ArrayCompare<T: Hashable> {

	var old: [T] = []
	var new: [T] = []

	var insertBlock: (insert: T, at: Int) -> Void = { _, _ in }
	var removeBlock: (remove: T, from: Int) -> Void = { _, _ in }
	var moveBlock: (move: T, from: Int, to: Int) -> Void = { _, _, _ in }

	func run() {
		var newPositions: [T: Int] = [:]
		for (index, obj) in new.enumerate() {
			newPositions[obj] = index
		}

		for (index, obj) in old.enumerate() {
			if let newPosition = newPositions[obj] {
				if index != newPosition {
					moveBlock(move: obj, from: index, to: newPosition)
				}
				newPositions.removeValueForKey(obj)
			}
			else {
				removeBlock(remove: obj, from: index)
			}
		}

		for (obj, position) in newPositions {
			insertBlock(insert: obj, at: position)
		}
	}
}
