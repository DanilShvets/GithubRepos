//
//  FavoritesManagerTests.swift
//  GithubReposTests
//
//  Created by Данил Швец on 04.12.2024.
//

import XCTest
import SwiftData
@testable import GithubRepos

@MainActor
final class FavoritesManagerTests: XCTestCase {
  private var manager: FavoritesManager!
  private var modelContainer: ModelContainer!
  
  override func setUp() async throws {
    try await super.setUp()
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    modelContainer = try ModelContainer(for: FavoriteRepository.self, configurations: config)
    manager = FavoritesManager(modelContext: modelContainer.mainContext)
  }
  
  override func tearDown() {
    manager = nil
    modelContainer = nil
    super.tearDown()
  }
  
  func testAddFavorite() async throws {
    let repository = createTestRepository()
    
    await manager.addFavorite(repository)
    let favorites = await manager.getFavorites()
    
    XCTAssertEqual(favorites.count, 1)
    XCTAssertEqual(favorites.first?.name, repository.name)
    XCTAssertEqual(favorites.first?.parentId, repository.id)
    XCTAssertTrue(manager.favoriteIds.contains(repository.id))
  }
  
  func testDeleteFavorite() async throws {
    let repository = createTestRepository()
    await manager.addFavorite(repository)
    let favorites = await manager.getFavorites()
    
    await manager.deleteFavorite(favorites[0])
    let updatedFavorites = await manager.getFavorites()
    
    XCTAssertTrue(updatedFavorites.isEmpty)
  }
  
  func testGetFavorites() async throws {
    let repositories = [
      createTestRepository(),
      createTestRepository()
    ]
    
    for repo in repositories {
      await manager.addFavorite(repo)
    }
    let favorites = await manager.getFavorites()
    
    XCTAssertEqual(favorites.count, 2)
    XCTAssertEqual(Set(repositories.map(\.id)), Set(favorites.map(\.parentId)))
  }
  
  func testUpdateOrder() async throws {
    let repositories = createTestRepositories()
    for repo in repositories {
      await manager.addFavorite(repo)
    }
    var favorites = await manager.getFavorites()
    
    favorites.swapAt(0, 1)
    await manager.updateOrder(favorites)
    let updatedFavorites = await manager.getFavorites()
    
    XCTAssertEqual(updatedFavorites[0].name, "Second")
    XCTAssertEqual(updatedFavorites[1].name, "First")
    XCTAssertEqual(updatedFavorites[0].orderInt, 0)
    XCTAssertEqual(updatedFavorites[1].orderInt, 1)
  }
  
  private func createTestRepository() -> GithubRepository {
    let data = loadJSON(name: "repositories")
    guard let response = try? JSONDecoder().decode(GithubNetworkService.RepositorySearchResponse.self, from: data),
          let repository = response.items.first
    else {
      fatalError("Failed to decode test repository data")
    }
    
    return repository
  }
  
  private func createTestRepositories() -> [GithubRepository] {
    let data = loadJSON(name: "repositories-order")
    guard let response = try? JSONDecoder().decode(GithubNetworkService.RepositorySearchResponse.self, from: data)
    else {
      fatalError("Failed to decode test repository data")
    }
    
    return response.items
  }
}
