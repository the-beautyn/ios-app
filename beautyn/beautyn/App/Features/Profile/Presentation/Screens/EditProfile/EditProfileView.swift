import SwiftUI

// MARK: - EditProfileView
//
// Matches Figma node 1:8605 ("Редагування профілю"). The screen is hosted in
// a UINavigationController — the title and trailing confirm checkmark are
// owned by `EditProfileController` via UIKit, not SwiftUI.

struct EditProfileView: BaseViewProtocol {

    @StateObject var viewModel: EditProfileViewModel

    private enum Field { case firstName, lastName, phone }
    @FocusState private var focusedField: Field?

    var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CGFloat.Spacing.sm + 4) {
                nameField
                secondNameField
                birthDateField
                phoneField
                cityField
                sexField
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .padding(.top, CGFloat.Spacing.md)
            .padding(.bottom, CGFloat.Spacing.xxxl)
        }
        .background(Color.App.backgroundLight)
        .sheet(isPresented: $viewModel.isDateSheetPresented) {
            BirthDateSheet(
                initialDate: viewModel.birthDate ?? defaultBirthDate,
                onCancel: { viewModel.isDateSheetPresented = false },
                onDone:   viewModel.didSelectBirthDate
            )
        }
        .sheet(isPresented: $viewModel.isCitySheetPresented) {
            LocationPickerView(
                viewModel: LocationPickerViewModel(
                    transition: .init(
                        didSelectCity: viewModel.didSelectCity,
                        didDismiss:    viewModel.didDismissCitySheet
                    )
                )
            )
        }
        .alert(
            Localization.editProfilePhoneChangeTitle,
            isPresented: $viewModel.isPhoneChangeAlertPresented
        ) {
            Button(Localization.commonCancel, role: .cancel) {}
            Button(Localization.continueButton) { viewModel.confirmPhoneChange() }
        } message: {
            Text(Localization.editProfilePhoneChangeMessage)
        }
    }

    // MARK: - Fields

    private var nameField: some View {
        LabeledField(label: Localization.editProfileFirstNameLabel) {
            AppTextField(
                placeholder: Localization.signUpFirstNamePlaceholder,
                text: $viewModel.name,
                textContentType: .givenName,
                onSubmit: { focusedField = .lastName }
            )
            .focused($focusedField, equals: .firstName)
        }
    }

    private var secondNameField: some View {
        LabeledField(label: Localization.editProfileLastNameLabel) {
            AppTextField(
                placeholder: Localization.signUpLastNamePlaceholder,
                text: $viewModel.secondName,
                textContentType: .familyName,
                onSubmit: { viewModel.didTapBirthDate() }
            )
            .focused($focusedField, equals: .lastName)
        }
    }

    private var birthDateField: some View {
        LabeledField(label: Localization.editProfileBirthDateLabel) {
            EditProfileBirthDateRow(
                date: viewModel.birthDate,
                onTap: viewModel.didTapBirthDate
            )
        }
    }

    private var phoneField: some View {
        LabeledField(label: Localization.editProfilePhoneLabel) {
            AppPhoneField(
                countryCode: viewModel.countryCode,
                text: Binding(
                    get: { viewModel.phoneDigits },
                    set: viewModel.updatePhoneDigits
                ),
                errorMessage: viewModel.phoneError
            )
            .focused($focusedField, equals: .phone)
        }
    }

    private var cityField: some View {
        LabeledField(label: Localization.editProfileCityLabel) {
            EditProfileSelectorField(
                placeholder: Localization.editProfileCityLabel,
                value: viewModel.city,
                onTap: viewModel.didTapCity
            )
        }
    }

    private var sexField: some View {
        LabeledField(label: Localization.editProfileSexLabel) {
            EditProfileSelectorField(
                placeholder: Localization.editProfileSexLabel,
                value: viewModel.sexDisplay(viewModel.sex),
                onTap: viewModel.didTapSex
            )
        }
        // Attached to the field (not the root ScrollView) so iOS anchors the
        // popover-style presentation to the trigger row instead of the scroll
        // view's center.
        .confirmationDialog(
            Localization.editProfileSexLabel,
            isPresented: $viewModel.isSexDialogPresented,
            titleVisibility: .visible
        ) {
            Button(Localization.profileSexFemale)         { viewModel.didSelectSex(.female) }
            Button(Localization.profileSexMale)           { viewModel.didSelectSex(.male) }
            Button(Localization.profileSexOther)          { viewModel.didSelectSex(.other) }
            Button(Localization.profileSexPreferNotToSay) { viewModel.didSelectSex(.preferNotToSay) }
            Button(Localization.commonCancel, role: .cancel) {}
        }
    }

    // MARK: - Defaults

    /// 1990-01-01 — neutral default for the date sheet's first open when the
    /// user has no stored birth date.
    private var defaultBirthDate: Date {
        var components = DateComponents()
        components.year = 1990
        components.month = 1
        components.day = 1
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }
}

// MARK: - Birth date sheet

private struct BirthDateSheet: View {
    let initialDate: Date
    let onCancel: () -> Void
    let onDone: (Date) -> Void

    @State private var date: Date

    init(initialDate: Date, onCancel: @escaping () -> Void, onDone: @escaping (Date) -> Void) {
        self.initialDate = initialDate
        self.onCancel = onCancel
        self.onDone = onDone
        _date = State(initialValue: initialDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(Localization.commonCancel, action: onCancel)
                    .font(.App.callout)
                    .foregroundStyle(Color.App.brown1)
                Spacer()
                Text(Localization.editProfileBirthDateLabel)
                    .font(.App.headline)
                    .foregroundStyle(Color.App.text)
                Spacer()
                Button(Localization.commonDone) { onDone(date) }
                    .font(.App.calloutMedium)
                    .foregroundStyle(Color.App.brown1)
            }
            .padding(.horizontal, CGFloat.Spacing.md)
            .frame(height: 44)

            DatePicker(
                "",
                selection: $date,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .environment(\.locale, Locale(identifier: "uk_UA"))
            .padding(.horizontal, CGFloat.Spacing.md)

            Spacer(minLength: 0)
        }
        .presentationDetents([.medium, .large])
        .background(Color.App.backgroundLight)
    }
}
