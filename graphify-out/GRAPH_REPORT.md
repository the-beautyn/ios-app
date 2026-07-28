# Graph Report - .  (2026-07-15)

## Corpus Check
- 450 files · ~125,296 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 4080 nodes · 8999 edges · 230 communities (227 shown, 3 thin omitted)
- Extraction: 90% EXTRACTED · 10% INFERRED · 0% AMBIGUOUS · INFERRED: 876 edges (avg confidence: 0.8)
- Token cost: 322,418 input · 0 output

## Community Hubs (Navigation)
- Shared UI Components
- Profile Screen
- Formatting & Localization
- Search Filters & Sorting
- Salon DTO & Mapping
- Saved Salons Domain
- Salon Profile Screen
- Home Feed UI
- Home Feed DTOs
- Service Type Filter
- Salon Profile ViewModel
- Auth Domain UseCases
- Search Map ViewModel
- Booking Details
- Search Domain Entities
- Agent Skills & Docs
- View Render Tests
- Search Geo Models
- Login Screen
- Search Data & Assembly
- Change Password Screen
- Navigation Router
- Email Check Flow
- Booking List DTOs
- Input Field Components
- Auth Data Layer
- Password Reset Flow
- Search Screen Factory
- Location Services
- Dependency Injection Container
- Profile Settings Screen
- Altegio Booking Data
- Select Date-Time Screen
- Bottom Sheet Component
- API Target Definitions
- App Factory & Resolver
- Bookings Domain UseCases
- Auth Screen Factory
- Sign Up Screen
- Bookings Data Layer
- Select Service Screen
- Bookings Repository Tests
- Home Feed Mapping
- Phone OTP Flow
- Search Map Items
- WebBookingWebView
- ForgotPasswordViewModel
- SessionManager
- BookingDetailsView
- SavedSalonsViewModel
- HomeViewRenderTests
- MainTabCoordinator
- AltegioBookableWorkersResponseDTO
- AltegioBookingRepositoryImpl
- Salon
- SearchLocationViewModel
- UserProfileDTO
- AppleSignInService
- Booking
- PhoneVerificationViewModel
- SalonProfileView
- SearchDTO
- BookingsSourceOfTruthTests
- SearchRepositoryImpl
- SelectDateTimeViewRenderTests
- SearchViewModel
- AppButton
- UserProfilePatchDTO
- NetworkService
- SalonBookingCoordinator
- ConfirmBookingViewModel
- BookingSuccessController
- ResolveInitialSearchRegionUseCase
- AuthCoordinator
- MyBookingsViewModel
- SearchLocationView
- SearchMapViewRenderTests
- BookingListResponseDTO
- MyBookingsView
- EditProfileViewModel
- LocationPickerViewModel
- SearchDatePickerViewModel
- SearchDTO (82)
- KeychainService
- UIApplication+Keyboard
- HomeView
- BeautynAlertContent
- AppCoordinator
- GetSalonByIdUseCase
- SearchSortView
- EventEditViewRepresentable
- ProfileCoordinator
- TokenRefresher
- AuthDTO
- AuthTarget
- MyBookingsCoordinator
- UserRepositoryImpl
- SearchMapView
- CalendarView
- NetworkService (99)
- BookingDetailsViewRenderTests
- HomeCoordinator
- MapsLauncher
- ResetPasswordCoordinator
- SalonBookingControllerFactory
- SearchViewModel (105)
- MyBookingsViewRenderTests
- SavedSalonsViewRenderTests
- AppDelegate
- HomeFeedRepositoryImpl
- PersonalDataViewModel
- AltegioBookableServicesResponseDTO
- UpdateNotificationSettingsRequest
- SearchViewRenderTests
- BaseHostingViewController
- WebBookingTests
- SceneDelegate
- SalonRepositoryImpl
- ConfirmBookingView
- AppRangeSlider
- ClearUserUseCase
- ConfirmBookingViewRenderTests
- BookingDetailsController
- ProfileSettingsViewModel
- SalonBookingEntry
- AltegioCreateRecordResponseDTO
- SalonsTarget
- ServiceRowView
- SelectServiceController
- SearchViewRenderTests (129)
- CachedImage
- ImagePipelineConfig
- HomeFeed
- PhoneVerificationCoordinator
- LocationPickerViewModel (134)
- WebBookingConfiguration
- SearchTarget
- AppointmentCardView
- WebPageView
- GoogleSignInService
- HomeViewRenderTests (140)
- MyBookingsControllerFactory
- BookingCategory
- ProfileControllerFactory
- EditProfileBirthDateRow
- BaseViewModel
- BookingMapView
- AppTypography
- DeepLinkingService
- DefaultsStorageService
- SocialAuthButtonView
- ObserveBookingsUseCase
- EditProfileViewModel (152)
- EditProfileView
- SelectDateTimeView
- SearchView
- AlertableViewModifier
- LoadableViewModifier
- EditProfileViewRenderTests
- HomeControllerFactoryImpl
- SavedSalonsRepositoryImpl
- ProfileMenuRowView
- PersonalDataController
- AltegioBookableWorker
- SpecialistRowView
- SearchLocation
- BaseViewModel (166)
- WebBookingWebView (167)
- WebBookingTests (168)
- AuthModels
- GetHomeFeedUseCase
- BookingStatusBadge
- EditProfileController
- ConfirmEasyweekBookingUseCase
- ShareSheetRepresentable
- NavigationBarVisibility
- NavigationBarVisibility (177)
- HomeController
- BookingMapper
- PhoneCodeView
- SavedSalonsMapper
- UserProfile
- LocationPickerViewModel (183)
- MasterPickerView
- ConfirmBookingController
- AlertableViewModel
- SalonCardView
- SalonBookingProvider
- ApiDateFormatter
- Environment
- BookingsSourceOfTruthTests (191)
- ChangePasswordUseCase
- RefreshTokenUseCase
- ResetPasswordUseCase
- NextBooking
- SalonCard
- BookingsRepository
- BookingDetailsView (198)
- SalonListTab
- GetLocationCompletionsUseCase
- ReverseGeocodeNameUseCase
- SearchBorderedField
- SalonSearchField
- app_store_icon_1024 1
- BookingDetailsViewRenderTests (205)
- BookingDetailsViewRenderTests (206)
- swiftui-pro-icon
- Resolver+Require
- MyBookingsViewModel (209)
- SalonStickyActionBar
- TabSelectorView
- SearchView (212)
- FilterChipView
- SearchPillButton
- WebPagePresentation
- AppColors
- SelectServiceViewRenderTests
- AppCategory
- CategoryChipView
- CreateAltegioBookingUseCase
- ObserveLocationPermissionUseCase
- SearchHeaderView
- SearchSheetHeaderView
- FavoriteButtonView
- RatingBadgeView
- AppSpacing
- app_store_icon_1024 2
- BookingDetailsViewRenderTests (228)
- SearchViewRenderTests (229)

## God Nodes (most connected - your core abstractions)
1. `Foundation` - 232 edges
2. `SwiftUI` - 136 edges
3. `SearchMapViewModel` - 82 edges
4. `Date` - 66 edges
5. `UIKit` - 63 edges
6. `SessionManager` - 63 edges
7. `Combine` - 61 edges
8. `BookingDetailsViewModel` - 56 edges
9. `SalonProfileViewModel` - 56 edges
10. `HomeViewModel` - 53 edges

## Surprising Connections (you probably didn't know these)
- `SwiftUI Data Flow and State Rules (@Observable over ObservableObject)` --semantically_similar_to--> `ViewModel Pattern (@Published state, intents, calls UseCases only, never repositories)`  [INFERRED] [semantically similar]
  .agents/skills/swiftui-pro/references/data.md → AGENTS.md
- `SwiftUI Design and HIG Rules (shared constants enum, 44pt tap areas)` --semantically_similar_to--> `Design Token System (Font.App.*, Color.App.*, CGFloat.Spacing.*, CGFloat.Tracking.*, Localization.*). Rationale: the design system is the single source of truth for the app's look; no hardcoded fonts, colors, spacings, or sizes in feature code`  [INFERRED] [semantically similar]
  .agents/skills/swiftui-pro/references/design.md → AGENTS.md
- `15-Category UI Audit Checklist (A-O: structure through chrome)` --semantically_similar_to--> `SwiftUI Design and HIG Rules (shared constants enum, 44pt tap areas)`  [INFERRED] [semantically similar]
  .claude/skills/audit-ui/SKILL.md → .agents/skills/swiftui-pro/references/design.md
