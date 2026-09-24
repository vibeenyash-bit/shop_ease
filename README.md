# ShopEase

A simple Flutter shopping app with Firebase login and Firestore orders.
Prices are in Indian Rupees (₹). It keeps working offline.

## Features

- Login / create account (Firebase email + password)
- Product list with search, product details
- Add to cart, change quantity, total in ₹
- Checkout with name, mobile, address, pincode (Cash on Delivery)
- Order history (Pending / Confirmed)
- Loading, empty and error screens

## Offline scenarios

| Scenario | How |
|---|---|
| Persistent cart | Cart is saved on the phone on every change (`lib/state/cart_state.dart`). |
| Offline orders | An order is saved on the phone first as **Pending**, then sent (`lib/state/order_state.dart`). |
| Sync | Pending orders are sent when internet returns, when the app opens or resumes, on pull-to-refresh, and every 30 seconds. |
| No duplicates | Each checkout has one order id. It is the Firestore document id, and the order is only written if it doesn't exist (`lib/services/order_api.dart`). The Place order button is disabled while sending. |
| API failures / timeouts | All calls have timeouts. Errors show a short message; failed orders stay Pending and retry. Products fall back to the last saved list. |
| App restart | Login, cart and orders are all restored. |

Products come from a mock API: `assets/data/products.json`. Product photos are
loaded from the internet and cached on the phone.

## Project structure

```
lib/
  main.dart, app.dart
  models/     product, cart_item, order
  services/   storage, connectivity, product_api (mock), order_api (Firestore)
  state/      auth, products, cart, orders
  screens/    login, product list, product detail, cart, checkout, orders
  widgets/    loading / empty / error views, product image, quantity buttons
```

## Setup

1. Firebase Console → Authentication → enable **Email/Password**.
2. Firebase Console → Firestore → create a database, then paste `firestore.rules` into the Rules tab and publish.
3. Run:
   ```bash
   flutter pub get
   flutter run
   ```

## Tests

```bash
flutter test
```
