# iOS App Architecture — Agent Instructions

> **Purpose**: This document is the single source of truth for the app's architecture.
> Every code-generating agent (Claude Code, Cursor, Copilot, custom GPTs, etc.) MUST follow these rules when creating, modifying, or reviewing code in this project.
> If a rule here conflicts with a general best practice, **this document wins**.

---

## 1. Project Structure

```
MyApp/
├── App/
│   ├── Bootstrap/              # AppDelegate, SceneDelegate, startup wiring
│   ├── Coordinator/            # AppCoordinator, RootCoordinator, protocol
│   ├── DI/                     # AppAssembly + feature assemblies (Swinject)
│   ├── Shared/
│   │   ├── Components/         # Reusable UI (Buttons, Inputs, Feedback, Layout, Media, Base)
│   │   ├── DesignSystem/       # Colors, typography, spacing, icons
│   │   ├── Services/
│   │   │   ├── Network/
│   │   │   ├── Storage/
│   │   │   ├── DeepLink/
│   │   │   └── Analytics/
│   │   ├── Foundation/
│   │   │   ├── Extensions/
│   │   │   ├── Utils/
│   │   │   ├── Protocols/
│   │   │   └── Errors/
│   │   └── Base/               # BaseViewModel, BaseViewProtocol, BaseHostingViewController
│   ├── Features/
│   │   ├── FeatureX/           # One folder per feature — see Feature Structure below
│   │   └── ...
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── Colors.xcassets/
│       ├── Localization/
│       └── Generated/
├── Config/
├── Tests/
│   ├── UnitTests/
│   └── UITests/
└── Packages/                   # Local SPM modules (optional)
```

---

## 2. Feature Structure (Data + Domain + Presentation + Coordinator + DI)

Every feature lives in `Features/FeatureX/` with exactly this layout:

```
FeatureX/
├── Coordinator/
│   ├── FeatureXCoordinator.swift
│   ├── FeatureXControllerFactory.swift        # protocol
│   └── FeatureXControllerFactoryImpl.swift    # implementation
├── Dependency/
│   └── FeatureXAssembly.swift                 # Swinject assembly
├── Presentation/
│   ├── Entities/                              # UI models (Presentation Entities)
│   ├── Mappers/                               # Domain → UI mappers
│   ├── Screens/
│   │   └── ScreenA/
│   │       ├── ScreenAView.swift
│   │       ├── ScreenAViewModel.swift
│   │       └── ScreenAController.swift
│   └── Components/                            # Feature-scoped UI components
├── Domain/
│   ├── Entities/
│   │   ├── Models/
│   │   ├── ValueObjects/
│   │   └── Errors/
│   ├── Repositories/
│   │   └── FeatureXRepository.swift           # protocol ONLY
│   ├── Services/                              # Pure domain services
│   └── UseCases/
│       ├── GetFeatureXUseCase.swift
│       ├── CreateFeatureXUseCase.swift
│       └── UpdateFeatureXUseCase.swift
└── Data/
    ├── Entities/
    │   ├── DTO/                               # Remote / API models
    │   ├── Local/                             # Persistence models
    │   └── Mappers/                           # DTO/Local ↔ Domain mappers
    ├── Repositories/
    │   └── FeatureXRepositoryImpl.swift        # implements Domain protocol
    ├── Services/                               # Parser / store helpers
    └── Target/                                # API endpoints / routes
```

---

## 3. Layer Rules

### 3.1 Dependency Direction

```
Presentation → Domain ← Data
```

Domain is the center contract. Data depends on Domain protocols. **Domain NEVER depends on Data or Presentation.**

### 3.2 Data Layer

**Is**: the infrastructure adapter between business logic and external systems.

**Does**:
- Network access and request building.
- Local persistence (DB, Keychain, UserDefaults, SwiftData).
- DTO / local-object mapping to Domain entities.
- Repository implementation for Domain protocols.
- Error translation (transport / parsing / storage → app-level errors).
- Source orchestration (remote vs. local, fallback, local-first, sync).
- Parsing / decoding raw payload formats.

