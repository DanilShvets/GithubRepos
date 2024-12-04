//
//  FavoritesManager.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import Foundation
import SwiftData
import Combine

@MainActor
class FavoritesManager: ObservableObject, @preconcurrency FavoritesService, StorageService {
  
  // MARK: - Public Variables
  var favoriteIds: Set<String> = []
  
  // MARK: - Private Variables
  private let modelContext: ModelContext
  
  // MARK: - Init
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
    loadFavoriteIds()
  }
  
  // MARK: - Public Methods
  func getFavorites() async -> [FavoriteRepository] {
    let descriptor = FetchDescriptor<FavoriteRepository>(sortBy: [SortDescriptor(\.orderInt)])
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  func addFavorite(_ repository: GithubRepository) async {
    let descriptor = FetchDescriptor<FavoriteRepository>(
      sortBy: [SortDescriptor(\FavoriteRepository.orderInt, order: .reverse)]
    )
    let currentMaxOrder = (try? modelContext.fetch(descriptor).first?.orderInt ?? 0) ?? 0
    let favorite = FavoriteRepository(repository: repository, order: currentMaxOrder + 1)
    modelContext.insert(favorite)
    favoriteIds.insert(repository.id)
    try? modelContext.save()
  }
  
  func deleteFavorite(_ repository: FavoriteRepository) async {
    modelContext.delete(repository)
    try? modelContext.save()
  }
  
  func updateOrder(_ favorites: [FavoriteRepository]) async {
    for (index, item) in favorites.enumerated() {
      item.orderInt = index
    }
    try? modelContext.save()
  }
  
  func loadFavoriteIds() {
    let descriptor = FetchDescriptor<FavoriteRepository>()
    if let favorites = try? modelContext.fetch(descriptor) {
      DispatchQueue.main.async {
        self.favoriteIds = Set(favorites.map { $0.parentId })
      }
    }
  }
}
