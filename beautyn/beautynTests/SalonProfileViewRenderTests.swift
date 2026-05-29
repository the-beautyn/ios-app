import Combine
import SwiftUI
import XCTest
@testable import beautyn

// MARK: - SalonProfileViewRenderTests
//
// Renders the actual SalonProfileView with mock data to PNG files for visual
// verification against Figma node 143:3968 in file 7nmKybCJdJ84RCtY4D6ebK.
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/SalonProfileViewRenderTests

@MainActor
final class SalonProfileViewRenderTests: XCTestCase {

    // MARK: - With Tag (Top 10 Masters)

    func testRenderSalonProfileWithTag() async throws {
        let view = SalonProfileView(
            viewModel: self.makeViewModel(salon:.previewWithTag)
        )
        try await ViewRenderer.render(view, name: "salon_profile_with_tag")
    }

    // MARK: - Without Tag (collapse behavior)

    func testRenderSalonProfileWithoutTag() async throws {
        let view = SalonProfileView(
            viewModel: self.makeViewModel(salon:.previewWithoutTag)
        )
        try await ViewRenderer.render(view, name: "salon_profile_without_tag")
    }

    // MARK: - Specialists Tab

    func testRenderSalonProfileSpecialistsTab() async throws {
        let viewModel = self.makeViewModel(salon: .previewWithTag)
        viewModel.selectedTab = 1
        let view = SalonProfileView(viewModel: viewModel)
        try await ViewRenderer.render(view, name: "salon_profile_specialists_tab")
    }

    // MARK: - Helpers

    private func makeViewModel(salon: Salon) -> SalonProfileViewModel {
        SalonProfileViewModel(
            salonId: salon.id,
            transition: .init(
                didTapBack: {},
                didRequireAuth: {},
                didRequestBooking: { _ in }
            ),
            getSalonByIdUseCase: MockGetSalonByIdUseCase(salon: salon),
            getSalonShareUseCase: MockGetSalonShareUseCase(),
            saveSalonUseCase: MockSalonProfileSaveSalonUseCase(),
            unsaveSalonUseCase: MockSalonProfileUnsaveSalonUseCase(),
            savedSalonsEventBus: MockSalonProfileSavedSalonsEventBus(),
            sessionManager: SessionManager(
                keychainService: KeychainServiceImpl(),
                defaultsService: DefaultsStorageService()
            )
        )
    }
}

// MARK: - Mocks

private final class MockGetSalonByIdUseCase: GetSalonByIdUseCase {
    let salon: Salon
    init(salon: Salon) { self.salon = salon }
    func execute(id: String) async throws -> Salon { salon }
}

private final class MockGetSalonShareUseCase: GetSalonShareUseCase {
    func execute(id: String) async throws -> SalonShare {
        SalonShare(
            url: URL(string: "https://stage.beautyn.com.ua/salon/\(id)")!,
            title: "Nail bar: Glossy Room",
            description: nil
        )
    }
}

private final class MockSalonProfileSaveSalonUseCase: SaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class MockSalonProfileUnsaveSalonUseCase: UnsaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class MockSalonProfileSavedSalonsEventBus: SavedSalonsEventBus {
    var changes: AnyPublisher<SavedSalonChange, Never> { Empty().eraseToAnyPublisher() }
    func notify(_ change: SavedSalonChange) {}
}

// MARK: - Preview Data

extension Salon {

    static let previewWithTag = Salon(
        id: "s1",
        name: "Nail bar: Glossy Room",
        provider: .easyweek,
        bookingUrl: URL(string: "https://booking.easyweek.com.ua/glossy-room"),
        addressLine: "вул. Зеленицька, 15, 05-091",
        city: "Київ",
        phone: nil,
        description: nil,
        coverImageUrl: "https://picsum.photos/seed/salon1/800/600",
        imageUrls: [
            "https://picsum.photos/seed/salon1/800/600",
            "https://picsum.photos/seed/salon2/800/600",
            "https://picsum.photos/seed/salon3/800/600",
            "https://picsum.photos/seed/salon4/800/600"
        ],
        ratingAvg: 4.5,
        ratingCount: 120,
        workingSchedule: "ПН – ВС, 12:00 — 20:00",
        topMastersTag: "Top 10 Masters",
        isSaved: false,
        services: previewServices,
        workers: previewWorkers,
        categories: []
    )

    static let previewWithoutTag = Salon(
        id: "s2",
        name: "Beauty Studio Kyiv",
        provider: .altegio,
        bookingUrl: nil,
        addressLine: "вул. Франка, 10",
        city: "Київ",
        phone: nil,
        description: nil,
        coverImageUrl: nil,
        imageUrls: [],
        ratingAvg: 4.8,
        ratingCount: 85,
        workingSchedule: "ПН – ПТ, 10:00 — 21:00",
        topMastersTag: nil,
        isSaved: true,
        services: previewServices,
        workers: previewWorkers,
        categories: []
    )

    private static let previewServices: [SalonService] = [
        SalonService(
            id: "srv1", salonId: "s1", categoryId: nil,
            name: "Classic Manicure",
            description: "Охайна форма, кутикула, легкий care та базове покриття.",
            durationMinutes: 90, price: 700, currency: "UAH",
            isActive: true, sortOrder: 0, workerIds: [], imageUrls: []
        ),
        SalonService(
            id: "srv2", salonId: "s1", categoryId: nil,
            name: "French Manicure",
            description: "Класичний французький манікюр із гель-лаком.",
            durationMinutes: 120, price: 900, currency: "UAH",
            isActive: true, sortOrder: 1, workerIds: [], imageUrls: []
        ),
        SalonService(
            id: "srv3", salonId: "s1", categoryId: nil,
            name: "Pedicure Express",
            description: "Швидкий педикюр із покриттям.",
            durationMinutes: 60, price: 600, currency: "UAH",
            isActive: true, sortOrder: 2, workerIds: [], imageUrls: []
        )
    ]

    private static let previewWorkers: [SalonWorker] = [
        SalonWorker(id: "w1", firstName: "Ashley", lastName: "Brown", position: "Майстер манікюру", description: nil, photoUrl: nil),
        SalonWorker(id: "w2", firstName: "Amber", lastName: "Stone", position: "Майстер манікюру", description: nil, photoUrl: nil),
        SalonWorker(id: "w3", firstName: "Олена", lastName: "Коваль", position: "Топ-майстер", description: nil, photoUrl: nil)
    ]
}
