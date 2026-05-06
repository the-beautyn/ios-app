import Foundation

struct WebPagePresentation: Identifiable, Equatable {
    let id = UUID()
    let url: URL
    let title: String?
}
