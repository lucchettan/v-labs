//
//  UsersListView.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import SwiftUI
import UIKit

/// The view to display all users
struct UsersListView: View {
    @ObservedObject var viewModel: UserListViewModel

    var body: some View {
        if viewModel.users.isEmpty {
            ProgressView()
                .foregroundColor(.green)
        } else {
            NavigationView {
                List(viewModel.users, id: \.self) { user in
                    NavigationLink(destination: UserPageView(viewModel: UserPageViewModel(user: user))) {
                        UserListCell(user: user)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                }
                .navigationTitle("Discover")
            }
        }
    }
}

struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView(viewModel: UserListViewModel(forPreviews: ()))
    }
}