**Does NOT**:
- UI logic, navigation, or view state.
- High-level business decisions (belongs in UseCases).
- Expose raw DTOs to Presentation.

### 3.3 Domain Layer

**Is**: the business core. Rules and behavior that remain valid even if UI, backend, or storage changes.

**Does**:
- Define business models and invariants (Entities).
- Orchestrate business actions (UseCases).
- Define contracts for data access (Repository protocols).
- Hold pure business logic helpers (Domain Services, managers, calculators).
- Model business errors and event/state transitions.

**Does NOT**:
- UI logic (SwiftUI, UIKit).
- Transport / storage details (Moya, SwiftData, Keychain).
- DTO parsing or endpoint knowledge.

### 3.4 Presentation Layer

**Is**: View + ViewModel + ViewController working together.

| Role | Responsibility |
|---|---|
| **View** | Renders UI from ViewModel state. Sends user intents to ViewModel. No business logic, no navigation. |
| **ViewModel** | Holds presentation state. Processes intents. Calls UseCases. Publishes updated state. Emits navigation intents via `Transition` closures. |
| **ViewController** | Platform host. Bridges UIKit lifecycle to ViewModel. Manages platform-only concerns (status bar, nav bar, keyboard). Stays thin. |

**Flow**:
1. User action → View → ViewModel
2. State update → ViewModel → View
3. Navigation intent → ViewModel → Coordinator (via Transition closures)
4. Lifecycle bridge → ViewController → ViewModel

---

## 4. Entity Rules (Strict Boundary Enforcement)

Each layer has its **own entity type**. Data never leaks across boundaries.

```
External/Storage → Data Entity → Domain Entity → Presentation Entity → View
```

| Entity Type | Purpose | Lives In | Mapped By |
|---|---|---|---|
| **Data Entity** (DTO / Local) | Mirror API payloads, DB rows, raw formats. May contain coding keys, nullable quirks. | `Data/Entities/` | Mappers / Repositories |
| **Domain Entity** | Framework-agnostic business model. Holds invariants and business validation. | `Domain/Entities/` | UseCases return these |
| **Presentation Entity** | UI-ready state (display fields, UI flags like `isExpanded`, `isSelected`). | `Presentation/Entities/` | ViewModel / Mappers |

**Hard rules**:
- NEVER expose Data Entities to Presentation.
- Domain MUST NOT depend on DTO / storage models.
- Presentation Entities MUST NOT leak back into Data.
- All mapping between layers MUST be explicit and testable.

---

## 5. Repository Pattern

### Protocol (Domain side)

```swift
// Domain/Repositories/FeatureXRepository.swift
protocol ItemRepository {
    func get(id: UUID) async throws -> Item      // Domain type only
    func save(_ item: Item) async throws
}
```

### Implementation (Data side)

```swift
// Data/Repositories/FeatureXRepositoryImpl.swift
final class ItemRepositoryImpl: ItemRepository {
    private let network: NetworkService
    private let store: ItemStore

    init(network: NetworkService, store: ItemStore) {
        self.network = network
        self.store = store
    }

    func get(id: UUID) async throws -> Item {
        if let local = try await store.get(id: id) { return local.toDomain() }
        let dto: ItemDTO = try await network.request(Target(type: ItemTarget.get(id)))
        let item = dto.toDomain()
        try await store.upsert(item)
        return item
    }

    func save(_ item: Item) async throws {
        try await store.upsert(item)
    }
}
```

**Rules**:
- Domain protocol exposes Domain types only — never DTOs.
- Protocol methods are use-case oriented (`getNotes`, `create`, `updateFromRemote`).
- Async methods use `async throws`; streams use `AnyPublisher` when needed.
- Implementation injects dependencies via initializer only.
- Repository must be replaceable by test doubles.
- No DTO leaks outside Data. Mapping is explicit and testable.
- Error mapping is explicit. Source strategy is deterministic.

---

## 6. UseCase Pattern

One UseCase = one business intent.

