//
//  RepositoryRowViewModel.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import SwiftUI

class RepositoryRowViewModel: ObservableObject {
  @Published var repository: GithubRepository
  @Published var isExpanded: Bool = false
  var onFavoriteToggle: () -> Void
  var showAddButton: Bool
  var repositoryURL: URL? {
    URL(string: "https://github.com/\(repository.owner.login)/\(repository.name)")
  }
  var truncatedDescription: String? {
    guard let description = repository.description else { return nil }
    
    guard description.count > 150 else {
      return description
    }
    
    return isExpanded ? description : description.prefix(150) + "..."
  }
  var showExpandButton: Bool {
    guard let description = repository.description else { return false }
    return description.count > 150
  }
  
  init(
    repository: GithubRepository,
    showAddButton: Bool = true,
    onFavoriteToggle: @escaping () -> Void
  ) {
    self.repository = repository
    self.showAddButton = showAddButton
    self.onFavoriteToggle = onFavoriteToggle
  }
  
  func expandAndHideDescription() {
    if !isExpanded {
      withAnimation {
        isExpanded.toggle()
      }
    }
    else {
      isExpanded.toggle()
    }
  }
}
