//
//  Words.swift
//  Acronym
//
//  Created by Naina Sai Tipparti on 3/10/17.
//  Copyright © 2017 Naina Sai Tipparti. All rights reserved.
//

import Foundation

class Words {
    var name: String?
    var freq: Int
    var since: Int

    init(name: String?, freq: Int, since: Int) {
        self.name = name
        self.freq = freq
        self.since = since
    }
}