- `ViewRenderer Render Pipeline (UIHostingController in UIWindow, 0.5s async wait, sizeThatFits, 2x PNG to /tmp/beautyn_previews). Rationale: Xcode SwiftUI Previews are not accessible from the CLI, so render tests are the CLI-equivalent visual check` --semantically_similar_to--> `Code Hygiene Rules (secrets, tests, string catalogs, Xcode MCP RenderPreview)`  [INFERRED] [semantically similar]
  .claude/skills/render-preview/SKILL.md → .agents/skills/swiftui-pro/references/hygiene.md
- `SocialAuthButtonView` --references--> `Google Logo Icon (ic_google)`  [INFERRED]
  beautyn/beautyn/App/Features/Authorization/Presentation/Components/SocialAuthButtonView.swift → beautyn/beautyn/Assets.xcassets/ic_google.imageset/ic_google.svg

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Figma-to-SwiftUI UI Workflow (token map -> implement -> static review -> swiftui-pro -> render-preview -> audit-ui)** — _claude_skills_build_ui_from_figma_skill_build_ui_from_figma, _claude_skills_render_preview_skill_render_preview, _claude_skills_audit_ui_skill_audit_ui, _agents_skills_swiftui_pro_skill_swiftui_pro, agents_design_token_system [EXTRACTED 1.00]
- **Clean Architecture Feature Pattern (MVVM + Coordinator + UseCase + Repository + DI)** — agents_clean_architecture_layers, agents_entity_boundary_enforcement, agents_repository_pattern, agents_usecase_pattern, agents_viewmodel_pattern, agents_coordinator_pattern, agents_controllerfactory_pattern, agents_dependency_injection_swinject [EXTRACTED 1.00]
- **SwiftUI Pro Nine-Step Review Process** — _agents_skills_swiftui_pro_skill_swiftui_pro, _agents_skills_swiftui_pro_references_api_modern_api_rules, _agents_skills_swiftui_pro_references_views_view_rules, _agents_skills_swiftui_pro_references_data_data_flow_rules, _agents_skills_swiftui_pro_references_navigation_navigation_rules, _agents_skills_swiftui_pro_references_design_design_rules, _agents_skills_swiftui_pro_references_accessibility_rules, _agents_skills_swiftui_pro_references_performance_performance_rules, _agents_skills_swiftui_pro_references_swift_swift_rules, _agents_skills_swiftui_pro_references_hygiene_hygiene_rules [EXTRACTED 1.00]

## Communities (230 total, 3 thin omitted)

### Community 0 - "Shared UI Components"
Cohesion: 0.04
Nodes (48): SearchBarButton, Void, SectionHeaderView, String, Void, BookingTabSelector, Void, BookingActionRow (+40 more)

### Community 1 - "Profile Screen"
Cohesion: 0.05
Nodes (33): ProfileController, NSCoder, ProfileView, View, ProfileViewModel, Bool, URL, Void (+25 more)

### Community 2 - "Formatting & Localization"
Cohesion: 0.08
Nodes (19): BookingCardFormatter, Booking, Bool, Double, String, BundleToken, Localization, Any (+11 more)

### Community 3 - "Search Filters & Sorting"
Cohesion: 0.08
Nodes (27): SearchFilterOptions, SearchSortOption, distance, popular, priceAsc, priceDesc, ratingDesc, SearchSortContext (+19 more)

### Community 4 - "Salon DTO & Mapping"
Cohesion: 0.05
Nodes (48): CodingKeys, addressLine, bookingUrl, categories, categoryId, city, color, country (+40 more)

### Community 5 - "Saved Salons Domain"
Cohesion: 0.06
Nodes (31): SavedSalonsRepository, GetSavedSalonsUseCase, GetSavedSalonsUseCaseImpl, Int, SavedSalonsList, String, SaveSalonUseCaseImpl, String (+23 more)

### Community 6 - "Salon Profile Screen"
Cohesion: 0.07
Nodes (25): SalonProfileController, AnyCancellable, Bool, NSCoder, UIBarButtonItem, UIImage, SalonProfileView, CGFloat (+17 more)

### Community 7 - "Home Feed UI"
Cohesion: 0.08
Nodes (23): items, GetHomeFeedUseCase, CategoryChipModel, String, URL, SavedSalonItemView, SavedSalonUI, CGFloat (+15 more)

### Community 8 - "Home Feed DTOs"
Cohesion: 0.04
Nodes (47): CodingKeys, addressLine, appCategoryIds, bookingId, categories, city, coverImageUrl, createdAt (+39 more)

### Community 9 - "Service Type Filter"
Cohesion: 0.08
Nodes (23): ServiceTypeFilterContext, AppCategory, Void, [AppCategory], CountingResolveInitialRegionUseCase, MockGetAppCategoriesUseCase, SearchMapCategoryFilterTests, ServiceTypeFilterViewModelTests (+15 more)

### Community 10 - "Salon Profile ViewModel"
Cohesion: 0.09
Nodes (20): SalonWorker, String, GetAltegioAvailableServicesUseCase, GetAltegioAvailableWorkersUseCase, SalonProfileViewModel, ShareSheetPresentation, Binding, Booking (+12 more)

### Community 11 - "Auth Domain UseCases"
Cohesion: 0.07
Nodes (19): AuthRepository, DeleteAccountUseCaseImpl, ForgotPasswordUseCaseImpl, String, LoginUseCase, LoginUseCaseImpl, String, LogoutUseCaseImpl (+11 more)

### Community 12 - "Search Map ViewModel"
Cohesion: 0.08
Nodes (24): GetSearchFilterOptionsUseCase, ObserveLocationPermissionUseCase, PreviewGetSearchFilterOptionsUseCase, FilterChip, price, serviceType, sort, SearchMapViewModel (+16 more)

### Community 13 - "Booking Details"
Cohesion: 0.10
Nodes (22): ObserveBookingUseCase, RefreshBookingUseCase, SyncBookingFromCrmUseCase, BookingDetailsViewModel, CalendarDraft, ServiceRow, ShareSheetPresentation, State (+14 more)

### Community 14 - "Search Domain Entities"
Cohesion: 0.11
Nodes (17): SearchPin, SearchQuery, SearchResults, SearchSalon, SearchViewport, Bool, Double, Int (+9 more)

### Community 15 - "Agent Skills & Docs"
Cohesion: 0.08
Nodes (39): SwiftUI Pro Agent Interface Config, SwiftUI Accessibility Rules (Dynamic Type, VoiceOver, Reduce Motion), Modern SwiftUI API Rules (deprecated API replacements), SwiftUI Data Flow and State Rules (@Observable over ObservableObject), SwiftUI Design and HIG Rules (shared constants enum, 44pt tap areas), Code Hygiene Rules (secrets, tests, string catalogs, Xcode MCP RenderPreview), Navigation and Presentation Rules (NavigationStack, sheets, dialogs), SwiftUI Performance Rules (structural identity, lazy stacks, task cancellation) (+31 more)

### Community 16 - "View Render Tests"
Cohesion: 0.10
Nodes (19): PhoneCodeView, View, AuthViewRenderTests, MockCheckEmailUseCase, MockForgotPasswordUseCase, MockLoginUseCase, MockResetPasswordUseCase, MockSendPhoneOTPUseCase (+11 more)

### Community 17 - "Search Geo Models"
Cohesion: 0.12
Nodes (17): GeoPoint, Double, SearchRegion, Double, SearchInputContext, SearchSubmission, String, Void (+9 more)

### Community 18 - "Login Screen"
Cohesion: 0.08
Nodes (14): LoginController, Bool, NSCoder, LoginView, Bool, View, LoginViewModel, Bool (+6 more)

### Community 19 - "Search Data & Assembly"
Cohesion: 0.09
Nodes (13): SearchAssembly, SearchRepository, ClearSearchHistoryUseCaseImpl, DeleteSearchHistoryItemUseCaseImpl, String, GetAppCategoriesUseCase, GetAppCategoriesUseCaseImpl, AppCategory (+5 more)

### Community 20 - "Change Password Screen"
Cohesion: 0.09
Nodes (14): ChangePasswordController, Bool, NSCoder, ChangePasswordView, View, ChangePasswordViewModel, Bool, String (+6 more)

### Community 21 - "Navigation Router"
Cohesion: 0.14
Nodes (14): Router, Bool, UINavigationController, UIViewController, Void, SearchControllerFactory, SearchCoordinator, SearchModalDismissDelegate (+6 more)

### Community 22 - "Email Check Flow"
Cohesion: 0.09
Nodes (16): CheckEmailUseCase, CheckEmailUseCaseImpl, String, EmailCheckController, Bool, NSCoder, EmailCheckView, PreviewCheckEmailUseCase (+8 more)

