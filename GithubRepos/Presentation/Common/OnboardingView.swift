//
//  OnboardingView.swift
//  GithubRepos
//
//  Created by Данил Швец on 03.12.2024.
//

import SwiftUI

struct OnboardingView: View {
  @StateObject var service: OnboardingService
  var bookmarkFrame: CGRect
  
  private struct Constants {
    static let buttonHeight: CGFloat = 50
    static let padding: CGFloat = 50
    static let delay: Double = 1.0
    static let animationDuration: Double = 0.3
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack {
        if service.showSpotlight {
          Path { path in
            path.addRect(CGRect(origin: .zero, size: geometry.size))
          }
          .fill(AnyShapeStyle(Material.thinMaterial))
          .overlay {
            Circle()
              .frame(width: max(bookmarkFrame.width, bookmarkFrame.height) + 8)
              .position(x: bookmarkFrame.midX + 3, y: bookmarkFrame.midY)
              .blendMode(.destinationOut)
          }
          .compositingGroup()
        }
        
        Spacer()
        
        Button {
          switch service.currentStep {
          case .search:
            withAnimation(.easeInOut(duration: Constants.animationDuration)) {
              service.currentStep = .favorite
            }
          case .favorite:
            withAnimation(.easeInOut(duration: Constants.animationDuration)) {
              service.currentStep = .bookmarks
            }
            service.showSpotlight = true
          case .bookmarks:
            withAnimation(.easeInOut(duration: Constants.animationDuration)) {
              service.completeOnboarding()
            }
            break
          }
        } label: {
          Text(service.currentStep == .bookmarks ? "Закрыть" : "Продолжить")
            .frame(maxWidth: .infinity)
            .frame(height: Constants.buttonHeight)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .padding()
        .padding(.bottom, Constants.padding)
      }
      .background(service.showSpotlight ? AnyShapeStyle(.clear) : AnyShapeStyle(Material.thinMaterial))
    }
    .overlay(alignment: .center) {
      VStack(alignment: .center, spacing: 20) {
        StepView(
          text: "Пользуйтесь поиском, чтобы найти репозитории",
          isVisible: service.currentStep == .search
        )
        
        if service.currentStep == .favorite {
          VStack(alignment: .center, spacing: Constants.padding) {
            StepView(
              text: "Добавляйте репозитории в избранное",
              isVisible: service.currentStep == .favorite
            )
            
            Image(systemName: "plus.square.on.square")
              .foregroundColor(.blue)
              .font(.system(size: 24, weight: .bold))
          }
          .transition(.blurReplace)
        }
        
        StepView(
          text: "Просматривайте и изменяйте репозитории, добавленные в избранное",
          isVisible: service.currentStep == .bookmarks
        )
      }
      .padding(.horizontal, Constants.padding)
    }
  }
}

struct StepView: View {
  let text: String
  let isVisible: Bool
  
  var body: some View {
    if isVisible {
      Text(text)
        .font(.system(size: 24, weight: .semibold))
        .frame(maxWidth: .infinity, alignment: .center)
        .multilineTextAlignment(.center)
        .transition(.blurReplace)
    }
  }
}
