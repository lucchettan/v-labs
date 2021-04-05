//
//  UserPageView.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import SwiftUI
import MapKit

/// The view to display a user infos.
struct UserPageView: View {
    @ObservedObject var viewModel: UserPageViewModel

    var body: some View {
        VStack {
            description
            
             albums
                .padding(.top, 15)

             posts
                .padding(.top, 15)

        }
        .padding(.horizontal, 15)
        .padding(.top, 15)
        .navigationTitle("@" + viewModel.user.username)
    }
    
    // MARK: Components
    var description : some View {
        return HStack {
            VStack(alignment: .leading, spacing: 7) {
                Text(viewModel.user.name)
                    .foregroundColor(.white)
                    .bold()
                
                Button(action: {
                    let phone = "tel://"
                    let phoneNumberformatted = phone + viewModel.user.phone
                    guard let url = URL(string: phoneNumberformatted) else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text(viewModel.user.phone)
                }
                
                Link(destination: URL(string: "https://" + viewModel.user.website)!) {
                    Text("\(Image(systemName: "globe"))\(viewModel.user.website)")
                        .underline()
                }

            }
            
            Spacer()
        }
        .padding()

        .background(
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.green)
        )
    }
    
    var albums : some View {
        return VStack {
            HStack {
                Text("Explore Albums")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.green)

                Spacer()
            }
            
            Divider()
            
            List(viewModel.albums, id: \.self) { album in
                NavigationLink(destination: AlbumView(viewModel: AlbumViewModel(album: album))) {
                    Text(album.title)
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.2)
        }
    }
    
    var posts : some View {
        return VStack {
            HStack {
                Text("Explore Posts")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(.green)
                Spacer()
            }
            
            Divider()
            
            List(viewModel.posts, id: \.self) { post in
                NavigationLink(destination: PostView(viewModel: PostViewModel(post: post))) {
                    Text(post.title)
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.2)
        }
    }
}

struct UserPageView_Previews: PreviewProvider {
    static var previews: some View {
        UserPageView(viewModel: UserPageViewModel(forPreviews: ()))
    }
}
