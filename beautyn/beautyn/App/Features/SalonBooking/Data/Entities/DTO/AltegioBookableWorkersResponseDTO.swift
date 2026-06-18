import Foundation

// MARK: - AltegioBookableWorkersResponseDTO

struct AltegioBookableWorkersResponseDTO: Decodable {
    let workers: [AltegioBookableWorkerDTO]
}

// MARK: - AltegioBookableWorkerDTO

struct AltegioBookableWorkerDTO: Decodable {
    let id: String
    let name: String
    let specialization: String?
    let avatar: String?
    let rating: Double?
    let bookable: Bool
    /// Present only when the request asked for `includeSlots`.
    let slots: [AltegioBookingSlotDTO]?
}

// MARK: - AltegioBookingSlotDTO

struct AltegioBookingSlotDTO: Decodable {
    let time: String
    let datetime: String
    let seanceLengthSec: Int
    let sumLengthSec: Int

    enum CodingKeys: String, CodingKey {
        case time
        case datetime
        case seanceLengthSec = "seance_length_sec"
        case sumLengthSec = "sum_length_sec"
    }
}
