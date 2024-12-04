//
//  TestHelpers.swift
//  GithubReposTests
//
//  Created by Данил Швец on 04.12.2024.
//

import Foundation
import XCTest
@testable import GithubRepos

extension XCTestCase {
  func loadJSON(name: String) -> Data {
    let bundle = Bundle(for: type(of: self))
    guard let url = bundle.url(forResource: name, withExtension: "json"),
          let data = try? Data(contentsOf: url)
    else {
      fatalError("Failed to load JSON file: \(name)")
    }
    return data
  }
}

enum TestError: Error {
  case test
}
