//
//  Payback.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/15/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import Foundation


struct Payback: Hashable {

	let id: Int
	let firstName: String
	let lastName: String
	let amount: Double

	var hashValue: Int {
		return id.hashValue
	}
}

extension Payback {
	
	init(dictionary: [String: AnyObject]) {
		id = dictionary["id"] as! Int
		firstName = dictionary["firstName"] as! String
		lastName = dictionary["lastName"] as! String
		amount = dictionary["amount"] as! Double
	}
	
	var dictionary: [String: AnyObject] {
		return [
			"id": id as AnyObject,
			"firstName": firstName as AnyObject,
			"lastName": lastName as AnyObject,
			"amount": amount as AnyObject,
		]
	}
}

func ==(lhs: Payback, rhs: Payback) -> Bool {
	return lhs.id == rhs.id
}