```swift
// Domain/UseCases/CreateItemUseCase.swift
protocol CreateItemUseCase {
    func execute(_ input: CreateItemUseCaseImpl.Input) async throws -> CreateItemUseCaseImpl.Output
}

final class CreateItemUseCaseImpl: CreateItemUseCase {
    struct Input { let title: String }
    struct Output { let item: Item }

    private let repository: ItemRepository
    private let validator: ItemValidator

    init(repository: ItemRepository, validator: ItemValidator) {
        self.repository = repository
        self.validator = validator
    }

    func execute(_ input: Input) async throws -> Output {
        try validator.validateTitle(input.title)
        let item = try Item(title: input.title)
        let saved = try await repository.create(item)
        return Output(item: saved)
    }
}
```

**Rules**:
- One protocol + one implementation per UseCase (same file is fine).
- Constructor-injected dependencies (repository protocols, domain services).
- Prefer domain `Input` / `Output` types over primitive-heavy signatures.
- Single business purpose per UseCase.
- No infra leakage (DTO / local objects) in signatures.
- Input validation and error mapping are explicit.
- No UI state, no navigation, no direct API/storage details.

---

## 7. ViewModel Pattern

```swift
@MainActor
final class JourneySelectionViewModel: BaseViewModel {

    // MARK: - Transition (navigation intents for Coordinator)
    struct Transition {
        let didSelectJourney: (_ id: UUID) -> Void
        let didTapBack: () -> Void
    }

    // MARK: - Presentation Entity
    struct JourneyCardUI: Identifiable, Equatable {
        let id: UUID
        let title: String
        let subtitle: String
        let isLocked: Bool
    }

    // MARK: - Published State
    @Published private(set) var cards: [JourneyCardUI] = []
    @Published var searchText: String = ""

    // MARK: - Dependencies
    private let transition: Transition
    private let getJourneysUseCase: GetJourneysUseCase

    init(transition: Transition, getJourneysUseCase: GetJourneysUseCase) {
        self.transition = transition
        self.getJourneysUseCase = getJourneysUseCase
        super.init()
    }

    // MARK: - Lifecycle
    override func onViewTask() async {
        await loadJourneys()
    }

    // MARK: - Intents
    func didTapBack() { transition.didTapBack() }

    func didTapCard(_ card: JourneyCardUI) {
        guard !card.isLocked else { return }
        transition.didSelectJourney(card.id)
    }

    // MARK: - Private
    private func loadJourneys() async {
        showLoader()
        defer { hideLoader() }
        do {
            let journeys = try await getJourneysUseCase.execute()
            cards = journeys.map {
                JourneyCardUI(id: $0.id, title: $0.name,
                              subtitle: "Episode \($0.episodeNumber)",
                              isLocked: !$0.isAvailable)
            }
        } catch {
            showError(error)
        }
    }
}
```

**Rules**:
- ViewModel calls UseCases only — never repositories / network / storage directly.
- Navigation is emitted via `Transition` closures — no direct `push` / `present`.
- State is `@Published` and observable.
- Maps Domain entities → Presentation entities for the View.
- Handles task cancellation and error normalization.

---

## 8. View Pattern

```swift
struct ExampleView: BaseViewProtocol {
    @StateObject var viewModel: ExampleViewModel

    var contentView: some View {
        VStack(spacing: 16) {
            Text("Example Screen").font(.title2)
            Button("Load") { Task { await viewModel.load() } }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
```

**Rules**:
- Conforms to `BaseViewProtocol` — exposes `contentView`.
- `BaseViewProtocol` auto-applies: `.loader(isPresented:)`, `.handleError(with:)`, `.onAppear`, `.task`.
- View sends user intents to ViewModel — never calls repositories/services.
- No routing decisions. No domain rule encoding. No long-lived business state.

---

## 9. ViewController Pattern

```swift
final class ScreenAController: BaseHostingViewController<ScreenAViewModel, ScreenAView> {
    init(viewModel: ScreenAViewModel) {
        let view = ScreenAView(viewModel: viewModel)
        super.init(viewModel: viewModel, rootView: view)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
```

**Rules**:
- Hosts SwiftUI View inside UIKit navigation (Coordinator-driven).
- Bridges UIKit lifecycle (`viewDidLoad`, `viewWillAppear`, etc.) to ViewModel.
- Created by ControllerFactory, pushed/presented by Coordinator.
- No business logic, no data orchestration — stays thin.

