import SwiftUI

// MARK: - EditProfileBirthDateRow
//
// Three side-by-side cells (Day · Month abbr · Year) styled to match
// `AppTextField`. All three share a single tap handler — tapping any cell
// opens the date picker sheet owned by the parent view. The month cell shows
// the Ukrainian short name (e.g. "Лют") and includes a chevron, matching
// Figma node 1:8631.

struct EditProfileBirthDateRow: View {

    let date: Date?
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: CGFloat.Spacing.sm) {
            cell(text: dayText, placeholder: Localization.editProfileBirthDateDayPlaceholder, showsChevron: false)
                .frame(maxWidth: .infinity)
            cell(text: monthText, placeholder: Localization.editProfileBirthDateMonthPlaceholder, showsChevron: true)
                .frame(maxWidth: .infinity)
            cell(text: yearText, placeholder: Localization.editProfileBirthDateYearPlaceholder, showsChevron: false)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Cell

    @ViewBuilder
    private func cell(text: String?, placeholder: String, showsChevron: Bool) -> some View {
        Button(action: onTap) {
            HStack(spacing: CGFloat.Spacing.sm) {
                Text(text ?? placeholder)
                    .font(.App.footnote)
                    .foregroundStyle(text == nil ? Color.App.gray2 : Color.App.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)

                if showsChevron {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.App.gray2)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.App.blueTransparency, lineWidth: 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Formatted parts

    private var dayText: String? {
        guard let date else { return nil }
        return Self.dayFormatter.string(from: date)
    }

    private var monthText: String? {
        guard let date else { return nil }
        let month = Calendar(identifier: .gregorian).component(.month, from: date)
        return Self.monthAbbreviations[safe: month - 1]
    }

    private var yearText: String? {
        guard let date else { return nil }
        return Self.yearFormatter.string(from: date)
    }

    // MARK: - Formatters

    private static let ukLocale = Locale(identifier: "uk_UA")

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = ukLocale
        f.dateFormat = "d"
        return f
    }()

    /// Capitalized 3-letter Ukrainian month abbreviations matching Figma
    /// (1:8633 shows "Лют"). Apple's `uk_UA` locale returns lowercase forms
    /// with trailing periods ("лют."), so we hard-code the expected forms.
    private static let monthAbbreviations: [String] = [
        "Січ", "Лют", "Бер", "Кві", "Тра", "Чер",
        "Лип", "Сер", "Вер", "Жов", "Лис", "Гру",
    ]

    private static let yearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = ukLocale
        f.dateFormat = "yyyy"
        return f
    }()
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#if DEBUG
#Preview {
    VStack(spacing: CGFloat.Spacing.md) {
        EditProfileBirthDateRow(date: nil, onTap: {})
        EditProfileBirthDateRow(date: Date(timeIntervalSince1970: 1_014_854_400), onTap: {})
    }
    .padding()
    .background(Color.App.backgroundLight)
}
#endif
