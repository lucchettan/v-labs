//
//  Post.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation

struct Post: Codable, Hashable {
    let userId      : Int
    let id          : Int
    let title       : String
    let body        : String
    var comments    : [Comment]?
}

extension Post {
    static let example = Post(
        userId: 1,
        id: 1,
        title: "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
        body: "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto",
        comments: nil
    )
}
