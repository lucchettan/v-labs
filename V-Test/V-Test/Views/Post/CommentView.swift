//
//  CommentView.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import SwiftUI

/// The view to display a comment in a list.
struct CommentView: View {
    @ObservedObject var viewModel: CommentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(self.viewModel.userName)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(viewModel.comment.body)
                .font(.footnote)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
            .foregroundColor(.green)
        )
        .padding()
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(viewModel:  .init(forPreviews: ()))
    }
}
