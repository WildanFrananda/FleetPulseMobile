# Product Requirement Document (PRD): FleetPulse Driver App

**The driver-facing mobile client for the FleetPulse tracking & dispatch engine.**

---

## 1. Executive Summary

FleetPulse Driver is the native mobile companion to the FleetPulse backend. It
turns a courier's phone into a live telemetry source and an order terminal: it
streams GPS to the server over a persistent WebSocket, receives dispatched
orders in real time, and lets the driver advance an order through pickup and
delivery — all while surviving the flaky connectivity of real-world driving.

The backend (Elixir/Phoenix) already exists and holds all business logic. This
app is a **thin, resilient client** over the backend's driver channel. It owns
no domain rules; it owns connectivity, location, battery discipline, and a
clean driver UX.

---

## 2. Problem Statement

The FleetPulse backend can track thousands of drivers and dispatch orders in
milliseconds — but today it has **no real driver client**. All telemetry has
been simulated by tests and RPC. Without a phone app:

- No real GPS ever reaches the system.
- Dispatched orders cannot be delivered to a human.
- The channel contract (auth, reconnection, ping cadence, order lifecycle) has
  never been exercised by a real device on a real network.

A driver on the road needs an app that: stays connected through tunnels and
cell handovers, reports location without draining the battery, and shows the
current order with unambiguous pickup/deliver actions.

---

## 3. Goals & Non-Goals

### Goals (V1)

- Authenticate a driver and hold a session token securely.
- Maintain a live WebSocket to the backend driver channel, with automatic reconnection.
- Stream GPS position every 3–5 seconds while on duty, including with the screen off.
- Receive dispatched orders instantly and display pickup/dropoff.
- Let the driver mark an order **picked up** and **delivered**.
- Let the driver toggle availability (online / offline).
- Degrade gracefully offline and recover cleanly on reconnect.

### Non-Goals (V1)

