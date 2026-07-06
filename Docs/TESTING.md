# What's REAL — Manual Testing Guide

## Setup Before You Start

| Requirement | Notes |
|---|---|
| Device or Simulator | iOS 17+ simulator or physical iPhone |
| Firebase project | `GoogleService-Info.plist` already in project |
| Internet connection | Required for Auth + Firestore |
| Xcode scheme | `WR` → any iOS 17+ simulator |
| Second device (optional) | For real-time sync tests |

**Build and run:** `Cmd+R` in Xcode with the `WR` scheme selected.

---

## 1. Cold Launch

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 1.1 | Build and run on a fresh simulator (or after clearing app data) | Auth screen appears — NOT the Feed | |
| 1.2 | Verify the app title "Whats REAL" is visible | Title renders correctly | |
| 1.3 | Check Sign In / Create Account segmented control | Toggles correctly between modes | |

---

## 2. Sign Up (Email + Password)

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 2.1 | Tap "Create Account" in the segmented picker | Mode switches to sign-up | |
| 2.2 | Leave fields empty → tap "Create Account" button | Button is disabled — nothing happens | |
| 2.3 | Enter an invalid email (e.g. `notanemail`) + valid password → tap button | Error: "Invalid email format." | |
| 2.4 | Enter valid email + password shorter than 6 chars → tap button | Error: "Password is too weak. Use at least 6 characters." | |
| 2.5 | Enter a valid email + password ≥ 6 chars → tap "Create Account" | Loading spinner appears, then Profile Setup screen | |
| 2.6 | On Profile Setup, leave display name empty → tap "Get Started" | Button is disabled | |
| 2.7 | Enter a display name (e.g. "Test User") → tap "Get Started" | Feed appears | |
| 2.8 | Check Firebase Console → **Authentication → Users** | New user appears with the email used | |
| 2.9 | Check Firebase Console → **Firestore → users collection** | Document exists with `uid`, `displayName`, `profileComplete: true` | |

---

## 3. Sign In (Email + Password)

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 3.1 | Sign out (Profile tab → Sign Out) → try signing in with wrong password | Error: "Incorrect password. Please try again." | |
| 3.2 | Try signing in with an unregistered email | Error: "No account found with this email." | |
| 3.3 | Try signing in with a previously registered email that was already used for sign-up | Error: "This email is already registered. Try signing in instead." (only in sign-up mode) | |
| 3.4 | Enter correct email + password in Sign In mode → tap button | Feed appears, profile setup is skipped | |

---

## 4. Apple Sign-In (Physical Device Required)

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 4.1 | Tap "Sign in with Apple" button | Apple authentication sheet appears | |
| 4.2 | Complete Face ID / Touch ID | App continues to Profile Setup (first time) or Feed (returning user) | |
| 4.3 | Check Firebase Console → Authentication → Users | Apple user appears with a `privaterelay.appleid.com` email or real email | |

---

## 5. Guest Sign-In

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 5.1 | Tap "Continue as Guest" | Feed appears, profile setup is skipped | |
| 5.2 | Verify guest can see the Feed | Questions load (or empty state) | |
| 5.3 | Guest taps Ask tab and posts a question | Question is posted with name "Anonymous" | |
| 5.4 | Check Firestore → questions | `authorName` is "Anonymous" | |

---

## 6. Session Persistence

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 6.1 | Sign in successfully → force-quit the app | — | |
| 6.2 | Relaunch the app | Feed appears immediately — Auth screen does NOT show | |
| 6.3 | Sign out → force-quit → relaunch | Auth screen appears — session is cleared | |

---

## 7. Feed

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 7.1 | Launch app as signed-in user | Feed tab is selected by default | |
| 7.2 | When no location permission granted | Yellow/orange "Enable Location" banner appears at the top | |
| 7.3 | Tap "Enable Location" in the banner | iOS permission dialog appears | |
| 7.4 | Grant location → banner disappears | Feed loads questions near your location | |
| 7.5 | When no questions exist nearby | Empty state shows "No Questions Nearby" | |
| 7.6 | Pull down on the feed | Refresh spinner appears → feed reloads | |
| 7.7 | Toggle "Nearby" / "Following" in the segmented picker | Picker switches (Following is UI-only for now) | |
| 7.8 | Post a question (see Section 8) → return to Feed | New question appears in the list without manual refresh | |

---

## 8. Ask a Question

### 8a. Place Picker — Nearby List

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 8a.1 | Tap the Ask tab | Ask form opens | |
| 8a.2 | Tap "Select a place" | Place picker sheet opens | |
| 8a.3 | Without typing, check the list | Nearby places (within ~500m) appear automatically | |
| 8a.4 | If location not granted | List is empty — "Search for a place" prompt shown | |

### 8b. Place Picker — Search

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 8b.1 | In the place picker, type a place name (e.g. "Starbucks") | Search results appear within ~300ms (debounced) | |
| 8b.2 | Results are biased toward your current location | Nearby Starbucks locations appear first | |
| 8b.3 | Clear the search text (X button) | Nearby list restores | |
| 8b.4 | Tap a result | Place is selected, picker closes, Ask form shows place name + address | |

