# Whats REAL — Xcode Build Prompts Playbook (Step-by-Step)

This file turns the **Master Project & Idea** into a practical, *pro-engineer* build sequence for an **iOS native Swift 6 + SwiftUI** app with **Firebase + Google Places**, designed with **Apple-native UI patterns**.

## How to use this file
For each step:
1. In **Xcode**, create the files/folders listed.
2. Paste the **PROMPT** into your editor assistant (Cursor / Copilot Chat / ChatGPT in-editor).
3. Implement exactly what the step produces.
4. Build & run. Do not skip steps.

> Rule: **Do not overbuild.** Each step is intentionally small and will not break the next step.

---

## UI/UX North Star (Apple-native)
**Design language**
- Use **SF Symbols**, **system fonts**, **Material** (thin/regular) backgrounds, and **standard navigation patterns**.
- Prefer: `NavigationStack`, `TabView`, `Toolbar`, `Sheet`, `Form`, `ContextMenu`, `SwipeActions`, `ShareLink`.
- Keep it Quora-simple: **read feed → ask → wait → respond**.

**Tabs (TabView)**
1. **Feed** — `house`
2. **Ask** — `plus.circle.fill`
3. **Inbox** — `bell`
4. **Profile** — `person.circle`

**Key screens**
- Feed: clean cards, location chip, “Verified responders only” badge.
- Ask: compose like Apple Notes (text first), attach 10s video, tag place.
- Question Detail: thread + response composer pinned at bottom.
- Profile: trust score, recent verified places (privacy-safe summary).

---

# STEP 0 — Project Foundation (Pro setup)
### Goal
Create the **architecture skeleton**: AppState, Router, DI container, folder structure, and Firebase bootstrap.

### Xcode actions
- Create Groups/Folders:
  - `App/`, `Core/Routing/`, `Core/UIComponents/`, `Services/`, `Models/`, `Features/`
- Add Firebase via **Swift Package Manager** (preferred):
  - `File > Add Package Dependencies…`
  - Add: `https://github.com/firebase/firebase-ios-sdk`
  - Select products: `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage`, `FirebaseMessaging`
- Ensure your `GoogleService-Info.plist` is added to the target.

### PROMPT (paste in editor)
```
Create the Step 0 foundation for a Swift 6 + SwiftUI app named “Whats REAL” using MVVM + protocol services + dependency injection.

Requirements:
- Create AppState (ObservableObject) tracking: authState (signedOut/signedIn), profileState (unknown/incomplete/complete)
- Create AppRouter (SwiftUI) that routes: AuthFlow -> ProfileSetup -> MainTabView
- Create a lightweight DI container (AppContainer) that constructs services and view models
- Add placeholders for services: AuthService, UserService, LocationService, PlacesService, MediaService, NotificationService, TrustService (protocols + concrete stubs)
- Update Whats_REALApp.swift to configure Firebase in init and inject AppState + AppContainer
- Use NavigationStack where appropriate
- Include minimal comments and no force unwraps
Output the full file list and the code for each file.
```

✅ **Build check**: app launches to Auth screen placeholder.

---

# STEP 1 — Auth Flow (Email/Password) + Apple-native UI
### Goal
Working login/signup with Firebase Auth, using clean SwiftUI components.

### Xcode actions
Create files:
- `Features/Auth/AuthView.swift` (container)
- `Features/Auth/LoginView.swift`
- `Features/Auth/SignUpView.swift`
- `Features/Auth/AuthViewModel.swift`
- `Services/AuthService.swift` (real implementation)

### PROMPT
```
Implement Step 1: Firebase email/password authentication for Whats REAL.

Requirements:
- AuthService protocol + FirebaseAuth implementation using async/await
- AuthViewModel that exposes login/signup actions and updates AppState on success
- AuthView that presents LoginView with a navigation link to SignUpView
- UI: Apple-native, Form or VStack with system styling, primary button, disabled state, inline error text
- Add reusable components in Core/UIComponents:
  - WRPrimaryButton
  - WRTextField (email)
  - WRSecureField (password)
- No business logic in Views; keep logic in ViewModel/Service
Output code for all new/updated files.
```

✅ **Build check**: can create account + login; AppState routes to Profile setup.

---

# STEP 2 — Mandatory Profile Setup (Demographics + Social Status)
### Goal
After sign-in, user must complete profile.

### Xcode actions
Create files:
- `Features/Profile/ProfileSetupView.swift`
- `Features/Profile/ProfileViewModel.swift`
- `Models/WRUserProfile.swift`
- `Services/UserService.swift` (Firestore users collection)

### PROMPT
```
Implement Step 2: Mandatory profile creation and profile gate.

Requirements:
- Firestore users collection: users/{uid}
- Profile fields: displayName, age (Int), gender (String), socialStatus (String), profileComplete (Bool), createdAt
- UserService protocol + Firestore implementation: fetchProfile(uid), upsertProfile(uid, profile)
- ProfileViewModel handles validation and save (async/await)
- ProfileSetupView uses a Form with native pickers where sensible (gender can be free text for now if you prefer)
- On successful save, set AppState.profileState = complete to route to MainTabView
- Add WRCard container component for future reuse
Output code for all files.
```

