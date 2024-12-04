//
//  RepositoryRowView.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import SwiftUI
import Kingfisher

struct RepositoryRowView: View {
  // MARK: - Public Variables
  @ObservedObject var viewModel: RepositoryRowViewModel
  
  // MARK: - Private Types
  private struct Constants {
    static let avatarSize: CGFloat = 50
    static let spacing: CGFloat = 12
    static let innerSpacing: CGFloat = 4
    static let expandButtonHeight: CGFloat = 30
    static let expandButtonColor = Color.blue
    static let expandButtonFont: Font = .subheadline
    static let defaultLineLimit = 7
  }
  
  // MARK: - Body  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      KFImage(URL(string: viewModel.repository.owner.avatarUrl)!)
        .resizable()
        .placeholder {
          ProgressView()
            .frame(width: 50, height: 50)
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: 50, height: 50)
        .clipShape(Circle())
      
      VStack(alignment: .leading, spacing: 4) {
        Text(viewModel.repository.name)
          .font(.headline)
        
        if let description = viewModel.truncatedDescription {
          VStack(alignment: .leading, spacing: Constants.innerSpacing) {
            Text(description)
              .font(.subheadline)
              .foregroundColor(.secondary)
            
            if viewModel.showExpandButton {
              Button {
                viewModel.expandAndHideDescription()
              } label: {
                Text(viewModel.isExpanded ? "Свернуть" : "Развернуть")
                  .font(Constants.expandButtonFont)
                  .foregroundColor(Constants.expandButtonColor)
              }
              .buttonStyle(.plain)
            }
          }
        }
        
        HStack {
          Image(systemName: "star.fill")
            .foregroundColor(.yellow)
          Text("\(viewModel.repository.stargazersCount)")
            .font(.caption)
        }
      }
      
      Spacer()
      
      if viewModel.showAddButton {
        ZStack {
          Color.clear
            .frame(width: 44, height: 44)
          
          Button {
            viewModel.onFavoriteToggle()
          } label: {
            Image(systemName: "plus.square.on.square")
              .foregroundColor(.blue)
          }
          .buttonStyle(.plain)
        }
      }
    }
  }
}

