//
//  GithubRepository.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import Foundation

struct GithubRepository: Codable, Identifiable, Equatable {
  
  struct Owner: Codable {
    let login: String
    let avatarUrl: String
    
    enum CodingKeys: String, CodingKey {
      case login
      case avatarUrl = "avatar_url"
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case id, name, description, owner
    case stargazersCount = "stargazers_count"
  }
  
  let id: String
  let name: String
  let description: String?
  let owner: Owner
  let stargazersCount: Int
  var uniqueId: String {
    "\(id)_\(name)_\(owner.login)"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let numericId = try container.decode(Int.self, forKey: .id)
    self.id = String(numericId)
    self.name = try container.decode(String.self, forKey: .name)
    self.description = try container.decode(String?.self, forKey: .description)
    self.owner = try container.decode(Owner.self, forKey: .owner)
    self.stargazersCount = try container.decode(Int.self, forKey: .stargazersCount)
  }
  
  static func == (lhs: GithubRepository, rhs: GithubRepository) -> Bool {
    lhs.id == rhs.id &&
    lhs.name == rhs.name &&
    lhs.description == rhs.description &&
    lhs.owner.login == rhs.owner.login &&
    lhs.stargazersCount == rhs.stargazersCount &&
    lhs.uniqueId == rhs.uniqueId
  }
}

extension GithubRepository {
  init(favorite: FavoriteRepository) {
    self.id = favorite.parentId
    self.name = favorite.name
    self.description = favorite.descriptionText
    self.stargazersCount = favorite.stargazersCount
    self.owner = Owner(
      login: favorite.ownerLogin,
      avatarUrl: favorite.ownerAvatarUrl
    )
  }
}
