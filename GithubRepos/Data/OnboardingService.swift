//
//  OnboardingService.swift
//  GithubRepos
//
//  Created by Данил Швец on 03.12.2024.
//

import Foundation
import SwiftUI

class OnboardingService: ObservableObject {
  @AppStorage("isRepositoriesOnboardingShown") var isOnboardingShown: Bool = false
  @AppStorage("isFavoritesOnboardingShown") var isFavoritesOnboardingShown: Bool = false
  @Published var currentStep: OnboardingStep = .search
  @Published var showSpotlight: Bool = false

  enum OnboardingStep {
    case search
    case favorite
    case bookmarks
  }
  
  func completeOnboarding() {
    isOnboardingShown = true
  }
  
  func completeFavoritesOnboarding() {
    isFavoritesOnboardingShown = true
  }
}
