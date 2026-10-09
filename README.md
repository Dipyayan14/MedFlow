# MedFlow

Open-source hospital management system: a Flutter desktop app with a Laravel REST API, role-based staff login, Windows Hello biometric unlock, and OTP password reset.

> **Status:** learning project. See [Known limitations](#known-limitations) before using it anywhere real.

## Features
- Staff sign-up, login, logout, and password reset (email, OTP, new password)
- Five staff roles: staff, doctor, nurse, duty desk, admin
- Role-based navigation, so each role sees only its own tabs
- Biometric quick unlock with Windows Hello, using a separate long-lived device pass
- Doctor dashboard and patient queue screens (sample data for now)

## Tech stack
| Layer | Technology |
|---|---|
| Frontend | Flutter / Dart (Windows desktop) |
| Backend | Laravel (PHP) with Sanctum token auth |
| Database | MySQL |

## Getting started

### Backend
```bash
cd backend
composer install
copy .env.example .env
php artisan key:generate
```
Create a MySQL database named `hms`, check the `DB_*` values in `.env`, then:
```bash
php artisan migrate
php artisan serve
```
You may need to enable these extensions in `php.ini`: `zip`, `fileinfo`, `pdo_mysql`.

### Frontend
```bash
cd stitch_medflow_hospital_management_app
flutter pub get
flutter run -d windows
```
The app expects the API at `http://localhost:8000/api`. Windows Developer Mode must be on for Flutter plugins.

## Known limitations
- This is a learning project. It uses **no real patient data** and is **not certified or audited** for clinical use.
- Password-reset OTPs are written to Laravel's log in the local environment. Email sending is not built yet.
- Dashboards and patient queues show sample data. Patient and appointment tables are not built yet.
- Role restrictions are enforced in the app only. Server-side role checks are still to do.

## Contributing
Contributions are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License
MIT. See [LICENSE](LICENSE).
