import Foundation

// MARK: - SalonMapper

enum SalonMapper {

    // MARK: - Map Response → Domain

    static func map(_ dto: SalonResponseDTO) -> Salon {
        Salon(
            id: dto.id,
            name: dto.name,
            addressLine: dto.addressLine,
            city: dto.city,
            phone: dto.phone,
            description: dto.description,
            coverImageUrl: dto.coverImageUrl,
            imageUrls: dto.images ?? [],
            ratingAvg: dto.ratingAvg,
            ratingCount: dto.ratingCount ?? 0,
            workingSchedule: dto.workingSchedule,
            topMastersTag: nil,
            isSaved: dto.isSaved ?? false,
            services: dto.services?.map { mapService($0) } ?? [],
            workers: dto.workers?.map { mapWorker($0) } ?? [],
            categories: dto.categories?.map { mapCategory($0) } ?? []
        )
    }

    // MARK: - Individual Mappers

    static func mapService(_ dto: SalonServiceDTO) -> SalonService {
        SalonService(
            id: dto.id,
            salonId: dto.salonId,
            categoryId: dto.categoryId,
            name: dto.name,
            description: dto.description,
            durationMinutes: dto.duration,
            price: dto.price,
            currency: dto.currency,
            isActive: dto.isActive,
            sortOrder: dto.sortOrder,
            workerIds: dto.workerIds ?? [],
            imageUrls: []
        )
    }

    static func mapWorker(_ dto: SalonWorkerDTO) -> SalonWorker {
        SalonWorker(
            id: dto.id,
            firstName: dto.firstName,
            lastName: dto.lastName,
            position: dto.position,
            description: dto.description,
            photoUrl: dto.photoUrl
        )
    }

    static func mapCategory(_ dto: SalonCategoryDTO) -> SalonCategory {
        SalonCategory(
            id: dto.id,
            salonId: dto.salonId,
            name: dto.name,
            color: dto.color,
            sortOrder: dto.sortOrder,
            serviceIds: dto.serviceIds ?? []
        )
    }

    static func mapShare(_ dto: SalonShareResponseDTO) -> SalonShare {
        guard let url = URL(string: dto.url) else {
            assertionFailure("SalonMapper: invalid share URL '\(dto.url)'")
            return SalonShare(url: URL(string: "about:blank")!, title: dto.title, description: dto.description)
        }
        return SalonShare(url: url, title: dto.title, description: dto.description)
    }
}