### Community 23 - "Booking List DTOs"
Cohesion: 0.06
Nodes (33): CodingKeys, addressLine, cancelledAt, cost, costToPay, coverImageUrl, crmRecordId, crmType (+25 more)

### Community 24 - "Input Field Components"
Cohesion: 0.13
Nodes (23): AppCodeField, AppPhoneField, AppSecureField, AppTextEditor, AppTextField, Color, InputHintRow, InputMetrics (+15 more)

### Community 25 - "Auth Data Layer"
Cohesion: 0.11
Nodes (11): AuthMapper, AuthRepositoryImpl, Bool, String, AuthSession, OAuthSession, Bool, Int (+3 more)

### Community 26 - "Password Reset Flow"
Cohesion: 0.10
Nodes (18): ForgotPasswordUseCase, String, UIViewController, SetNewPasswordController, Bool, NSCoder, UIBarButtonItem, PreviewForgotPasswordUseCase (+10 more)

### Community 27 - "Search Screen Factory"
Cohesion: 0.10
Nodes (15): SearchControllerFactoryImpl, AssemblerLike, UIViewController, ServiceTypeFilterController, NSCoder, PreviewGetAppCategoriesUseCase, ServiceTypeFilterView, AppCategory (+7 more)

### Community 28 - "Location Services"
Cohesion: 0.11
Nodes (19): CompleterDelegate, LocationDelegate, SearchLocationServiceImpl, AnyPublisher, Bool, CheckedContinuation, CLAuthorizationStatus, CLLocation (+11 more)

### Community 29 - "Dependency Injection Container"
Cohesion: 0.12
Nodes (13): Assembler, Assembly, Container, Resolver, Any, String, T, AuthAssembly (+5 more)

### Community 30 - "Profile Settings Screen"
Cohesion: 0.10
Nodes (14): DeleteAccountUseCase, LogoutUseCase, ProfileSettingsController, Bool, NSCoder, ProfileSettingsView, View, ProfileSettingsViewModel (+6 more)

### Community 31 - "Altegio Booking Data"
Cohesion: 0.10
Nodes (14): SalonBookingFactoryImpl, AltegioBookingRepository, GetAltegioAvailableServicesUseCaseImpl, Set, String, GetAltegioAvailableWorkersUseCaseImpl, Bool, String (+6 more)

### Community 32 - "Select Date-Time Screen"
Cohesion: 0.15
Nodes (12): SelectDateTimeViewModel, Binding, DateFormatter, Double, Int, Never, Salon, Set (+4 more)

### Community 33 - "Bottom Sheet Component"
Cohesion: 0.14
Nodes (21): AppBottomSheet, BottomSheetStyle, draggable, fixed, PreviewRoot, SnapPosition, compact, fraction (+13 more)

### Community 34 - "API Target Definitions"
Cohesion: 0.08
Nodes (29): AccessTokenAuthorizable, HomeFeedTarget, getHomeFeed, AuthorizationType, Double, String, URL, SavedSalonsTarget (+21 more)

### Community 35 - "App Factory & Resolver"
Cohesion: 0.14
Nodes (19): AppFactory, AppFactoryImpl, Assembler, Resolver, ResolverInjector, ResolverInjectorImpl, AuthFactory, AuthFactoryImpl (+11 more)

### Community 36 - "Bookings Domain UseCases"
Cohesion: 0.09
Nodes (16): BookingsRepository, ObserveBookingUseCaseImpl, AnyPublisher, Booking, Never, String, RefreshBookingsUseCase, RefreshBookingsUseCaseImpl (+8 more)

### Community 37 - "Auth Screen Factory"
Cohesion: 0.11
Nodes (13): AuthControllerFactoryImpl, AssemblerLike, String, UIViewController, CheckEmailSentController, Bool, NSCoder, CheckEmailSentView (+5 more)

### Community 38 - "Sign Up Screen"
Cohesion: 0.10
Nodes (17): SignUpController, Bool, NSCoder, Field, firstName, lastName, password, PreviewRegisterUseCase (+9 more)

### Community 39 - "Bookings Data Layer"
Cohesion: 0.14
Nodes (15): BookingsRepositoryImpl, AnyPublisher, Booking, Int, ISO8601DateFormatter, Never, String, BookingsTarget (+7 more)

### Community 40 - "Select Service Screen"
Cohesion: 0.15
Nodes (13): AddedServiceModel, CategoryTab, SelectServiceViewModel, Binding, Double, Int, Never, Salon (+5 more)

### Community 41 - "Bookings Repository Tests"
Cohesion: 0.16
Nodes (10): BookingsRepositoryTests, InMemoryStorage, MockBookingsRepository, Any, AnyObject, AnyPublisher, Booking, Never (+2 more)

### Community 42 - "Home Feed Mapping"
Cohesion: 0.18
Nodes (17): AppCategoryDTO, HomeFeedNextBookingDTO, HomeFeedNextBookingServiceDTO, HomeFeedResponseDTO, HomeFeedSalonCardDTO, HomeFeedSectionDTO, HomeFeedSectionSearchParamsDTO, SavedSalonItemDTO (+9 more)

### Community 43 - "Phone OTP Flow"
Cohesion: 0.10
Nodes (12): SendPhoneOTPUseCase, SendPhoneOTPUseCaseImpl, String, PhoneCodeController, Bool, NSCoder, PhoneCodeViewModel, String (+4 more)

### Community 44 - "Search Map Items"
Cohesion: 0.11
Nodes (16): SearchMapCluster, SearchMapItem, cluster, pin, SearchMapPin, CLLocationCoordinate2D, Double, Int (+8 more)

### Community 45 - "WebBookingWebView"
Cohesion: 0.15
Nodes (14): String, WebBookingAutofill, String, URL, WebBookingResult, Coordinator, Coordinator, Int (+6 more)

### Community 46 - "ForgotPasswordViewModel"
Cohesion: 0.11
Nodes (13): ForgotPasswordController, Bool, NSCoder, ForgotPasswordView, PreviewForgotPasswordUseCase, String, View, ForgotPasswordViewModel (+5 more)

### Community 47 - "SessionManager"
Cohesion: 0.14
Nodes (15): RefreshTokenUseCaseImpl, AuthState, authenticated, unauthenticated, unknown, SessionManager, AnyPublisher, Bool (+7 more)

### Community 48 - "BookingDetailsView"
Cohesion: 0.14
Nodes (17): makePreviewViewModel(), PreviewConfirmEasyweekBookingUseCase, PreviewGetCurrentUserUseCase, PreviewGetSalonByIdUseCase, PreviewGetSalonShareUseCase, PreviewObserveBookingUseCase, PreviewRefreshBookingUseCase, PreviewSavedSalonsEventBus (+9 more)

### Community 49 - "SavedSalonsViewModel"
Cohesion: 0.13
Nodes (11): SaveSalonUseCase, UnsaveSalonUseCase, SavedSalonsController, Bool, NSCoder, SavedSalonsView, View, SavedSalonsViewModel (+3 more)

### Community 50 - "HomeViewRenderTests"
Cohesion: 0.14
Nodes (14): HomeViewRenderTests, MockGetCurrentUserUseCase, MockHomeFeedUseCase, MockObserveBookingUseCase, MockSavedSalonsEventBus, MockSaveSalonUseCase, MockUnsaveSalonUseCase, AnyPublisher (+6 more)

### Community 51 - "MainTabCoordinator"
Cohesion: 0.13
Nodes (13): MainTabBarController, MainTabCoordinator, Assembler, Bool, String, UIImage, UINavigationController, UIViewController (+5 more)

### Community 52 - "AltegioBookableWorkersResponseDTO"
Cohesion: 0.11
Nodes (17): AltegioBookableWorkerDTO, AltegioBookableWorkersResponseDTO, AltegioBookingSlotDTO, CodingKeys, seanceLengthSec, sumLengthSec, time, Bool (+9 more)

### Community 53 - "AltegioBookingRepositoryImpl"
Cohesion: 0.11
Nodes (17): AltegioBookingRepositoryImpl, Bool, Set, String, AltegioBookingTarget, createRecord, getBookableDates, getBookableServices (+9 more)

### Community 54 - "Salon"
Cohesion: 0.10
Nodes (18): Salon, Bool, Double, Int, SalonBookingProvider, String, URL, SalonCategory (+10 more)

### Community 55 - "SearchLocationViewModel"
Cohesion: 0.14
Nodes (13): SearchLocationController, NSCoder, SearchLocationView, View, Row, SearchLocationViewModel, Duration, Int (+5 more)

### Community 56 - "UserProfileDTO"
Cohesion: 0.09
Nodes (19): CodingKeys, authProvider, avatarUrl, birthDate, city, email, id, isOnboardingCompleted (+11 more)