---

## 10. Coordinator Pattern

### Coordinator

```swift
@MainActor
final class FeatureCoordinator: BaseCoordinator {
    private let router: Router
    private let factory: FeatureControllerFactory

    init(router: Router, factory: FeatureControllerFactory) {
        self.router = router
        self.factory = factory
    }

    override func start() { showRoot() }

    private func showRoot() {
        let vc = factory.makeRoot { [weak self] id in self?.showDetails(id: id) }
        router.setRoot(vc, animated: false)
    }

    private func showDetails(id: UUID) {
        let vc = factory.makeDetails(id: id) { [weak self] in self?.router.pop(animated: true) }
        router.push(vc, animated: true)
    }
}
```

### ControllerFactory

```swift
@MainActor
protocol FeatureControllerFactory {
    func makeRoot(onOpenDetails: @escaping (UUID) -> Void) -> UIViewController
    func makeDetails(id: UUID, onBack: @escaping () -> Void) -> UIViewController
}

@MainActor
final class FeatureControllerFactoryImpl: FeatureControllerFactory {
    private let assembler: AssemblerLike

    init(assembler: AssemblerLike) { self.assembler = assembler }

    func makeRoot(onOpenDetails: @escaping (UUID) -> Void) -> UIViewController {
        let transition = FeatureRootViewModel.Transition(openDetails: onOpenDetails)
        let vm = FeatureRootViewModel(transition: transition,
                                       getItemsUseCase: assembler.getItemsUseCase)
        return FeatureRootController(viewModel: vm)
    }

    func makeDetails(id: UUID, onBack: @escaping () -> Void) -> UIViewController {
        let transition = FeatureDetailsViewModel.Transition(back: onBack)
        let vm = FeatureDetailsViewModel(id: id, transition: transition,
                                          getItemDetailsUseCase: assembler.getItemDetailsUseCase)
        return FeatureDetailsController(viewModel: vm)
    }
}
```

**Coordinator rules**:
- Owns navigation flow for a scope (app / tab / feature).
- `start()` kicks off the flow. Routes via `setRoot` / `push` / `present` / `pop` / `dismiss`.
- Manages child coordinators and `onFinish` callbacks.
- Asks Factory to build controllers — never builds screens itself.
- No business logic. No API/storage logic. No screen construction details.

**Factory rules**:
- Builds ViewModel with dependencies from DI.
- Builds View/ViewController from that ViewModel.
- Wires `Transition` closures from Coordinator into ViewModel.
- No navigation actions. No flow ownership. No domain orchestration.

---

## 11. Dependency Injection (Swinject)

### Core Files

| File | Purpose |
|---|---|
| `Resolver+Require.swift` | `require<T>()` extension — fatal on missing registration |
| `DIContainer.swift` | `typealias DIContainer = Assembler` |
| `AppFactory.swift` | Protocol exposing shared services (`networkService`, `storageService`, `sessionUseCase`) resolved from container |
| `AppAssembly.swift` | Registers shared services, session repo/usecase, `AppFactory` itself |
| `FeatureXAssembly.swift` | Registers feature repository, usecases, `FeatureXFactory` |

### Runtime Wiring

1. Create root container: `Assembler([AppAssembly()])`.
2. Start app/root coordinator with this container.
3. For a feature flow, create child container: `Assembler([FeatureXAssembly()], parent: rootAssembler)`.
4. Resolve feature factory from child assembler.

### DI Rules

- Resolve only in composition points (assemblies / coordinators / factories).
- Constructor injection is the default.
- Register protocols, not concrete types.
- Do NOT call container from domain entities / UseCases directly.
- One assembly per feature.
- Feature factories are protocol + implementation (`FeatureXFactory` / `FeatureXFactoryImpl`).

---

## 12. Base Components

### BaseViewModel

```swift
class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    func onAppear() {}
    func onViewTask() async {}
}
```

