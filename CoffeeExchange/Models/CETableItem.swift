//
//  CETableElement.swift
//  CoffeeExchange
//
//  Created by Hershal Bhave on 2016-05-02.
//  Copyright © 2016 Hershal Bhave. All rights reserved.
//

import Foundation

protocol CETableItem {
    var visible: Bool { get }
    var cellText: String { get }
    func action()
}

