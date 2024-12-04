//
//  FavoritesOnboardingItemView.swift
//  GithubRepos
//
//  Created by Данил Швец on 03.12.2024.
//

import SwiftUI

struct FavoritesOnboardingItemView: View {
  let iconName: String
  let text: String
  let iconColor: Color
  
  private struct Constants {
    static let iconSize: CGFloat = 24
    static let spacing: CGFloat = 16
  }
  
  var body: some View {
    HStack(spacing: Constants.spacing) {
      Image(systemName: iconName)
        .font(.system(size: Constants.iconSize, weight: .semibold))
        .foregroundColor(iconColor)
      
      
      
      Text(text)
        .font(.system(size: 17, weight: .semibold))
    }
    .padding(.horizontal)
  }
}
