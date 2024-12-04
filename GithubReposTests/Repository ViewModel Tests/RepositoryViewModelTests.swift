//
//  RepositoryViewModelTests.swift
//  GithubReposTests
//
//  Created by Данил Швец on 04.12.2024.
//

import XCTest
import SwiftData
@testable import GithubRepos

@MainActor
class MockFavoritesManager: FavoritesManager {
  private var items: [FavoriteRepository] = []
  
  init() {
    super.init(modelContext: try! ModelContainer(for: FavoriteRepository.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext)
  }
  
  override func loadFavoriteIds() {
  }
  
  override func getFavorites() async -> [FavoriteRepository] {
    items
  }
  
  override func addFavorite(_ repository: GithubRepository) async {
    let favorite = FavoriteRepository(repository: repository, order: items.count)
    items.append(favorite)
    favoriteIds.insert(repository.id)
  }
  
  override func deleteFavorite(_ repository: FavoriteRepository) async {
    items.removeAll { $0.id == repository.id }
    favoriteIds.remove(repository.parentId)
  }
  
  override func updateOrder(_ favorites: [FavoriteRepository]) async {
    items = favorites
  }
}

@MainActor
final class RepositoryViewModelTests: XCTestCase {
  private var viewModel: RepositoryViewModel!
  private var container: ModelContainer!
  private var mockManager: MockFavoritesManager!
  
  override func setUp() async throws {
    try await super.setUp()
    
    mockManager = MockFavoritesManager()
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    container = try ModelContainer(for: FavoriteRepository.self, configurations: config)
    viewModel = RepositoryViewModel(storageService: mockManager, context: container.mainContext)
  }
  
  override func tearDown() {
    viewModel = nil
    container = nil
    super.tearDown()
  }
  
  func testSearchQueryProcessing() async throws {
    viewModel.searchText = "test"
    viewModel.updateSearchQuery()
    
    XCTAssertEqual(viewModel.query, "test")
    XCTAssertEqual(viewModel.currentPage, 1)
    XCTAssertTrue(viewModel.repositories.isEmpty)
  }
  
  func testLoadingStates() async throws {
    XCTAssertEqual(viewModel.loadingState, .idle)
    
    viewModel.query = "test"
    let emptyData = loadJSON(name: "repositories-empty")
    let emptyRepositories = try await loadRepositoriesTest(data: emptyData)
    viewModel.repositories = emptyRepositories
    viewModel.loadingState = .empty
    XCTAssertEqual(viewModel.loadingState, .empty)
    
    let errorData = "invalid".data(using: .utf8)
    do {
      _ = try await loadRepositoriesTest(data: errorData)
    } catch {
      viewModel.loadingState = .error
    }
    XCTAssertEqual(viewModel.loadingState, .error)
    
    let successData = loadJSON(name: "repositories")
    let successRepositories = try await loadRepositoriesTest(data: successData)
    viewModel.repositories = successRepositories
    viewModel.loadingState = .loaded
    XCTAssertEqual(viewModel.loadingState, .loaded)
  }
  
  func testPagination() async throws {
    let firstPageData = loadJSON(name: "repositories")
    let firstPage = try await loadRepositoriesTest(data: firstPageData)
    viewModel.repositories = firstPage
    viewModel.currentPage = 2
    XCTAssertEqual(viewModel.currentPage, 2)
    
    let secondPageData = loadJSON(name: "repositories-second-page")
    let secondPage = try await loadRepositoriesTest(data: secondPageData)
    viewModel.repositories.append(contentsOf: secondPage)
    viewModel.currentPage = 3
    XCTAssertEqual(viewModel.currentPage, 3)
    XCTAssertEqual(viewModel.repositories.count, 2)
  }
  
  func testAddToFavorites() async throws {
    let data = loadJSON(name: "repositories")
    let repositories = try await loadRepositoriesTest(data: data)
    viewModel.repositories = repositories
    
    XCTAssertFalse(viewModel.isToastShown)
    viewModel.addFavorite(repositories[0])
    
    try await Task.sleep(nanoseconds: 1_000_000_000)
    let favorites = await mockManager.getFavorites()
    XCTAssertEqual(favorites.last?.name, repositories.first?.name)
  }
  
  private func loadRepositoriesTest(data: Data?) async throws -> [GithubRepository] {
    guard let data = data else {
      throw URLError(.badURL)
    }
    
    let response = try JSONDecoder().decode(GithubNetworkService.RepositorySearchResponse.self, from: data)
    return response.items
  }
}