- Turn-by-turn navigation (hand off to the phone's map app via a deep link).
- In-app chat, ratings, earnings, or payments.
- Driver self-registration (drivers are provisioned by an operator).
- The dispatcher experience (that is the existing Phoenix LiveView web dashboard).

---

## 4. Target User

A **courier / driver** operating a vehicle, using their own Android or iOS phone,
often with one hand, in bright sunlight, on intermittent mobile data. Primary
needs: know if they're connected, know their next order, and complete it in as
few taps as possible.

---

## 5. Backend Contract (source of truth)

This app is a client of the existing FleetPulse backend. The contract below is
what the backend already implements; the app must speak it exactly.

### 5.1 Login & token issuance (REST) — **live**

A driver logs in with **phone + password** (provisioned by an operator, never
self-registered) to obtain a bearer token:

```
POST /driver/session          Content-Type: application/json
  request:  { "phone": "...", "password": "..." }
  201:      { "token": "...", "driver_id": 1, "expires_in": 604800 }
  401:      { "error": "invalid_credentials" }
  400:      { "error": "phone and password are required" }
```

- The token is a `Phoenix.Token`-signed value carrying the `driver_id`
  (`expires_in` = 604800 s = 7 days). Store it in secure storage.
- A wrong password and an unknown phone both return the **same** `401
  invalid_credentials` — no account enumeration by response or timing.
- There is no refresh token: when a token is rejected as expired, re-login.

### 5.2 Socket & join

- Endpoint: `ws://<host>/driver/websocket?token=<TOKEN>` (WSS in production).
- After connecting, the app joins the topic **`driver:<driver_id>`**, which must
  match the id inside the token, or the join is refused (`forbidden`).
- Joining starts server-side tracking and sets availability: **`busy` if the
  driver already holds an active order, otherwise `online`.** A reconnect
  mid-delivery is never reset to available.
- Immediately after a successful join the server pushes **exactly one**
  `active_order` event (see 5.4), so the app can restore any in-flight order
  without waiting for a fresh assignment.

### 5.3 Messages the app SENDS (channel `push`)

| Event | Payload | Success reply | Error replies (`{reason}`) |
| :--- | :--- | :--- | :--- |
| `ping` | `latitude`, `longitude`, `recorded_at` (ISO8601), optional `speed_kmh`, `bearing_deg` | `ok` | `invalid_telemetry`, `not_found` |
| `status` | `status`: `"online"` \| `"busy"` \| `"offline"` | `ok` | `invalid_status` |
| `pickup` | `order_id` | `ok` | `forbidden`, `invalid_transition`, `not_found` |
| `delivered` | `order_id` | `ok` | `forbidden`, `invalid_transition`, `not_found` |

Validation enforced server-side: latitude −90..90, longitude −180..180,
`speed_kmh` ≥ 0, `bearing_deg` 0..<360, `recorded_at` must be parseable ISO8601.
Invalid pings are rejected as a reply, not a disconnect — the app should surface
and drop them, never crash.

### 5.4 Messages the app RECEIVES (channel push from server)

| Event | Payload | When |
| :--- | :--- | :--- |
| `active_order` | `{ "order": <order fields> \| null }` | once, right after join |
| `order_assigned` | `id`, `status`, `weight_kg`, `pickup {latitude, longitude}`, `dropoff {latitude, longitude}`, `assigned_at` | on a fresh dispatch |
| `order_updated` | same order shape | on any lifecycle change from the server side (e.g. a dispatcher cancellation) |

The `order` object (in all three) has: `id`, `status`
(`assigned`/`picked_up`/`delivered`/`cancelled`), `weight_kg`,
`pickup {latitude, longitude}`, `dropoff {latitude, longitude}`, `assigned_at`.
On join the app should treat `active_order` as the source of truth: a non-null
order means restore that job (and expect `busy`); `null` means the driver is
free.

### 5.5 Phoenix Channel wire protocol

The backend speaks the Phoenix Channel protocol over the raw socket. Using
`web_socket_channel`, the app must implement the framing itself:

- Join with a `phx_join` frame on `driver:<id>`; expect a `phx_reply` with `status: "ok"`.
- Every message is `[join_ref, ref, topic, event, payload]` (v2 serializer).
- Send a **heartbeat** (`phoenix` topic, `heartbeat` event) roughly every 30 s or the server closes the socket.
- Correlate replies by `ref`.

> **Decision point:** implement this thin protocol layer over
> `web_socket_channel` (full control, already in `pubspec`), or adopt a
> `phoenix`-protocol Dart package. This PRD assumes a small in-house
> `ChannelClient` over `web_socket_channel`.

### 5.6 Disconnect semantics

On socket loss the backend marks the driver `offline` but **keeps their process
warm** — a reconnect within minutes preserves the last known position. The app
should reconnect aggressively and re-join the same topic.

---

## 6. Backend Dependencies — status

Building this app surfaced two gaps in the backend; both are now **closed**.
This is the intended loop: mobile reveals the gap, the backend fills it, this
document is re-locked.

1. **Driver login / token issuance — ✅ DONE.** `POST /driver/session` accepts
   phone + password and returns a signed `DriverToken` (see 5.1). Drivers are
   provisioned by an operator, who sets the password; there is no self-signup.
2. **Active order on (re)connect — ✅ DONE.** The channel pushes one
   `active_order` event right after join (see 5.2/5.4), and sets the driver
   `busy` rather than `online` when an order is in flight, so a reconnecting
   driver never loses their job or gets double-assigned.
3. **Token expiry handling — app-side, open.** Tokens last 7 days
   (`expires_in`); there is no refresh token by design. The app must detect an
   `expired`/`invalid` token (socket-connect refusal or a `401` from
   `/driver/session`) and route back to login.

For local development a token can also be minted manually with
`FleetPulseWeb.DriverToken.sign(driver_id)` in an `iex -S mix` session and pasted
into a dev-only config screen — useful before real credentials are seeded.

---

## 7. Core Features

### 7.1 Authentication & session

- Driver logs in (credentials → driver token). Token stored in secure storage.
- Auto-login on launch if a valid token exists; route straight to tracking.
- On `expired`/`invalid` token, clear session and return to login.

### 7.2 Connectivity

- Connect and join on going on-duty; show a clear connection indicator
  (connected / connecting / reconnecting / offline).
- Exponential-backoff reconnect with heartbeat keep-alive.
- Queue nothing critical on the client: the backend samples position, so a
  dropped ping is acceptable; a dropped **lifecycle action** (pickup/delivered)
  must be retried until acknowledged.

### 7.3 Live location streaming

- Acquire location permission (foreground **and** background/"always").
- Emit a ping every 3–5 s while on duty, throttled to avoid redundant sends.
- Continue while the screen is off / app backgrounded (foreground service on
  Android, background location mode on iOS).
- Stamp each ping with the device clock as `recorded_at` (ISO8601, UTC).

### 7.4 Availability status

- Toggle **online ⇄ offline**. Going offline stops streaming and informs the
  server. `busy` is set by the server on assignment, reflected read-only in the UI.

### 7.5 Order handling

- Receive `order_assigned` → show an order card (pickup & dropoff, weight).
- One-tap **"Picked up"** (enabled when assigned) → `pickup`.
- One-tap **"Delivered"** (enabled when picked up) → `delivered`; on success the
  driver returns to available.
- Receive `order_updated` (e.g. cancellation) → update or dismiss the card.
- "Navigate" opens pickup/dropoff in the phone's map app (deep link).

---

## 8. Screens (map to sealed `AppRoute`s)

Per the project's Navigator 2.0 + sealed-class routing convention:

| Route | Screen | Purpose |
| :--- | :--- | :--- |
| `SplashRoute` | Splash | Bootstrap DI, check token, decide next route |
| `LoginRoute` | Login | Driver credentials → token (dev: manual token entry) |
| `TrackingRoute` | Tracking (home) | Connection state, online toggle, live position, GPS running |
| `OrderRoute(order)` | Active order | Pickup/dropoff detail, pickup/deliver actions, navigate |

Each route is a subclass of `sealed class AppRoute`; screens are `StatelessWidget`
reading a ViewModel via `context.watch`; navigation intent flows through
`AppRouterState` — never `Navigator.pushNamed` or `BuildContext` in a ViewModel.

---

## 9. Technical Architecture

Follows `CLAUDE.md` (Enterprise Flutter, MVVM, strict type-safety).

### 9.1 Layers

```
UI (StatelessWidget)  ──watch──▶  ViewModel (ChangeNotifier, @injectable)
                                        │ calls
                                        ▼
                               Services (@injectable, get_it)
                     ┌───────────────┬───────────────┬──────────────┐
              AuthService      ChannelClient    LocationService   TokenStore
           (login, refresh)  (WS + Phoenix     (geolocator,     (secure
                              protocol)         permissions)     storage)
```

### 9.2 Services (singletons via `get_it` / `injectable`)

- **`ChannelClient`** — wraps `web_socket_channel`; connect, join `driver:<id>`,
  `push(event, payload)` with ref correlation, heartbeat timer, backoff
  reconnect, and a broadcast `Stream` of inbound events (`order_assigned`,
  `order_updated`) plus a `ConnectionStatus` stream.
- **`LocationService`** — `geolocator` position stream + permission handling;
  emits throttled `TelemetryPing`s; manages the background/foreground service.
- **`AuthService`** — login and logout via `POST /driver/session` (5.1) and
  `TokenStore`; on an expired/invalid token, clears the session and signals a
  re-login (no refresh token).
- **`TokenStore`** — `flutter_secure_storage` wrapper for the driver token.
- **`TelemetryService`** (optional) — bridges `LocationService` → `ChannelClient`,
  applying the 3–5 s cadence and retry policy.

### 9.3 ViewModels (`ChangeNotifier`, `@injectable`)

- **`LoginViewModel`** — credential entry, calls `AuthService`, routes on success.
- **`TrackingViewModel`** — subscribes to connection + position streams; owns the
  online/offline toggle; starts/stops streaming.
- **`OrderViewModel`** — holds the active order; exposes `pickup()` /
  `delivered()`; retries lifecycle actions until acknowledged.

ViewModels never touch `BuildContext`; navigation goes through injected
`AppRouterState`.

### 9.4 Models (`freezed`, immutable)

- `DriverSession { int driverId, String token }`
- `TelemetryPing { double latitude, longitude, DateTime recordedAt, double? speedKmh, bearingDeg }`
- `Order { int id, OrderStatus status, int weightKg, LatLng pickup, dropoff, DateTime assignedAt }`
- `enum ConnectionStatus { disconnected, connecting, connected, reconnecting }`
- `enum OrderStatus { pending, assigned, pickedUp, delivered, cancelled }`

All JSON (de)serialization uses `freezed` + `json_serializable`; keys map to the
backend's snake_case payloads.

---

## 10. Additional Packages

Beyond the architecture stack already mandated in `CLAUDE.md`
(`provider`, `get_it`, `injectable`, `freezed`) and `web_socket_channel`:

| Package | Purpose |
| :--- | :--- |
| `geolocator` | GPS position stream + permissions |
| `permission_handler` | Location (incl. "always") + notification permissions |
| `flutter_secure_storage` | Store the driver token |
| `json_serializable` / `json_annotation` | Payload (de)serialization |
| `flutter_foreground_task` *(Android)* | Keep streaming with the screen off |
| `url_launcher` | Deep-link pickup/dropoff into a maps app |

A visible map (`flutter_map` or `google_maps_flutter`) is **optional for V1** —
the driver mainly needs the order and connection state, not a self-view map.

---

## 11. Non-Functional Requirements

- **Battery:** location at balanced accuracy; no ping when stationary beyond a
  small threshold; single persistent socket, no polling.
- **Resilience:** reconnect within seconds of signal return; lifecycle actions
  are idempotent and retried; the app never loses an assigned order to a
  disconnect.
- **Background execution:** compliant foreground service (Android) and
  background location mode (iOS), with the required permission prompts and
  store-review justifications.
- **Type safety:** no dynamic maps in domain code — every payload parsed into a
  `freezed` model at the boundary.
- **Security:** token in secure storage only; WSS in production; never log the
  token or precise coordinates in release builds.

---

## 12. Milestones

| Phase | Deliverable |
| :--- | :--- |
| **M0 — Skeleton** | DI + routing scaffolding, models (`freezed`), splash → login → tracking navigation. |
| **M1 — Channel** | `ChannelClient` over `web_socket_channel`: connect, join, heartbeat, reconnect, ref-correlated replies. Prove `ping` with a manually minted token. |
| **M2 — Location** | `LocationService` streaming real GPS → `ping` every 3–5 s, foreground; connection indicator + online toggle. |
| **M3 — Orders** | Receive `order_assigned`/`order_updated`; order screen; `pickup`/`delivered` with retry. |
| **M4 — Background & auth** | Background streaming; real driver login via `POST /driver/session`; expired-token → re-login handling. |
| **M5 — Hardening** | Battery tuning, reconnect edge cases, permission flows, store-readiness. |

---

## 13. Success Metrics

- **Connectivity:** driver stays effectively connected ≥ 99% of on-duty time on normal mobile data.
- **Freshness:** dispatcher dashboard reflects a driver's position within ~1 s of a ping.
- **Reliability:** zero lost lifecycle actions (every pickup/delivered eventually acknowledged).
- **Battery:** < ~5% battery/hour attributable to the app during active tracking (device-dependent target).

---

## 14. Out of Scope (restated)

Navigation SDKs, payments/earnings, chat, ratings, driver onboarding/registration,
and the dispatcher UI. This app is the driver's telemetry-and-orders terminal —
nothing more, and deliberately so.