✅ **Build check**: after saving profile, routes to MainTabView placeholder.

---

# STEP 3 — MainTabView + Feed UI Skeleton (Quora-simple)
### Goal
Create the main shell with Feed + Ask + Inbox + Profile tabs, and a feed card UI.

### Xcode actions
Create files:
- `Features/Feed/FeedView.swift`
- `Features/Feed/FeedViewModel.swift`
- `Features/Ask/AskEntryView.swift` (placeholder)
- `Features/Inbox/InboxView.swift` (placeholder)
- `Features/Profile/ProfileView.swift` (placeholder)
- `Core/UIComponents/WRQuestionCard.swift`

### PROMPT
```
Implement Step 3: MainTabView and Feed UI skeleton.

Requirements:
- Create MainTabView with 4 tabs:
  Feed (house), Ask (plus.circle.fill), Inbox (bell), Profile (person.circle)
- FeedView uses NavigationStack and shows:
  - segmented control placeholder (Nearby / Following)
  - list of WRQuestionCard (use mock data in ViewModel for now)
- WRQuestionCard design:
  - title (question preview)
  - place chip (SF Symbol: mappin.and.ellipse)
  - “Verified responders only” badge (checkmark.seal)
  - timestamp (relative)
- Keep view models separate; no Firestore yet
Output code for all files.
```

✅ **Build check**: app shows tabs; Feed renders mock cards.

---

# STEP 4 — Location Permission + LocationService (Privacy-first)
### Goal
Request location while-in-use and expose current location for Nearby feed later.

### Xcode actions
- Add Info.plist keys:
  - `NSLocationWhenInUseUsageDescription`
- Create files:
  - `Services/LocationService.swift`
  - `Core/UIComponents/WRPermissionBanner.swift`

### PROMPT
```
Implement Step 4: LocationService and permission UX.

Requirements:
- LocationService protocol + CoreLocation implementation
- Expose:
  - authorizationStatus
  - currentLocation (CLLocation?)
  - requestPermission()
  - startUpdatingIfAuthorized()
- Create WRPermissionBanner component used by FeedView to prompt for location permission elegantly (not aggressive).
- Do not track in background; while-in-use only.
- Update FeedView to show permission banner when not authorized.
Output code and minimal integration changes.
```

✅ **Build check**: permission prompt appears; Feed updates state.

---

# STEP 5 — Google Places: Location Picker Component
### Goal
Let user tag a place using Google Places autocomplete.

### Xcode actions
- Add Google Places SDK (SPM or CocoaPods; choose one and be consistent)
- Create files:
  - `Services/PlacesService.swift`
  - `Core/UIComponents/WRPlacePickerView.swift`
  - `Models/WRPlace.swift`

### PROMPT
```
Implement Step 5: Google Places autocomplete picker for tagging.

Requirements:
- WRPlace model: placeId, name, address, lat, lng
- PlacesService protocol + GooglePlaces implementation (autocomplete + fetch place details)
- WRPlacePickerView:
  - search field
  - list of suggestions
  - selection callback returns WRPlace
  - uses Sheet presentation with NavigationStack and Cancel button
- Keep UI Apple-native; use SF Symbols and standard list styles
Output code for all files and show how AskEntryView will present the place picker.
```

✅ **Build check**: Ask tab can open place picker and select a place.

---

# STEP 6 — Ask Flow (Text Question MVP) + Firestore Write
### Goal
Post a text question with place tag and radius to Firestore.

### Xcode actions
Create files:
- `Models/WRQuestion.swift`
- `Services/QuestionService.swift`
- `Features/Ask/AskView.swift`
- `Features/Ask/AskViewModel.swift`

### PROMPT
```
Implement Step 6: Ask a TEXT question and save to Firestore.

Requirements:
- Question Firestore structure:
  questions/{questionId}
  Fields: authorId, authorName, type(text/video), text, placeId, placeName, lat, lng, radiusMeters (50-100), allowRatings, allowVideoResponses, createdAt
- QuestionService protocol + Firestore implementation: createQuestion(question)
- AskView UI:
  - multiline text editor with placeholder
  - place chip (tap to open WRPlacePickerView)
  - radius selector (segmented 50/75/100)
  - toggles: allowRatings, allowVideoResponses
  - Post button (disabled until valid)
- On success, dismiss and show a toast or alert
Output code for all files and any small changes needed in MainTabView.
```

✅ **Build check**: can post question; see it in Firebase console.

---

# STEP 7 — Feed: Firestore Read (Nearby) + Card Rendering
### Goal
Replace mock feed with Firestore data.