### Community 57 - "AppleSignInService"
Cohesion: 0.12
Nodes (16): ASAuthorization, ASAuthorizationController, ASAuthorizationControllerDelegate, AuthenticationServices, AppleSignInError, missingToken, AppleSignInResult, AppleSignInServiceImpl (+8 more)

### Community 58 - "Booking"
Cohesion: 0.11
Nodes (19): NextBookingMapper, Booking, Booking, BookingService, BookingStatus, canceled, completed, created (+11 more)

### Community 59 - "PhoneVerificationViewModel"
Cohesion: 0.13
Nodes (13): String, UIViewController, PhoneVerificationController, Bool, NSCoder, PhoneVerificationView, Bool, View (+5 more)

### Community 60 - "SalonProfileView"
Cohesion: 0.15
Nodes (15): makePreviewViewModel(), PreviewConfirmEasyweekBookingUseCase, PreviewGetAltegioAvailableServicesUseCase, PreviewGetAltegioAvailableWorkersUseCase, PreviewGetCurrentUserUseCase, PreviewGetSalonByIdUseCase, PreviewGetSalonShareUseCase, PreviewSaveSalonUseCase (+7 more)

### Community 61 - "SearchDTO"
Cohesion: 0.17
Nodes (19): AppCategoriesResponseDTO, FilterOptionsResponseDTO, SearchHistoryItemDTO, SearchMetaDTO, SearchPinItemDTO, SearchPinsResponseDTO, SearchRequestDTO, SearchResponseDTO (+11 more)

### Community 62 - "BookingsSourceOfTruthTests"
Cohesion: 0.13
Nodes (12): Set, BookingCategoryOrderingTests, BookingCategoryTests, makeBooking(), StaleBookingReconcileTests, D, SalonBookingProvider, TaskPriority (+4 more)

### Community 63 - "SearchRepositoryImpl"
Cohesion: 0.15
Nodes (13): String, SearchRepositoryImpl, AppCategory, Int, String, Bool, AuthorizationType, Data (+5 more)

### Community 64 - "SelectDateTimeViewRenderTests"
Cohesion: 0.13
Nodes (12): SelectDateTimeController, Bool, NSCoder, SelectDateTimeView, View, Salon, SelectDateTimeViewRenderTests, StubDatesUseCase (+4 more)

### Community 65 - "SearchViewModel"
Cohesion: 0.18
Nodes (10): Row, SearchViewModel, Bool, DateFormatter, Duration, Never, SearchSalon, String (+2 more)

### Community 66 - "AppButton"
Cohesion: 0.17
Nodes (16): AppButton, AppButtonStyle, Size, big, small, Style, primary, secondary (+8 more)

### Community 67 - "UserProfilePatchDTO"
Cohesion: 0.09
Nodes (16): CodingKeys, avatarUrl, birthDate, city, name, phone, secondName, sex (+8 more)

### Community 68 - "NetworkService"
Cohesion: 0.17
Nodes (3): Alamofire, Foundation, Moya

### Community 69 - "SalonBookingCoordinator"
Cohesion: 0.22
Nodes (11): T, SalonBookingControllerFactory, SalonBookingCoordinator, Assembler, Booking, Bool, Salon, Set (+3 more)

### Community 70 - "ConfirmBookingViewModel"
Cohesion: 0.15
Nodes (12): datetime, ConfirmBookingViewModel, Booking, DateFormatter, Double, Int, Salon, Set (+4 more)

### Community 71 - "BookingSuccessController"
Cohesion: 0.12
Nodes (12): BookingSuccessController, Bool, NSCoder, BookingSuccessView, View, BookingSuccessViewModel, Duration, Void (+4 more)

### Community 72 - "ResolveInitialSearchRegionUseCase"
Cohesion: 0.14
Nodes (8): SearchLocationService, GetUserLocationUseCaseImpl, ObserveLocationPermissionUseCaseImpl, ResolveInitialSearchRegionUseCaseImpl, Span, Double, ResolveLocationCompletionUseCase, ResolveLocationCompletionUseCaseImpl

### Community 73 - "AuthCoordinator"
Cohesion: 0.22
Nodes (9): AuthControllerFactory, AuthCoordinator, Assembler, Bool, Error, String, UIViewController, OAuthSignInUseCase (+1 more)

### Community 74 - "MyBookingsViewModel"
Cohesion: 0.16
Nodes (11): MyBookingsViewModel, Booking, Bool, String, Void, TabState, failed, idle (+3 more)

### Community 75 - "SearchLocationView"
Cohesion: 0.12
Nodes (12): SearchLocationCompletion, Int, String, PreviewGetLocationCompletionsUseCase, PreviewObserveLocationPermissionUseCase, PreviewResolveLocationCompletionUseCase, PreviewReverseGeocodeNameUseCase, AnyPublisher (+4 more)

### Community 76 - "SearchMapViewRenderTests"
Cohesion: 0.15
Nodes (14): MockGetSearchFilterOptionsUseCase, MockGetUserLocationUseCase, MockObserveLocationPermissionUseCase, MockResolveInitialRegionUseCase, MockSavedSalonsEventBus, MockSaveSalonUseCase, MockSearchPinsUseCase, MockSearchSalonsUseCase (+6 more)

### Community 77 - "BookingListResponseDTO"
Cohesion: 0.22
Nodes (18): BookingAltegioDTO, BookingAltegioServiceDTO, BookingEasyweekDTO, BookingEasyweekServiceDTO, BookingItemDTO, BookingListResponseDTO, BookingProviderSpecificDTO, BookingSalonDTO (+10 more)

### Community 78 - "MyBookingsView"
Cohesion: 0.22
Nodes (11): BookingTab, cancelled, past, upcoming, String, MyBookingsView, Binding, Booking (+3 more)

### Community 79 - "EditProfileViewModel"
Cohesion: 0.17
Nodes (6): EditProfileViewModel, Snapshot, Bool, String, Void, Transition

### Community 80 - "LocationPickerViewModel"
Cohesion: 0.14
Nodes (11): LocationPickerController, NSCoder, LocationPickerView, Bool, View, LocationPickerViewModel, Bool, CheckedContinuation (+3 more)

### Community 81 - "SearchDatePickerViewModel"
Cohesion: 0.15
Nodes (9): SearchDatePickerController, NSCoder, SearchDatePickerView, View, SearchDatePickerViewModel, Void, Transition, Date (+1 more)

### Community 82 - "SearchDTO (82)"
Cohesion: 0.10
Nodes (20): CodingKeys, address, city, distanceKm, effectiveRadiusKm, geoSource, id, imageUrl (+12 more)

### Community 83 - "KeychainService"
Cohesion: 0.19
Nodes (12): KeychainError, deleteFailed, loadFailed, saveFailed, unexpectedData, KeychainKeys, KeychainServiceImpl, Data (+4 more)

### Community 84 - "UIApplication+Keyboard"
Cohesion: 0.11
Nodes (5): SearchMapController, UIApplication, UIViewController, UIApplication, UIKit

### Community 85 - "HomeView"
Cohesion: 0.13
Nodes (12): PreviewGetCurrentUserUseCase, PreviewGetHomeFeedUseCase, PreviewObserveBookingUseCase, PreviewSavedSalonsEventBus, PreviewSaveSalonUseCase, PreviewUnsaveSalonUseCase, AnyPublisher, Booking (+4 more)

### Community 86 - "BeautynAlertContent"
Cohesion: 0.20
Nodes (9): AttributedString, AlertRelay, BeautynAlertContent, BeautynAlertVariant, error, success, warning, Color (+1 more)

### Community 87 - "AppCoordinator"
Cohesion: 0.20
Nodes (5): AppCoordinator, Assembler, Void, BaseCoordinator, Void

### Community 88 - "GetSalonByIdUseCase"
Cohesion: 0.18
Nodes (10): SalonBookingFactory, SalonRepository, GetSalonByIdUseCase, GetSalonByIdUseCaseImpl, Bool, Salon, String, GetSalonShareUseCase (+2 more)

### Community 89 - "SearchSortView"
Cohesion: 0.16
Nodes (8): SearchSortController, NSCoder, SearchSortView, Bool, CGFloat, String, View, SearchSortViewRenderTests

### Community 90 - "EventEditViewRepresentable"
Cohesion: 0.15
Nodes (12): Coordinator, EventEditViewRepresentable, Context, Coordinator, EKEvent, EKEventStore, Void, EKEventEditViewAction (+4 more)

### Community 91 - "ProfileCoordinator"
Cohesion: 0.28
Nodes (4): ProfileControllerFactory, ProfileCoordinator, Assembler, String

