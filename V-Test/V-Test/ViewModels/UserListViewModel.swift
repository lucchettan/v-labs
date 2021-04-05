//
//  UserListViewModel.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import Foundation
import Combine
import OWOWKit

final class UserListViewModel: ObservableObject {
    
    // MARK: State
    
    /// 🗑 Combine cancellables.
    private var cancellables = Set<AnyCancellable>()
    
    /// The users.
    var users: [User] { usersFetchState.result ?? [] }
    
    /// The progress of fetching the users.
    @Published var usersFetchState: OperationState<[User], Error>

    
    // MARK: Init
    
    /// 🌷
    init() {
        self.usersFetchState = .normal
        fetchUsers()
    }
    
    // MARK: Preview content
    
    /// 👀
    init(forPreviews: ()) {
        self.usersFetchState = .normal
        fetchUsers()
    }
    
    func fetchUsers() {
        NetWorkManager().getUsers()
            .convertToOperationState()
            .receive(on: DispatchQueue.main)
            .weakAssign(to: \.usersFetchState, on: self)
            .store(in: &cancellables)
    }
}
