//
//  ContentView.swift
//  GithubRepos
//
//  Created by Данил Швец on 29.11.2024.
//

import SwiftUI
import Combine
import SwiftData

struct RepositoryListView: View {
  // MARK: - Public Types
  enum Route {
    case favorites
  }
  
  // MARK: - Public Variables
  @StateObject var viewModel: RepositoryViewModel
  
  // MARK: - Private Types
  private struct Constants {
    static let bookmarkColor = Color(red: 0.8, green: 0.2, blue: 0.2)
  }
  
  // MARK: - Private Variables
  @State private var navigationPath = NavigationPath()
  @FocusState private var isSearchFocused: Bool
  @State private var bookmarkButtonFrame: CGRect = .zero
  @StateObject private var onboardingService = OnboardingService()
  @State private var isOnboardingHidden: Bool = true
  
  // MARK: - Body
  var body: some View {
    NavigationStack(path: $navigationPath) {
      VStack(spacing: 16) {
        if !viewModel.isListHidden() {
          reposList
        }
        else {
          Group {
            if viewModel.isQueryEmpty() {
              EmptySearchView(
                languages: viewModel.languages,
                onLanguageSelect: { language in
                  hideKeyboard()
                  isSearchFocused = false
                  viewModel.searchText = language
                  viewModel.updateSearchQuery()
                },
                loadingState: viewModel.loadingState,
                isSearchFocused: isSearchFocused
              )
            } else if viewModel.loadingState == .loading {
              ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
              EmptySearchView(
                languages: viewModel.languages,
                onLanguageSelect: { language in
                  hideKeyboard()
                  isSearchFocused = false
                  viewModel.searchText = language
                  viewModel.updateSearchQuery()
                },
                loadingState: viewModel.loadingState,
                isSearchFocused: isSearchFocused
              )
            }
          }
        }
      }
      .navigationTitle("Репозитории")
      .searchable(text: $viewModel.searchText)
      .searchFocused($isSearchFocused)
      .onSubmit(of: .search) {
        withAnimation {
          viewModel.updateSearchQuery()
        }
      }
      .onChange(of: viewModel.searchText) { oldValue, newValue in
        if newValue.isEmpty {
          viewModel.repositories = []
          viewModel.query = ""
          viewModel.loadingState = .idle
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            navigationPath.append(Route.favorites)
          } label: {
            Image(systemName: "bookmark.fill")
              .foregroundStyle(Constants.bookmarkColor)
          }
          .overlay {
            GeometryReader { geometry in
              Color.clear.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                  self.bookmarkButtonFrame = geometry.frame(in: .global)
                  withAnimation {
                    self.isOnboardingHidden = false
                  }
                }
              }
            }
          }
        }
      }
      .navigationDestination(for: Route.self) { route in
        switch route {
        case .favorites:
          FavoriteRepositoriesView(
            viewModel: .init()
          )
        }
      }
    }
    .overlay {
      if !onboardingService.isOnboardingShown && !isOnboardingHidden {
        OnboardingView(service: onboardingService, bookmarkFrame: bookmarkButtonFrame)
          .ignoresSafeArea()
      }
    }
    .overlay(alignment: .bottom) {
      Group {
        if viewModel.isToastShown {
          ToastView()
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
      }
      .animation(.easeInOut(duration: 0.3), value: viewModel.isToastShown)
    }
  }
  
  // MARK: - Private Views
  private var reposList: some View {
    List {
      ForEach(viewModel.repositories, id: \.uniqueId) { repo in
        RepositoryRowView(
          viewModel: .init(
            repository: repo,
            onFavoriteToggle: {
              viewModel.addFavorite(repo)
            }
          )
        )
        .onAppear {
          if repo == viewModel.repositories.last {
            viewModel.loadRepositories()
          }
        }
      }
      
      if viewModel.isLoading {
        HStack {
          Spacer()
          ProgressView()
          Spacer()
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .id(UUID())
      }
    }
    .listStyle(.plain)
    .buttonStyle(.plain)
  }
}

extension View {
  func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
