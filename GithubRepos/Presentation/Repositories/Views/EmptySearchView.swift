//
//  EmptySearchView.swift
//  GithubRepos
//
//  Created by Данил Швец on 02.12.2024.
//

import SwiftUI

struct EmptySearchView: View {
  // MARK: - Public Variables
  let languages: [String]
  let onLanguageSelect: (String) -> Void
  let loadingState: RepositoryViewModel.LoadingState
  let isSearchFocused: Bool
  
  // MARK: - Private Types
  private struct Constants {
    static let spacing: CGFloat = 24
    static let buttonSpacing: CGFloat = 8
    static let magnifierSize: CGFloat = 40
    static let buttonCornerRadius: CGFloat = 12
    static let buttonTextFontSize: CGFloat = 15
    static let infoVstackHeight: CGFloat = 120
    static let buttonPadding: EdgeInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
    static let contentAnimation = Animation.easeInOut(duration: 0.3)
    static let insertionAnimation = Animation.easeInOut(duration: 0.2).delay(0.15)
    static let removalAnimation = Animation.easeInOut(duration: 0.2)
  }
  
  // MARK: - Private Variables
  private var messageForState: String {
    switch loadingState {
    case .error:
      return "Не удалось загрузить данные. Попробуйте еще раз"
    case .empty:
      return "По вашему запросу ничего не найдено"
    default:
      return "Начните поиск репозиториев или выберите язык программирования"
    }
  }
  
  // MARK: - Body
  var body: some View {
    VStack(spacing: Constants.spacing) {
      VStack(spacing: Constants.spacing) {
        iconView
          .opacity(isSearchFocused ? 0 : 1)
          .scaleEffect(isSearchFocused ? 0 : 1)
          .animation(isSearchFocused ? Constants.removalAnimation : Constants.insertionAnimation, value: isSearchFocused)
        
        messageView
          .opacity(isSearchFocused ? 0 : 1)
          .scaleEffect(isSearchFocused ? 0 : 1)
          .animation(isSearchFocused ? Constants.removalAnimation : Constants.insertionAnimation, value: isSearchFocused)
      }
      .frame(height: isSearchFocused ? 0 : nil)
      .animation(Constants.contentAnimation, value: isSearchFocused)
      
      languageButtonsView
        .padding(.top, isSearchFocused ? 0 : Constants.spacing)
        .animation(Constants.contentAnimation, value: isSearchFocused)
      
      if isSearchFocused {
        Spacer()
      }
    }
    .padding()
  }
  
  // MARK: - Private Views
  private var iconView: some View {
    Group {
      switch loadingState {
      case .error, .empty:
        Image(systemName: "exclamationmark.triangle")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(.orange)
      default:
        Image(systemName: "magnifyingglass")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundColor(.secondary)
      }
    }
    .frame(width: Constants.magnifierSize)
  }
  
  private var messageView: some View {
    Text(messageForState)
      .font(.headline)
      .padding(.horizontal, Constants.spacing)
      .multilineTextAlignment(.center)
  }
  
  private var languageButtonsView: some View {
    WrappingHStack(
      models: languages,
      horizontalSpacing: Constants.buttonSpacing,
      verticalSpacing: Constants.buttonSpacing
    ) { language in
      Button {
        onLanguageSelect(language)
      } label: {
        Text(language.capitalized)
          .font(.system(size: Constants.buttonTextFontSize))
          .padding(Constants.buttonPadding)
          .background(Color.blue.opacity(0.1))
          .foregroundColor(.blue)
          .cornerRadius(Constants.buttonCornerRadius)
      }
    }
  }
}

// MARK: - WrappingHStack
struct WrappingHStack<Model, V>: View where Model: Hashable, V: View {
  typealias ViewGenerator = (Model) -> V
  
  var models: [Model]
  var viewGenerator: ViewGenerator
  var horizontalSpacing: CGFloat
  var verticalSpacing: CGFloat
  
  @State private var totalHeight = CGFloat.zero
  
  init(
    models: [Model],
    horizontalSpacing: CGFloat,
    verticalSpacing: CGFloat,
    viewGenerator: @escaping ViewGenerator
  ) {
    self.models = models
    self.viewGenerator = viewGenerator
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
  }
  
  var body: some View {
    VStack {
      GeometryReader { geometry in
        generateContent(in: geometry)
      }
    }
    .frame(height: totalHeight)
  }
  
  private func generateContent(in geometry: GeometryProxy) -> some View {
    var width = CGFloat.zero
    var height = CGFloat.zero
    
    return ZStack(alignment: .topLeading) {
      ForEach(models, id: \.self) { model in
        viewGenerator(model)
          .padding(.horizontal, horizontalSpacing)
          .padding(.vertical, verticalSpacing)
          .alignmentGuide(.leading) { dimension in
            if abs(width - dimension.width) > geometry.size.width {
              width = 0
              height -= dimension.height
            }
            let result = width
            if model == models.last! {
              width = 0
            } else {
              width -= dimension.width
            }
            return result
          }
          .alignmentGuide(.top) { dimension in
            let result = height
            if model == models.last! {
              height = 0
            }
            return result
          }
      }
    }
    .background(viewHeightReader($totalHeight))
  }
  
  private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
    return GeometryReader { geometry -> Color in
      let rect = geometry.frame(in: .local)
      DispatchQueue.main.async {
        binding.wrappedValue = rect.size.height
      }
      return .clear
    }
  }
}
