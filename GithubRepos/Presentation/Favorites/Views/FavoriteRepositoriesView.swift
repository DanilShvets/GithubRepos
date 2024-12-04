//
//  FavoriteRepositoriesView.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import SwiftUI
import SwiftData

struct FavoriteRepositoriesView: View {
  @StateObject var viewModel: FavoriteRepositoriesViewModel
  
  private struct Constants {
    static let listSpacing: CGFloat = 16
    static let deleteIcon = "trash.fill"
    static let editIcon = "pencil"
    static let magnifierSize: CGFloat = 40
    static let spacing: CGFloat = 24
    
    static let alertTitle = "Удаление"
    static let alertMessage = "Вы уверены, что хотите удалить этот репозиторий?"
    static let deleteButtonTitle = "Удалить"
    static let cancelButtonTitle = "Отмена"
  }
  
  @StateObject private var onboardingService = OnboardingService()
  @State private var editingRepository: FavoriteRepository?
  @State private var repositoryToDelete: FavoriteRepository?
  @State private var isDeleteAlertPresented: Bool = false
  @State private var isOnboardingHidden = true
  
  var body: some View {
    VStack {
      if viewModel.favorites.isEmpty {
        VStack(spacing: Constants.spacing) {
          Image(systemName: "bookmark.slash")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Constants.magnifierSize)
            .foregroundColor(.secondary)
          
          Text("Нет избранных репозиториев")
            .font(.headline)
            .padding(.horizontal, Constants.spacing)
            .multilineTextAlignment(.center)
        }
        .padding()
      } else {
        List {
          ForEach(viewModel.favorites, id: \.id) { repo in
            RepositoryRowView(
              viewModel: .init(
                repository: .init(favorite: repo),
                showAddButton: false,
                onFavoriteToggle: {}
              )
            )
            .swipeActions(edge: .leading) {
              Button {
                editingRepository = repo
              } label: {
                Label("Изменить", systemImage: Constants.editIcon)
              }
              .tint(.orange)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
              Button {
                repositoryToDelete = repo
                isDeleteAlertPresented = true
              } label: {
                Label("Удалить", systemImage: Constants.deleteIcon)
              }
              .tint(.red)
            }
          }
          .onMove(perform: viewModel.moveItems)
        }
        .listStyle(.plain)
      }
    }
    .navigationTitle(!onboardingService.isFavoritesOnboardingShown && !isOnboardingHidden && !viewModel.favorites.isEmpty ? "" : "Избранное")
    .navigationBarBackButtonHidden(!onboardingService.isFavoritesOnboardingShown && !isOnboardingHidden  && !viewModel.favorites.isEmpty)
    .toolbar {
      if !viewModel.favorites.isEmpty {
        Menu {
          ForEach(FavoriteRepositoriesViewModel.SortOption.allCases, id: \.self) { option in
            Button {
              viewModel.sortItems(by: option)
            } label: {
              Text(option.rawValue)
            }
          }
        } label: {
          Image(systemName: "arrow.up.arrow.down")
            .opacity(!onboardingService.isFavoritesOnboardingShown && !isOnboardingHidden ? 0 : 1)
        }
      }
    }
    .fullScreenCover(item: $editingRepository) {
      editingRepository = nil
    } content: { repository in
      EditFavoriteRepositoryView(
        viewModel: .init(
          repository: repository,
          dependencies: Dependencies.shared
        )
      )
    }
    .alert(
      Constants.alertTitle,
      isPresented: $isDeleteAlertPresented,
      actions: {
        Button(role: .destructive) {
          if let repo = repositoryToDelete {
            viewModel.deleteItem(repo)
          }
          repositoryToDelete = nil
        } label: {
          Text(Constants.deleteButtonTitle)
        }
        
        Button(role: .cancel) {
          repositoryToDelete = nil
        } label: {
          Text(Constants.cancelButtonTitle)
        }
      },
      message: {
        Text(Constants.alertMessage)
      }
    )
    .overlay {
      if !onboardingService.isFavoritesOnboardingShown && !isOnboardingHidden && !viewModel.favorites.isEmpty {
        FavoritesOnboardingView(service: onboardingService)
          .ignoresSafeArea()
      }
    }
    .onAppear {
      if !onboardingService.isFavoritesOnboardingShown {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          withAnimation {
            self.isOnboardingHidden = false
          }
        }
      }
    }
  }
}
