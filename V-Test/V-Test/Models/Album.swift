//
//  Album.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation

struct Album: Codable, Hashable {
    let userId  : Int
    let id      : Int
    let title   : String
}

extension Album {
    static let example = Album(
        userId: 1,
        id: 1,
        title: "quidem molestiae enim"
    )
}