### Community 92 - "TokenRefresher"
Cohesion: 0.17
Nodes (9): RefreshTokenUseCase, TokenProvider, Error, Task, Void, TokenRefresher, NetworkServiceImpl, MoyaProvider (+1 more)

### Community 93 - "AuthDTO"
Cohesion: 0.21
Nodes (16): CheckEmailResponseDTO, CodingKeys, accessToken, expiresIn, isNewUser, phoneVerificationRequired, refreshToken, LoginResponseDTO (+8 more)

### Community 94 - "AuthTarget"
Cohesion: 0.12
Nodes (17): AuthTarget, changePassword, checkEmail, deleteAccount, forgotPassword, login, logout, oauth (+9 more)

### Community 95 - "MyBookingsCoordinator"
Cohesion: 0.18
Nodes (8): MyBookingsControllerFactory, MyBookingsCoordinator, Assembler, Booking, String, UIViewController, Void, SalonBookingAssembly

### Community 96 - "UserRepositoryImpl"
Cohesion: 0.18
Nodes (4): UserRepositoryImpl, UserLocalDataSource, Bool, UserProfile

### Community 97 - "SearchMapView"
Cohesion: 0.14
Nodes (10): SearchFactory, SearchFactoryImpl, GetUserLocationUseCase, ResolveInitialSearchRegionUseCase, PreviewGetUserLocationUseCase, PreviewGetUserLocationUseCase, PreviewResolveInitialRegionUseCase, PreviewSaveSalonUseCase (+2 more)

### Community 98 - "CalendarView"
Cohesion: 0.21
Nodes (9): Calendar, CalendarView, Binding, Bool, Color, Int, Set, String (+1 more)

### Community 99 - "NetworkService (99)"
Cohesion: 0.17
Nodes (13): NetworkError, decoding, nilData, underlying, Bool, D, Data, Int (+5 more)

### Community 100 - "BookingDetailsViewRenderTests"
Cohesion: 0.19
Nodes (8): BookingDetailsViewRenderTests, MockConfirmEasyweekBookingUseCase, MockGetCurrentUserUseCase, MockGetSalonShareUseCase, MockRefreshBookingUseCase, MockSaveSalonUseCase, MockSyncBookingFromCrmUseCase, MockUnsaveSalonUseCase

### Community 101 - "HomeCoordinator"
Cohesion: 0.23
Nodes (8): HomeControllerFactory, HomeCoordinator, AppCategory, Assembler, Booking, String, UIViewController, Void

### Community 102 - "MapsLauncher"
Cohesion: 0.23
Nodes (7): Destination, MapsLauncher, Bool, CLLocationCoordinate2D, String, URL, CoreLocation

### Community 103 - "ResetPasswordCoordinator"
Cohesion: 0.18
Nodes (9): ResetPasswordControllerFactory, ResetPasswordControllerFactoryImpl, AssemblerLike, ResetPasswordCoordinator, ResetPasswordDismissDelegate, Assembler, String, UIPresentationController (+1 more)

### Community 104 - "SalonBookingControllerFactory"
Cohesion: 0.23
Nodes (8): SalonBookingControllerFactoryImpl, AssemblerLike, Booking, Bool, Salon, Set, String, UIViewController

### Community 105 - "SearchViewModel (105)"
Cohesion: 0.16
Nodes (8): SearchHistoryItem, String, GetSearchHistoryUseCase, PreviewGetSearchHistoryUseCase, Int, Task, MockGetSearchHistoryUseCase, Int

### Community 106 - "MyBookingsViewRenderTests"
Cohesion: 0.21
Nodes (7): Array, MockObserveBookingsUseCase, MockRefreshBookingsUseCase, MyBookingsViewRenderTests, AnyPublisher, Booking, Never

### Community 107 - "SavedSalonsViewRenderTests"
Cohesion: 0.21
Nodes (8): MockGetSavedSalonsUseCase, MockSaveSalonUseCase, MockUnsaveSalonUseCase, SavedSalonsList, SavedSalonsViewRenderTests, Int, SavedSalonsList, String

### Community 108 - "AppDelegate"
Cohesion: 0.13
Nodes (12): AppDelegate, Any, Assembler, Bool, Set, UIScene, UISceneSession, AppAssembly (+4 more)

### Community 109 - "HomeFeedRepositoryImpl"
Cohesion: 0.16
Nodes (6): HomeFeedRepositoryImpl, Double, HomeFeed, EasyweekBookingRepositoryImpl, UserSettingsRepositoryImpl, NetworkService

### Community 110 - "PersonalDataViewModel"
Cohesion: 0.22
Nodes (7): Display, PersonalDataViewModel, DateFormatter, String, URL, Void, Transition

### Community 111 - "AltegioBookableServicesResponseDTO"
Cohesion: 0.17
Nodes (14): AltegioBookableServiceCategoryDTO, AltegioBookableServiceDTO, AltegioBookableServicesResponseDTO, CodingKeys, categoryId, durationSec, id, isAvailable (+6 more)

### Community 112 - "UpdateNotificationSettingsRequest"
Cohesion: 0.15
Nodes (12): CodingKeys, bookingId, status, ConfirmEasyweekBookingResponseDTO, String, CodingKeys, emailEnabled, pushEnabled (+4 more)

### Community 113 - "SearchViewRenderTests"
Cohesion: 0.19
Nodes (10): DeleteSearchHistoryItemUseCase, MockDeleteSearchHistoryItemUseCase, MockGetLocationCompletionsUseCase, MockGetUserLocationUseCase, MockObserveLocationPermissionUseCase, MockResolveLocationCompletionUseCase, MockReverseGeocodeNameUseCase, MockSheetSearchSalonsUseCase (+2 more)

### Community 114 - "BaseHostingViewController"
Cohesion: 0.20
Nodes (7): BaseHostingViewController, Bool, Content, NSCoder, UIGestureRecognizer, UIGestureRecognizerDelegate, VM

### Community 115 - "WebBookingTests"
Cohesion: 0.21
Nodes (4): MockEasyweekBookingRepository, Booking, String, WebBookingTests

### Community 116 - "SceneDelegate"
Cohesion: 0.19
Nodes (10): SceneDelegate, Set, UIScene, UISceneSession, UIWindow, GoogleSignIn, NSUserActivity, UIOpenURLContext (+2 more)

### Community 117 - "SalonRepositoryImpl"
Cohesion: 0.16
Nodes (7): SalonRepositoryImpl, Bool, Salon, String, SalonShare, String, URL

### Community 118 - "ConfirmBookingView"
Cohesion: 0.21
Nodes (9): ConfirmBookingView, makePreviewVM(), PreviewCreateBookingUseCase, PreviewCurrentUserUseCase, Booking, Color, String, View (+1 more)

### Community 119 - "AppRangeSlider"
Cohesion: 0.26
Nodes (9): AppRangeSlider, Knob, lower, upper, RangeSliderPreview, CGFloat, ClosedRange, Double (+1 more)

### Community 120 - "ClearUserUseCase"
Cohesion: 0.22
Nodes (5): UserRepository, ClearUserUseCase, ClearUserUseCaseImpl, GetCurrentUserUseCaseImpl, UpdateUserProfileUseCaseImpl

### Community 121 - "ConfirmBookingViewRenderTests"
Cohesion: 0.21
Nodes (7): beautyn, ConfirmBookingViewRenderTests, Salon, StubCreateBookingUseCase, StubCurrentUserUseCase, Booking, String

### Community 122 - "BookingDetailsController"
Cohesion: 0.26
Nodes (5): BookingDetailsController, AnyCancellable, Bool, UIBarButtonItem, UIImage

### Community 123 - "ProfileSettingsViewModel"
Cohesion: 0.17
Nodes (8): URL, Void, WebBookingConfiguration, String, URL, Void, WebBookingConfiguration, WebBookingPresentation

### Community 124 - "SalonBookingEntry"
Cohesion: 0.22
Nodes (9): SalonBookingEntry, book, service, worker, String, makePreviewVM(), PreviewGetAltegioAvailableServicesUseCase, Set (+1 more)

### Community 125 - "AltegioCreateRecordResponseDTO"
Cohesion: 0.17
Nodes (10): AltegioBookableDatesResponseDTO, String, AltegioCreateRecordResponseDTO, CodingKeys, bookingId, crmRecordId, shortLink, status (+2 more)

### Community 126 - "SalonsTarget"
Cohesion: 0.17
Nodes (13): SalonInclude, categories, images, services, workers, SalonsTarget, getSalonById, getShare (+5 more)

### Community 127 - "ServiceRowView"
Cohesion: 0.18
Nodes (11): SelectServiceRow, Bool, CGFloat, Void, ServiceModel, ServiceRowView, Bool, CGFloat (+3 more)

