import Combine
import Foundation
import SwiftUI

// MARK: - ConfirmBookingViewModel
//
// Final review step of the booking flow. Shows the salon, the chosen day / time,
// the picked services and total, plus a discount-code field and a comment. No
// network work — everything is carried forward from the previous steps. Apply
// discount / confirm are placeholders for now (the real submit is wired later);
// they surface the same "coming soon" toast the rest of the flow uses for unbuilt
// destinations.

@MainActor
final class ConfirmBookingViewModel: BaseViewModel {

    // MARK: - Transition

    struct Transition {
        /// The booking was created — hand the full backend `Booking` back so the
        /// coordinator can show the success splash and push the details screen.
        let didFinishBooking: (Booking) -> Void
    }

    // MARK: - Published State

    @Published var discountCode: String = ""
    @Published var comment: String = ""

    /// "Ваші дані" — the logged-in user's contact info sent with the booking.
    @Published private(set) var userName: String = ""
    @Published private(set) var userPhone: String = ""
    @Published private(set) var userEmail: String = ""

    // MARK: - Dependencies

    private let salon: Salon
    private let selectedServiceIds: Set<String>
    /// nil = "Будь-який" (any team member) → booked with Altegio `staff_id: 0`.
    private let workerId: String?
    /// Chosen slot datetime, ISO 8601 (e.g. "2025-06-25T09:00:00+03:00").
    private let datetime: String
    private let transition: Transition
    private let createBookingUseCase: any CreateAltegioBookingUseCase
    private let getCurrentUserUseCase: any GetCurrentUserUseCase

    // MARK: - Init

    init(
        salon: Salon,
        selectedServiceIds: Set<String>,
        workerId: String?,
        datetime: String,
        transition: Transition,
        createBookingUseCase: any CreateAltegioBookingUseCase,
        getCurrentUserUseCase: any GetCurrentUserUseCase
    ) {
        self.salon = salon
        self.selectedServiceIds = selectedServiceIds
        self.workerId = workerId
        self.datetime = datetime
        self.transition = transition
        self.createBookingUseCase = createBookingUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        super.init()
    }

    // MARK: - Lifecycle

    override func onViewTask() async {
        // Best-effort: fills "Ваші дані". A failure just leaves the rows empty.
        guard let profile = try? await getCurrentUserUseCase.execute() else { return }
        userName = [profile.name, profile.secondName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        userPhone = profile.phone ?? ""
        userEmail = profile.email
    }

    // MARK: - Salon header

    var salonName: String { salon.name }
    var addressLine: String { salon.addressLine ?? "" }
    var salonImageURL: URL? {
        (salon.coverImageUrl ?? salon.imageUrls.first).flatMap(URL.init(string:))
    }

    // MARK: - Date / time

    /// e.g. "Середа, 25 Чер, 2025" — same format as the home appointment card.
    var dateText: String {
        guard let date = Self.dayDate(from: datetime) else { return "" }
        return Self.dayLabelFormatter.string(from: date).capitalized
    }

    /// e.g. "9:00 - 11:00" — start taken from the slot's local clock, end is
    /// start + total duration. String-based so it never shifts with the device
    /// timezone (mirrors `SelectDateTimeViewModel.timeComponent(from:)`).
    var timeText: String {
        guard let startMinutes = Self.minutesOfDay(from: datetime) else { return "" }
        let endMinutes = startMinutes + totalDurationMinutes
        return "\(Self.clock(startMinutes)) - \(Self.clock(endMinutes))"
    }

    // MARK: - Services / totals

    private var selectedServices: [SalonService] {
        salon.services
            .filter { selectedServiceIds.contains($0.id) }
            .sorted { ($0.sortOrder ?? .max) < ($1.sortOrder ?? .max) }
    }

    private var totalDurationMinutes: Int {
        selectedServices.reduce(0) { $0 + $1.durationMinutes }
    }

    private var totalPrice: Double {
        selectedServices.reduce(0) { $0 + $1.price }
    }

    /// Reuses the edit-sheet row model (name + duration + price) already used by
    /// the previous step.
    var serviceRows: [SelectServiceViewModel.AddedServiceModel] {
        selectedServices.map { service in
            SelectServiceViewModel.AddedServiceModel(
                id: service.id,
                name: service.name,
                duration: Localization.salonDuration("\(service.durationMinutes)"),
                price: Localization.priceUAH(formattedPrice(service.price))
            )
        }
    }

    var totalPriceText: String { Localization.priceUAH(formattedPrice(totalPrice)) }

    // MARK: - Intents

    func didTapApplyDiscount() {
        let code = discountCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else { return }
        // Discount validation isn't built yet — keep the placeholder toast.
        showSuccess(
            title: Localization.salonProfileComingSoonTitle,
            message: Localization.salonProfileComingSoonMessage,
            scope: .current
        )
    }

    func didTapConfirm() {
        guard !isLoading else { return }
        Task { await submitBooking() }
    }

    private func submitBooking() async {
        showLoader()
        defer { hideLoader() }
        do {
            let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
            let result = try await createBookingUseCase.execute(
                salonId: salon.id,
                workerId: workerId,
                serviceIds: Array(selectedServiceIds),
                datetime: datetime,
                comment: trimmedComment.isEmpty ? nil : trimmedComment
            )
            // Hand off to the coordinator, which shows the success splash
            // (Figma 143:3199) before returning to the salon profile.
            transition.didFinishBooking(result)
        } catch {
            // Surfaces backend 400s (e.g. missing name/phone) via NetworkError.
            showError(error)
        }
    }

    // MARK: - Helpers

    private func formattedPrice(_ price: Double) -> String {
        price.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", price)
            : String(format: "%.2f", price)
    }

    // MARK: - Date / time formatting (static)

    /// "EEEE, d MMM, yyyy" in the app's display language — same as the home
    /// appointment card, so the date matches the rest of the UI's language.
    private static let dayLabelFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .appDisplay
        f.dateFormat = "EEEE, d MMM, yyyy"
        return f
    }()

    /// Gregorian day from a datetime string's leading `yyyy-MM-dd`.
    private static let dayParser: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale(identifier: "uk_UA")
        f.calendar = c
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static func dayDate(from datetime: String) -> Date? {
        dayParser.date(from: String(datetime.prefix(10)))
    }

    /// Minutes-since-midnight from the datetime's local `HH:mm` (chars 11–15).
    private static func minutesOfDay(from datetime: String) -> Int? {
        guard datetime.count >= 16 else { return nil }
        let start = datetime.index(datetime.startIndex, offsetBy: 11)
        let end = datetime.index(start, offsetBy: 5)
        let hhmm = datetime[start..<end].split(separator: ":")
        guard hhmm.count == 2, let h = Int(hhmm[0]), let m = Int(hhmm[1]) else { return nil }
        return h * 60 + m
    }

    /// Renders minutes-since-midnight back to "H:mm", wrapping past midnight.
    private static func clock(_ minutes: Int) -> String {
        let wrapped = ((minutes % 1440) + 1440) % 1440
        return String(format: "%d:%02d", wrapped / 60, wrapped % 60)
    }
}
