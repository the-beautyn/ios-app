import Foundation

// MARK: - HomeFeed

struct HomeFeed {
    let categories: [AppCategory]
    let nextBooking: NextBooking?
    let savedSalons: [SavedSalon]?
    let sections: [HomeFeedSection]
}
