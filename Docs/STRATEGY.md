# What's REAL — Strategy & Pitch Document

---

## The Problem

Right now, when you need to know something about a place — is it crowded? is it safe? is the line too long? — you have nowhere fast to turn.

- **Yelp / Google Maps**: Reviews written weeks ago by someone who may not have been there in months.
- **Nextdoor**: Slow forum. Text walls. No urgency signals. Not structured for questions.
- **Citizen**: Real-time local alerts, but one-way broadcasts. No Q&A. No community.
- **Reddit / Quora**: No location context. Answers go stale. Anyone can answer anything.
- **Call the business**: Unreliable and inefficient.

**The gap**: Nobody owns real-time, verified, location-specific Q&A.

---

## The Solution: What's REAL

> *"The only app where answers come from people who are provably there, right now — not opinions written from memory six months later."*

What's REAL is a hyperlocal Q&A platform that lets you ask time-sensitive questions about a specific place and get answers from people who are physically there at that moment.

**Core mechanic:**
1. You're at a restaurant. You want to know if the patio is open.
2. You post: *"Is the rooftop open tonight?"* — tagged to that exact location, marked as **Happening** (expires in 1 hour).
3. A Trusted Local who is at or near that venue gets notified and answers within minutes.
4. You get the truth. Not a review. The truth, right now.

---

## Why Now

Three forces are converging:

1. **Location precision is commodity** — GPS on modern phones is accurate to 3-5 meters.
2. **Real-time trust is unsolved** — Every major review platform is plagued by fake, stale, or paid reviews.
3. **Hyperlocal is the last unsaturated market** — Nextdoor proved neighborhood networks have value. Nobody has cracked real-time Q&A within them.

---

## Unique Differentiators

### 1. Verified Presence
Respondents must be within 200m of the place to answer. This single constraint transforms "what people think" into "what people are experiencing right now." It cannot be gamed by bots, offshore farms, or paid reviewers.

### 2. Urgency System
Questions expire. "Need to Know" lives 24 hours. "What's Happening" expires in 1 hour. "Urgent" expires in 30 minutes. Expiration creates a sense of real-time stakes and keeps the feed fresh.

### 3. Trust Graph
Every answer you give is attached to your presence record at that location. Over time, your identity becomes tied to where you've been and what you've gotten right. This reputation cannot be transferred to a competitor — it lives in What's REAL.

### 4. Temporal Truth Database
Questions expire, but answers are archived. After 6 months of data, we own something no review platform has: *"This bar is always slammed at 10pm on Fridays, quieter by midnight."* Historical truth, timestamped and verified by GPS. This data moat grows daily and is nearly impossible for a competitor to replicate.

### 5. Scout Identity
Frequent visitors of an area earn "Scout" status — they get notified when questions arise near their usual spots. Scouts create an organic expert user layer that deepens community trust.

### 6. AI Consensus Layer (Roadmap)
When 8 people answer "is it crowded?" — AI synthesizes: *"6/8 say packed right now, 2/8 say it's quiet — updated 4 min ago."* Answers become signals, not noise.

---

## Competitive Moat

| Moat | Description |
|------|-------------|
| **Network Density Effect** | Value explodes per block, not per city. A single dense block with 50 Scouts is nearly impossible to displace once formed. |
| **Temporal Data Asset** | 6 months of GPS-verified, timestamped local truth is worth more than any review database. It accumulates passively every day. |
| **Trust Graph Lock-in** | Your reputation, badges, and Scout status are tied to your location history in What's REAL. None of it transfers to a competitor. |
| **Verified Presence Barrier** | The GPS presence requirement means answers are structurally more trustworthy — Yelp or Google cannot bolt this on to their existing model. |

---

## Go-to-Market Strategy

**Phase 1 — Dense Seeding (Month 1-2)**
Do not launch city-wide. Target 2-3 high-density neighborhoods with natural question-asking behavior:
- University campuses (always asking: "is the library crowded?")
- Downtown food/nightlife districts (always asking: "is there a wait?")
- Large residential complexes or markets

Seed manually. Hire 10 part-time "Founding Scouts" who answer questions for the first month. Make the product feel magical before going wider.

**Phase 2 — Business Layer (Month 3-4)**
Introduce verified business accounts. Restaurants, cafés, and venues can claim their location and respond with a "Business Verified" badge. This gives businesses a direct channel to reach people actively asking questions about them in real time.

Revenue model starts here: **premium verified accounts** ($49/mo), **promoted answers** (appear first in feed), and **analytics dashboard** (see what questions get asked about your venue).

**Phase 3 — Platform Expansion (Month 5-6)**
- iOS widget: "3 questions near you right now" — passive discovery without opening the app
- Apple Watch complication: live urgency alerts
- API access for business intelligence use cases
- Geographic expansion to second city

---

## Business Model

| Stream | Description | Target |
|--------|-------------|--------|
| **Verified Business Accounts** | Monthly subscription for venues | $49–$199/mo |
| **Promoted Answers** | Paid placement in feed for businesses | CPM-based |
| **Data Intelligence** | Anonymized foot-traffic / sentiment API | $5K–$50K/yr per client |
| **Premium Users** | Power user features (extended history, bulk asks) | $4.99/mo |

The data intelligence tier is the long-term prize. Retailers, commercial real estate, urban planners, and event operators all need real-time foot traffic and sentiment data. What's REAL accumulates it organically.

---

## Technology

Built natively on iOS with SwiftUI and Firebase:

- **Real-time feeds**: Firestore listeners push questions to devices within milliseconds.
- **Geohash proximity**: All questions are indexed by geohash. The feed queries by geohash prefix, not global scan — location filtering is fast and scales linearly.
- **Trust system**: Votes, badges, and Scout levels computed per user and stored in Firestore.
- **Auth**: Email/password + Apple Sign-In. Guest access for frictionless onboarding.
- **Architecture**: Protocol-based services with clean MVVM. Easy to add platforms (Android, web) without rewriting business logic.

---

## Current Status

- **iOS app**: Core architecture complete. Auth, real-time feed, question posting, and response flow functional.
- **Geohash proximity filtering**: Implemented — Firestore queries by geohash prefix, in-memory radius filter at 10km.
- **Trust models**: Defined and stored in Firestore. UI implementation next.
- **Target launch**: Private beta in one dense neighborhood within 60 days.

---

## The Ask

We are raising a **$500K pre-seed** to:
1. Fund 6 months of the founding team (2 engineers, 1 community manager)
2. Run the dense neighborhood seeding campaign (Founding Scouts, marketing)
3. Build and launch the Business Verified layer (primary revenue stream)

In return, early investors get ground-floor access to the only platform building a GPS-verified, real-time truth layer for the physical world.

---

## Vision

Every city block has a thousand unanswered questions happening right now. *Is it busy? Is it safe? Is the food still good? Is the event still on?*

What's REAL is the infrastructure that answers them — not from memory, not from marketing, but from people who are there, right now, with something to prove.

**We are building the real-time truth layer for the physical world.**

---

*What's REAL · Hyperlocal Truth · Verified Presence*