### Community 128 - "SelectServiceController"
Cohesion: 0.22
Nodes (6): SelectServiceController, Bool, NSCoder, SelectServiceView, View, SelectServiceViewRenderTests

### Community 129 - "SearchViewRenderTests (129)"
Cohesion: 0.26
Nodes (5): SearchController, NSCoder, SearchView, Bool, SearchViewRenderTests

### Community 130 - "CachedImage"
Cohesion: 0.30
Nodes (9): AnyView, Void, CachedImage, CGFloat, URL, CGSize, Circle, ClipShape (+1 more)

### Community 131 - "ImagePipelineConfig"
Cohesion: 0.18
Nodes (8): ImagePipelineConfig, SalonCoverCarouselView, CGFloat, Double, Int, URL, Nuke, NukeUI

### Community 132 - "HomeFeed"
Cohesion: 0.17
Nodes (8): HomeFeed, AppCategory, SavedSalon, Double, Int, String, SavedSalonsList, Int

### Community 133 - "PhoneVerificationCoordinator"
Cohesion: 0.29
Nodes (6): PhoneVerificationControllerFactory, PhoneVerificationControllerFactoryImpl, AssemblerLike, PhoneVerificationCoordinator, Assembler, String

### Community 134 - "LocationPickerViewModel (134)"
Cohesion: 0.27
Nodes (7): CompleterDelegate, Suggestion, MKLocalSearchCompleter, MKLocalSearchCompletion, String, Void, Transition

### Community 135 - "WebBookingConfiguration"
Cohesion: 0.23
Nodes (10): SalonBookingProvider, WebBookingConfiguration, Kind, email, firstName, lastName, phone, String (+2 more)

### Community 136 - "SearchTarget"
Cohesion: 0.17
Nodes (12): SearchTarget, appCategories, clearHistory, deleteHistoryItem, filterOptions, history, pins, search (+4 more)

### Community 137 - "AppointmentCardView"
Cohesion: 0.21
Nodes (10): AppointmentCardModel, AppointmentCardView, FooterAction, book, details, Bool, CLLocationCoordinate2D, String (+2 more)

### Community 138 - "WebPageView"
Cohesion: 0.20
Nodes (7): Context, URL, WKWebView, WebContentView, WebPageView, UIViewRepresentable, WebKit

### Community 139 - "GoogleSignInService"
Cohesion: 0.27
Nodes (8): GoogleSignInError, missingIDToken, GoogleSignInResult, GoogleSignInService, GoogleSignInServiceImpl, Int, String, UIViewController

### Community 140 - "HomeViewRenderTests (140)"
Cohesion: 0.36
Nodes (6): HomeFeedSection, HomeSectionSearchParams, Double, String, HomeFeed, HomeSectionSearchPresetTests

### Community 141 - "MyBookingsControllerFactory"
Cohesion: 0.22
Nodes (6): MyBookingsControllerFactoryImpl, AssemblerLike, Booking, UIViewController, MyBookingsController, NSCoder

### Community 142 - "BookingCategory"
Cohesion: 0.22
Nodes (6): BookingCategory, cancelled, past, upcoming, Booking, Bool

### Community 143 - "ProfileControllerFactory"
Cohesion: 0.29
Nodes (3): ProfileControllerFactoryImpl, AssemblerLike, UIViewController

### Community 144 - "EditProfileBirthDateRow"
Cohesion: 0.20
Nodes (8): Array, EditProfileBirthDateRow, Bool, DateFormatter, Int, String, Void, Element

### Community 145 - "BaseViewModel"
Cohesion: 0.18
Nodes (3): BaseViewModel, Bool, ObservableObject

### Community 146 - "BookingMapView"
Cohesion: 0.33
Nodes (7): BookingMapSnapshotCache, BookingMapView, CLLocationCoordinate2D, String, UIImage, NSCache, NSString

### Community 147 - "AppTypography"
Cohesion: 0.24
Nodes (8): AeonikPro, App, CGFloat, Font, CGFloat, String, Tracking, View

### Community 148 - "DeepLinkingService"
Cohesion: 0.31
Nodes (9): DeepLinkingService, DeepLinkingServiceImpl, ResetPasswordLinkModel, SalonLinkModel, AnyPublisher, Never, Set, String (+1 more)

### Community 149 - "DefaultsStorageService"
Cohesion: 0.27
Nodes (5): DefaultsKeys, DefaultsStorageService, String, T, UserDefaults

### Community 150 - "SocialAuthButtonView"
Cohesion: 0.22
Nodes (9): Provider, apple, google, SocialAuthButtonView, Bool, String, Void, Google Logo Icon (ic_google) (+1 more)

### Community 151 - "ObserveBookingsUseCase"
Cohesion: 0.24
Nodes (5): ObserveBookingsUseCase, ObserveBookingsUseCaseImpl, AnyPublisher, Booking, Never

### Community 152 - "EditProfileViewModel (152)"
Cohesion: 0.24
Nodes (3): Bool, String, UserProfilePatch

### Community 153 - "EditProfileView"
Cohesion: 0.27
Nodes (8): BirthDateSheet, EditProfileView, Field, firstName, lastName, phone, View, Void

### Community 154 - "SelectDateTimeView"
Cohesion: 0.31
Nodes (6): makePreviewVM(), PreviewDatesUseCase, PreviewTimeSlotsUseCase, PreviewWorkersUseCase, Bool, String

### Community 155 - "SearchView"
Cohesion: 0.24
Nodes (6): PreviewDeleteSearchHistoryItemUseCase, PreviewSheetSearchSalonsUseCase, SectionHeaderChrome, Content, String, View

### Community 156 - "AlertableViewModifier"
Cohesion: 0.22
Nodes (7): AlertableViewModifier, Binding, Content, View, View, PopupView, ViewModifier

### Community 157 - "LoadableViewModifier"
Cohesion: 0.24
Nodes (6): LoadableViewModifier, Bool, Content, View, View, LoaderView

### Community 158 - "EditProfileViewRenderTests"
Cohesion: 0.29
Nodes (4): UpdateUserProfileUseCase, EditProfileViewRenderTests, MockEditProfileGetCurrentUserUseCase, MockEditProfileUpdateUserProfileUseCase

### Community 159 - "HomeControllerFactoryImpl"
Cohesion: 0.31
Nodes (4): HomeControllerFactoryImpl, AssemblerLike, Booking, UIViewController

### Community 160 - "SavedSalonsRepositoryImpl"
Cohesion: 0.28
Nodes (4): SavedSalonsRepositoryImpl, Int, SavedSalonsList, String

### Community 161 - "ProfileMenuRowView"
Cohesion: 0.25
Nodes (8): ProfileMenuRowView, Binding, Bool, String, Void, Trailing, chevron, toggle

### Community 162 - "PersonalDataController"
Cohesion: 0.25
Nodes (5): PersonalDataController, Bool, NSCoder, PersonalDataView, View

### Community 163 - "AltegioBookableWorker"
Cohesion: 0.28
Nodes (6): AltegioBookableWorker, AltegioBookingSlot, Bool, Int, String, Bool

### Community 164 - "SpecialistRowView"
Cohesion: 0.33
Nodes (8): AnySpecialistRowView, SpecialistModel, SpecialistRowView, Bool, CGFloat, String, URL, Void

### Community 165 - "SearchLocation"
Cohesion: 0.28
Nodes (7): SearchLocation, SearchLocationKind, address, city, neighborhood, poi, unknown

### Community 166 - "BaseViewModel (166)"
Cohesion: 0.36
Nodes (5): Error, String, AlertScope, current, global

### Community 167 - "WebBookingWebView (167)"
Cohesion: 0.28
Nodes (5): Context, WKNavigation, WKWebView, WKNavigationAction, WKNavigationActionPolicy

### Community 168 - "WebBookingTests (168)"
Cohesion: 0.22
Nodes (7): CheckedContinuation, Never, Void, WKNavigation, WKWebView, WebViewLoadWaiter, WKNavigationDelegate

### Community 169 - "AuthModels"
Cohesion: 0.29
Nodes (5): EmailStatus, apple, google, notFound, password

### Community 170 - "GetHomeFeedUseCase"
Cohesion: 0.32
Nodes (4): HomeFeedRepository, GetHomeFeedUseCaseImpl, Double, HomeFeed

### Community 172 - "BookingStatusBadge"
Cohesion: 0.29
Nodes (7): BookingStatusBadge, Style, cancelled, completed, confirmed, Color, String

### Community 173 - "EditProfileController"
Cohesion: 0.36
Nodes (3): EditProfileController, Bool, NSCoder

### Community 174 - "ConfirmEasyweekBookingUseCase"
Cohesion: 0.32
Nodes (4): EasyweekBookingRepository, ConfirmEasyweekBookingUseCaseImpl, Booking, String

