//
//  Photo.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation

struct Photo: Codable, Hashable {
    let albumId     : Int
    let id          : Int
    let title       : String
    let url         : String
    let thumbnailUrl: String
}

extension Photo {
    static let example = Photo(
        albumId: 1,
        id: 1,
        title: "accusamus beatae ad facilis cum similique qui sunt",
        url: "https://via.placeholder.com/600/92c952",
        thumbnailUrl: "https://via.placeholder.com/150/92c952"
    )
}
