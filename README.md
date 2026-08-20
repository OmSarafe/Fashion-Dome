# Fashion Dome

Fashion Dome is a Flutter clothing e-commerce application developed as an MSc
Computer Science project. It demonstrates a complete customer and administrator
shopping workflow backed by Firebase, with test payments through Stripe and
delivery-address selection through Google Maps.

The application targets Android and uses a responsive Material interface that
supports small phones, standard phones, tablets, portrait and landscape layouts,
and light and dark themes.

## Main features

### Customer application

- Email/password registration, login, password reset and persistent sessions
- Google Sign-In through Firebase Authentication
- Editable customer profile, delivery address and notification preferences
- GDPR-friendly account deletion with reauthentication and data removal
- Live product catalogue with categories, search, sorting and filters
- Product details, stock information, sizes, ratings and customer reviews
- Persistent favourites and shopping cart
- Address autocomplete, manual address entry and Google Maps location selection
- Cash-on-delivery and Stripe test-card checkout
- Order history, order details, status tracking and customer cancellation
- Stripe refund handling for eligible cancelled orders
- Firebase Cloud Messaging notifications for order and promotional updates

### Administrator application

- Role-protected administrator navigation
- Sales, customer, order, product and low-stock dashboard metrics
- Product and category creation, editing and deletion
- Firebase Storage product-image upload
- Inventory levels and stock-movement history
- Order-status management
- Promotional and new-product notifications

## Technology stack

- Flutter and Dart
- Provider state management
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Storage
- Firebase Cloud Messaging and local notifications
- Firebase Cloud Functions (Node.js 20)
- Stripe test-mode Payment Sheet
- Google Maps, Places autocomplete and geocoding
- Cached network images

## Architecture

The Flutter application is organised by responsibility:

```text
lib/
├── models/       Domain models for products, carts, orders, reviews and users
├── providers/    Application state and theme state
├── screens/      Customer, authentication, checkout and administrator screens
├── services/     Firebase, Stripe, image, notification and persistence services
├── utils/        Currency, validation, cart and responsive-layout helpers
├── widgets/      Reusable product, form, image and review components
└── main.dart     Firebase initialization, providers, themes and app startup
```

Cloud Functions in `functions/index.js` perform trusted operations including
payment creation and verification, refunds, inventory reservation, review
submission and push-notification delivery. Firestore and Storage access is
restricted by the rules in `firestore.rules` and `storage.rules`.

## Data model

The main Firestore collections are:

- `users/{userId}` — profile, role, address, preferences and FCM tokens
- `users/{userId}/favorites/{productId}` — saved products
- `users/{userId}/cart/{cartItemId}` — persistent cart entries
- `products/{productId}` — catalogue, pricing, images, sizes and inventory
- `products/{productId}/reviews/{userId}` — verified customer reviews
- `products/{productId}/stockMovements/{movementId}` — inventory audit trail
- `categories/{categoryId}` — administrator-managed catalogue categories
- `orders/{orderId}` — order items, totals, payment and delivery status

Monetary values are stored as integer pence to avoid floating-point rounding
errors.

## Prerequisites

- Flutter SDK compatible with Dart `>=3.5.3 <4.0.0`
- Android Studio and an Android SDK/device with API 24 or newer
- Node.js 20 and npm
- Firebase CLI
- A Firebase project
- Google Maps Platform and Stripe test-mode accounts

## Local setup

1. Clone the repository and install Flutter packages:

   ```powershell
   git clone https://github.com/Gaux29/Ecommerce.git
   cd Ecommerce
   flutter pub get
   ```

2. Register an Android application in Firebase using the package identifier from
   `android/app/build.gradle`. Download `google-services.json` and place it at:

   ```text
   android/app/google-services.json
   ```

3. Enable Email/Password and Google providers in Firebase Authentication. Add
   the Android debug and release SHA fingerprints to the Firebase application.

4. Create Firestore and Cloud Storage, then deploy the repository rules:

   ```powershell
   firebase login
   firebase use msc-clothing-ecommerce
   firebase deploy --only "firestore:rules,storage"
   ```

5. Enable Maps SDK for Android, Places API and Geocoding API. Add a restricted
   Android Maps key to `android/local.properties`:

   ```properties
   MAPS_API_KEY=YOUR_RESTRICTED_ANDROID_MAPS_KEY
   ```

   Restrict the key to the Android package name and signing SHA fingerprints.

6. Install Cloud Function dependencies and set Stripe test secrets. Never place
   Stripe secret keys in Flutter source code or commit them to Git:

   ```powershell
   npm install --prefix functions
   firebase functions:secrets:set STRIPE_SECRET_KEY
   firebase functions:secrets:set STRIPE_PUBLISHABLE_KEY
   firebase deploy --only functions
   ```

7. Start an emulator or connect an Android device, then run:

   ```powershell
   flutter run
   ```

## Administrator access

New accounts are always created with the `customer` role. Administrator access
must be assigned deliberately by changing the trusted user's Firestore `role`
field to `admin`. Do not publish administrator credentials in this repository.

## Quality checks

Run these checks before committing or creating a release:

```powershell
flutter analyze
flutter test
```

The automated suite covers authentication validators, cart calculations, role
handling, customer/admin navigation, order lifecycle rules and responsive-layout
breakpoints. Firebase integration, payment, notification and release flows must
also be verified against the configured test project.

## Security and privacy

- The project privacy notice is available in
  [PRIVACY_POLICY.md](PRIVACY_POLICY.md), with a GitHub Pages-ready copy in
  `docs/privacy-policy.html` and an equivalent page inside the app.
- Customer and administrator permissions are enforced by Firebase rules and
  trusted Cloud Functions, not only by the interface.
- Stripe handles card details; the application stores payment references rather
  than card numbers.
- Product uploads are restricted by role, file type and size.
- Customers can view/edit their profile and permanently delete their Firebase
  account and associated application data.
- API keys and signing material must remain in ignored local configuration or
  managed Firebase secrets.

## Release status

The functional MSc prototype is complete and tested in Firebase/Stripe test
mode. Android uses the production application ID `com.omsarafe.fashiondome`.
Release signing is configured with a separately backed-up upload key, its
Firebase/Maps fingerprints are registered, and a signed Android App Bundle has
been verified. Before public distribution, publish the privacy policy, complete
the store listing and data-safety declaration, run closed-device testing, and
either retain clearly labelled test payments or complete the production payment
onboarding and compliance checks.