### Community 175 - "ShareSheetRepresentable"
Cohesion: 0.32
Nodes (5): ShareSheetRepresentable, Any, Context, UIActivityViewController, UIViewControllerRepresentable

### Community 176 - "NavigationBarVisibility"
Cohesion: 0.29
Nodes (4): AnyObject, NavigationBarPreferring, ViewModelLifecycle, LoadableViewModel

### Community 177 - "NavigationBarVisibility (177)"
Cohesion: 0.29
Nodes (6): NavigationBarVisibilityController, Bool, UINavigationController, UIViewController, NSObject, UINavigationControllerDelegate

### Community 178 - "HomeController"
Cohesion: 0.38
Nodes (4): HomeController, NSCoder, HomeView, View

### Community 179 - "BookingMapper"
Cohesion: 0.38
Nodes (4): BookingMapper, Booking, ISO8601DateFormatter, String

### Community 180 - "PhoneCodeView"
Cohesion: 0.33
Nodes (4): PreviewSendPhoneOTPUseCase, PreviewVerifyPhoneOTPUseCase, Bool, String

### Community 181 - "SavedSalonsMapper"
Cohesion: 0.29
Nodes (4): SavedSalonListResponseDTO, Int, SavedSalonsMapper, SavedSalonsList

### Community 182 - "UserProfile"
Cohesion: 0.29
Nodes (5): Sex, female, male, other, preferNotToSay

### Community 183 - "LocationPickerViewModel (183)"
Cohesion: 0.43
Nodes (5): LocationDelegate, CLLocation, CLLocationManager, Error, CLLocationManagerDelegate

### Community 184 - "MasterPickerView"
Cohesion: 0.48
Nodes (5): MasterModel, MasterPickerView, CGFloat, String, URL

### Community 185 - "ConfirmBookingController"
Cohesion: 0.33
Nodes (3): ConfirmBookingController, Bool, NSCoder

### Community 186 - "AlertableViewModel"
Cohesion: 0.38
Nodes (3): AlertableViewModel, Error, String

### Community 187 - "SalonCardView"
Cohesion: 0.33
Nodes (6): SalonCardView, Style, fullWidth, horizontal, CGFloat, Void

### Community 188 - "SalonBookingProvider"
Cohesion: 0.29
Nodes (5): SalonBookingProvider, altegio, easyweek, unknown, String

### Community 189 - "ApiDateFormatter"
Cohesion: 0.33
Nodes (3): ApiDateFormatter, DateFormatter, String

### Community 190 - "Environment"
Cohesion: 0.29
Nodes (6): Environment, Keys, Any, Bool, String, URL

### Community 192 - "ChangePasswordUseCase"
Cohesion: 0.40
Nodes (3): ChangePasswordUseCase, ChangePasswordUseCaseImpl, String

### Community 193 - "RefreshTokenUseCase"
Cohesion: 0.33
Nodes (5): RefreshTokenError, missingRefreshToken, Failure, notStubbed, Error

### Community 194 - "ResetPasswordUseCase"
Cohesion: 0.40
Nodes (3): ResetPasswordUseCase, ResetPasswordUseCaseImpl, String

### Community 195 - "NextBooking"
Cohesion: 0.53
Nodes (5): NextBooking, NextBookingService, Int, String, TimeZone

### Community 196 - "SalonCard"
Cohesion: 0.33
Nodes (5): SalonCard, Bool, Double, Int, String

### Community 197 - "BookingsRepository"
Cohesion: 0.33
Nodes (5): BookingsSort, datetimeAsc, datetimeDesc, MyBookingsError, bookingNotFound

### Community 198 - "BookingDetailsView (198)"
Cohesion: 0.40
Nodes (4): NSCoder, BookingDetailsView, CGFloat, View

### Community 199 - "SalonListTab"
Cohesion: 0.33
Nodes (5): SalonListTab, Bool, String, Void, Rows

### Community 200 - "GetLocationCompletionsUseCase"
Cohesion: 0.40
Nodes (3): GetLocationCompletionsUseCase, GetLocationCompletionsUseCaseImpl, String

### Community 201 - "ReverseGeocodeNameUseCase"
Cohesion: 0.40
Nodes (3): ReverseGeocodeNameUseCase, ReverseGeocodeNameUseCaseImpl, String

### Community 202 - "SearchBorderedField"
Cohesion: 0.33
Nodes (5): SearchBorderedField, Bool, FocusState, String, Void

### Community 203 - "SalonSearchField"
Cohesion: 0.33
Nodes (5): SalonSearchField, Bool, CGFloat, FocusState, String

### Community 204 - "app_store_icon_1024 1"
Cohesion: 0.40
Nodes (6): Beautyn App Store Icon 1024 (copy 1), Beautyn Brand Identity (feminine silhouette, brown/cream palette), Beautyn App Store Icon (1024px), Beautyn Brand Identity, Beautyn Launch Screen Image (Header.svg), LaunchScreen.storyboard

### Community 206 - "BookingDetailsViewRenderTests (206)"
Cohesion: 0.40
Nodes (4): MockObserveBookingUseCase, MockSavedSalonsEventBus, AnyPublisher, Never

### Community 207 - "swiftui-pro-icon"
Cohesion: 0.40
Nodes (5): SwiftUI Pro Skill Icon, Swift Bird Logo Motif, Swift / SwiftUI Logo Branding, SwiftUI Pro Icon (SVG), swiftui-pro Skill

### Community 208 - "Resolver+Require"
Cohesion: 0.40
Nodes (3): Resolver, String, T

### Community 209 - "MyBookingsViewModel (209)"
Cohesion: 0.40
Nodes (5): FetchPhase, failed, idle, loaded, loading

### Community 210 - "SalonStickyActionBar"
Cohesion: 0.40
Nodes (4): SalonStickyActionBar, Int, String, Void

### Community 211 - "TabSelectorView"
Cohesion: 0.60
Nodes (3): Int, String, TabSelectorView

### Community 212 - "SearchView (212)"
Cohesion: 0.40
Nodes (3): ClearSearchHistoryUseCase, PreviewClearSearchHistoryUseCase, MockClearSearchHistoryUseCase

### Community 213 - "FilterChipView"
Cohesion: 0.40
Nodes (4): FilterChipView, Bool, String, Void

### Community 214 - "SearchPillButton"
Cohesion: 0.40
Nodes (4): SearchPillButton, Image, String, Void

### Community 215 - "WebPagePresentation"
Cohesion: 0.40
Nodes (4): String, URL, Void, WebPagePresentation

### Community 216 - "AppColors"
Cohesion: 0.50
Nodes (3): App, Color, String

### Community 217 - "SelectServiceViewRenderTests"
Cohesion: 0.80
Nodes (3): StubGetAltegioAvailableServicesUseCase, Set, String

### Community 218 - "AppCategory"
Cohesion: 0.50
Nodes (3): AppCategory, Int, String

### Community 219 - "CategoryChipView"
Cohesion: 0.50
Nodes (3): CategoryChipView, CGFloat, Void

### Community 221 - "ObserveLocationPermissionUseCase"
Cohesion: 0.50
Nodes (3): AnyPublisher, Bool, Never

### Community 222 - "SearchHeaderView"
Cohesion: 0.50
Nodes (3): SearchHeaderView, String, Void

### Community 223 - "SearchSheetHeaderView"
Cohesion: 0.50
Nodes (3): SearchSheetHeaderView, String, Void

### Community 224 - "FavoriteButtonView"
Cohesion: 0.50
Nodes (3): FavoriteButtonView, Bool, Void

### Community 225 - "RatingBadgeView"
Cohesion: 0.50
Nodes (3): RatingBadgeView, Double, String

### Community 226 - "AppSpacing"
Cohesion: 0.67
Nodes (3): CGFloat, Spacing, CoreFoundation

### Community 227 - "app_store_icon_1024 2"
Cohesion: 0.50
Nodes (4): Beautyn Beauty-Salon Brand Identity, App Store Icon 1024 - Tinted Variant (Woman Profile Logo), App Store Icon 1024 (Beautyn App Icon), AppIcon Asset Set (Contents.json)

### Community 228 - "BookingDetailsViewRenderTests (228)"
Cohesion: 0.50
Nodes (3): MockGetSalonByIdUseCase, Bool, Salon

### Community 229 - "SearchViewRenderTests (229)"
Cohesion: 0.50
Nodes (3): AnyPublisher, Bool, Never

