//
//  CommentViewModel.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation
import Combine
import OWOWKit

final class CommentViewModel: ObservableObject {
    
    // MARK: State
    
    /// 🌌🔭 The comment to start our researches on.
    let comment: Comment
    
    /// 🗑 Combine cancellables.
    private var cancellables = Set<AnyCancellable>()
    
    /// The users.
    var users: [User] { usersFetchState.result ?? [] }
    
    var userName: String {
        if let username =  users.first(where: { $0.email == comment.email })?.username {
            return username
        } else {
            print("@: FAILED RETRIEVING USER FROM: \(comment.email)")
            return comment.email
        }
    }
    /// The progress of fetching the users.
    @Published var usersFetchState: OperationState<[User], Error>

    
    // MARK: Init
    
    /// 🌷
    init(comment: Comment) {
        self.comment = comment
        self.usersFetchState = .normal
        fetchUsers()
    }
    
    // MARK: Preview content
    
    /// 👀
    init(forPreviews: ()) {
        self.comment = .example
        self.usersFetchState = .normal
        self.fetchUsers()
    }
    
    func fetchUsers() {
        NetWorkManager().getUsers()
            .convertToOperationState()
            .receive(on: DispatchQueue.main)
            .weakAssign(to: \.usersFetchState, on: self)
            .store(in: &cancellables)
    }
}
