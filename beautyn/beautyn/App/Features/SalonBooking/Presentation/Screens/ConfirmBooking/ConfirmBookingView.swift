import SwiftUI

// MARK: - ConfirmBookingView
//
// Matches Figma "Підтвердження запису" (node 143:4979). Scrollable review of the
// booking (salon, day/time, services + total, discount, comment) with the
// "Підтвердити" button pinned to the bottom.

struct ConfirmBookingView: BaseViewProtocol {

    @StateObject var viewModel: ConfirmBookingViewModel

    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: CGFloat.Spacing.xs) {
                salonHeader
                dateTimeRows
                servicesSummary
                yourDataSection
                discountSection
                commentSection
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.lg)
        }
        // The comment field sits low, so let the scroll view lift the focused
        // field above the keyboard. `.interactively` lets the keyboard track the
        // drag down (smooth), so it and the Confirm bar move together — no
        // keyboard toolbar, whose "Done" accessory overlapped the Confirm bar.
        .scrollDismissesKeyboard(.interactively)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.App.white)
        .safeAreaInset(edge: .bottom, spacing: 0) { bottomBar }
    }

    // MARK: - Salon header

    private var salonHeader: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            CachedImage(
                url: viewModel.salonImageURL,
                size: CGSize(width: 68, height: 68),
                clipShape: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )

            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.salonName)
                    .font(.App.headline)
                    .foregroundStyle(Color.App.black)
                    .lineLimit(1)

                Text(viewModel.addressLine)
                    .font(.App.subheadline)
                    .foregroundStyle(Color.App.gray.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Date & time rows

    private var dateTimeRows: some View {
        VStack(alignment: .leading, spacing: 0) {
            infoRow(icon: "calendar", text: viewModel.dateText)
            infoRow(icon: "clock", text: viewModel.timeText)
        }
        .padding(.vertical, CGFloat.Spacing.sm)
    }

    private func infoRow(icon: String, text: String, iconColor: Color = Color.App.gray2) -> some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(iconColor)
                .frame(width: 20, height: 20)

            Text(text)
                .font(.App.caption2)
                .tracking(CGFloat.Tracking.caption2)
                .foregroundStyle(Color.App.gray2)
        }
    }

    // MARK: - Your data (Ваші дані)

    private var yourDataSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
            Text(Localization.confirmBookingYourData)
                .font(.App.headline)
                .foregroundStyle(Color.App.black)

            VStack(alignment: .leading, spacing: 0) {
                if !viewModel.userName.isEmpty {
                    infoRow(icon: "person", text: viewModel.userName, iconColor: Color.App.gray)
                }
                if !viewModel.userPhone.isEmpty {
                    infoRow(icon: "phone", text: viewModel.userPhone, iconColor: Color.App.gray)
                }
                if !viewModel.userEmail.isEmpty {
                    infoRow(icon: "envelope", text: viewModel.userEmail, iconColor: Color.App.gray)
                }
            }
        }
        .padding(.vertical, CGFloat.Spacing.sm)
    }

    // MARK: - Services summary

    private var servicesSummary: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.xs) {
            ForEach(viewModel.serviceRows) { row in
                serviceRow(row)
            }

            Rectangle()
                .fill(Color.App.blueTransparency)
                .frame(height: 1)
                .padding(.vertical, CGFloat.Spacing.sm)

            totalRow
        }
    }

    private func serviceRow(_ row: SelectServiceViewModel.AddedServiceModel) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(row.name)
                    .font(.App.footnote)
                    .foregroundStyle(Color.App.black)

                Text(row.duration)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.gray2)
            }

            Spacer(minLength: CGFloat.Spacing.sm)

            Text(row.price)
                .font(.App.footnote)
                .foregroundStyle(Color.App.black)
        }
        .padding(.vertical, CGFloat.Spacing.xs)
    }

    private var totalRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                Text(Localization.editServicesTotal)
                    .font(.App.footnoteSemibold)
                    .foregroundStyle(Color.App.black)

                Text(Localization.confirmBookingPaymentOnSite)
                    .font(.App.caption2)
                    .tracking(CGFloat.Tracking.caption2)
                    .foregroundStyle(Color.App.gray2)
            }

            Spacer(minLength: CGFloat.Spacing.sm)

            Text(viewModel.totalPriceText)
                .font(.App.footnoteSemibold)
                .foregroundStyle(Color.App.black)
        }
        .padding(.vertical, CGFloat.Spacing.xs)
    }

    // MARK: - Discount

    private var discountSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
            Text(Localization.confirmBookingDiscountTitle)
                .font(.App.headline)
                .foregroundStyle(Color.App.black)

            HStack(alignment: .center, spacing: CGFloat.Spacing.sm) {
                AppTextField(
                    placeholder: Localization.confirmBookingDiscountPlaceholder,
                    text: $viewModel.discountCode
                )

                AppButton.secondaryOutlined(
                    title: Localization.bookingApplyButton,
                    size: .big
                ) {
                    viewModel.didTapApplyDiscount()
                }
                .frame(width: 140)
            }
        }
        .padding(.vertical, CGFloat.Spacing.sm)
    }

    // MARK: - Comment

    private var commentSection: some View {
        VStack(alignment: .leading, spacing: CGFloat.Spacing.sm) {
            Text(Localization.confirmBookingCommentTitle)
                .font(.App.headline)
                .foregroundStyle(Color.App.black)

            AppTextEditor(
                placeholder: Localization.confirmBookingCommentPlaceholder,
                text: $viewModel.comment
            )
        }
        .padding(.vertical, CGFloat.Spacing.sm)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            AppButton(title: Localization.confirmBookingConfirmButton) {
                viewModel.didTapConfirm()
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .background(Color.App.white)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.App.blueTransparency)
                .frame(height: 1)
        }
    }
}

