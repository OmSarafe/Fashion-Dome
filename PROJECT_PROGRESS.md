# MSc Clothing E-commerce — Progress Checkpoint

Last updated: 29 August 2026

## Completed

- Firebase Android configuration and Firebase initialization
- Email/password registration, login, password reset, logout, and session routing
- One-time onboarding using Shared Preferences
- Firestore user profiles with customer/admin role-based access
- Secure Firestore rules for products, users, favourites, carts, and orders
- Live Firestore product catalogue with search and category filtering
- Persistent favourites and cart
- Checkout, order creation, customer order history, and admin order-status updates
- GBP/pence currency migration and formatting
- Same-app admin dashboard with product and order management
- Firebase Storage bucket and secure Storage rules
- Admin product-image selection and upload to Firebase Storage
- Uploaded product images shown in admin, cart, orders, product details, and Discover
- Google Sign-In provider, Android SHA fingerprint, updated Firebase configuration, and working Google authentication
- First-time Google users receive a Firestore customer profile without overwriting existing admin roles
- My Details screen connected to Firestore with prefilled name/email and editable name, phone, date of birth, and gender
- My Details changes persist in Firestore and update the Account screen
- GDPR-friendly account deletion with secure reauthentication, removal of the user's profile, favourites, cart, reviews and Firebase Authentication account, plus anonymisation of historical orders
- Saved delivery address shared between My Details and Checkout
- Transactional Cloud Function for one-time product stock reservation when an order is created
- Automatic cancellation metadata for invalid orders or insufficient stock
- Trusted Cloud Function order creation for cash-on-delivery and Stripe orders
- One-order-per-Payment-Intent enforcement with automatic compensating refunds
- Backend account deletion with order anonymisation and rating reconciliation
- Backend product deletion including Storage images and nested Firestore data
- Chunked currency migration beyond Firestore's single-batch limit
- Local-only, per-user My Fit Profile with height, chest, waist and preferred-fit settings
- Explainable size recommendations for T-shirts, shirts, jackets and jeans
- Automatic selection of the closest available recommended product size
- Fit Profile validation, deletion, privacy notice and sizing disclaimer
- Fit Profile removal during account deletion and isolation between users sharing a device
- Completed Help Center, FAQ and Customer Service screens with working navigation
- Signup access to the current Privacy Policy without unsupported Terms or cookie claims
- Defensive product-size validation and safe handling of products with no available sizes
- Admin-only starter-catalogue initialization after the user's role is confirmed
- Privacy Policy updated to document local Fit Profile processing and retention

## Verified manually

- Email account creation and login
- Firestore user document creation
- Favourites and cart persistence
- Order placement and order-status changes
- Admin add/edit/delete product workflow
- Firebase Storage image upload and image display on Discover
- Google Sign-In and Google profile display
- My Details name and email prefill
- My Details save, reopen, and persistence
- Account-deletion warning and cancellation
- Complete deletion of a disposable email/password account, returning the user to Login
- Firebase Messaging package installed and Android notification receiver compiled successfully
- Signed-in device FCM token saved and verified in the Firestore user profile
- Second-generation Cloud Function deployed in europe-west2 for automatic order-status notifications
- End-to-end order notification verified: Firestore status update triggered the Cloud Function and reached the customer app
- Checkout address saved and prefilled when Checkout was reopened
- Stock reservation verified: a newly placed order was marked `reserved` and product stock reduced exactly once
- My Fit Profile save and confirmation verified on the Android emulator
- T-shirt recommendation verified as size M for a 100 cm chest and regular fit
- Recommended size automatically selected and retained when added to the cart
- Jeans recommendation verified as size 32 for an 82 cm waist
- Full Flutter automated test suite passed: 44 tests
- Cloud Functions trusted-order logic suite passed: 5 tests
- Flutter static analysis passed with no errors after the final application audit

## Submission status

The functional Android prototype and release packaging are complete. Remaining
work is submission evidence, the formal testing report, dissertation content,
demonstration video, presentation and viva preparation.
