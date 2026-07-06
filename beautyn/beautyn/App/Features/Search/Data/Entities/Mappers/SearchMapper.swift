import Foundation

// MARK: - SearchMapper

enum SearchMapper {

    static func makeRequestDTO(_ query: SearchQuery) -> SearchRequestDTO {
        SearchRequestDTO(
            query: query.query,
            centerLat: query.centerLat,
            centerLng: query.centerLng,
            viewport: query.viewport.map {
                SearchViewportDTO(neLat: $0.neLat, neLng: $0.neLng, swLat: $0.swLat, swLng: $0.swLng)
            },
            locationType: query.locationType?.rawValue,
            date: query.date.map { ApiDateFormatter.string(from: $0) },
            sortBy: query.sortBy?.rawValue,
            priceMin: query.priceMin,
            priceMax: query.priceMax,
            appCategoryIds: query.appCategoryIds,
            page: query.page,
            limit: query.limit
        )
    }

    static func map(_ dto: FilterOptionsResponseDTO) -> SearchFilterOptions {
        SearchFilterOptions(
            // Unknown server keys (future sorts) are dropped rather than crashing.
            sortOptions: dto.sortOptions.compactMap(SearchSortOption.init(rawValue:)),
            minPrice: dto.minPrice,
            maxPrice: dto.maxPrice
        )
    }

    // Mirrors HomeFeedMapper.mapCategory — that mapper is MainActor-isolated,
    // so it can't be reused from this nonisolated repository path.
    static func map(_ dto: AppCategoriesResponseDTO) -> [AppCategory] {
        dto.items.map {
            AppCategory(
                id: $0.id,
                slug: $0.slug,
                name: $0.name,
                imageUrl: $0.imageUrl,
                sortOrder: $0.sortOrder
            )
        }
    }

    static func map(_ dto: SearchResponseDTO) -> SearchResults {
        SearchResults(
            items: dto.items.map { map($0) },
            page: dto.page,
            limit: dto.limit,
            total: dto.total,
            effectiveRadiusKm: dto.meta?.effectiveRadiusKm
        )
    }

    static func map(_ dto: SearchPinsResponseDTO) -> [SearchPin] {
        dto.items.map {
            SearchPin(id: $0.salonId, latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    static func map(_ dto: SearchHistoryItemDTO) -> SearchHistoryItem {
        SearchHistoryItem(
            id: dto.id,
            salonId: dto.salonId,
            name: dto.salonName,
            city: dto.city,
            imageUrl: dto.logoUrl,
            point: makePoint(latitude: dto.latitude, longitude: dto.longitude)
        )
    }

    private static func makePoint(latitude: Double?, longitude: Double?) -> GeoPoint? {
        guard let latitude, let longitude else { return nil }
        return GeoPoint(latitude: latitude, longitude: longitude)
    }

    private static func map(_ dto: SearchSalonItemDTO) -> SearchSalon {
        SearchSalon(
            id: dto.salonId,
            name: dto.name,
            address: dto.address,
            rating: dto.rating,
            distanceKm: dto.distanceKm,
            imageUrl: dto.imageUrl ?? dto.logoUrl,
            latitude: dto.latitude,
            longitude: dto.longitude,
            isSaved: dto.isSaved ?? false
        )
    }
}
