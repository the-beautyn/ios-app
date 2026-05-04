import Combine
import SwiftUI
import XCTest
@testable import beautyn

// MARK: - SavedSalonsViewRenderTests
//
// Renders the Saved Salons (Обрані салони) screen against Figma node 1:8475.
//
// Run:
//   xcodebuild test -scheme beautyn-Production \
//     -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
//     -only-testing:beautynTests/SavedSalonsViewRenderTests

@MainActor
final class SavedSalonsViewRenderTests: XCTestCase {

    func testRenderSavedSalonsPopulated() async throws {
        let view = SavedSalonsView(
            viewModel: self.makeViewModel(list: .populatedPreview)
        )
        try await ViewRenderer.render(view, name: "saved_salons_populated")
    }

    func testRenderSavedSalonsEmpty() async throws {
        let view = SavedSalonsView(
            viewModel: self.makeViewModel(list: .emptyPreview)
        )
        try await ViewRenderer.render(view, name: "saved_salons_empty")
    }

    // MARK: - Helpers

    private func makeViewModel(list: SavedSalonsList) -> SavedSalonsViewModel {
        SavedSalonsViewModel(
            transition: .init(
                didTapSalon: { _ in },
                didTapBack: {}
            ),
            getSavedSalonsUseCase: MockGetSavedSalonsUseCase(list: list),
            saveSalonUseCase: MockSaveSalonUseCase(),
            unsaveSalonUseCase: MockUnsaveSalonUseCase(),
            savedSalonsEventBus: MockSavedSalonsEventBus()
        )
    }
}

// MARK: - Mocks

private final class MockGetSavedSalonsUseCase: GetSavedSalonsUseCase {
    let list: SavedSalonsList
    init(list: SavedSalonsList) { self.list = list }

    func execute(query: String?, page: Int?, limit: Int?) async throws -> SavedSalonsList {
        list
    }
}

private final class MockSaveSalonUseCase: SaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class MockUnsaveSalonUseCase: UnsaveSalonUseCase {
    func execute(salonId: String) async throws {}
}

private final class MockSavedSalonsEventBus: SavedSalonsEventBus {
    var changes: AnyPublisher<SavedSalonChange, Never> { Empty().eraseToAnyPublisher() }
    func notify(_ change: SavedSalonChange) {}
}

// MARK: - Preview Data

extension SavedSalonsList {

    static let populatedPreview = SavedSalonsList(
        items: [
            SavedSalon(
                id: "ss1",
                salonId: "s1",
                salonName: "Nail bar: Glossy Room",
                coverImageUrl: nil,
                addressLine: "вул. Зеленицька, 15 (411), 05-091",
                city: nil,
                ratingAvg: 4.5,
                ratingCount: 120,
                savedAt: Date()
            ),
            SavedSalon(
                id: "ss2",
                salonId: "s2",
                salonName: "Beauty Studio Kyiv",
                coverImageUrl: nil,
                addressLine: "вул. Франка, 10",
                city: nil,
                ratingAvg: 4.8,
                ratingCount: 85,
                savedAt: Date()
            ),
            SavedSalon(
                id: "ss3",
                salonId: "s3",
                salonName: "Glamour Nails",
                coverImageUrl: nil,
                addressLine: "вул. Шевченка, 22",
                city: nil,
                ratingAvg: 4.2,
                ratingCount: 60,
                savedAt: Date()
            ),
            SavedSalon(
                id: "ss4",
                salonId: "s4",
                salonName: "Hair Lab Lviv",
                coverImageUrl: nil,
                addressLine: "пр. Свободи, 8",
                city: nil,
                ratingAvg: 4.7,
                ratingCount: 210,
                savedAt: Date()
            ),
        ],
        page: 1,
        limit: 20,
        total: 4
    )

    static let emptyPreview = SavedSalonsList(items: [], page: 1, limit: 20, total: 0)
}