Conforms to `LoadableViewModel` (provides `showLoader()` / `hideLoader()`) and `ErrorableViewModel` (provides `showError(_:)`).

### BaseViewProtocol

```swift
protocol BaseViewProtocol: View {
    associatedtype Content: View
    associatedtype VM: BaseViewModel
    var viewModel: VM { get }
    @ViewBuilder var contentView: Content { get }
}
```

Extension auto-applies: `.loader(isPresented:)`, `.handleError(with:)`, `.onAppear`, `.task`.

### BaseHostingViewController

```swift
class BaseHostingViewController<VM: ViewModelLifecycle, Content: View>: UIHostingController<Content>
```

Bridges UIKit lifecycle events to ViewModel via `ViewModelLifecycle` protocol (`viewDidLoad`, `viewWillAppear`, `viewDidAppear`, `viewWillDisappear`, `viewDidDisappear`).

---

## 13. Shared Components (Loader & Error)

### Loader

Files: `Shared/Components/Loader/` → `LoaderView.swift`, `LoadableViewModel.swift`, `LoadableViewModifier.swift`.

- ViewModel calls `showLoader()` before async work, `hideLoader()` after.
- View binds with `.loader(isPresented: $viewModel.isLoading)`.
- Only ViewModel mutates `isLoading`. Screens never manually toggle it.

### Error

Files: `Shared/Components/Error/` → `ErrorAlertView.swift`, `ErrorableViewModel.swift`, `ErrorableViewModifier.swift`.

- ViewModel calls `showError(_:)` on catch — sets `errorMessage`.
- View binds with `.handleError(with: $viewModel.errorMessage)`.
- Modifier derives `isPresented` from `errorMessage != nil`, clears on dismiss.

---

## 14. Shared Layer Rules

**Add to Shared only if**:
- Code is reused by 2+ features or is truly cross-cutting.
- It has a stable, generic API.
- No dependency on feature modules.
- Side effects are explicit — no hidden global state.
- Registered in root DI only once.

**Ownership**: every Shared file has a clear owner domain (UI, Network, Storage, Foundation). If ownership is unclear, it belongs in a feature.

---

## 15. Bootstrap Checklist

When setting up the app entry point, ensure:

1. **Entry points** — `AppDelegate` / `SceneDelegate` defined; startup path documented.
2. **Composition root** — single composition root creates the DI container; shared services registered once; feature modules wired through the container; dependency scopes defined.
3. **Global infra init** — logging, crash reporting, analytics, remote config, localization, deep link SDK, push notification setup.
4. **Persistence & session recovery** — storage migrations before feature flows; session/token restore before routing; first-install logic; corrupted/expired session fallback.
5. **Root UI & navigation** — root window created; root coordinator created; initial route decision centralized (onboarding / auth / main) with deterministic fallback.
6. **Global event wiring** — deep link, logout / session-expired, app lifecycle, notification / open-url handlers.
7. **Startup safety** — no feature business logic in bootstrap; no UI rendering beyond root setup; startup failures logged and surfaced; timeout/retry for critical services.
8. **Verification** — cold start on fresh install; warm start with session; deep link cold + warm; logged-out and logged-in routing; unit/integration test covers startup route decision.
9. **Definition of done** — a new developer can trace startup in under 5 minutes; startup is reproducible from docs; bootstrap changes require re-validation.

---

## 16. Quality Checklists (For Agent Self-Review)

Before marking any generated code as complete, verify:

**Repository**:
- [ ] No DTO leaks outside Data.
- [ ] Mapping is explicit and testable.
- [ ] Error mapping is explicit.
- [ ] Source strategy is deterministic.
- [ ] UseCase tests can mock repository without touching network/storage.

**UseCase**:
- [ ] Single business purpose.
- [ ] No infra leakage in signatures.
- [ ] Input validation and error mapping are explicit.
- [ ] Side effects are deterministic and testable.
- [ ] Easy to mock dependencies in unit tests.

**Component**:
- [ ] Reusable API is clear and minimal.
- [ ] No feature imports in component files.
- [ ] Supports light/dark/theme tokens.
- [ ] Testable (snapshot/unit/UI).
- [ ] Documented inputs and behavior.

