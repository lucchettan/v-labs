//
//  UserListCell.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import SwiftUI

/// The view to display a user in a list.
struct UserListCell: View {
    let user: User
    var body: some View {
        HStack {
            VStack(spacing: 10) {
                HStack(alignment: .center) {
                    Text("@\(user.username)")
                        .font(.system(size: 20, weight: .heavy))
                    
                    Spacer()
                    
                    Text("\(Image(systemName: "mappin"))  \(user.address.city)")
                        .font(.system(size: 15, weight: .thin))
                }
                
                HStack {
                    Text("\(user.company.name)")
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .frame(
            width: UIScreen.main.bounds.width * 0.85,
            height: UIScreen.main.bounds.height * 0.1
        )
    }
}

struct UserListCell_Previews: PreviewProvider {
    static var previews: some View {
        UserListCell(user: User.example)
    }
}
