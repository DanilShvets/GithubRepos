//
//  GithubNetworkService.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import Foundation

class GithubNetworkService: RepositoryService {
  struct RepositorySearchResponse: Codable {
    let items: [GithubRepository]
  }
  
  private let baseUrl = "https://api.github.com/search/repositories"
  
  func fetchRepositories(query: String, page: Int) async throws -> [GithubRepository] {
    let urlString = "\(baseUrl)?q=\(query)&sort=stars&page=\(page)&per_page=30"
    guard let url = URL(string: urlString) else {
      throw URLError(.badURL)
    }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(RepositorySearchResponse.self, from: data)
    
    return response.items
  }
}
