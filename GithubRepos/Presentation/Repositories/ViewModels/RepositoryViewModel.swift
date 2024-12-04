//
//  RepositoryViewModel.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import SwiftUI
import Combine
import SwiftData

@MainActor
class RepositoryViewModel: ObservableObject {
  // MARK: - Public Types
  enum LoadingState {
    case idle
    case loading
    case error
    case empty
    case loaded
  }
  
  // MARK: - Public Variables
  @Published var repositories: [GithubRepository] = []
  @Published var isLoading = false
  @Published var searchText: String = ""
  @Published var query: String = ""
  @Published var isToastShown = false
  @Published var loadingState: LoadingState = .idle
  let languages = ["Swift", "Python", "Java", "Ruby", "Go", "Kotlin", "C++", "JavaScript"]
  let storageService: FavoritesManager
  let modelContext: ModelContext
  var currentPage = 1
  
  // MARK: - Private Variables
  private let networkService: RepositoryService
  private let dependencies: Dependencies = Dependencies.shared
  private var loadingTask: Task<Void, Never>?
  
  // MARK: - Init
  
  init() {
    self.networkService = dependencies.networkService
    self.storageService = dependencies.storageService
    self.modelContext = dependencies.container.mainContext
  }
  
  init(storageService: FavoritesManager, context: ModelContext) {
    self.storageService = storageService
    self.modelContext = context
    self.networkService = Dependencies.shared.networkService
  }
  
  // MARK: - Public Methods
  func loadRepositories() {
    guard !isLoading else { return }
    
    isLoading = true
    loadingState = .loading
    
    loadingTask?.cancel()
    loadingTask = Task {
      do {
        try await withTimeout(seconds: 10) { [weak self] in
          guard let self else { return }
          
          let newRepositories = try await networkService.fetchRepositories(
            query: query,
            page: currentPage
          )
          
          if newRepositories.isEmpty && repositories.isEmpty {
            loadingState = .empty
          } else {
            repositories.append(contentsOf: newRepositories)
            currentPage += 1
            loadingState = .loaded
          }
        }
      } catch {
        loadingState = .error
      }
      isLoading = false
    }
  }
  
  func addFavorite(_ repo: GithubRepository) {
    Task {
      await storageService.addFavorite(repo)
    }
    showToast()
  }
  
  func updateSearchQuery() {
    query = searchText
    repositories = []
    currentPage = 1
    loadRepositories()
  }
  
  func isListHidden() -> Bool {
    repositories.isEmpty
  }
  
  func isQueryEmpty() -> Bool {
    query.isEmpty
  }
  
  private func showToast() {
    isToastShown = true
    
    Task {
      try? await Task.sleep(nanoseconds: 2_000_000_000)
      isToastShown = false
    }
  }
  
  private func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
      group.addTask {
        try await operation()
      }
      
      group.addTask {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        throw TimeoutError()
      }
      
      let result = try await group.next()!
      group.cancelAll()
      return result
    }
  }
}

struct TimeoutError: Error {}
