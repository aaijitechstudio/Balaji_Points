## Multi‑Tenant SaaS Plan for Balaji Points

### 1. Goal

Transform the existing single‑store Balaji Points app into a **multi‑tenant SaaS** platform where:

- Each hardware store (tenant) has **its own isolated data**.
- Carpenters and admins **select their store** (or enter a store code) at sign‑up / sign‑in.
- Existing Balaji users continue to work with minimal friction.

> Note: This plan is written so you can start with one Firebase project per store (strong isolation) but can also work with a single shared project + `storeId` flags later if desired.

---

### 2. Core Concepts

#### 2.1 Store (Tenant)

Introduce a first‑class `Store` entity:

- Fields:
  - `id` (e.g. `balaji_main`, `xyz_plywood`)
  - `name` (e.g. `Shri Balaji Plywood & Hardware`)
  - `code` – a short, human‑typed **store code** (e.g. `BALAJI01`)
  - `firebaseConfig` – app config object for that store’s Firebase project:
    - `apiKey`, `appId`, `projectId`, `messagingSenderId`, `storageBucket` etc.
  - `isActive` (bool)
  - `createdAt`, `updatedAt`

Where to store:

- In a **master Firebase project**:
  - `stores/{storeId}` = one doc per store.
  - This project is used only before we know which store to connect to.

#### 2.2 Per‑Store Firebase Projects

For strong data isolation:

- Each store gets **its own Firebase project**, with its own:
  - Firestore DB
  - Authentication
  - Storage
  - Cloud Messaging
- Within each project, the schema looks like your current Balaji app:
  - `users` – carpenters & admins for that store
  - `bills`
  - `user_points`
  - `offers`
  - `daily_spins`, `daily_prize_winners`
  - other collections you already use

This means:

- No cross‑store data leakage is possible at DB level.
- Operationally, each tenant is cleanly separated (billing, quotas, backups).

---

### 3. App Flow Changes

#### 3.1 Startup Flow

Current:

- App launches → Splash → Checks session → Login/Pin or Home (single store).

New:

1. **Splash** (unchanged visually).
2. **Store selection step** (new screen):
   - If `selected_store_id` is **not set** in local storage → show this screen.
   - Options:
     - **Store code input**: user types `BALAJI01`, `XYZ01`, etc.
     - (Optional) Store list search if you want a browsing UX.
3. App calls **master project**:
   - Looks up `stores` by `code` or `id`.
   - If found and `isActive == true`, loads `firebaseConfig`.
4. App **initialises Firebase** with that store’s `firebaseConfig`.
5. Persist the selection in `SessionService`:
   - `selected_store_id`, `selected_store_name`, `selected_store_code`.
6. Continue existing auth logic:
   - If already logged in for that store → Home.
   - Else → Phone / PIN login flow.

On subsequent launches:

- If `selected_store_id` is present:
  - Skip Store selection.
  - Initialise Firebase with that store’s config immediately.
  - Then proceed to login/session check like today.

#### 3.2 Switching Store

Future enhancement:

- In profile/settings, allow “Switch Store”:
  - Logout current session.
  - Clear `selected_store_id`.
  - Navigate back to Store selection screen.

---

### 4. Session & Auth Changes

#### 4.1 SessionService

Extend `SessionService` with store awareness:

- New keys:
  - `selected_store_id`
  - `selected_store_name`
  - `selected_store_code`
- Save these when user selects a store.
- Clear them on logout (same time you clear phone/userId).

This guarantees:

- Every authenticated session is always tied to **one specific store**.

#### 4.2 Auth Behavior Per Store

- A phone number can be reused across stores:
  - `Store A` can have phone `+91 9xxxxxxx01`.
  - `Store B` can also have the same phone as a separate account.
- Login flow:
  - User picks store first.
  - Phone / PIN verification is done **only against that store’s Firebase project**.

---

### 5. Data Model Per Store

In each store’s Firebase project (tenant DB):

- Keep your current structure:

  - `users/{phone}`:
    - `role` = `carpenter` or `admin`
    - `totalPoints`, `tier`, `status`, `pinHash`, `pinSalt`, etc.
  - `bills/{billId}`:
    - Linked to user `phone`/`userId`.
  - `user_points/{userId}`:
    - `totalPoints`, `tier`, `pointsHistory`.
  - `offers`, `daily_spins`, `daily_prize_winners`, etc.

No extra `storeId` fields are strictly required in this mode, because each project is already single‑tenant.

> If you ever move back to a **single Firebase project** for all stores:
> - Add `storeId` to all docs.
> - Every query must filter by `storeId`.
> - Rules must ensure users only access docs with their `storeId`.

---

### 6. Migration Plan for Existing Balaji Users

#### 6.1 Treat Current Project as “Balaji Store”

- Create a new **store record** in the master project:

  - `stores/balaji_main`:
    - `name`: `Shri Balaji Plywood & Hardware`
    - `code`: `BALAJI01`
    - `firebaseConfig`: current app’s Firebase config
    - `isActive`: true

