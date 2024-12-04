//
//  EditFavoriteRepositoryView.swift
//  GithubRepos
//
//  Created by Данил Швец on 03.12.2024.
//

import SwiftUI
import SwiftData

struct EditFavoriteRepositoryView: View {
  // MARK: - Public Variables
  @StateObject var viewModel: EditFavoriteRepositoryViewModel
  
  // MARK: - Private Types
  private struct Constants {
    static let spacing: CGFloat = 16
    static let stackSpacing: CGFloat = 8
    static let horizontalPadding: CGFloat = 16
    
    static let labelColor = Color.secondary
    static let destructiveColor = Color.red
    
    static let namePlaceholder = "Введите название репозитория"
    static let descriptionPlaceholder = "Введите описание репозитория"
    
    static let alertTitle = "Несохраненные изменения"
    static let alertMessage = "У вас есть несохраненные изменения. Хотите выйти без сохранения?"
    static let cancelButtonTitle = "Отменить"
    static let discardButtonTitle = "Выйти без сохранения"
  }
  
  // MARK: - Private Variables
  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL
  @State private var showingAlert = false
  
  // MARK: - Body
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: Constants.spacing) {
          VStack(alignment: .leading, spacing: Constants.stackSpacing) {
            Text("Название")
              .font(.headline.weight(.semibold))
            TextField(Constants.namePlaceholder, text: $viewModel.name)
              .textFieldStyle(.roundedBorder)
              .onChange(of: viewModel.name) { _, _ in
                viewModel.updateValidation()
              }
          }
          
          VStack(alignment: .leading, spacing: Constants.stackSpacing) {
            Text("Описание")
              .font(.headline.weight(.semibold))
            TextField(Constants.descriptionPlaceholder, text: $viewModel.description, axis: .vertical)
              .textFieldStyle(.roundedBorder)
              .lineLimit(1...10)
              .onChange(of: viewModel.description) { _, _ in
                viewModel.updateValidation()
              }
          }
          
          HStack {
            Text("@\(viewModel.repository.ownerLogin)")
              .foregroundColor(Constants.labelColor)
            
            Spacer()
            
            Button {
              if let url = viewModel.repositoryURL {
                openURL(url)
              }
            } label: {
              Image(systemName: "arrow.up.forward.app")
            }
          }
        }
        .padding(.horizontal, Constants.horizontalPadding)
      }
      .navigationTitle("Редактирование")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Отменить") {
            if viewModel.isEdited {
              showingAlert = true
            } else {
              dismiss()
            }
          }
        }
        
        ToolbarItem(placement: .confirmationAction) {
          if viewModel.isValid {
            Button("Сохранить") {
              viewModel.save()
              dismiss()
            }
            .font(.body.bold())
          }
        }
      }
      .alert(Constants.alertTitle, isPresented: $showingAlert) {
        Button(role: .destructive) {
          dismiss()
        } label: {
          Text(Constants.discardButtonTitle)
        }
        .foregroundColor(Constants.destructiveColor)
        
        Button(role: .cancel) {
        } label: {
          Text(Constants.cancelButtonTitle)
            .fontWeight(.bold)
        }
      } message: {
        Text(Constants.alertMessage)
      }
    }
  }
}
