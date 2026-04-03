// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Localization {

  // MARK: - Common
  public static let addButton = Localization.tr("Localizable", "add_button", fallback: "Додати")
  public static let addedButton = Localization.tr("Localizable", "added_button", fallback: "Додано")
  public static let continueButton = Localization.tr("Localizable", "continue_button", fallback: "Продовжити")
  public static let detailsButton = Localization.tr("Localizable", "details_button", fallback: "Деталі")
  public static let errorTitle = Localization.tr("Localizable", "error_title", fallback: "Помилка")
  public static let inputPhonePlaceholder = Localization.tr("Localizable", "input_phone_placeholder", fallback: "номер телефону")
  public static let okButton = Localization.tr("Localizable", "ok_button", fallback: "OK")
  public static let or = Localization.tr("Localizable", "or", fallback: "або")
  public static let searchHint = Localization.tr("Localizable", "search_hint", fallback: "Уведить назву салону або майстра")
  public static let selectButton = Localization.tr("Localizable", "select_button", fallback: "Обрати")
  public static let sendButton = Localization.tr("Localizable", "send_button", fallback: "Відправити")

  // MARK: - Errors
  public static let errorInvalidResponse = Localization.tr("Localizable", "error_invalid_response", fallback: "Невірна відповідь сервера.")
  public static func errorServer(_ p1: Int) -> String {
    return Localization.tr("Localizable", "error_server", p1, fallback: "Помилка сервера (%d).")
  }
  public static let errorNoConnection = Localization.tr("Localizable", "error_no_connection", fallback: "Відсутнє інтернет-з'єднання.")
  public static let errorTimeout = Localization.tr("Localizable", "error_timeout", fallback: "Час очікування запиту вичерпано.")
  public static func errorData(_ p1: Any) -> String {
    return Localization.tr("Localizable", "error_data", String(describing: p1), fallback: "Помилка даних: %@")
  }
  public static let errorUnknown = Localization.tr("Localizable", "error_unknown", fallback: "Сталася невідома помилка.")

  // MARK: - Tab Bar
  public static let tabBookings = Localization.tr("Localizable", "tab_bookings", fallback: "Бронювання")
  public static let tabHome = Localization.tr("Localizable", "tab_home", fallback: "Головна")
  public static let tabProfile = Localization.tr("Localizable", "tab_profile", fallback: "Профайл")
  public static let tabSearch = Localization.tr("Localizable", "tab_search", fallback: "Пошук")

  // MARK: - Authorization
  public static let authContinueApple = Localization.tr("Localizable", "auth_continue_apple", fallback: "Продовжити з Apple")
  public static let authContinueGoogle = Localization.tr("Localizable", "auth_continue_google", fallback: "Продовжити з Google")
  public static let authEmailPlaceholder = Localization.tr("Localizable", "auth_email_placeholder", fallback: "Введіть email")
  public static let authSubtitle = Localization.tr("Localizable", "auth_subtitle", fallback: "Створи акаунт або увійди.")
  public static let authTitle = Localization.tr("Localizable", "auth_title", fallback: "Авторизація")
  public static let forgotPasswordLink = Localization.tr("Localizable", "forgot_password_link", fallback: "Забули пароль?")
  public static let forgotPasswordSubtitle = Localization.tr("Localizable", "forgot_password_subtitle", fallback: "Ми відправимо на вказану пошту інструкцію по відновленню")
  public static let forgotPasswordTitle = Localization.tr("Localizable", "forgot_password_title", fallback: "Забули пароль?")
  public static let loginPasswordPlaceholder = Localization.tr("Localizable", "login_password_placeholder", fallback: "Введіть пароль")
  public static func loginSubtitle(_ p1: Any) -> String {
    return Localization.tr("Localizable", "login_subtitle", String(describing: p1), fallback: "Введіть пароль від аккаунту зареєстрованого за поштою %@")
  }
  public static let loginTitle = Localization.tr("Localizable", "login_title", fallback: "Увійдіть до аккаунту")
  public static let signUpFirstNamePlaceholder = Localization.tr("Localizable", "sign_up_first_name_placeholder", fallback: "Введіть ім'я")
  public static let signUpLastNamePlaceholder = Localization.tr("Localizable", "sign_up_last_name_placeholder", fallback: "Введіть Прізвище")
  public static let signUpPasswordPlaceholder = Localization.tr("Localizable", "sign_up_password_placeholder", fallback: "Створіть пароль")
  public static let signUpSubtitle = Localization.tr("Localizable", "sign_up_subtitle", fallback: "Додайте інформацію про себе")
  public static let signUpTitle = Localization.tr("Localizable", "sign_up_title", fallback: "Створення аккаунту")

  // MARK: - Home
  public static func homeGreeting(_ p1: Any) -> String {
    return Localization.tr("Localizable", "home_greeting", String(describing: p1), fallback: "Привіт, %@!")
  }
  public static let homeGreetingUnauthorized = Localization.tr("Localizable", "home_greeting_unauthorized", fallback: "Привіт!")
  public static let homeSectionAvailableToday = Localization.tr("Localizable", "home_section_available_today", fallback: "Nails доступні сьогодні 💅🏼")
  public static let homeSectionNearby = Localization.tr("Localizable", "home_section_nearby", fallback: "Перукар біля тебе 💇🏻‍♀️")
  public static let homeSectionNextAppointment = Localization.tr("Localizable", "home_section_next_appointment", fallback: "Наступний запис")
  public static let homeSectionPopular = Localization.tr("Localizable", "home_section_popular", fallback: "Популярні ⭐️")
  public static let homeSectionSaved = Localization.tr("Localizable", "home_section_saved", fallback: "Збережені 🩷")
  public static func homeAppointmentPrice(_ p1: Any) -> String {
    return Localization.tr("Localizable", "home_appointment_price", String(describing: p1), fallback: "%@ грн")
  }
  public static func homeAppointmentDuration(_ p1: Any) -> String {
    return Localization.tr("Localizable", "home_appointment_duration", String(describing: p1), fallback: "%@ хв.")
  }

  // MARK: - Search
  public static let searchFilterPrice = Localization.tr("Localizable", "search_filter_price", fallback: "Ціна")
  public static let searchFilterServiceType = Localization.tr("Localizable", "search_filter_service_type", fallback: "Тип послуги")
  public static let searchFilterSort = Localization.tr("Localizable", "search_filter_sort", fallback: "Сортувати")
  public static func searchResultsCount(_ p1: Int) -> String {
    return Localization.tr("Localizable", "search_results_count", p1, fallback: "Знайдено: %d місць")
  }

  // MARK: - Salon Profile
  public static let salonBadgeTopMasters = Localization.tr("Localizable", "salon_badge_top_masters", fallback: "Top 10 Masters")
  public static let salonBookButton = Localization.tr("Localizable", "salon_book_button", fallback: "Записатись")
  public static func salonDuration(_ p1: Any) -> String {
    return Localization.tr("Localizable", "salon_duration", String(describing: p1), fallback: "%@ хв.")
  }
  public static func salonOptionsCount(_ p1: Int) -> String {
    return Localization.tr("Localizable", "salon_options_count", p1, fallback: "%d опцій")
  }
  public static func salonPriceFrom(_ p1: Any) -> String {
    return Localization.tr("Localizable", "salon_price_from", String(describing: p1), fallback: "від %@ грн")
  }
  public static func salonSpecialistNearestDate(_ p1: Any) -> String {
    return Localization.tr("Localizable", "salon_specialist_nearest_date", String(describing: p1), fallback: "Найближча дата запису %@:")
  }
  public static let salonTabDetails = Localization.tr("Localizable", "salon_tab_details", fallback: "Деталі")
  public static let salonTabPortfolio = Localization.tr("Localizable", "salon_tab_portfolio", fallback: "Портфоліо")
  public static func salonTabReviews(_ p1: Int) -> String {
    return Localization.tr("Localizable", "salon_tab_reviews", p1, fallback: "Відгуки (%d)")
  }
  public static let salonTabServices = Localization.tr("Localizable", "salon_tab_services", fallback: "Послуги")
  public static let salonTabSpecialists = Localization.tr("Localizable", "salon_tab_specialists", fallback: "Спеціалісти")

  // MARK: - Booking
  public static let bookingAnyMaster = Localization.tr("Localizable", "booking_any_master", fallback: "Будь-який")
  public static let bookingApplyButton = Localization.tr("Localizable", "booking_apply_button", fallback: "Застосувати")
  public static let bookingChooseDay = Localization.tr("Localizable", "booking_choose_day", fallback: "Оберіть день:")
  public static let bookingChooseTime = Localization.tr("Localizable", "booking_choose_time", fallback: "Оберіть час:")
  public static let bookingClearButton = Localization.tr("Localizable", "booking_clear_button", fallback: "Почистити")
  public static let bookingDatePickerTitle = Localization.tr("Localizable", "booking_date_picker_title", fallback: "Оберіть час та дату")
  public static func bookingTotalPrice(_ p1: Any) -> String {
    return Localization.tr("Localizable", "booking_total_price", String(describing: p1), fallback: "Всього: %@ грн")
  }

  // MARK: - My Bookings
  public static let bookingsTabCancelled = Localization.tr("Localizable", "bookings_tab_cancelled", fallback: "Скасовані")
  public static let bookingsTabPast = Localization.tr("Localizable", "bookings_tab_past", fallback: "Попередні")
  public static let bookingsTabUpcoming = Localization.tr("Localizable", "bookings_tab_upcoming", fallback: "Наступні")
  public static let bookingsTitle = Localization.tr("Localizable", "bookings_title", fallback: "Мої бронювання")
  public static let bookingsUpcomingSectionTitle = Localization.tr("Localizable", "bookings_upcoming_section_title", fallback: "Наступні записи")

  // MARK: - My Profile
  public static let profileChangePasswordTitle = Localization.tr("Localizable", "profile_change_password_title", fallback: "Змінити пароль")
  public static let profileCity = Localization.tr("Localizable", "profile_city", fallback: "Місто")
  public static let profileConfirmPasswordLabel = Localization.tr("Localizable", "profile_confirm_password_label", fallback: "Повторити новий пароль")
  public static let profileDateOfBirth = Localization.tr("Localizable", "profile_date_of_birth", fallback: "Дата народження")
  public static let profileEditButton = Localization.tr("Localizable", "profile_edit_button", fallback: "Редагувати профіль")
  public static let profileEmail = Localization.tr("Localizable", "profile_email", fallback: "Пошта")
  public static let profileGender = Localization.tr("Localizable", "profile_gender", fallback: "Стать")
  public static let profileMenuLanguage = Localization.tr("Localizable", "profile_menu_language", fallback: "Мова")
  public static let profileMenuNotifications = Localization.tr("Localizable", "profile_menu_notifications", fallback: "Нотифікації")
  public static let profileMenuPersonalData = Localization.tr("Localizable", "profile_menu_personal_data", fallback: "Персональні дані")
  public static let profileMenuSavedSalons = Localization.tr("Localizable", "profile_menu_saved_salons", fallback: "Обрані салони")
  public static let profileMenuSettings = Localization.tr("Localizable", "profile_menu_settings", fallback: "Налаштування")
  public static let profileNewPasswordLabel = Localization.tr("Localizable", "profile_new_password_label", fallback: "Новий пароль")
  public static let profileOldPasswordLabel = Localization.tr("Localizable", "profile_old_password_label", fallback: "Старий пароль")
  public static let profilePersonalDataTitle = Localization.tr("Localizable", "profile_personal_data_title", fallback: "Персональні дані")
  public static let profilePhoneNumber = Localization.tr("Localizable", "profile_phone_number", fallback: "Номер телефону")
  public static let profileTitle = Localization.tr("Localizable", "profile_title", fallback: "Профайл")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Localization {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
