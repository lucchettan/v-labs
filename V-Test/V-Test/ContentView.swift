//
//  ContentView.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: UserListViewModel
    
    var body: some View {
        VStack {
            List(viewModel.users, id: \.self) { user in
                Text(user.name)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: UserListViewModel())
    }
}