### Xcode actions
Update/create:
- `Features/Feed/FeedViewModel.swift` to fetch from Firestore
- `Services/QuestionService.swift` add fetch queries

### PROMPT
```
Implement Step 7: Fetch questions from Firestore and display in Feed.

Requirements:
- FeedViewModel subscribes to Firestore updates (listener) for recent questions.
- For MVP: fetch latest N questions and sort by createdAt desc.
- If location permission granted, prepare hooks for future nearby filtering (do not implement geohash yet unless necessary).
- Map Firestore documents to WRQuestion model using Codable or manual mapping.
- FeedView displays live results in WRQuestionCard.
Output updated code.
```

✅ **Build check**: newly created questions appear in Feed.

---

# STEP 8 — Question Detail + Respond (Text + Rating)
### Goal
Open a question, show thread, allow text response and rating if enabled.

### Xcode actions
Create files:
- `Features/Feed/QuestionDetailView.swift`
- `Features/Respond/RespondComposerView.swift`
- `Models/WRResponse.swift`
- `Services/ResponseService.swift`
- `Features/Feed/QuestionDetailViewModel.swift`

### PROMPT
```
Implement Step 8: Question detail and responses.

Requirements:
- Firestore structure:
  questions/{questionId}/responses/{responseId}
  Fields: responderId, type(text/rating/video), text, ratingValue, createdAt
- ResponseService: addTextResponse(), addRatingResponse()
- QuestionDetailView shows:
  - question header card
  - responses list
  - pinned RespondComposerView at bottom
- Composer:
  - text field + send button
  - if allowRatings == true: show rating control (1-5) using native SwiftUI components
- Navigation from FeedView card -> QuestionDetailView
Output all code.
```

✅ **Build check**: can add responses; they appear live.

---

# STEP 9 — 10s Video Recording + Upload (AVFoundation + Firebase Storage)
### Goal
Record ≤10s video for Ask and Respond.

### Xcode actions
Create files:
- `Core/UIComponents/WRVideoRecorderView.swift`
- `Services/MediaService.swift`
- Update AskView/RespondComposerView to add “Record 10s” option

### PROMPT
```
Implement Step 9: 10-second video recorder and upload.

Requirements:
- Use Apple-native APIs (AVFoundation/AVKit). Keep UI minimal and stable.
- Enforce 10s max recording.
- MediaService handles:
  - local file URL creation
  - upload to Firebase Storage
  - returns a public downloadURL string
- Update question and response models to support videoURL when type is video.
- UI:
  - “Record 10s” button opens a sheet recorder
  - After recording, show preview thumbnail and allow Remove
Output code and integration points.
```

✅ **Build check**: record video; upload; see URL saved in Firestore.

---

# STEP 10 — In-app + Push Notification Scaffold (FCM)
### Goal
Register device token, store it, and create in-app notification model.

### Xcode actions
Create/update:
- `Services/NotificationService.swift`
- `Models/WRNotification.swift`
- `Features/Inbox/InboxViewModel.swift`

### PROMPT
```
Implement Step 10: Notifications scaffold.

Requirements:
- Configure APNs + Firebase Messaging hooks:
  - request notification permission
  - register FCM token
  - store token in Firestore under users/{uid}/devices/{deviceId}
- Create a simple in-app notifications collection:
  users/{uid}/notifications/{notificationId}
- InboxView shows notifications list from Firestore.
- Do not implement Cloud Functions sending yet; just scaffold storage + display.
Output code and required AppDelegate/UIApplicationDelegateAdaptor wiring for SwiftUI.
```

✅ **Build check**: token saved; Inbox renders notifications (even if manually inserted).

---

# STEP 11 — Trust Layer v1 (Authenticity + Reputation Scaffolding)
### Goal
Create the trust “referee” framework without heavy AI yet.

### Xcode actions
Create files:
- `Models/WRAuthorTrust.swift`
- `Models/WRAIConfidence.swift`
- `Services/TrustService.swift`
- Update Feed ranking stub to include trust score

### PROMPT
```
Implement Step 11: Trust layer scaffolding (no ML yet).

Requirements:
- Define WRAIConfidence enum: high/mixed/low
- Add fields to response/question models:
  - authenticityConfidence (optional)
- Create TrustService that computes a simple placeholder confidence:
  - uses heuristics: very short/generic text => mixed, repeated content => low (basic)
- Create user trust score model:
  - trustScore (0-100), updatedAt
- Update WRQuestionCard to display a small “Authenticity: High/Mixed/Low” label when present.
Output code only for scaffolding; no heavy AI.
```

✅ **Build check**: can show confidence label and trust score placeholders.

---

## What you do after Step 11
- Add **geohash nearby filtering**
- Add **eligibility based on “been there” ledger**
- Add **Cloud Functions for targeted notifications**
- Add **Trust-as-a-Service API spec** (separate repo/service)

---

If you want, I can also generate a **Sprint checklist** matching these steps (1–2 weeks MVP).
