//
//  PostView.swift
//  V-Test
//
//  Created by mac on 03/04/2021.
//

import SwiftUI
import OWOWKit

/// The view to display a Post.
struct PostView: View {
    @ObservedObject var viewModel: PostViewModel
    
    // MARK: Input values
    @State var nameInput    = ""
    @State var emailInput   = ""
    @State var bodyInput    = ""
    @State var showSentMessage = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Post")
                    .font(.title)
                    .bold()
                    .foregroundColor(.green)
                
                Text(viewModel.post.title)
                    .font(.system(size: 30, weight: .medium))
                
                Text(viewModel.post.body)
                    .font(.system(size: 15, weight: .thin))
                
                Button(action: { viewModel.tapModal() }) {
                    Text("See comments \(Image(systemName: "text.magnifyingglass"))")
                }
                .foregroundColor(.green)
                .accessibilityIdentifier("SeeComments")

                form
                
                Spacer()
            }
            .padding(.horizontal, 10)
        }
        .padding(.top, -20)
        .sheet(isPresented: $viewModel.isDisplayinComments, content: { commentList })
        .alert(isPresented: $showSentMessage) {
            Alert(
                title: Text("On the way!"),
                message: Text("🎊 Your comment has been sent. 🎊"),
                dismissButton: .default(Text("Ok"))
            )
        }
    }
    
    // MARK: Components
    var commentList: some View {
        return ZStack(alignment: .topTrailing) {
            ScrollView {
                ForEach(viewModel.comments, id: \.self) { comment in
                    CommentView(viewModel: CommentViewModel(comment: comment))
                }
                .padding(.top, 45)
            }
            
            Button(action: { viewModel.tapModal() }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.gray)
                    .padding()
            }
            .accessibilityIdentifier("Close")
        }
    }
    
    var form : some View {
        return Form {
            TextField("Enter Name", text: $nameInput)
            
            TextField("Enter Email", text: $emailInput)

            TextField("Comment here", text: $bodyInput)

            Button(action: {
                if self.isCommentComplete() {
                    viewModel.sendComment(comment: generateTheComment())
                    emptyTextFields()
                    self.showSentMessage.toggle()
                    hideKeyboard()
                }
            }) {
                Text("Add comment \(Image(systemName: "paperplane.circle.fill"))")
            }
            .foregroundColor(self.isCommentComplete() ? .green : .gray)
            .accessibilityIdentifier("AddComment")
        }
        .cornerRadius(10)
        .frame(height: 250)
    }
    
    // MARK: Private functions
    private func isCommentComplete() -> Bool {
        if bodyInput.isEmpty {
            return false
        }
        
        if emailInput.isEmpty {
            return false
        }
        
        if nameInput.isEmpty {
            return false
        }
        
        return true
    }
    
    private func emptyTextFields(){
        bodyInput = ""
        emailInput = ""
        nameInput = ""
    }
    
    private func generateTheComment() -> Comment {
        let comment = Comment(
            postId: viewModel.post.id,
            id: Int.random(in: 0..<50),
            name: nameInput,
            email: emailInput,
            body: bodyInput)
        
        return comment
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(viewModel: PostViewModel(forPreviews: ()))
    }
}


/// View extension to fix  a bug, unselect textfield and hide keyboard.
/// After clicking send a textfield was still active.
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
