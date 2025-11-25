# BSEB Connect - Architecture Documentation

## Overview
Official mobile app for Bihar School Examination Board (BSEB) students (Class 9-12).

**Tech Stack**: Flutter 3.x | GetX | Dio | Firebase
**Languages**: Hindi + English
**Platform**: iOS & Android

---

## ⚠️ CRITICAL ARCHITECTURAL STATE

> [!WARNING]
> **"Shadow Architecture" Detected**
> The codebase currently contains two parallel architectures:
> 1.  **Legacy (Active)**: The UI screens (`lib/view_controllers/`) use inline `Dio` calls, manual state management (`setState`), and raw `Map<String, dynamic>` for data. This code uses **HTTP** (insecure).
> 2.  **Modern (Unused)**: A new set of `Controllers`, `Services`, and `Models` exists in `lib/controllers`, `lib/services`, and `lib/models`. This code uses **HTTPS** (secure) and proper state management, but is **NOT connected to the UI**.

**Immediate Goal**: Refactor UI screens to use the Modern architecture.

---

## Project Structure

### Core Files
| File | Purpose | Status |
|------|---------|--------|
| `lib/main.dart` | App entry point, Firebase initialization | ✅ Active |
| `lib/translation.dart` | Localization | ✅ Active |

### Modern Architecture (Currently Unused)
These files represent the target architecture but are not yet integrated.

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `lib/services/` | Centralized API handling | `api_service.dart` (Uses HTTPS) |
| `lib/controllers/` | State management (GetX) | `auth_controller.dart`, `notification_controller.dart` |
| `lib/models/` | Type-safe data models | `student_model.dart`, `notification_model.dart` |

### Legacy UI (`lib/view_controllers/`)
These screens contain mixed UI and business logic. They need refactoring.

| Screen | Issues | Refactoring Priority |
|--------|--------|----------------------|
| `LoginScreen.dart` | Inline API calls, HTTP, manual Prefs | 🔴 High |
| `SignUpScreen.dart` | Inline API calls, HTTP | 🔴 High |
| `NotificationScreen.dart` | Inline API calls, HTTP, no Model usage | 🟡 Medium |
| `EditProfileScreen.dart` | Large file (1000+ lines), mixed logic | 🟡 Medium |

---

## API & Network

### Current State (Legacy)
- **Base URL**: `http://registrationapi.bsebmarks.in/api/` (Insecure HTTP)
- **Implementation**: Inline `Dio` calls in Widgets.
- **Error Handling**: Scattered `try-catch` blocks with manual SnackBars.

### Target State (Modern)
- **Base URL**: `https://registrationapi.bsebmarks.in/api/` (Secure HTTPS)
- **Implementation**: `ApiService` class.
- **Error Handling**: Centralized `ErrorHandler`.

---

## Known Bugs & Issues

1.  **Security Risk**: Active App uses HTTP for all calls (Login, Registration, Data).
2.  **Code Duplication**: API logic repeated across every screen.
3.  **State Desync**: `LoginScreen` updates SharedPreferences manually; `AuthController` is unaware of login state changes.
4.  **Hardcoded URLs**: URLs are hardcoded in `Constant.dart` (HTTP) and `ApiService.dart` (HTTPS).
5.  **Missing iOS Config**: Firebase is not configured for iOS, causing potential crashes if not caught.

---

## Refactoring Roadmap

1.  **Phase 1: Auth & Core**
    - [ ] Update `LoginScreen` to use `AuthController`.
    - [ ] Update `SignUpScreen` to use `AuthController`.
    - [ ] Verify HTTPS works for all Auth endpoints.

2.  **Phase 2: Data & Models**
    - [ ] Update `NotificationScreen` to use `NotificationController`.
    - [ ] Replace `Map` usage with `StudentModel` in Profile screens.

3.  **Phase 3: Cleanup**
    - [ ] Remove inline `Dio` calls.
    - [ ] Remove unused constants from `Constant.dart`.