// MARK: - Preview

#if DEBUG
@MainActor
private func makePreviewVM() -> ConfirmBookingViewModel {
    let services = [
        SalonService(id: "srv1", salonId: "s1", categoryId: "c1", name: "Classic Manicure", description: nil, durationMinutes: 90, price: 700, currency: "UAH", isActive: true, sortOrder: 0, workerIds: [], imageUrls: []),
        SalonService(id: "srv2", salonId: "s1", categoryId: "c1", name: "French", description: nil, durationMinutes: 15, price: 150, currency: "UAH", isActive: true, sortOrder: 1, workerIds: [], imageUrls: [])
    ]
    let salon = Salon(
        id: "s1", name: "Nail bar: Glossy Room", provider: .altegio, bookingUrl: nil,
        addressLine: "вул. Зеленицька, 15, 05-091", city: "Київ", phone: nil, description: nil,
        coverImageUrl: nil, imageUrls: [], ratingAvg: 4.8, ratingCount: 85, workingSchedule: nil,
        topMastersTag: nil, isSaved: false, services: services, workers: [], categories: []
    )
    return ConfirmBookingViewModel(
        salon: salon,
        selectedServiceIds: ["srv1", "srv2"],
        workerId: nil,
        datetime: "2025-06-25T09:00:00+03:00",
        transition: .init(didFinishBooking: { _ in }),
        createBookingUseCase: PreviewCreateBookingUseCase(),
        getCurrentUserUseCase: PreviewCurrentUserUseCase()
    )
}

private final class PreviewCreateBookingUseCase: CreateAltegioBookingUseCase {
    func execute(salonId: String, workerId: String?, serviceIds: [String], datetime: String, comment: String?) async throws -> Booking {
        Booking(
            id: "preview", salonId: salonId, salonName: "Preview Salon", salonAddress: nil,
            salonImageURL: nil, coordinate: nil, bookingUrl: nil, crmType: .altegio, crmRecordId: nil, status: .created,
            datetime: Date(), endDatetime: nil, cancelledAt: nil, services: [],
            totalPrice: nil, currency: nil, durationMinutes: nil, timezone: nil
        )
    }
}

private final class PreviewCurrentUserUseCase: GetCurrentUserUseCase {
    func execute() async throws -> UserProfile {
        UserProfile(
            id: "u1", email: "helga.altuhova@gmail.com", role: "client", name: "Ольга",
            secondName: nil, phone: "+380506314634", avatarUrl: nil, birthDate: nil, city: nil,
            sex: nil, authProvider: "email", isPhoneVerified: true, isProfileCreated: true
        )
    }
}

#Preview {
    NavigationStack {
        ConfirmBookingView(viewModel: makePreviewVM())
            .navigationTitle(Localization.confirmBookingTitle)
            .navigationBarTitleDisplayMode(.inline)
    }
}
#endif
