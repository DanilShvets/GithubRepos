//
//  FavoritesOnboardingView.swift
//  GithubRepos
//
//  Created by Данил Швец on 03.12.2024.
//

import SwiftUI

struct FavoritesOnboardingView: View {
  @ObservedObject var service: OnboardingService
  
  private struct Constants {
    static let buttonHeight: CGFloat = 50
    static let padding: CGFloat = 50
    static let smallPadding: CGFloat = 15
    static let spacing: CGFloat = 32
    static let dividerPadding: CGFloat = 16
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack {
        Spacer()
        
        VStack(alignment: .leading, spacing: Constants.spacing) {
          FavoritesOnboardingItemView(
            iconName: "hand.rays.fill",
            text: "Перетащите ячейку, чтобы изменить порядок",
            iconColor: .blue
          )
          
          Divider().padding(.horizontal, Constants.dividerPadding)
          
          FavoritesOnboardingItemView(
            iconName: "arrow.right.to.line.compact",
            text: "Смахните слева для редактирования",
            iconColor: .orange
          )
          
          Divider().padding(.horizontal, Constants.dividerPadding)
          
          FavoritesOnboardingItemView(
            iconName: "arrow.left.to.line.compact",
            text: "Смахните справа для удаления",
            iconColor: .red
          )
          
          Divider().padding(.horizontal, Constants.dividerPadding)
          
          FavoritesOnboardingItemView(
            iconName: "arrow.up.arrow.down",
            text: "Измените сортировку ячеек",
            iconColor: .blue
          )
        }
        .padding(.horizontal, Constants.smallPadding)
        
        Spacer()
        
        Button {
          withAnimation {
            service.completeFavoritesOnboarding()
          }
        } label: {
          Text("Закрыть")
            .frame(maxWidth: .infinity)
            .frame(height: Constants.buttonHeight)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .padding()
        .padding(.bottom, Constants.padding)
      }
      .background(AnyShapeStyle(Material.thinMaterial))
    }
  }
}