---

## 17. Common Mistakes to Avoid

| Mistake | Correct Approach |
|---|---|
| ViewModel calls network/storage directly | ViewModel → UseCase → Repository |
| DTO types used in Presentation | Map to Domain Entity, then to Presentation Entity |
| Navigation logic in ViewModel | Emit via `Transition` closure; Coordinator decides |
| Business logic in View | Move to ViewModel or UseCase |
| Manual dependency construction in features | Register in Assembly; inject via initializer |
| Singletons scattered across codebase | Register once in `AppAssembly`; resolve from container |
| Shared code that depends on a feature | Move to the feature or refactor to be generic |
| Repository doing business orchestration | That belongs in UseCases |
| ViewController doing data work | Keep thin — host View + bridge lifecycle only |

---

## 18. How to Use This Document with AI Agents

**For Claude Code / Cursor / Copilot / custom agents:**

1. **Include this file as project knowledge** — add it to `.cursorrules`, Claude project instructions, or your agent's system prompt.
2. **Reference it in prompts** — e.g. "Follow the architecture instructions when generating this feature."
3. **Use it for code review** — ask the agent to verify generated code against these rules.

**For building from scratch:**
- Ask the agent to scaffold the project structure (Section 1–2) first.
- Then generate Base components (Section 12–13).
- Then generate DI setup (Section 11).
- Then generate features one at a time following the Feature Structure (Section 2) and all layer rules.

**For refactoring existing code:**
- Ask the agent to audit against the Quality Checklists (Section 16) and Common Mistakes (Section 17).

---

## 19. Visual Fidelity & Design Tokens

UI code must source every visual primitive from the design system. No hardcoded fonts, colors, spacings, or sizes — the system is the single source of truth for the look of the app.

### 19.1 Hard rules

- **Fonts**: only `Font.App.*` (defined in `Shared/DesignSystem/AppTypography.swift`).
  Never `Font.system(...)`, never `.font(.title)`, never `Font.custom("Aeonik…")` inline.
- **Letter-spacing**: only `CGFloat.Tracking.*`, applied via `.tracking(...)`. Pair tracking with the matching font tier (e.g. `title1Medium` + `Tracking.title1`).
- **Colors**: only `Color.App.*` (backed by `Colors.xcassets`). Never raw hex, never `Color(red:green:blue:)`, never `Color(.systemBackground)` in feature code — wrap in `Color.App.*` first if needed.
- **Spacing**: only `CGFloat.Spacing.*` (`xxs`, `xs`, `sm`, `md`, `lg`, `xl`, …). Never magic numbers like `12`, `16` directly in `.padding(...)` or `spacing:`.
- **Corner radius / icon size / stroke width**: use design-system constants if one exists; otherwise add a justification comment naming the Figma source value.
- **Strings**: `Localization.*` only. The SwiftGen path is broken in this repo — when adding a key, edit both `Localizable.strings` and the generated `Localization.swift` by hand.

### 19.2 When the design system has no exact match

Don't extend the design system mid-feature. Don't write a magic number either. Instead, **compose from existing tokens**:

```swift
// Figma says 6pt — closest tokens are xxs (4) and xs (8).
.padding(.top, CGFloat.Spacing.xxs + 2)

// Figma says 18pt — no exact token; compose.
.padding(.bottom, CGFloat.Spacing.sm + CGFloat.Spacing.xxs)
```

The composition makes the relationship to the design system explicit and reviewable. A literal `6` hides that relationship.

If the same composed value appears 3+ times across the app, that's a signal the design system genuinely needs a new token — raise it then, not on first sight.

If a Figma value looks wrong (off-brand, inconsistent with adjacent tokens), flag it with the designer before coding around it.

### 19.3 Self-review before declaring a UI task complete

For every modifier on every view, the answer to "where does this value come from?" must be a design-system token or a documented composition of tokens, not a literal. If you find a literal, fix it or explain why.

For UI work driven from a Figma node, follow the `build-ui-from-figma` skill — it owns the procedure (token-map → implement → static code-vs-Figma review loop → render-preview → audit).
