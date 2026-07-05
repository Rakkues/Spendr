//
//  Supabase.swift
//  Spendr
//
//  Created by Anas Azman on 16/05/2026.
//

import Foundation
import Supabase

private var customSupabaseDecoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)

        let pureDateFormatter = DateFormatter()
        pureDateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = pureDateFormatter.date(from: dateStr) { return date }

        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractionalFormatter.date(from: dateStr) { return date }

        let standardFormatter = ISO8601DateFormatter()
        if let date = standardFormatter.date(from: dateStr) { return date }

        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Cannot decode date string: \(dateStr)"
        )
    }
    return decoder
}

let supabase = SupabaseClient(
  supabaseURL: URL(string: "https://sljhupiglspigoatsodf.supabase.co")!,
  supabaseKey: "sb_publishable_fAbeH4M1MY-iDRIia_IS6Q_m0eD2Gnw",
  options: SupabaseClientOptions(db: .init(decoder: customSupabaseDecoder))
)
