//
//  CountryData.swift
//  AddressVerification
//
//  Created on 2026-03-20.
//

import Foundation

/// Represents a country with its administrative divisions
struct HomeCountry: Codable, Identifiable, Hashable {
    let code2: String
    let code3: String
    let name: String
    let capital: String
    let region: String
    let subregion: String
    let states: [State]
    
    var id: String { code2 }
    
    enum CodingKeys: String, CodingKey {
        case code2
        case code3
        case name
        case capital
        case region
        case subregion
        case states
    }
}

/// Represents a state or province within a country
struct State: Codable, Identifiable, Hashable {
    let code: String
    let name: String
    let subdivision: [String]
    
    var id: String { code }
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case subdivision
    }
}

// MARK: - Convenience Extensions

extension HomeCountry {
    /// Returns a state by its code
    func state(withCode code: String) -> State? {
        states.first { $0.code == code }
    }
    
    /// Returns a state by its name
    func state(withName name: String) -> State? {
        states.first { $0.name.lowercased() == name.lowercased() }
    }
    
    /// Returns all state names
    var stateNames: [String] {
        states.map { $0.name }
    }
}

extension State {
    /// Checks if a subdivision exists in this state
    func hasSubdivision(_ name: String) -> Bool {
        subdivision.contains { $0.lowercased() == name.lowercased() }
    }
    
    /// Returns true if this state has subdivisions
    var hasSubdivisions: Bool {
        !subdivision.isEmpty
    }
    
    /// Number of subdivisions in this state
    var subdivisionCount: Int {
        subdivision.count
    }
}
