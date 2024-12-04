//
//  GithubReposApp.swift
//  GithubRepos
//
//  Created by Данил Швец on 29.11.2024.
//

import SwiftUI
import SwiftData

@main
struct GithubReposApp: App {
  var body: some Scene {
    WindowGroup {
      RepositoryListView(
        viewModel: .init()
      )
      .modelContainer(Dependencies.shared.container)
    }
  }
}
