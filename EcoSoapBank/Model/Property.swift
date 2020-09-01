/* GRAPHQL SCHEMA (as of 2020-08-07 15:25)
 type Property {
     id: ID!
     name: String!
     propertyType: PropertyType!
     rooms: Int!
     services: [HospitalityService]!
     collectionType: CollectionType!
     logo: Url
     phone: String
     billingAddress: Address
     shippingAddress: Address
     coordinates: Coordinates
     shippingNote: String
     notes: String
     hub: Hub
     impact: ImpactStats
     users: [User]
     pickups: [Pickup]
     contract: HospitalityContract
 }
 */

import Foundation

struct Property: Codable, Equatable, Identifiable, Hashable {
    let id: String
    let name: String
    let propertyType: PropertyType
    let rooms: Int
    let services: [HospitalityService]
    let collectionType: Pickup.CollectionType
    let logo: String?
    let phone: String?
    let billingAddress: Address?
    let shippingAddress: Address?
    let shippingNote: String?
    let notes: String?

    enum PropertyType: String, Codable, CaseIterable {
        case bedAndBreakfast = "BED_AND_BREAKFAST"
        case guesthouse = "GUESTHOUSE"
        case hotel = "HOTEL"
        case other = "OTHER"
    }

    enum BillingMethod: String, Codable, CaseIterable {
        case ach = "ACH"
        case credit = "CREDIT"
        case debit = "DEBIT"
        case invoice = "INVOICE"
    }
}
