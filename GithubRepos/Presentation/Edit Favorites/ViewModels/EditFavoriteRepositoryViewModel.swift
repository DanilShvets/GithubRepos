//
//  EditFavoriteRepositoryViewModel.swift
//  GithubRepos
//
//  Created by Данил Швец on 03.12.2024.
//

import SwiftUI
import SwiftData

@MainActor
final class EditFavoriteRepositoryViewModel: ObservableObject {
  // MARK: - Public Variables
  var repository: FavoriteRepository
  @Published var name: String
  @Published var description: String
  @Published var isValid: Bool = true
  @Published var isEdited: Bool = false
  
  var repositoryURL: URL? {
    URL(string: repository.originalUrl)
  }
  
  // MARK: - Private Variables
  private let modelContext: ModelContext
  
  // MARK: - Init
  init(
    repository: FavoriteRepository,
    dependencies: Dependencies
  ) {
    self.repository = repository
    self.modelContext = dependencies.container.mainContext
    self.name = repository.name
    self.description = repository.descriptionText ?? ""
  }
  
  func save() {
    repository.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    repository.descriptionText = description.trimmingCharacters(in: .whitespacesAndNewlines)
    try? modelContext.save()
  }
  
  func updateValidation() {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
    let currentDescription = repository.descriptionText ?? ""
    
    isValid = !trimmedName.isEmpty
    isEdited = trimmedName != repository.name || trimmedDescription != currentDescription
  }
}
