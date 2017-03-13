//
//  PaybackCollection.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/25/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//


struct PaybackCollection {
	
	var paybacks: [Payback] = []
	
	mutating func addPaybackWithFirstName(_ firstName: String, lastName: String, amount: Double) {
		let id = uniqueId
		uniqueId += 1
		let payback = Payback(id: id, firstName: firstName, lastName: lastName, amount: amount)
		paybacks.append(payback)
	}
	
	mutating func removeAtIndex(_ index: Int) {
		paybacks.remove(at: index)
	}
	
	fileprivate var uniqueId = 0
	
}

extension PaybackCollection {
	
	init(dictionary: [String: Any]) {
		let paybackDicts = dictionary["paybacks"]! as! [[String: AnyObject]]
		paybacks = paybackDicts.map { Payback(dictionary: $0) }
		uniqueId = dictionary["uniqueId"]! as! Int
	}
	
	var dictionary: [String: Any] {
		return [
			"paybacks": paybacks.map { $0.dictionary },
			"uniqueId": uniqueId
		]
	}
	
}
