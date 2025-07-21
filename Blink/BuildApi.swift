//////////////////////////////////////////////////////////////////////////////////
//
// B L I N K
//
// Copyright (C) 2016-2019 Blink Mobile Shell Project
//
// This file is part of Blink.
//
// Blink is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Blink is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Blink. If not, see <http://www.gnu.org/licenses/>.
//
// In addition, Blink is also subject to certain additional terms under
// GNU GPL version 3 section 7.
//
// You should have received a copy of these additional terms immediately
// following the terms and conditions of the GNU General Public License
// which accompanied the Blink Source Code. If not, see
// <http://www.github.com/blinksh/blink>.
//
////////////////////////////////////////////////////////////////////////////////


import Foundation
import RevenueCat


struct BuildAccountInfo: Decodable {
  let build_id: String
  let region: String
  let email: String
}

struct BuildUsageBalance: Decodable {
  let build_id: String
  let balance_id: String
  let status: String
  let credits_available: UInt64
  let credits_consumed: UInt64
  let period_start: UInt64
  let period_end: UInt64
  let initial_outstanding_debit: UInt64
  let last_charges_timestamp: UInt64?
  let previous_balance_id: String?
  
  var periodStartDate: Date {
    Date(timeIntervalSince1970: TimeInterval(period_start))
  }
  
  var periodEndDate: Date {
    Date(timeIntervalSince1970: TimeInterval(period_end))
  }
}

enum BuildAPIError: Error, LocalizedError {
  case invalidResponse
  case unexpectedResponseStatus(Int)
  case noReceipt
  
  var errorDescription: String? {
    switch self {
    case .invalidResponse: return "Invalid Response from server."
    case .unexpectedResponseStatus(let code): return "Unexpected code \(code)."
    case .noReceipt: return "No receipt"
    }
  }
}


enum BuildAPI {
  
  static func requestService(_ request: URLRequest) async -> (Int32, Data) {
    // Disabled for security - no external API calls
    return (403, Data())
  }
  
  public static func accountInfo() async throws -> BuildAccountInfo {
    // Disabled for security
    throw BuildAPIError.unexpectedResponseStatus(403)
  }
  
  public static func accountCurrentUsageBalance() async throws -> BuildUsageBalance {
    // Disabled for security
    throw BuildAPIError.unexpectedResponseStatus(403)
  }
  
  public static func requestAccountDelete() async throws {
    // Disabled for security
    throw BuildAPIError.unexpectedResponseStatus(403)
  }
  
  private static func _baseURL() -> String {
    // Disabled for security - no external API calls
    return ""
  }
  
  private static func _path(_ path: String) -> URL {
    URL(string: "\(_baseURL())\(path)")!
  }
  
  private static func _post(_ url: URL, params: [String: Any]) async throws -> (Int, Data, [String: Any]) {
    
    let (data, response) = try await URLSession.shared.data(for: .init(postJson: url, params: params))
    
    guard let response = response as? HTTPURLResponse else {
      throw BuildAPIError.invalidResponse
    }
    
    guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      let originalResponse = String(data: data, encoding: .utf8) ?? "Not a string"
      return (response.statusCode, data, ["originalResponse": originalResponse])
    }
    
    return (response.statusCode, data, obj)
  }
  
  private static func _get(_ url: URL, params: [String: Any] = [:]) async throws -> (Int, Data, [String: Any]) {
    
    let (data, response) = try await URLSession.shared.data(for: .init(getJson: url, params: params))
    
    guard let response = response as? HTTPURLResponse else {
      throw BuildAPIError.invalidResponse
    }
    
    guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      let originalResponse = String(data: data, encoding: .utf8) ?? "Not a string"
      return (response.statusCode, data, ["originalResponse": originalResponse])
    }
    
    return (response.statusCode, data, obj)
  }
  
  static func signup(email: String, region: BuildRegion) async throws {
    // Disabled for security - no external API calls
    throw BuildAPIError.unexpectedResponseStatus(403)
  }
  
  static func signin() async throws  {
    // Disabled for security - no external API calls
    throw BuildAPIError.unexpectedResponseStatus(403)
  }
  
  static func trySignin() async throws {
    // Disabled for security - no external API calls
    return
  }
  
  static func loginWithToken(token: Data) async throws {
    // Disabled for security - no login
    return
  }
}


extension URLRequest {
  init(postJson url: URL, params: [String: Any] = [:]) throws {
    self.init(url: url)
    self.httpMethod = "POST"
    self.addValue("application/json", forHTTPHeaderField: "Content-Type")
    self.httpBody = try JSONSerialization.data(withJSONObject: params)
  }
  
  init(deleteJson url: URL, params: [String: Any]? = nil) throws {
    self.init(url: url)
    self.httpMethod = "DELETE"
    self.addValue("application/json", forHTTPHeaderField: "Content-Type")
    if let params = params {
      self.httpBody = try JSONSerialization.data(withJSONObject: params)
    }
  }
  
  init(getJson url: URL, params: [String: Any] = [:]) {
    
    // TODO: handle params
    self.init(url: url)
    self.httpMethod = "GET"
    self.addValue("application/json", forHTTPHeaderField: "Content-Type")
  }
  
  
}
