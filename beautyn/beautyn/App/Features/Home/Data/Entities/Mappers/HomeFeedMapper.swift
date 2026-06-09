import Foundation

// MARK: - HomeFeedMapper

enum HomeFeedMapper {

    // MARK: - ISO8601 Date Formatters

    private static let isoFormatterWithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func parseDate(_ string: String) -> Date {
        if let date = isoFormatterWithFractional.date(from: string) {
            return date
        }
        if let date = isoFormatter.date(from: string) {
            return date
        }
        assertionFailure("HomeFeedMapper: failed to parse date '\(string)'")
        return Date()
    }

    // MARK: - Map Response → Domain
    static func map(_ dto: HomeFeedResponseDTO) -> HomeFeed {
        HomeFeed(
            categories: dto.categories.map { mapCategory($0) },
            nextBooking: dto.nextBooking.map { mapNextBooking($0) },
            savedSalons: dto.savedSalons?.map { mapSavedSalon($0) },
            sections: dto.sections.map { mapSection($0) }
        )
    }

    // MARK: - Individual Mappers

    static func mapCategory(_ dto: AppCategoryDTO) -> AppCategory {
        AppCategory(
            id: dto.id,
            slug: dto.slug,
            name: dto.name,
            imageUrl: dto.imageUrl,
            sortOrder: dto.sortOrder
        )
    }

    static func mapNextBooking(_ dto: HomeFeedNextBookingDTO) -> NextBooking {
        NextBooking(
            bookingId: dto.bookingId,
            salonId: dto.salonId,
            salonName: dto.salonName,
            salonCoverImageUrl: dto.salonCoverImageUrl,
            salonAddressLine: dto.salonAddressLine,
            datetime: parseDate(dto.datetime),
            endDatetime: dto.endDatetime.map { parseDate($0) },
            totalPriceCents: dto.totalPriceCents,
            durationMinutes: dto.durationMinutes,
            serviceNames: dto.serviceNames ?? [],
            timezone: dto.salonTimezone.flatMap(TimeZone.init(identifier:))
        )
    }

    static func mapSavedSalon(_ dto: SavedSalonItemDTO) -> SavedSalon {
        SavedSalon(
            id: dto.id,
            salonId: dto.salonId,
            salonName: dto.salonName,
            coverImageUrl: dto.coverImageUrl,
            addressLine: dto.addressLine,
            city: dto.city,
            ratingAvg: dto.ratingAvg,
            ratingCount: dto.ratingCount,
            savedAt: parseDate(dto.savedAt)
        )
    }

    static func mapSection(_ dto: HomeFeedSectionDTO) -> HomeFeedSection {
        HomeFeedSection(
            id: dto.id,
            type: dto.type,
            title: dto.title,
            emoji: dto.emoji,
            items: dto.items.map { mapSalonCard($0) }
        )
    }

    static func mapSalonCard(_ dto: HomeFeedSalonCardDTO) -> SalonCard {
        SalonCard(
            id: dto.id,
            name: dto.name,
            coverImageUrl: dto.coverImageUrl,
            addressLine: dto.addressLine,
            city: dto.city,
            ratingAvg: dto.ratingAvg,
            ratingCount: dto.ratingCount,
            distanceKm: dto.distanceKm,
            isSaved: dto.isSaved ?? false
        )
    }
}
