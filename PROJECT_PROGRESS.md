# MSc Clothing E-commerce — Progress Checkpoint

Last updated: 7 August 2026

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
- GDPR-friendly account deletion with secure reauthentication and removal of the user's profile, favourites, cart, orders, and Firebase Authentication account
- Saved delivery address shared between My Details and Checkout
- Transactional Cloud Function for one-time product stock reservation when an order is created
- Automatic cancellation metadata for invalid orders or insufficient stock

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

## Next step

Audit and improve unfinished screens and navigation:

1. Identify legacy placeholder screens and broken or confusing navigation links.
2. Connect the Address screen to the saved Firestore delivery address.
3. Make the customer navigation and Account options consistent.
4. Run the app and test the revised customer journey.
