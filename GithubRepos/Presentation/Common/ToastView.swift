//
//  ToastView.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import SwiftUI

struct ToastView: View {
  private struct Constants {
    static let height: CGFloat = 40
    static let cornerRadius: CGFloat = 20
    static let horizontalPadding: CGFloat = 16
    static let bottomPadding: CGFloat = 32
    static let backgroundColor = AnyShapeStyle(Material.thickMaterial)
  }
  
  var body: some View {
    Text("Добавлено в избранное")
      .font(.subheadline)
      .frame(height: Constants.height)
      .padding(.horizontal, Constants.horizontalPadding)
      .background(Constants.backgroundColor)
      .clipShape(Capsule())
      .padding(.bottom, Constants.bottomPadding)
      .transition(.move(edge: .bottom).combined(with: .opacity))
  }
}
