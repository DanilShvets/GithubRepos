//
//  Dependencies.swift
//  GithubRepos
//
//  Created by Данил Швец on 03.12.2024.
//

import Foundation
import SwiftData

@MainActor
final class Dependencies {
  let networkService: RepositoryService
  let storageService: FavoritesManager
  let container: ModelContainer
  
  static let shared = Dependencies()
  
  private init() {
    do {
      self.container = try ModelContainer(for: FavoriteRepository.self)
      self.networkService = GithubNetworkService()
      self.storageService = FavoritesManager(modelContext: container.mainContext)
    } catch {
      let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
      self.container = try! ModelContainer(for: FavoriteRepository.self, configurations: configuration)
      self.networkService = GithubNetworkService()
      self.storageService = FavoritesManager(modelContext: container.mainContext)
    }
  }
}