- Your existing Firebase project **becomes the DB for `balaji_main`**.

#### 6.2 Existing Sessions

- After app update:
  - On first launch, `selected_store_id` will be empty.
  - You can:
    - Either show Store selection and let Balaji users enter `BALAJI01`.
    - Or do a **one‑time shortcut**:
      - If phone is already present in current `SessionService`, default them to `balaji_main` and save that store automatically.

#### 6.3 Existing Data

- No data migration is required if you:
  - Keep Balaji’s data in the current Firebase project.
  - Treat that project as the tenant DB for `balaji_main`.

Optionally (for future single‑project mode):

- Add `storeId: 'balaji_main'` to:
  - `users`, `bills`, `user_points`, `offers`, etc.

---

### 7. Onboarding a New Hardware Store

For each new tenant (store):

1. **Create Firebase project**
   - Enable:
     - Firestore
     - Authentication
     - Storage
     - Cloud Messaging

2. **Register mobile apps**
   - Add Android (and iOS) apps to this Firebase project.
   - Note the config values.

3. **Seed minimal data**
   - Create at least one `admin` user doc in `users`.
   - Optionally create some default offers or settings.

4. **Create store doc in master project**
   - `stores/{storeId}` with:
     - `name`
     - `code` (unique)
     - `firebaseConfig`
     - `isActive: true`

5. **Distribute store code**
   - Give the store admin their code (e.g. `XYZ01`).
   - They install app, select/enter code, then login as admin.
   - They can onboard carpenters from there.

---

### 8. Code Refactor Plan (Guidance)

#### 8.1 Centralize Firebase Initialization

Create a utility/service, e.g. `FirebaseEnvironmentService`:

- Responsibilities:
  - Know **current store** from `SessionService`.
  - Initialize Firebase with correct config.
  - Allow re‑initialization if user switches store.

Usage guidance:

- Replace all naked `FirebaseFirestore.instance` calls with something that:
  - Either uses the default app after proper initialization, or
  - Uses a specific `FirebaseApp` stored in this service.
- For now, a **single default app** per launch is fine:
  - Initialize when store is chosen.
  - Don’t change store while logged in.

#### 8.2 Store Selection Screen

Add a new screen, e.g. `StoreSelectPage`:

- UI:
  - Text input: “Enter Store Code”.
  - Button: “Continue”.
- Behavior:
  - On submit:
    - Call master project → `stores` collection:
      - `where('code', isEqualTo: enteredCode)`.
    - If found:
      - Save store in `SessionService`.
      - Initialize Firebase for that store.
      - Navigate to login or home (depending on session).
    - If not found:
      - Show error: “Store code not recognized. Please check with your hardware store.”

#### 8.3 Splash / Routing Logic

Update `SplashPage` / initial router guard:

- Steps:
  1. Check `SessionService.selectedStoreId`.
  2. If null → route to `StoreSelectPage`.
  3. If not null:
     - Initialize Firebase with that store’s config.
     - Then run current session checks (`isLoggedIn`, role, etc.).

---

### 9. Data & Security Considerations

#### 9.1 Firestore Rules Per Store Project

Each store project will have its own rules, but they can share the same template:

- Ensure:
  - Only authenticated users can read/write.
  - Role checks (`admin` vs `carpenter`) are enforced for admin operations.

Because each project is single‑tenant, you **don’t** need `storeId` checks inside rules there.

#### 9.2 Backups & Monitoring

For each Firebase project:

- Enable automatic Firestore backups (using Google Cloud backup or scheduled exports).
- Keep a simple internal document or admin dashboard:
  - List of stores with:
    - Total users
    - Total points issued
    - Last bill date

This helps you see usage per store and catch anomalies.

---

### 10. Recommended Implementation Order

To reduce risk and keep app stable:

1. **Add Store model & master project integration**
   - Implement `stores` collection (manually in master project).
   - Hardcode Balaji’s store record.

2. **Extend SessionService with store fields**
   - No visible change yet.

3. **Add StoreSelectPage + routing guard**
   - For now, **don’t** re‑initialize Firebase; just prototype selecting a code and saving it.

4. **Introduce FirebaseEnvironmentService & rewire initialization**
   - Make app read config from store doc instead of local `google-services.json` only.

5. **Fully switch Balaji to store‑aware mode**
   - Balaji store works through the same new flow but auto‑selects `balaji_main`.

6. **Onboard one new test store**
   - Create a second Firebase project.
   - Add its config into master project.
   - Verify carpenters & admin flows are completely isolated.

7. **Refine UX & admin tooling**
   - Nice store selector.
   - Possibly a small web admin for you to manage stores.

---

### 11. Summary Guidance

- Keep **one master project** for:
  - List of stores
  - Store Firebase configs
  - (Optional) global analytics
- Use **one Firebase project per hardware store** for:
  - All operational data (users, bills, points, offers, spin, etc.).
- Make **store selection the first step** before login.
- Tie every session to a store; never reuse a session across stores.
- Implement changes in small, safe steps, starting with:
  - Store model
  - Session + routing
  - Then Firebase initialization.

