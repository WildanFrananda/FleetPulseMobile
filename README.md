# 📱 Kinetix Courier Mobile App (`kinetix-courier-mobile`)

Cross-platform Flutter mobile application (iOS & Android) managed via **FVM (Flutter Version Management)** designed for delivery couriers to accept dispatches, capture Proof of Delivery (POD), cache offline GPS telemetry in Hive DB, and stream location updates back to `kinetix-matching-service`.

---

## 🏛️ Resolved Audit Upgrades & Production Hardening

1. **Real Proof of Delivery (POD) Camera & Signature Canvas**:
   - Integrated `image_picker` for real device camera photo capture (`Capture Photo`) and `signature` package for an interactive digital signature drawing canvas modal (`Add Signature`), eliminating fake hardcoded strings.
2. **Offline Hive Database GPS Telemetry Caching**:
   - Implemented `HiveTelemetryDb` helper powered by `hive` and `hive_flutter`. Location pings recorded during network drops (in tunnels/basements) are cached locally in Hive key-value storage and automatically flushed when the WebSocket connection is re-established.
3. **Single Source of Truth Identity & Gateway Integration**:
   - Updated `AppConfig.httpBase` to point to OpenResty API Gateway (`http://10.0.2.2:8080`) and redirected `DriverApi.login` to `@POST('/api/v1/auth/login')`.
4. **FVM SDK & Clean Static Analysis**:
   - Project environment managed strictly via FVM (`.fvmrc`). Executed `fvm flutter analyze lib/` ➔ **`No issues found!`**.

---

## 📂 Repository Directory Structure

```
kinetix-courier-mobile/
├── .fvm/                               # Flutter Version Management Configuration
├── lib/
│   ├── config/
│   │   └── app_config.dart             # Environment & Gateway Config (:8080)
│   ├── models/                         # Data Models & Freezed Annotations
│   ├── repositories/                   # Domain Repositories
│   │   └── telemetry_repository_impl.dart # Telemetry Streaming & Hive Caching
│   ├── services/
│   │   ├── auth/
│   │   │   └── driver_api.dart         # Retrofit API Gateway Client
│   │   └── offline/
│   │       └── hive_telemetry_db.dart  # Hive Offline Ping Storage
│   └── ui/
│       ├── screens/
│       │   └── order_screen.dart       # Order Details & POD Screen
│       └── widgets/
│           └── order/order_view.dart   # Camera & Signature Modal UI
├── pubspec.yaml                        # Dependencies & Plugins
└── README.md
```

---

## ⚡ Local Execution Guide (FVM)

```bash
# 1. Fetch Flutter Dependencies via FVM
fvm flutter pub get

# 2. Run Static Code Analysis via FVM
fvm flutter analyze lib/

# 3. Launch App on Emulator / Device via FVM
fvm flutter run
```
