//
//  FavoriteRepositoriesViewModel.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import SwiftData
import SwiftUI
import Combine

@MainActor
final class FavoriteRepositoriesViewModel: ObservableObject {
  // MARK: - Public Types
  enum SortOption: String, CaseIterable {
    case dateDesc = "По дате сохранения (новее)"
    case dateAsc = "По дате сохранения (старее)"
    case nameAsc = "По имени (A-Z)"
    case nameDesc = "По имени (Z-A)"
    case starsDesc = "По звездам (больше)"
    case starsAsc = "По звездам (меньше)"
  }
  
  // MARK: - Public Variables
  @Published var favorites: [FavoriteRepository] = []
  let context: ModelContext
  
  // MARK: - Private Variables
  private let storageService: StorageService
  private let dependencies: Dependencies = Dependencies.shared
  
  // MARK: - Init
      
  init() {
    self.storageService = dependencies.storageService
    self.context = dependencies.container.mainContext
    fetchItems()
  }
  
  init(storageService: StorageService, context: ModelContext) {
    self.storageService = storageService
    self.context = context
    fetchItems()
  }
  
  // MARK: - Public Methods
  func deleteItem(_ repo: FavoriteRepository) {
    if let index = favorites.firstIndex(where: { $0.id == repo.id }) {
      withAnimation {
        favorites.remove(at: index)
      }
    }
    Task {
      await storageService.deleteFavorite(repo)
    }
  }
  
  func moveItems(from source: IndexSet, to destination: Int) {
    favorites.move(fromOffsets: source, toOffset: destination)
    Task {
      await storageService.updateOrder(favorites)
    }
  }
  
  func sortItems(by option: SortOption) {
    switch option {
    case .dateDesc:
      withAnimation {
        favorites.sort(by: { $0.addToFavoriteDate > $1.addToFavoriteDate })
      }
    case .dateAsc:
      withAnimation {
        favorites.sort(by: { $0.addToFavoriteDate < $1.addToFavoriteDate })
      }
    case .nameAsc:
      withAnimation {
        favorites.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
      }
    case .nameDesc:
      withAnimation {
        favorites.sort(by: { $0.name.lowercased() > $1.name.lowercased() })
      }
    case .starsDesc:
      withAnimation {
        favorites.sort(by: { $0.stargazersCount > $1.stargazersCount })
      }
    case .starsAsc:
      withAnimation {
        favorites.sort(by: { $0.stargazersCount < $1.stargazersCount })
      }
    }
    updateOrder()
  }
  
  // MARK: - Private Methods
  private func fetchItems() {
    Task {
      favorites = await storageService.getFavorites()
    }
  }
  
  private func updateOrder() {
    Task {
      await storageService.updateOrder(favorites)
    }
  }
}
