//
//  FavoriteRepository.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import Foundation
import SwiftData

@Model
final class FavoriteRepository {
  var id: String
  var parentId: String
  var name: String
  var descriptionText: String?
  var ownerLogin: String
  var ownerAvatarUrl: String
  var stargazersCount: Int
  var orderInt: Int
  var addToFavoriteDate: Date
  var originalUrl: String
  
  init(repository: GithubRepository, order: Int) {
    self.id = UUID().uuidString
    self.parentId = repository.id
    self.name = repository.name
    self.descriptionText = repository.description
    self.ownerLogin = repository.owner.login
    self.ownerAvatarUrl = repository.owner.avatarUrl
    self.stargazersCount = repository.stargazersCount
    self.orderInt = order
    self.addToFavoriteDate = Date.now
    self.originalUrl = "https://github.com/\(repository.owner.login)/\(repository.name)"
  }
}
