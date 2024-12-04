//
//  GithubNetworkServiceTests.swift
//  GithubReposTests
//
//  Created by Данил Швец on 04.12.2024.
//

import XCTest
@testable import GithubRepos

final class GithubNetworkServiceTests: XCTestCase {
  private var service: GithubNetworkService!
  
  override func setUp() {
    super.setUp()
    service = GithubNetworkService()
  }
  
  override func tearDown() {
    service = nil
    super.tearDown()
  }
  
  func testFetchRepositoriesSuccess() async throws {
    let data = loadJSON(name: "repositories")
    
    let repositories = try await service.fetchRepositoriesTest(data: data)
    
    XCTAssertEqual(repositories.count, 1)
    XCTAssertEqual(repositories.first?.name, "test-repo")
    XCTAssertEqual(repositories.first?.owner.login, "test-user")
    XCTAssertEqual(repositories.first?.stargazersCount, 100)
  }
  
  func testFetchRepositoriesInvalidJSON() async {
    let invalidData = "invalid json".data(using: .utf8)
    
    do {
      _ = try await service.fetchRepositoriesTest(data: invalidData)
      XCTFail("Expected error")
    } catch {
      XCTAssertTrue(error is DecodingError)
    }
  }
  
  func testFetchRepositoriesNetworkError() async {
    let error = TestError.test
    
    do {
      _ = try await service.fetchRepositoriesTest(data: nil, error: error)
      XCTFail("Expected error")
    } catch {
      XCTAssertTrue(error is TestError)
    }
  }
}

private extension GithubNetworkService {
  func fetchRepositoriesTest(
    data: Data?,
    error: Error? = nil
  ) async throws -> [GithubRepository] {
    if let error = error {
      throw error
    }
    
    guard let data = data else {
      throw URLError(.badURL)
    }
    
    let response = try JSONDecoder().decode(RepositorySearchResponse.self, from: data)
    return response.items
  }
}