### 8c. Place Picker — Map Pin

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 8c.1 | In place picker, tap "Pin on Map" (top-right button) | Full-screen map opens | |
| 8c.2 | Map centers on your current location | Map loads correctly | |
| 8c.3 | Drag the map | Center pin stays fixed, map moves beneath it | |
| 8c.4 | Stop dragging | Bottom card shows reverse-geocoded address within 1–2 seconds | |
| 8c.5 | Drag to a completely different location | Address updates to new location | |
| 8c.6 | Tap "Confirm Location" | Map closes, Ask form shows the pinned location | |
| 8c.7 | Tap "Cancel" | Map closes, no place is selected | |

### 8d. Posting the Question

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 8d.1 | Select a place but leave question text empty | "Post Question" button is disabled | |
| 8d.2 | Enter question text but no place selected | "Post Question" button is disabled | |
| 8d.3 | Fill in both → choose urgency: **Info (24h)** → post | Question is posted with 24h expiry | |
| 8d.4 | Post with urgency: **What's Happening (1h)** | Question expires in 1h | |
| 8d.5 | Post with urgency: **Urgent (30m)** | Question expires in 30 minutes | |
| 8d.6 | Tap "Post Question" | Loading state shows → success alert "Posted!" | |
| 8d.7 | Dismiss the alert | Form resets (text cleared, place cleared, urgency back to Info) | |
| 8d.8 | Check Firestore → `questions` collection | Document exists with correct `authorId`, `authorName`, `placeName`, `geohash`, `urgencyLevel`, `expiresAt` | |
| 8d.9 | Switch to Feed tab | New question appears in the list | |

---

## 9. Question Detail + Responses

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 9.1 | Tap any question card in the Feed | Question detail sheet slides up | |
| 9.2 | Verify question info shown | Urgency badge, place name, author, expiry timer all visible | |
| 9.3 | Leave response text empty → check Post button | Button shows as disabled (gray) | |
| 9.4 | Type a response → button becomes active (blue) | — | |
| 9.5 | Submit the response | Loading spinner → response appears in the list below | |
| 9.6 | Check Firestore → `responses` collection | Document exists with `questionId` linking to the question | |
| 9.7 | Submit a second response | Both responses appear, newest at bottom | |
| 9.8 | Close the sheet → reopen the same question | Previously submitted responses still visible | |

### 9a. Real-Time Sync (Two Devices/Simulators)

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 9a.1 | Open the same question on two devices | Both show the same response list | |
| 9a.2 | On Device 1, submit a response | Response appears on Device 2 **without refreshing** (within ~1–2 seconds) | |

---

## 10. Profile & Sign Out

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 10.1 | Tap the Profile tab | Profile screen shows your email and a Sign Out button | |
| 10.2 | Tap "Sign Out" | Auth screen appears | |
| 10.3 | Sign back in | Feed restores with questions | |

---

## 11. Location Edge Cases

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 11.1 | Deny location permission | Feed shows the location permission banner | |
| 11.2 | No location → feed still loads | Global fallback: all questions load (not filtered by distance) | |
| 11.3 | Grant location after initial denial (via Settings) | Banner disappears on next app launch or permission change | |

---

## 12. Error Handling

| # | Step | Expected Result | Pass/Fail |
|---|---|---|---|
| 12.1 | Turn off WiFi/cellular → try to sign in | Network error message appears | |
| 12.2 | Turn off WiFi/cellular → try to post a question | Error alert: "Failed to post: …" | |
| 12.3 | Turn off WiFi → open question detail | Error alert if responses fail to load | |
| 12.4 | Restore connection → retry any of the above | Operations succeed | |

---

## 13. Firebase Console Verification Checklist

After a full test run, verify these in the Firebase Console:

| Collection | What to check |
|---|---|
| `Authentication → Users` | Each registered user appears with correct provider (email, Apple, anonymous) |
| `Firestore → users` | `profileComplete: true` for users who completed setup; `displayName` matches what was entered |
| `Firestore → questions` | `geohash` is 9-char string; `expiresAt` is ~24h/1h/30m from `createdAt`; `placeId`, `placeName`, `lat`, `lng` are correct |
| `Firestore → responses` | Each response has `questionId` matching a question document; `responderName` matches the user's display name |

---

## 14. Known Limitations (Current Build)

These are intentional — not bugs — in the current MVP:

| Feature | Status |
|---|---|
| "Following" feed filter | UI only — shows same results as "Nearby" |
| Inbox tab | Placeholder ("Coming soon") |
| Photo questions/responses | Model supports it, no UI picker yet |
| Helpful (thumbs up) on responses | Button renders, no backend action yet |
| Push notifications | Not wired — `StubNotificationService` used |
| Question auto-expiry | `expiresAt` stored in Firestore but no background job removes expired docs |
| Google Sign-In | Not available in this build |
| "Following" filter | Not implemented — same feed as Nearby |
