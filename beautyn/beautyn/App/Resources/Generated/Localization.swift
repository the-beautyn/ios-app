// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum Localization {
  public static let addButton = Localization.tr("Localizable", "add_button", fallback: "Додати")
  public static let addedButton = Localization.tr("Localizable", "added_button", fallback: "Додано")
  public static let authContinueApple = Localization.tr("Localizable", "auth_continue_apple", fallback: "Продовжити з Apple")
  public static let authContinueGoogle = Localization.tr("Localizable", "auth_continue_google", fallback: "Продовжити з Google")
  public static let authEmailInvalidFormat = Localization.tr("Localizable", "auth_email_invalid_format", fallback: "Невірний формат email")
  public static let authEmailPlaceholder = Localization.tr("Localizable", "auth_email_placeholder", fallback: "Введіть email")
  public static func authSocialAccountMessage(_ p1: Any) -> String {
    return Localization.tr("Localizable", "auth_social_account_message", String(describing: p1), fallback: "Цей аккаунт зареєстрований через %@")
  }
  public static let authSubtitle = Localization.tr("Localizable", "auth_subtitle", fallback: "Створи акаунт або увійди.")
  public static let authTitle = Localization.tr("Localizable", "auth_title", fallback: "Авторизація")
  public static let bookingAnyMaster = Localization.tr("Localizable", "booking_any_master", fallback: "Будь-який")
  public static let bookingApplyButton = Localization.tr("Localizable", "booking_apply_button", fallback: "Застосувати")
  public static let bookingChooseDay = Localization.tr("Localizable", "booking_choose_day", fallback: "Оберіть день:")
  public static let bookingChooseTime = Localization.tr("Localizable", "booking_choose_time", fallback: "Оберіть час:")
  public static let bookingClearButton = Localization.tr("Localizable", "booking_clear_button", fallback: "Почистити")
  public static let bookingDatePickerTitle = Localization.tr("Localizable", "booking_date_picker_title", fallback: "Оберіть час та дату")
  public static let bookingDetailsComingSoon = Localization.tr("Localizable", "booking_details_coming_soon", fallback: "Деталі бронювання будуть доступні незабаром.")
  public static let bookingDetailsTitle = Localization.tr("Localizable", "booking_details_title", fallback: "Деталі бронювання")
  public static let bookingSuccessTitle = Localization.tr("Localizable", "booking_success_title", fallback: "Вас успішно записано")
  public static func bookingTotalPrice(_ p1: Any) -> String {
    return Localization.tr("Localizable", "booking_total_price", String(describing: p1), fallback: "Всього: %@ грн")
  }
  public static let bookingsBookButton = Localization.tr("Localizable", "bookings_book_button", fallback: "Забронювати")
  public static let bookingsCancelledSectionTitle = Localization.tr("Localizable", "bookings_cancelled_section_title", fallback: "Скасовані записи")
  public static let bookingsEmptyCancelled = Localization.tr("Localizable", "bookings_empty_cancelled", fallback: "У вас немає скасованих записів")
  public static let bookingsEmptyPast = Localization.tr("Localizable", "bookings_empty_past", fallback: "У вас немає попередніх записів")
  public static let bookingsEmptyUpcoming = Localization.tr("Localizable", "bookings_empty_upcoming", fallback: "У вас немає наступних записів")
  public static let bookingsPastSectionTitle = Localization.tr("Localizable", "bookings_past_section_title", fallback: "Попередні записи")
  public static let bookingsTabCancelled = Localization.tr("Localizable", "bookings_tab_cancelled", fallback: "Скасовані")
  public static let bookingsTabPast = Localization.tr("Localizable", "bookings_tab_past", fallback: "Попередні")
  public static let bookingsTabUpcoming = Localization.tr("Localizable", "bookings_tab_upcoming", fallback: "Наступні")
  public static let bookingsTitle = Localization.tr("Localizable", "bookings_title", fallback: "Мої бронювання")
  public static let bookingsUpcomingSectionTitle = Localization.tr("Localizable", "bookings_upcoming_section_title", fallback: "Наступні записи")
  public static let checkEmailSentBack = Localization.tr("Localizable", "check_email_sent_back", fallback: "Повернутись на вхід")
  public static func checkEmailSentSubtitle(_ p1: Any) -> String {
    return Localization.tr("Localizable", "check_email_sent_subtitle", String(describing: p1), fallback: "Ми надіслали інструкцію на %@")
  }
  public static let checkEmailSentTitle = Localization.tr("Localizable", "check_email_sent_title", fallback: "Перевірте вашу пошту")
  public static let commonCancel = Localization.tr("Localizable", "common_cancel", fallback: "Скасувати")
  public static let commonDone = Localization.tr("Localizable", "common_done", fallback: "Готово")
  public static let commonNotSpecified = Localization.tr("Localizable", "common_not_specified", fallback: "Не вказано")
  public static let commonToday = Localization.tr("Localizable", "common_today", fallback: "Сьогодні")
  public static let commonTomorrow = Localization.tr("Localizable", "common_tomorrow", fallback: "Завтра")
  public static let commonYesterday = Localization.tr("Localizable", "common_yesterday", fallback: "Вчора")
  public static let confirmBookingCommentPlaceholder = Localization.tr("Localizable", "confirm_booking_comment_placeholder", fallback: "Залиште додаткові коментарі для майстра або салону")
  public static let confirmBookingCommentTitle = Localization.tr("Localizable", "confirm_booking_comment_title", fallback: "Коментар")
  public static let confirmBookingConfirmButton = Localization.tr("Localizable", "confirm_booking_confirm_button", fallback: "Підтвердити")
  public static let confirmBookingDiscountPlaceholder = Localization.tr("Localizable", "confirm_booking_discount_placeholder", fallback: "Введить код")
  public static let confirmBookingDiscountTitle = Localization.tr("Localizable", "confirm_booking_discount_title", fallback: "Код знижки")
  public static let confirmBookingPaymentOnSite = Localization.tr("Localizable", "confirm_booking_payment_on_site", fallback: "Оплата на місці")
  public static let confirmBookingSuccess = Localization.tr("Localizable", "confirm_booking_success", fallback: "Бронювання створено")
  public static let confirmBookingTitle = Localization.tr("Localizable", "confirm_booking_title", fallback: "Підтвердження запису")
  public static let confirmBookingYourData = Localization.tr("Localizable", "confirm_booking_your_data", fallback: "Ваші дані")
  public static let continueButton = Localization.tr("Localizable", "continue_button", fallback: "Продовжити")
  public static let detailsButton = Localization.tr("Localizable", "details_button", fallback: "Деталі")
  public static let editProfileBirthDateDayPlaceholder = Localization.tr("Localizable", "edit_profile_birth_date_day_placeholder", fallback: "ДД")
  public static let editProfileBirthDateLabel = Localization.tr("Localizable", "edit_profile_birth_date_label", fallback: "Дата народження")
  public static let editProfileBirthDateMonthPlaceholder = Localization.tr("Localizable", "edit_profile_birth_date_month_placeholder", fallback: "ММ")
  public static let editProfileBirthDateYearPlaceholder = Localization.tr("Localizable", "edit_profile_birth_date_year_placeholder", fallback: "РРРР")
  public static let editProfileCityLabel = Localization.tr("Localizable", "edit_profile_city_label", fallback: "Місто")
  public static let editProfileFirstNameLabel = Localization.tr("Localizable", "edit_profile_first_name_label", fallback: "І'мя")
  public static let editProfileLastNameLabel = Localization.tr("Localizable", "edit_profile_last_name_label", fallback: "Призвіще")
  public static let editProfilePhoneChangeMessage = Localization.tr("Localizable", "edit_profile_phone_change_message", fallback: "Якщо ви зміните номер, його потрібно буде підтвердити заново.")
  public static let editProfilePhoneChangeTitle = Localization.tr("Localizable", "edit_profile_phone_change_title", fallback: "Зміна номера телефону")
  public static let editProfilePhoneLabel = Localization.tr("Localizable", "edit_profile_phone_label", fallback: "Номер телефону")
  public static let editProfileSexLabel = Localization.tr("Localizable", "edit_profile_sex_label", fallback: "Стать")
  public static let editProfileTitle = Localization.tr("Localizable", "edit_profile_title", fallback: "Редагування профілю")
  public static func editServicesCount(_ p1: Int) -> String {
    return Localization.tr("Localizable", "edit_services_count", p1, fallback: "%d послуги")
  }
  public static let editServicesTitle = Localization.tr("Localizable", "edit_services_title", fallback: "Додані послуги")
  public static let editServicesTotal = Localization.tr("Localizable", "edit_services_total", fallback: "Всього")
  public static func errorData(_ p1: Any) -> String {
    return Localization.tr("Localizable", "error_data", String(describing: p1), fallback: "Помилка даних: %@")
  }
  public static let errorInvalidResponse = Localization.tr("Localizable", "error_invalid_response", fallback: "Невірна відповідь сервера.")
  public static let errorNoConnection = Localization.tr("Localizable", "error_no_connection", fallback: "Відсутнє інтернет-з'єднання.")
  public static func errorServer(_ p1: Int) -> String {
    return Localization.tr("Localizable", "error_server", p1, fallback: "Помилка сервера (%d).")
  }
  public static let errorTimeout = Localization.tr("Localizable", "error_timeout", fallback: "Час очікування запиту вичерпано.")
  public static let errorTitle = Localization.tr("Localizable", "error_title", fallback: "Помилка")
  public static let errorUnknown = Localization.tr("Localizable", "error_unknown", fallback: "Сталася невідома помилка.")
  public static let forgotPasswordLink = Localization.tr("Localizable", "forgot_password_link", fallback: "Забули пароль?")
  public static let forgotPasswordSubtitle = Localization.tr("Localizable", "forgot_password_subtitle", fallback: "Ми відправимо на вказану пошту інструкцію по відновленню")
  public static let forgotPasswordTitle = Localization.tr("Localizable", "forgot_password_title", fallback: "Забули пароль?")
  public static func homeAppointmentDuration(_ p1: Any) -> String {
    return Localization.tr("Localizable", "home_appointment_duration", String(describing: p1), fallback: "%@ хв.")
  }
  public static func homeAppointmentPrice(_ p1: Any) -> String {
    return Localization.tr("Localizable", "home_appointment_price", String(describing: p1), fallback: "%@ грн")
  }
  public static func homeGreeting(_ p1: Any) -> String {
    return Localization.tr("Localizable", "home_greeting", String(describing: p1), fallback: "Привіт, %@!")
  }
  public static let homeGreetingUnauthorized = Localization.tr("Localizable", "home_greeting_unauthorized", fallback: "Привіт!")
  public static let homeSectionAvailableToday = Localization.tr("Localizable", "home_section_available_today", fallback: "Nails доступні сьогодні 💅🏼")
  public static let homeSectionNearby = Localization.tr("Localizable", "home_section_nearby", fallback: "Перукар біля тебе 💇🏻‍♀️")
  public static let homeSectionNextAppointment = Localization.tr("Localizable", "home_section_next_appointment", fallback: "Наступний запис")
  public static let homeSectionPopular = Localization.tr("Localizable", "home_section_popular", fallback: "Популярні ⭐️")
  public static let homeSectionSaved = Localization.tr("Localizable", "home_section_saved", fallback: "Збережені 🩷")
  public static let inputPhonePlaceholder = Localization.tr("Localizable", "input_phone_placeholder", fallback: "номер телефону")
  public static let locationPickerMyGeolocation = Localization.tr("Localizable", "location_picker_my_geolocation", fallback: "Моя геолокація")
  public static let locationPickerPermissionDenied = Localization.tr("Localizable", "location_picker_permission_denied", fallback: "Відкрийте Налаштування, щоб дозволити доступ до геолокації")
  public static let locationPickerSearchPlaceholder = Localization.tr("Localizable", "location_picker_search_placeholder", fallback: "Уведить адресу або місто")
  public static let locationPickerTitle = Localization.tr("Localizable", "location_picker_title", fallback: "Локація")
  public static let loginPasswordPlaceholder = Localization.tr("Localizable", "login_password_placeholder", fallback: "Введіть пароль")
  public static func loginSubtitle(_ p1: Any) -> String {
    return Localization.tr("Localizable", "login_subtitle", String(describing: p1), fallback: "Введіть пароль від аккаунту зареєстрованого за поштою %@")
  }
  public static let loginTitle = Localization.tr("Localizable", "login_title", fallback: "Увійдіть до аккаунту")
  public static let mapsAppleMaps = Localization.tr("Localizable", "maps_apple_maps", fallback: "Apple Maps")
  public static let mapsChooserTitle = Localization.tr("Localizable", "maps_chooser_title", fallback: "Відкрити в")
  public static let mapsGoogleMaps = Localization.tr("Localizable", "maps_google_maps", fallback: "Google Maps")
  public static let okButton = Localization.tr("Localizable", "ok_button", fallback: "OK")
  public static let or = Localization.tr("Localizable", "or", fallback: "або")
  public static let phoneCodeChangeNumber = Localization.tr("Localizable", "phone_code_change_number", fallback: "Змінити номер")
  public static let phoneCodeResend = Localization.tr("Localizable", "phone_code_resend", fallback: "Відправити ще раз")
  public static func phoneCodeSubtitle(_ p1: Any) -> String {
    return Localization.tr("Localizable", "phone_code_subtitle", String(describing: p1), fallback: "Введіть 4-значний код, який ми відправили на %@")
  }
  public static let phoneVerificationLegal = Localization.tr("Localizable", "phone_verification_legal", fallback: "Натискаючи \"Відправити код\", ви погоджуєтесь з Умовами використання та Політикою конфіденційності")
  public static let phoneVerificationSendCode = Localization.tr("Localizable", "phone_verification_send_code", fallback: "Відправити код")
  public static let phoneVerificationSubtitle = Localization.tr("Localizable", "phone_verification_subtitle", fallback: "Для завершення реєстрації, будь ласка, підтвердіть ваш номер телефону")
  public static let phoneVerificationTitle = Localization.tr("Localizable", "phone_verification_title", fallback: "Веріфікуй свій номер телефону")
  public static func priceUAH(_ p1: Any) -> String {
    return Localization.tr("Localizable", "price_uah", String(describing: p1), fallback: "%@ грн")
  }
  public static let profileChangePasswordSuccess = Localization.tr("Localizable", "profile_change_password_success", fallback: "Пароль оновлено")
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
  public static let profileSettingsChangePassword = Localization.tr("Localizable", "profile_settings_change_password", fallback: "Змінити пароль")
  public static let profileSettingsDeleteAccount = Localization.tr("Localizable", "profile_settings_delete_account", fallback: "Видалити акаунт")
  public static let profileSettingsDeleteAccountAlertConfirm = Localization.tr("Localizable", "profile_settings_delete_account_alert_confirm", fallback: "Видалити")
  public static let profileSettingsDeleteAccountAlertMessage = Localization.tr("Localizable", "profile_settings_delete_account_alert_message", fallback: "Цю дію неможливо скасувати. Ваш профіль, історія записів і всі особисті дані будуть остаточно видалені.")
  public static let profileSettingsDeleteAccountAlertTitle = Localization.tr("Localizable", "profile_settings_delete_account_alert_title", fallback: "Видалити акаунт?")
  public static let profileSettingsDeleteAccountSuccess = Localization.tr("Localizable", "profile_settings_delete_account_success", fallback: "Акаунт видалено")
  public static let profileSettingsLogout = Localization.tr("Localizable", "profile_settings_logout", fallback: "Вийти з акаунту")
  public static let profileSettingsLogoutAlertConfirm = Localization.tr("Localizable", "profile_settings_logout_alert_confirm", fallback: "Вийти")
  public static let profileSettingsLogoutAlertMessage = Localization.tr("Localizable", "profile_settings_logout_alert_message", fallback: "Ви вийдете з облікового запису. Щоб продовжити користуватися застосунком, потрібно буде увійти знову.")
  public static let profileSettingsLogoutAlertTitle = Localization.tr("Localizable", "profile_settings_logout_alert_title", fallback: "Вийти з акаунту?")
  public static let profileSettingsPrivacyPolicy = Localization.tr("Localizable", "profile_settings_privacy_policy", fallback: "Privacy Policy")
  public static let profileSettingsTermsOfService = Localization.tr("Localizable", "profile_settings_terms_of_service", fallback: "Terms of Service")
  public static let profileSettingsTitle = Localization.tr("Localizable", "profile_settings_title", fallback: "Налаштування")
  public static let profileSexFemale = Localization.tr("Localizable", "profile_sex_female", fallback: "Жіноча")
  public static let profileSexMale = Localization.tr("Localizable", "profile_sex_male", fallback: "Чоловіча")
  public static let profileSexOther = Localization.tr("Localizable", "profile_sex_other", fallback: "Інша")
  public static let profileSexPreferNotToSay = Localization.tr("Localizable", "profile_sex_prefer_not_to_say", fallback: "Не вказувати")
  public static let profileTitle = Localization.tr("Localizable", "profile_title", fallback: "Профайл")
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
  public static let salonProfileComingSoonMessage = Localization.tr("Localizable", "salon_profile_coming_soon_message", fallback: "Онлайн-запис у застосунку буде доступний найближчим часом.")
  public static let salonProfileComingSoonTitle = Localization.tr("Localizable", "salon_profile_coming_soon_title", fallback: "Скоро")
  public static let salonProfileNothingFound = Localization.tr("Localizable", "salon_profile_nothing_found", fallback: "Нічого не знайдено")
  public static let salonProfileSearchPlaceholder = Localization.tr("Localizable", "salon_profile_search_placeholder", fallback: "Пошук")
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
  public static let savedSalonsEmpty = Localization.tr("Localizable", "saved_salons_empty", fallback: "Ви ще не додали жоден салон")
  public static let savedSalonsSearchPlaceholder = Localization.tr("Localizable", "saved_salons_search_placeholder", fallback: "Уведить назву салону")
  public static let savedSalonsTitle = Localization.tr("Localizable", "saved_salons_title", fallback: "Обрані салони")
  public static let searchFilterPrice = Localization.tr("Localizable", "search_filter_price", fallback: "Ціна")
  public static let searchFilterServiceType = Localization.tr("Localizable", "search_filter_service_type", fallback: "Тип послуги")
  public static let searchFilterSort = Localization.tr("Localizable", "search_filter_sort", fallback: "Сортувати")
  public static let searchHint = Localization.tr("Localizable", "search_hint", fallback: "Уведить назву салону або майстра")
  public static func searchResultsCount(_ p1: Int) -> String {
    return Localization.tr("Localizable", "search_results_count", p1, fallback: "Знайдено: %d місць")
  }
  public static let selectButton = Localization.tr("Localizable", "select_button", fallback: "Обрати")
  public static let selectServiceOtherCategory = Localization.tr("Localizable", "select_service_other_category", fallback: "Інше")
  public static let selectServiceTitle = Localization.tr("Localizable", "select_service_title", fallback: "Оберіть послугу")
  public static let sendButton = Localization.tr("Localizable", "send_button", fallback: "Відправити")
  public static let setNewPasswordConfirmLabel = Localization.tr("Localizable", "set_new_password_confirm_label", fallback: "Повторити новий пароль")
  public static let setNewPasswordEmailLabel = Localization.tr("Localizable", "set_new_password_email_label", fallback: "Твій email")
  public static let setNewPasswordExpiredLink = Localization.tr("Localizable", "set_new_password_expired_link", fallback: "Посилання недійсне або застаріле. Запросіть нове.")
  public static let setNewPasswordMismatch = Localization.tr("Localizable", "set_new_password_mismatch", fallback: "Паролі не збігаються")
  public static let setNewPasswordNewLabel = Localization.tr("Localizable", "set_new_password_new_label", fallback: "Новий пароль")
  public static func setNewPasswordNewLinkSent(_ p1: Any) -> String {
    return Localization.tr("Localizable", "set_new_password_new_link_sent", String(describing: p1), fallback: "Ми надіслали нове посилання на %@")
  }
  public static let setNewPasswordRequestNewLink = Localization.tr("Localizable", "set_new_password_request_new_link", fallback: "Запросити нове посилання")
  public static let setNewPasswordSuccess = Localization.tr("Localizable", "set_new_password_success", fallback: "Пароль успішно змінено")
  public static let setNewPasswordTitle = Localization.tr("Localizable", "set_new_password_title", fallback: "Змінити пароль")
  public static let signUpFirstNamePlaceholder = Localization.tr("Localizable", "sign_up_first_name_placeholder", fallback: "Введіть ім'я")
  public static let signUpLastNamePlaceholder = Localization.tr("Localizable", "sign_up_last_name_placeholder", fallback: "Введіть Прізвище")
  public static let signUpPasswordPlaceholder = Localization.tr("Localizable", "sign_up_password_placeholder", fallback: "Створіть пароль")
  public static let signUpSubtitle = Localization.tr("Localizable", "sign_up_subtitle", fallback: "Додайте інформацію про себе")
  public static let signUpTitle = Localization.tr("Localizable", "sign_up_title", fallback: "Створення аккаунту")
  public static let tabBookings = Localization.tr("Localizable", "tab_bookings", fallback: "Бронювання")
  public static let tabHome = Localization.tr("Localizable", "tab_home", fallback: "Головна")
  public static let tabProfile = Localization.tr("Localizable", "tab_profile", fallback: "Профайл")
  public static let tabSearch = Localization.tr("Localizable", "tab_search", fallback: "Пошук")
  public static let validationInvalidCode = Localization.tr("Localizable", "validation_invalid_code", fallback: "Невірний код")
  public static let validationInvalidPhone = Localization.tr("Localizable", "validation_invalid_phone", fallback: "Невірний номер телефону")
  public static let validationNewPasswordSameAsOld = Localization.tr("Localizable", "validation_new_password_same_as_old", fallback: "Новий пароль має відрізнятися від старого")
  public static let validationOldPasswordIncorrect = Localization.tr("Localizable", "validation_old_password_incorrect", fallback: "Старий пароль невірний")
  public static let validationPasswordDigit = Localization.tr("Localizable", "validation_password_digit", fallback: "Пароль має містити хоча б одну цифру")
  public static let validationPasswordLatinOnly = Localization.tr("Localizable", "validation_password_latin_only", fallback: "Пароль має містити лише латинські літери, цифри та спецсимволи")
  public static let validationPasswordLowercase = Localization.tr("Localizable", "validation_password_lowercase", fallback: "Пароль має містити хоча б одну малу літеру")
  public static let validationPasswordMaxLength = Localization.tr("Localizable", "validation_password_max_length", fallback: "Пароль має містити максимум 50 символів")
  public static let validationPasswordMinLength = Localization.tr("Localizable", "validation_password_min_length", fallback: "Пароль має містити мінімум 8 символів")
  public static let validationPasswordUppercase = Localization.tr("Localizable", "validation_password_uppercase", fallback: "Пароль має містити хоча б одну велику літеру")
  public static let validationPasswordsDontMatch = Localization.tr("Localizable", "validation_passwords_dont_match", fallback: "Паролі не співпадають")
  public static let validationRequiredField = Localization.tr("Localizable", "validation_required_field", fallback: "Обов'язкове поле")
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