## Ambiguous Edges - Review These
- `Beautyn App Store Icon 1024 (copy 1)` → `Beautyn App Store Icon (1024px)`  [AMBIGUOUS]
  beautyn/beautyn/Assets.xcassets/AppIcon.appiconset/app_store_icon_1024 1.png · relation: semantically_similar_to

## Knowledge Gaps
- **356 isolated node(s):** `accessToken`, `refreshToken`, `expiresIn`, `phoneVerificationRequired`, `isNewUser` (+351 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Beautyn App Store Icon 1024 (copy 1)` and `Beautyn App Store Icon (1024px)`?**
  _Edge tagged AMBIGUOUS (relation: semantically_similar_to) - confidence is low._
- **Why does `Foundation` connect `NetworkService` to `Profile Screen`, `Formatting & Localization`, `Search Filters & Sorting`, `Salon DTO & Mapping`, `Saved Salons Domain`, `Home Feed UI`, `Salon Profile ViewModel`, `Auth Domain UseCases`, `Search Map ViewModel`, `Booking Details`, `Search Domain Entities`, `Search Geo Models`, `Login Screen`, `Search Data & Assembly`, `Change Password Screen`, `Email Check Flow`, `Auth Data Layer`, `Password Reset Flow`, `Search Screen Factory`, `Dependency Injection Container`, `Profile Settings Screen`, `Altegio Booking Data`, `Select Date-Time Screen`, `App Factory & Resolver`, `Bookings Domain UseCases`, `Auth Screen Factory`, `Sign Up Screen`, `Select Service Screen`, `Home Feed Mapping`, `Phone OTP Flow`, `Search Map Items`, `WebBookingWebView`, `ForgotPasswordViewModel`, `SessionManager`, `SavedSalonsViewModel`, `AltegioBookableWorkersResponseDTO`, `AltegioBookingRepositoryImpl`, `Salon`, `SearchLocationViewModel`, `UserProfileDTO`, `AppleSignInService`, `Booking`, `PhoneVerificationViewModel`, `SearchDTO`, `SearchViewModel`, `UserProfilePatchDTO`, `ConfirmBookingViewModel`, `BookingSuccessController`, `ResolveInitialSearchRegionUseCase`, `MyBookingsViewModel`, `SearchLocationView`, `BookingListResponseDTO`, `MyBookingsView`, `EditProfileViewModel`, `SearchDatePickerViewModel`, `KeychainService`, `BeautynAlertContent`, `AppCoordinator`, `GetSalonByIdUseCase`, `TokenRefresher`, `AuthDTO`, `MyBookingsCoordinator`, `UserRepositoryImpl`, `SearchMapView`, `MapsLauncher`, `SearchViewModel (105)`, `AppDelegate`, `HomeFeedRepositoryImpl`, `PersonalDataViewModel`, `AltegioBookableServicesResponseDTO`, `UpdateNotificationSettingsRequest`, `SalonRepositoryImpl`, `ClearUserUseCase`, `ProfileSettingsViewModel`, `SalonBookingEntry`, `AltegioCreateRecordResponseDTO`, `HomeFeed`, `LocationPickerViewModel (134)`, `WebBookingConfiguration`, `HomeViewRenderTests (140)`, `BookingCategory`, `BaseViewModel`, `DeepLinkingService`, `DefaultsStorageService`, `ObserveBookingsUseCase`, `EditProfileViewModel (152)`, `EditProfileViewRenderTests`, `SavedSalonsRepositoryImpl`, `AltegioBookableWorker`, `SearchLocation`, `GetHomeFeedUseCase`, `ConfirmEasyweekBookingUseCase`, `NavigationBarVisibility`, `SavedSalonsMapper`, `UserProfile`, `AlertableViewModel`, `SalonBookingProvider`, `ApiDateFormatter`, `Environment`, `ChangePasswordUseCase`, `RefreshTokenUseCase`, `ResetPasswordUseCase`, `NextBooking`, `SalonCard`, `BookingsRepository`, `GetLocationCompletionsUseCase`, `ReverseGeocodeNameUseCase`, `Resolver+Require`, `WebPagePresentation`, `AppCategory`, `CreateAltegioBookingUseCase`?**
  _High betweenness centrality (0.296) - this node is a cross-community bridge._
- **Why does `SwiftUI` connect `Shared UI Components` to `Profile Screen`, `Search Filters & Sorting`, `Salon Profile Screen`, `Home Feed UI`, `Service Type Filter`, `Salon Profile ViewModel`, `Search Map ViewModel`, `Booking Details`, `View Render Tests`, `Login Screen`, `Change Password Screen`, `Email Check Flow`, `Input Field Components`, `Auth Data Layer`, `Password Reset Flow`, `Search Screen Factory`, `Profile Settings Screen`, `Select Date-Time Screen`, `Bottom Sheet Component`, `Auth Screen Factory`, `Sign Up Screen`, `Select Service Screen`, `Phone OTP Flow`, `ForgotPasswordViewModel`, `BookingDetailsView`, `SavedSalonsViewModel`, `HomeViewRenderTests`, `MainTabCoordinator`, `Salon`, `SearchLocationViewModel`, `PhoneVerificationViewModel`, `SalonProfileView`, `SelectDateTimeViewRenderTests`, `SearchViewModel`, `AppButton`, `ConfirmBookingViewModel`, `BookingSuccessController`, `SearchLocationView`, `SearchMapViewRenderTests`, `MyBookingsView`, `LocationPickerViewModel`, `SearchDatePickerViewModel`, `HomeView`, `BeautynAlertContent`, `SearchSortView`, `EventEditViewRepresentable`, `SearchMapView`, `CalendarView`, `BookingDetailsViewRenderTests`, `MyBookingsViewRenderTests`, `SavedSalonsViewRenderTests`, `SearchViewRenderTests`, `BaseHostingViewController`, `ConfirmBookingView`, `AppRangeSlider`, `ConfirmBookingViewRenderTests`, `BookingDetailsController`, `SalonBookingEntry`, `ServiceRowView`, `SelectServiceController`, `ImagePipelineConfig`, `AppointmentCardView`, `WebPageView`, `EditProfileBirthDateRow`, `BookingMapView`, `AppTypography`, `SocialAuthButtonView`, `EditProfileView`, `SelectDateTimeView`, `SearchView`, `AlertableViewModifier`, `LoadableViewModifier`, `EditProfileViewRenderTests`, `ProfileMenuRowView`, `PersonalDataController`, `SpecialistRowView`, `BookingStatusBadge`, `EditProfileController`, `ShareSheetRepresentable`, `PhoneCodeView`, `MasterPickerView`, `ConfirmBookingController`, `SalonCardView`, `SalonListTab`, `SearchBorderedField`, `SalonSearchField`, `SalonStickyActionBar`, `TabSelectorView`, `FilterChipView`, `SearchPillButton`, `AppColors`, `CategoryChipView`, `SearchHeaderView`, `SearchSheetHeaderView`, `FavoriteButtonView`, `RatingBadgeView`?**
  _High betweenness centrality (0.169) - this node is a cross-community bridge._
- **Why does `BaseViewModel` connect `BaseViewModel` to `Profile Screen`, `Search Filters & Sorting`, `Home Feed UI`, `Salon Profile ViewModel`, `Search Map ViewModel`, `Booking Details`, `Login Screen`, `Change Password Screen`, `Email Check Flow`, `Password Reset Flow`, `Search Screen Factory`, `Profile Settings Screen`, `Select Date-Time Screen`, `Auth Screen Factory`, `Sign Up Screen`, `BaseViewModel (166)`, `Select Service Screen`, `Phone OTP Flow`, `HomeViewModel`, `ForgotPasswordViewModel`, `NavigationBarVisibility`, `SavedSalonsViewModel`, `SearchLocationViewModel`, `AlertableViewModel`, `PhoneVerificationViewModel`, `SearchViewModel`, `ConfirmBookingViewModel`, `BookingSuccessController`, `MyBookingsViewModel`, `EditProfileViewModel`, `LocationPickerViewModel`, `SearchDatePickerViewModel`, `BeautynAlertContent`, `WebPagePresentation`, `PersonalDataViewModel`, `ProfileSettingsViewModel`?**
  _High betweenness centrality (0.104) - this node is a cross-community bridge._
- **Are the 6 inferred relationships involving `SearchMapViewModel` (e.g. with `.makeViewModel()` and `.testApplyAfterClearHandsBackNil()`) actually correct?**
  _`SearchMapViewModel` has 6 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `Date` (e.g. with `.testEachBookingFallsInAtMostOneCategory()` and `.testPastIsCompletedOrElapsedNonCancelled()`) actually correct?**
  _`Date` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `accessToken`, `refreshToken`, `expiresIn` to the rest of the system?**
  _356 weakly-connected nodes found - possible documentation gaps or missing edges._