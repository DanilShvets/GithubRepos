//
//  FavoriteRepositoriesViewModelTests.swift
//  GithubReposTests
//
//  Created by Данил Швец on 04.12.2024.
//

import XCTest
import SwiftData
@testable import GithubRepos

@MainActor
class MockStorageService: StorageService {
  private var favorites: [FavoriteRepository] = []
  
  func getFavorites() async -> [FavoriteRepository] {
    favorites
  }
  
  func addFavorite(_ repository: GithubRepository) async {
    let favorite = FavoriteRepository(repository: repository, order: favorites.count)
    favorites.append(favorite)
  }
  
  func deleteFavorite(_ repository: FavoriteRepository) async {
    favorites.removeAll { $0.id == repository.id }
  }
  
  func updateOrder(_ favorites: [FavoriteRepository]) async {
    for (index, item) in favorites.enumerated() {
      item.orderInt = index
    }
    self.favorites = favorites
  }
}

@MainActor
final class FavoriteRepositoriesViewModelTests: XCTestCase {
  private var viewModel: FavoriteRepositoriesViewModel!
  private var mockStorage: MockStorageService!
  
  override func setUp() async throws {
    try await super.setUp()
    mockStorage = MockStorageService()
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: FavoriteRepository.self, configurations: config)
    viewModel = .init(storageService: mockStorage, context: container.mainContext)
  }
  
  override func tearDown() {
    viewModel = nil
    mockStorage = nil
    super.tearDown()
  }
  
  func testDeleteRepository() async throws {
    let data = loadJSON(name: "repositories")
    let repository = try JSONDecoder().decode(GithubNetworkService.RepositorySearchResponse.self, from: data).items.first!
    
    await mockStorage.addFavorite(repository)
    let favorites = await mockStorage.getFavorites()
    XCTAssertEqual(favorites.count, 1)
    
    viewModel.deleteItem(favorites[0])
    try await Task.sleep(nanoseconds: 1_000_000_000)
    let updatedFavorites = await mockStorage.getFavorites()
    XCTAssertTrue(updatedFavorites.isEmpty)
  }
  
  func testMoveItems() async throws {
    let data = loadJSON(name: "repositories-order")
    let repositories = try JSONDecoder().decode(GithubNetworkService.RepositorySearchResponse.self, from: data).items
    
    for repo in repositories {
      await mockStorage.addFavorite(repo)
    }
    viewModel.favorites = await mockStorage.getFavorites()
    
    viewModel.moveItems(from: IndexSet(integer: 1), to: 0)
    try await Task.sleep(nanoseconds: 1_000_000_000)
    try viewModel.context.save()
    
    let updatedFavorites = await mockStorage.getFavorites()
    XCTAssertEqual(updatedFavorites[0].name, "Second")
    XCTAssertEqual(updatedFavorites[1].name, "First")
    XCTAssertEqual(viewModel.favorites[0].orderInt, 0)
    XCTAssertEqual(viewModel.favorites[1].orderInt, 1)
  }
  
  func testSortByDateDesc() async throws {
    let data = loadJSON(name: "repositories-order")
    let repositories = try JSONDecoder().decode(GithubNetworkService.RepositorySearchResponse.self, from: data).items
    
    for repo in repositories {
      await mockStorage.addFavorite(repo)
    }
    viewModel.favorites = await mockStorage.getFavorites()
    
    viewModel.sortItems(by: .dateDesc)
    try await Task.sleep(nanoseconds: 1_000_000_000)
    
    XCTAssertEqual(viewModel.favorites[0].orderInt, 0)
    XCTAssertEqual(viewModel.favorites[1].orderInt, 1)
  }
  
  func testSortByStarsDesc() async throws {
    let data = loadJSON(name: "repositories-order")
    let repositories = try JSONDecoder().decode(GithubNetworkService.RepositorySearchResponse.self, from: data).items
    
    for repo in repositories {
      await mockStorage.addFavorite(repo)
    }
    viewModel.favorites = await mockStorage.getFavorites()
    
    viewModel.sortItems(by: .starsDesc)
    try await Task.sleep(nanoseconds: 1_000_000_000)
    
    XCTAssertEqual(viewModel.favorites[0].stargazersCount, 150)
    XCTAssertEqual(viewModel.favorites[1].stargazersCount, 100)
  }
  
  func testSortByNameAsc() async throws {
    let data = loadJSON(name: "repositories-order")
    let repositories = try JSONDecoder().decode(GithubNetworkService.RepositorySearchResponse.self, from: data).items
    
    for repo in repositories {
      await mockStorage.addFavorite(repo)
    }
    viewModel.favorites = await mockStorage.getFavorites()
    
    viewModel.sortItems(by: .nameAsc)
    try await Task.sleep(nanoseconds: 1_000_000_000)
    
    XCTAssertEqual(viewModel.favorites[0].name, "First")
    XCTAssertEqual(viewModel.favorites[1].name, "Second")
  }
}
