# ForgeFit — Complete Study Guide

## PART 1 — SYSTEM ARCHITECTURE

### 1.1 — What the system does

ForgeFit is a personal fitness tracking mobile app built for a single user who wants to manage their workouts and nutrition from their phone. It lets the user log gym sessions (exercises, sets, reps, weight), track food intake against daily macro goals, view personal records and training volume over time, and follow structured programs. The user adds exercises from a searchable database backed by the ExerciseDB API, logs food from the USDA FoodData Central database or by barcode scan, and gets a micronutrient breakdown of what they eat each day. The backend is a REST API running on Railway and the frontend is a Flutter mobile app.

### 1.2 — Tech stack table

| Technology | What it does in ForgeFit | Why this choice | What breaks without it |
|---|---|---|---|
| **Flutter** | Cross-platform mobile UI | Single codebase targets Android and iOS | The entire frontend |
| **Dart** | Language Flutter runs on | Required by Flutter | Flutter stops compiling |
| **Provider** | State management layer | Simple, officially recommended for small-medium apps | UI stops reacting to data changes |
| **Dio** | HTTP client | Interceptor support for automatic JWT refresh; richer error types than built-in http | Auth refresh stops working; error messages become generic |
| **flutter_secure_storage** | Stores JWT tokens in device keychain | More secure than SharedPreferences (encrypted on device) | Tokens stored in plain text; stolen on rooted devices |
| **SharedPreferences** | Stores macro goals (calorie/protein/carbs/fat targets) | Simple key-value persistence for non-sensitive data | Macro goals reset to defaults on app restart |
| **fl_chart** | Donut chart and line charts in nutrition and progress tabs | Clean Flutter-native chart library | Donut macro split, progress charts disappear |
| **FastAPI** | Backend REST API framework | Automatic OpenAPI docs, Pydantic validation, async support | No backend; the app has nothing to call |
| **SQLAlchemy** | ORM, maps Python classes to PostgreSQL tables | Standard Python ORM, works well with FastAPI | Direct SQL queries required; no ORM relationships |
| **PostgreSQL** | Relational database on Railway | Reliable relational DB; needed for joins across workouts/sets/nutrition | All data is lost; no persistence |
| **python-jose** | JWT encode/decode | Standard JWT library for Python | Auth tokens cannot be created or verified |
| **passlib/bcrypt** | Password hashing | Industry standard; bcrypt is slow-by-design against brute-force | Passwords stored in plain text |
| **slowapi** | Rate limiting on FastAPI routes | Prevents brute-force on login/register endpoints | Unlimited API calls; login endpoint attackable |
| **cachetools TTLCache** | In-memory cache for ExerciseDB and USDA responses | Reduces external API calls; respects rate limits | Every food search hits USDA directly; slow and rate-limited |
| **Railway** | PaaS hosting for the backend | Zero-config PostgreSQL + web service; free tier available | The API is unreachable |
| **Uvicorn** | ASGI server that runs FastAPI | Required to serve FastAPI in production | FastAPI won't start |

### 1.3 — System architecture diagram (ASCII)

```
┌─────────────────────────────────────────────────────────────┐
│  Flutter App (Android/iOS)                                   │
│                                                             │
│  ┌──────────┐    ┌─────────────────────────────────────┐   │
│  │ Provider │◄──►│ ApiClient (Dio)                      │   │
│  │ (state)  │    │  BaseURL: web-production-*.railway.app│   │
│  └──────────┘    │  AuthInterceptor ──────────────────  │   │
│                  │    onRequest: adds Bearer token       │   │
│                  │    onError 401: calls /auth/refresh   │   │
│                  │    if refresh fails: clear tokens     │   │
│                  └──────────────┬──────────────────────  │   │
│                                 │ HTTPS                   │   │
└─────────────────────────────────┼───────────────────────  ┘
                                  │
┌─────────────────────────────────▼──────────────────────────┐
│  Railway — FastAPI Backend                                  │
│                                                             │
│  Procfile: uvicorn main:app --host 0.0.0.0 --port $PORT    │
│                                                             │
│  main.py                                                    │
│    CORSMiddleware  (origins from CORS_ORIGINS env var)      │
│    slowapi rate limiter                                     │
│    Base.metadata.create_all()  ← auto-creates tables       │
│    app.include_router(auth_router, prefix="/auth")          │
│    app.include_router(workouts_router, prefix="/workouts")  │
│    ...etc for 5 more routers                                │
│                                                             │
│  Router function receives request                           │
│    ↓                                                        │
│  Depends(get_current_user)                                  │
│    ↓ reads Authorization: Bearer <token>                   │
│    ↓ jwt.decode(token, SECRET_KEY, algorithms=["HS256"])   │
│    ↓ checks revoked_tokens table for jti                   │
│    ↓ loads User from DB                                     │
│    ↓                                                        │
│  Depends(get_db)                                            │
│    db = SessionLocal()   ← opens connection                 │
│    yield db              ← used in route                    │
│    db.close()            ← always closes in finally         │
│    ↓                                                        │
│  SQLAlchemy ORM query → PostgreSQL                          │
│  Response serialized by Pydantic schema                     │
└─────────────────────────────────────────────────────────────┘
```

### 1.4 — Data flow for the 3 most important features

#### Feature 1: User logs a food (tap "Add to Breakfast" → database insert → UI update)

1. User is on the Nutrition tab; taps the Breakfast card (`_MealCard` in `nutrition_screen.dart`).
2. `Navigator.pushNamed(context, '/nutrition/add-food', arguments: 'breakfast')` fires.
3. `main.dart` `_generateRoute` matches `'/nutrition/add-food'` → builds `AddFoodScreen(initialMeal: 'breakfast')`.
4. User searches for "chicken breast" → `_onSearchChanged` debounces 400ms → calls `NutritionProvider.searchFood("chicken breast")`.
5. `NutritionProvider.searchFood` calls `ApiClient.get('/food/search', queryParameters: {'q': 'chicken breast'})`.
6. `AuthInterceptor.onRequest` injects `Authorization: Bearer <access_token>` header.
7. FastAPI `food_search.py` `search_food` endpoint checks `_search_cache`. If miss, calls USDA FDC `https://api.nal.usda.gov/fdc/v1/foods/search` with `USDA_API_KEY`.
8. USDA response parsed by `_parse_food_item`, result cached in `_search_cache` (TTL 1 hour), returned to Flutter.
9. User taps result → `_openFoodDetail(food)` opens a modal bottom sheet with quantity slider.
10. User taps "Add to Breakfast" button in the sheet.
11. Flutter builds body: `{'food_name': 'Chicken Breast', 'meal_name': 'Breakfast', 'calories': 165.0, 'protein_g': 31.0, 'carbs_g': 0.0, 'fat_g': 3.6, 'fdc_id': 331960}`.
12. `NutritionProvider.postNutritionLog(body)` calls `ApiClient.post('/nutrition/', data: body)`.
13. FastAPI `nutrition.py` `create_nutrition_log` validates body via `NutritionLogCreate` Pydantic schema. Inserts `NutritionLog` row. `db.commit()`. Returns `NutritionLogResponse`.
14. `postNutritionLog` then calls `loadTodayNutrition()` which calls `GET /nutrition/today`.
15. Backend queries all `NutritionLog` rows for `user_id=X AND date=today`, aggregates totals, returns `DailySummary`.
16. `NutritionProvider` updates `_todayLogs` and `_todaySummary`, calls `notifyListeners()`.
17. `nutrition_screen.dart` rebuilds, `Consumer<NutritionProvider>` reads new data, donut chart and meal card re-render with the new calorie count.
18. If user taps the green "Done" button in `add_food_screen.dart`, `loadTodayNutrition()` is called again and `Navigator.pop(context)` returns to the nutrition tab.

#### Feature 2: User starts a workout (tap "Empty Workout" → state changes → API calls)

1. User taps "Empty Workout" on the Workout tab (`log_workout_screen.dart`).
2. `WorkoutProvider.createWorkout()` is called → `ApiClient.post('/workouts/', data: {'date': today, 'name': 'My Workout', 'duration_seconds': 0})`.
3. Backend `workouts.py` `create_workout` inserts a `Workout` row with `user_id=X`. Returns the new workout JSON with an `id`.
4. Flutter stores `_activeWorkoutId = workout['id'].toString()` and calls `setWorkoutInProgress(true, title: 'My Workout', workoutId: id)`.
5. `setWorkoutInProgress` starts a `Timer.periodic(1 second)` that increments `_activeWorkoutElapsed` and calls `notifyListeners()` every second — this drives the live timer.
6. User searches for an exercise, taps it → `addExercise("Barbell Bench Press", muscle: "pectorals", gifUrl: "...")` appends an `ActiveExercise` to `_activeExercises` list. Three default `ActiveSet(weightKg: 0, reps: 8)` are created in-memory.
7. User edits weight/reps → `updateSet(exerciseIndex, setIndex, weight: 80.0, reps: 8)` updates the in-memory `ActiveSet`. No API call yet.
8. User taps the checkmark on a set → `toggleSetComplete(exerciseIndex, setIndex)` marks `isCompleted = true`. `checkAndUpdatePR` scans `_workouts` for a previous heavier set with the same name; if found, `hasPR = true` and `_prCount++`.
9. User taps "Finish Workout" → `completeWorkout()` iterates `_activeExercises`, for each exercise calls `ApiClient.post('/workouts/$id/sets', data: {exercise_name, sets, reps, weight_kg})` for each completed set.
10. At the end, `ApiClient.put('/workouts/$id', data: {duration_seconds: elapsed})` saves the final duration.
11. `clearActiveWorkout()` clears `_activeExercises` and stops the timer.
12. Navigator pushes `WorkoutCompleteScreen`.

#### Feature 3: User views progress stats (endpoints called, data aggregated)

1. User taps the Progress tab → `progress_screen.dart` mounts.
2. `initState` calls `StatsProvider.loadAllStats()`.
3. `loadAllStats` calls `Future.wait([GET /stats/weekly-volume, GET /stats/nutrition-trend, GET /stats/personal-records])` — three requests in parallel.
4. `GET /stats/weekly-volume`: Backend builds the last 8 Mondays. Queries all `Workout` rows in date range with `joinedload`. For each workout's sets, computes `sets * reps * weight_kg` and groups by week. Returns 8 `WeeklyWorkoutData` objects.
5. `GET /stats/nutrition-trend`: Queries `NutritionLog` grouped by date, summing calories/protein/carbs/fat per day. Returns daily rows ordered oldest-first.
6. `GET /stats/personal-records`: First query gets max weight per exercise name. Then for EACH exercise, a second query finds the date that weight was achieved. This is the N+1 problem — if user has 20 exercises, it fires 21 queries.
7. Responses are parsed into `WeeklyVolumeModel`, `MacroTrendModel`, `PersonalRecordModel` via `fromJson`.
8. `notifyListeners()` triggers `WeeklyVolumeChart` and `NutritionTrendChart` to rebuild using `fl_chart` `BarChart` and `LineChart`.

---

## PART 2 — BACKEND DEEP DIVE

### 2.1 — FastAPI fundamentals

**What a router is and how `app.include_router()` works:**
A router is a group of related endpoints defined in a separate file. In FastAPI you create `router = APIRouter()` and define endpoints on it with `@router.get()`, `@router.post()`, etc. In `main.py`, `app.include_router(auth_router, prefix="/auth", tags=["Authentication"])` mounts all routes from `auth.py` under the `/auth` prefix. So `@router.post("/login")` becomes `POST /auth/login`. This keeps the code modular — `nutrition.py` knows nothing about workouts.

**What a Pydantic schema is and why it's separate from the SQLAlchemy model:**
A Pydantic schema (e.g. `NutritionLogCreate`) defines the shape of data coming in or going out of an API endpoint. It validates types, runs field validators (like checking that `calories > 0`), and automatically generates error messages. A SQLAlchemy model (e.g. `NutritionLog`) represents a database table. The separation exists because they serve different purposes: the schema validates and serializes HTTP data; the model manages database persistence. If you used the SQLAlchemy model directly in the API response, you'd expose internal fields like `user_id` and leak implementation details. The schema `class Config: from_attributes = True` allows Pydantic to read from a SQLAlchemy object.

**What `Depends()` is — 3 real examples:**
`Depends()` is FastAPI's dependency injection system. Instead of calling a function inside a route, you declare it as a dependency and FastAPI calls it before running your route, injecting the result.

1. `db: Session = Depends(get_db)` — every route that touches the database receives an open `Session`. `get_db()` opens the connection with `SessionLocal()`, `yield`s it to the route, then closes it in the `finally` block automatically.
2. `current_user: User = Depends(get_current_user)` — every protected route receives the authenticated `User` object. `get_current_user()` reads the `Authorization` header, decodes the JWT, checks the `revoked_tokens` table, and returns the `User` row. If anything fails, it raises `HTTP 401` before your route code even runs.
3. `@limiter.limit("5/minute")` combined with `request: Request = ...` — slowapi uses the request object to enforce rate limits per IP on login and register endpoints.

**Trace of POST /nutrition/ from `main.py` to database:**
1. Request arrives at Uvicorn → passed to FastAPI's ASGI app.
2. `CORSMiddleware` checks the `Origin` header against `CORS_ORIGINS` env var.
3. FastAPI matches path `/nutrition/` to `nutrition_router`, which was included in `main.py` at prefix `/nutrition`.
4. The matching function is `create_nutrition_log(data: NutritionLogCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db))`.
5. FastAPI calls `get_current_user`: reads `Authorization: Bearer <token>`, decodes JWT with `SECRET_KEY` and `HS256`, extracts `sub` (email) and `jti`. Queries `revoked_tokens` for `jti`. Queries `users` for the email. Returns `User` object.
6. FastAPI calls `get_db`: opens `SessionLocal()`, yields `Session`.
7. FastAPI validates request body against `NutritionLogCreate`: checks `calories > 0`, `meal_name` min length 1, etc.
8. Route body runs: `log_date = data.date or date.today()`. Creates `NutritionLog(user_id=current_user.id, ...)`. `db.add(log)`. `db.commit()`. `db.refresh(log)`.
9. Returns `log` — Pydantic serializes it as `NutritionLogResponse` JSON.
10. `get_db` context exits — `db.close()` runs automatically.

### 2.2 — Database layer

**What SQLAlchemy is:** SQLAlchemy is a Python library that lets you define database tables as Python classes and write queries using Python instead of raw SQL. A class like `class NutritionLog(Base)` with columns defined as `Column(Float, ...)` maps directly to a PostgreSQL table with those columns.

**`SessionLocal`, `get_db`, and `Base`:**
- `Base = DeclarativeBase()` — the base class all models inherit from. SQLAlchemy uses it to discover which classes represent tables.
- `SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)` — a factory that creates database sessions. `autocommit=False` means changes require an explicit `db.commit()`, preventing accidental writes. `autoflush=False` means SQLAlchemy won't auto-sync before every query.
- `get_db()` is a generator that opens a `Session`, yields it, and always closes it. Used in every route via `Depends(get_db)`.

**The `users → workouts → workout_sets` chain:**
```python
# models/workout.py
class Workout(Base):
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    sets = relationship("WorkoutSet", back_populates="workout", cascade="all, delete-orphan")

class WorkoutSet(Base):
    workout_id = Column(Integer, ForeignKey("workouts.id", ondelete="CASCADE"))
    exercise_name = Column(String, index=True)
    workout = relationship("Workout", back_populates="sets")
```
`ForeignKey("users.id")` creates a relational link — every `Workout` row must have a matching `users.id`. `relationship("WorkoutSet", cascade="all, delete-orphan")` means when you `db.delete(workout)`, SQLAlchemy automatically deletes all child `WorkoutSet` rows. The `joinedload` used in `list_workouts` tells SQLAlchemy to fetch sets in the same SQL query using a JOIN, avoiding N+1 queries on the list endpoint.

**`Base.metadata.create_all()` and why it's dangerous in production:**
`Base.metadata.create_all(bind=engine)` scans all imported model classes and creates any tables that don't yet exist in the database. It is safe at initial setup but dangerous in production because it never modifies existing tables. If you add a new `Column` to a model, `create_all()` will NOT add it to the existing table — the column simply won't exist in PostgreSQL even though the Python class has it. The proper solution is **Alembic** — a migration tool that generates versioned SQL scripts (`alembic revision --autogenerate`) and applies them in order (`alembic upgrade head`). Each migration is stored in a `versions/` folder and tracked in an `alembic_version` table so the database always knows exactly what schema version it's on.

### 2.3 — Authentication system

**What JWT is:** JSON Web Token. A base64-encoded string with three parts: `header.payload.signature`. The payload contains claims like `sub` (subject = user email), `exp` (expiry timestamp), `jti` (unique token ID). HS256 means the signature uses HMAC-SHA256 with a symmetric `SECRET_KEY` — the same key signs and verifies, so it must stay secret on the server.

**How `create_access_token()` works:**
```python
def create_access_token(data: dict, expires_delta=None):
    to_encode = data.copy()              # e.g. {"sub": "user@email.com"}
    expire = datetime.now(utc) + timedelta(minutes=30)
    to_encode.update({"exp": expire, "jti": str(uuid4())})  # adds expiry + unique ID
    return jwt.encode(to_encode, SECRET_KEY, algorithm="HS256")
```
Input: `{"sub": user.email}`. Output: signed JWT string valid for 30 minutes.

**Why two tokens:** The access token is short-lived (30 min) to limit damage if stolen — an attacker has at most 30 minutes before it expires. The refresh token lives 30 days and is stored securely in `flutter_secure_storage`. When the access token expires, `AuthInterceptor` uses the refresh token to call `POST /auth/refresh`, which revokes the old refresh token and issues fresh tokens. This gives the user a long login session without keeping a long-lived access token in circulation.

**`get_current_user` traced line by line:**
```python
def get_current_user(credentials = Depends(HTTPBearer()), db = Depends(get_db)):
    token = credentials.credentials           # extract raw token string
    payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])  # verify signature + expiry
    email = payload.get("sub")               # who the token belongs to
    jti = payload.get("jti")                 # unique token ID
    if email is None or jti is None:
        raise HTTPException(401)
    if is_token_revoked(jti, db):            # check revoked_tokens table
        raise HTTPException(401)
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise HTTPException(401)
    return user                              # injects User into route
```

**Token revocation via `revoked_tokens`:** When a user logs out, both the access token's `jti` and the refresh token's `jti` are inserted into the `revoked_tokens` table. On every subsequent request, `get_current_user` checks this table. This is stateful blocklisting — it makes logout work even if the token hasn't expired yet. The downside: the table grows forever. No cleanup job currently exists.

**`forgot-password` endpoint — honest assessment:** It is a stub. `routers/auth.py` line 133: `return {"message": "If this email exists, a reset code has been sent"}`. It does nothing — no code is generated, no email is sent. The infrastructure exists (`auth/email.py`, `send_password_reset_email`, reset code columns on the `User` model), but the `forgot_password` route never populates `reset_password_code` or sends an email. `reset_password` would also fail because `reset_password_code` is always `None`.

### 2.4 — Each router explained

**auth.py**
- **Purpose:** User registration, login, logout, token refresh, and password reset.
- **Key endpoints:**
  - `POST /auth/register` (rate-limited 5/min): validates `UserCreate`, hashes password with bcrypt, inserts `User`. Sets `is_verified=True` immediately (email verification not enforced).
  - `POST /auth/login` (rate-limited 5/min): verifies password, returns access + refresh JWT pair.
  - `GET /auth/me`: returns current user profile (requires valid token).
  - `PUT /auth/profile`: partial update of `full_name`, `weight_kg`, etc.
  - `POST /auth/refresh`: validates refresh token, revokes it, issues new token pair.
  - `POST /auth/logout`: revokes both tokens by inserting their `jti` into `revoked_tokens`.
  - `POST /auth/forgot-password`: **STUB** — returns success message without sending email.
  - `POST /auth/reset-password`: validates reset code against `reset_password_code` column — but since `forgot-password` never sets this, it always fails.
- **Known issues:** `forgot-password` is non-functional. `reset-password` code matching uses `verify_password` but the stored code should be plain text, not hashed — this is a logic error.

**workouts.py**
- **Purpose:** CRUD for workout sessions and their sets.
- **Key endpoints:**
  - `POST /workouts/`: creates a new workout, returns it with computed totals and last-session data.
  - `GET /workouts/`: lists summaries for the user (paginated). Uses `joinedload(Workout.sets)` to avoid N+1.
  - `GET /workouts/{id}`: full detail with all sets and last-session data for each exercise.
  - `PUT /workouts/{id}`: partial update (name, notes, duration). Only updates non-None fields.
  - `DELETE /workouts/{id}`: cascades to delete all WorkoutSets.
  - `POST /workouts/{id}/sets`: adds a set to an existing workout. Returns the set with the last session data.
  - `DELETE /workouts/{id}/sets/{set_id}`: removes one set.
- **Business logic:** Calories burned is computed as `(3.5 * body_weight_kg * duration_minutes) / 60` using the MET value for weight training. Last-session data is batch-fetched in a single query via `_get_batch_last_sessions` to avoid N+1.
- **Known issues:** `calories_burned` field is in `WorkoutUpdate` schema but the `Workout` model has no `calories_burned` column — the `PUT` handler tries to set it and silently fails.

**exercises.py**
- **Purpose:** Search and retrieve exercises via ExerciseDB API; fetch exercise history from the user's own workout logs.
- **Key endpoints:**
  - `GET /exercises/search?q=...`: proxies to ExerciseDB, caches for 1 hour.
  - `GET /exercises/recent`: returns the 8 most recently used exercise names from the user's `workout_sets`.
  - `GET /exercises/{exercise_id}`: fetches exercise detail (GIF, instructions) from ExerciseDB by ID.
  - `GET /exercises/{exercise_name}/history`: returns the last 10 sessions the user logged that exercise.
- **Known issues:** If ExerciseDB is down, `search_exercises` returns `[]` silently and the user sees no results with no error message.

**nutrition.py**
- **Purpose:** CRUD for food log entries; daily and historical summaries.
- **Key endpoints:**
  - `POST /nutrition/`: logs a food entry. Accepts any `meal_name` string (flexible since the meal name migration from enum to string).
  - `GET /nutrition/today`: returns today's logs grouped by meal and aggregated totals.
  - `GET /nutrition/history?limit=30`: returns one `DailySummary` per logged day (last 30 days).
  - `GET /nutrition/date/{YYYY-MM-DD}`: same structure for a specific date.
  - `PUT /nutrition/{log_id}`: full replacement of a log entry.
  - `DELETE /nutrition/{log_id}`: removes a log entry.
- **Business logic:** `_build_daily_summary` aggregates totals in Python after fetching logs from the DB in one query.

**food_search.py**
- **Purpose:** Food search and nutrient lookup via USDA FoodData Central.
- **Key endpoints:**
  - `GET /food/search?q=...`: queries USDA `/foods/search`, caches results 1 hour. Falls back to stale cache on timeout.
  - `GET /food/{fdc_id}`: gets macro info for a specific USDA food item, cached 24 hours.
  - `GET /food/{fdc_id}/nutrients`: fetches the full nutrient list, filters to the 23 nutrients in `NUTRIENT_MAP`, computes `pct_rda`, cached 24 hours.
- **Business logic:** `NUTRIENT_MAP` hardcodes 23 USDA nutrient IDs with human names, units, and RDA values from NIH dietary reference intakes. These RDA values are hardcoded constants, not pulled from a database.
- **Known issues:** Cache is in-memory (`TTLCache`). It is lost entirely on every Railway deployment or server restart.

**stats.py**
- **Purpose:** Aggregate statistics for the progress tab.
- **Key endpoints:**
  - `GET /stats/workouts`: total workouts, sets, volume, avg per week, most frequent exercise, current and longest streaks.
  - `GET /stats/nutrition?days=30`: avg daily calories/macros over N days.
  - `GET /stats/personal-records`: heaviest weight per exercise with the date achieved.
  - `GET /stats/weekly-volume?weeks=8`: workout count and total volume per week for the last N weeks.
  - `GET /stats/nutrition-trend?days=30`: daily calorie/macro breakdown for charts.
- **Known issues:** N+1 in `get_personal_records`: for each exercise, a second query fires to find the date. With 20 exercises, that's 21 database hits.

**programs.py**
- **Purpose:** Structured training program management with templates.
- **Key endpoints:**
  - `GET /programs/templates`: returns 6 hardcoded templates (Push Pull Legs, Bro Split, Full Body, Upper Lower, Powerlifting Peaking, Starting Strength).
  - `POST /programs/from-template/{slug}`: clones a template into the user's programs table with all days and exercises.
  - `POST /programs/`: creates a blank program.
  - `GET /programs/active`: returns the user's currently active program.
  - `PUT /programs/{id}/activate`: sets one program active and deactivates all others atomically.
  - Various endpoints for adding/updating/deleting days and exercises within a program.
- **Business logic:** Templates are hardcoded Python dicts in `programs.py`. No database table stores templates — they only exist in code.

### 2.5 — External API integrations

**ExerciseDB (`exercisedb-apiii.vercel.app`):**
- What it returns: exercises with `exerciseId`, `name`, `gifUrl`, `targetMuscles`, `bodyParts`, `equipments`, `secondaryMuscles`, `instructions`.
- How it's cached: `TTLCache(maxsize=500, ttl=3600)` — 1 hour in memory. Cache key is `search_<query>` or `exercise_<id>`.
- What happens when it's down: `search_exercises` catches all exceptions and returns `[]`. No error is surfaced to the user — they just see an empty search result.

**USDA FoodData Central:**
- Endpoints used: `GET /foods/search?query=X&pageSize=10` for search; `GET /food/{fdcId}` for detail and for nutrients.
- Response shape: `{"foods": [{"fdcId": int, "description": str, "foodNutrients": [{"nutrientName": str, "value": float}], "brandOwner": str}]}`.
- How the backend normalizes it: `_parse_food_item` extracts `Energy`, `Protein`, `Carbohydrate, by difference`, `Total lipid (fat)` by exact nutrient name string match. The `foodNutrients` list contains all nutrients; the code does a linear scan for each field — O(n) per nutrient.

**USDA `/food/{fdc_id}/nutrients` for micronutrient dashboard:**
- The response is the same `/food/{fdcId}` endpoint. The backend reads `foodNutrients`, filters to IDs present in `NUTRIENT_MAP` (23 nutrients), and adds `rda` and `pct_rda`.
- RDA values are hardcoded in `food_search.py` based on NIH adult daily values (e.g. Iron = 18 mg, Vitamin D = 20 µg, Calcium = 1000 mg).

**SMTP email (auth/email.py):**
- The infrastructure exists: `_send_email` uses Python's `smtplib` with `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_SERVER` (default `smtp.gmail.com`), `MAIL_PORT` (default 587).
- `send_password_reset_email` and `send_verification_email` are defined.
- **Not actually wired**: `forgot_password` in `auth.py` returns a stub and never calls `send_password_reset_email`. Emails are never sent in production.

### 2.6 — Deployment

**Railway:** A Platform-as-a-Service that runs containers. The `Procfile` tells Railway how to start the app: `web: uvicorn main:app --host 0.0.0.0 --port $PORT`. Railway injects `$PORT` at runtime. PostgreSQL is a Railway add-on — it lives in the same project and its connection string is injected as `DATABASE_URL`.

**Required environment variables:**
- `DATABASE_URL`: PostgreSQL connection string. Without it, `database.py` raises `RuntimeError` at startup and the app won't start.
- `SECRET_KEY`: JWT signing key. Without it, `auth/utils.py` raises `RuntimeError` at startup.
- `USDA_API_KEY`: food search API key. Without it, every food search endpoint returns HTTP 503.
- `CORS_ORIGINS`: comma-separated list of allowed origins. Without it, defaults to `http://localhost:3000` — the Flutter app (running on a different origin) gets CORS rejected.
- `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_SERVER`, `MAIL_PORT`: email credentials. Without them, emails silently fail (caught exception) — currently doesn't matter since no email is sent.

**How the database persists:** Railway's PostgreSQL add-on persists data across deployments. The app server can be restarted or redeployed without losing data because the database is a separate service.

**Cold start:** Railway free tier instances sleep after inactivity. On the first request after sleep, the server takes 30–90 seconds to respond. `AuthProvider.register()` calls `ApiClient.wakeServer()` before the actual registration request. `wakeServer()` calls `GET /health` with a 90-second timeout. This pre-warms the server so the registration request doesn't time out.

---

## PART 3 — FRONTEND DEEP DIVE

### 3.1 — Flutter fundamentals used in this project

**StatefulWidget vs StatelessWidget:**
- `StatelessWidget` is a widget whose appearance depends entirely on its constructor arguments. In ForgeFit, `_MealCard` is a `StatelessWidget` — it receives its data (meal name, logs, colors) as constructor parameters and rebuilds only when those parameters change.
- `StatefulWidget` owns mutable state. `_AddFoodScreenState extends State<AddFoodScreen>` is a `StatefulWidget`. It stores `_query`, `_searchResults`, `_addedCount`, and `_frequentFoods` as private fields. When these change, `setState(() { ... })` triggers Dart to rebuild the widget tree for that subtree only.

**What `BuildContext` is:** `BuildContext` is a reference to the widget's position in the widget tree. It's how a widget finds things above it in the tree. `context.read<NutritionProvider>()` walks up the tree until it finds the `ChangeNotifierProvider<NutritionProvider>` that was declared in `main.dart`'s `MultiProvider`. Without context, you can't reach providers, themes, or navigate between screens.

**What `setState()` does:** `setState()` marks the widget as "dirty" — Flutter will call `build()` again on the next frame. It does not re-render the entire screen, just the subtree owned by that `State`. In `_AddFoodScreenState`, `setState(() => _addedCount++)` triggers a rebuild that makes the green "Done" bar appear at the bottom.

**`initState()` and `dispose()`:**
- `initState()` runs once when the widget is first inserted into the tree. In `_AddFoodScreenState`, `initState()` calls `_loadHistory()`, `_loadFavorites()`, and schedules `_loadCommonSources()` via `addPostFrameCallback`. In `_MicronutrientDashboardScreenState`, `initState()` starts the shimmer `AnimationController` and calls `_loadData()`.
- `dispose()` runs when the widget is removed from the tree permanently. In `_AddFoodScreenState`, `dispose()` calls `_searchController.dispose()` and `_debounceTimer?.cancel()` — without this, the timer would keep firing after the screen is gone, causing a "setState called after dispose" crash.

**`WidgetsBinding.instance.addPostFrameCallback`:** Schedules a callback to run after the current frame is fully painted. In `NutritionProvider._setLoading()`, `notifyListeners()` is wrapped in `addPostFrameCallback` to avoid calling it during widget build — which would throw a "setState during build" assertion error. This is a defensive safety measure.

### 3.2 — State management with Provider

**What Provider is and why it was chosen:** Provider is Flutter's officially recommended state management library. It wraps `InheritedWidget` in a cleaner API. It was chosen over Redux (too much boilerplate for a single-developer project), Bloc (event-based architecture overkill for CRUD operations), and Riverpod (Provider's newer cousin — would be the better choice if starting today, but Provider was established when this project began).

**What `ChangeNotifier` is:** A mixin that adds `notifyListeners()` to any class. When `notifyListeners()` is called, all widgets that called `context.watch<X>()` or `Consumer<X>` rebuild. `WorkoutProvider extends ChangeNotifier` means the entire workout tab refreshes when the workout timer ticks every second.

**`MultiProvider` in `main.dart`:** Declares 7 providers that live for the app's lifetime:
1. `Provider<ApiClient>` — the shared HTTP client (no state change, so plain `Provider`)
2. `ChangeNotifierProvider<AuthProvider>` — login state, current user
3. `ChangeNotifierProvider<OnboardingProvider>` — multi-step registration form state
4. `ChangeNotifierProvider<WorkoutProvider>` — active workout, workout history
5. `ChangeNotifierProvider<ProgramProvider>` — training programs
6. `ChangeNotifierProvider<NutritionProvider>` — today's food logs, food search
7. `ChangeNotifierProvider<StatsProvider>` — weekly volume, nutrition trend, PRs

**`context.read<X>()` vs `context.watch<X>()`:**
- `context.read<X>()` reads the current value once and does NOT subscribe to changes. Used inside event handlers: `ElevatedButton(onPressed: () => context.read<NutritionProvider>().logFood(...)`. If used in `build()`, the widget won't rebuild when the provider changes.
- `context.watch<X>()` subscribes — the widget rebuilds every time `notifyListeners()` fires. Used in `build()` methods: `final provider = context.watch<NutritionProvider>(); ... Text('${provider.todaySummary?.totalCalories}')`.

**The double `MultiProvider` bug in `main.dart`:**
```dart
// First MultiProvider — wraps the MaterialApp
return MultiProvider(
  providers: [...all providers created here...],
  child: MaterialApp(
    builder: (context, child) {
      // Second MultiProvider — wraps every Navigator page
      return MultiProvider(
        providers: [
          Provider.value(value: context.read<ApiClient>()),      // re-wraps!
          ChangeNotifierProvider.value(value: context.read<WorkoutProvider>()),  // re-wraps!
          ...
        ],
        child: child!,
      );
    },
  ),
);
```
The `builder` wraps every screen with a second `MultiProvider` using `.value` constructors (which reuse the existing instances). The intent was to make providers accessible inside named routes (which have a different context than the outer `MultiProvider`). The issue is it adds unnecessary overhead — providers are looked up through two layers. It works correctly but is redundant. The fix would be to use `navigatorKey` or ensure the outer `MultiProvider` is above `MaterialApp`.

### 3.3 — Network layer

**Why Dio instead of `http`:** Dio supports interceptors — pluggable middleware that runs before/after every request. `AuthInterceptor` automatically injects the JWT header on every request and transparently refreshes the token on 401 responses. The built-in `http` package has no interceptor concept, so this would require wrapping every API call manually. Dio also has better timeout handling and richer error types (`DioExceptionType`).

**What `ApiClient` wraps:** `ApiClient` creates a single `Dio` instance with `BaseOptions` (base URL, timeouts, default headers). The `get/post/put/delete` methods catch `DioException` and call `_handleError()` which extracts the `detail` field from FastAPI error responses and converts network errors to human-readable strings. This means callers receive a `String` on error instead of a raw exception.

**`AuthInterceptor` step-by-step on 401:**
1. Any request fires → `onRequest` reads `TokenStorage.getAccessToken()` → appends `Authorization: Bearer <token>` header.
2. Response returns 401 → `onError` is called.
3. `_tryRefreshToken()` reads the refresh token from `flutter_secure_storage`. Creates a fresh `Dio()` instance (separate from the main one, to avoid infinite interceptor loops). Calls `POST /auth/refresh` with the refresh token.
4. If 200: saves new tokens via `_tokenStorage.saveTokens()`. Returns `true`.
5. `onError` retries the original request with the new token via `_dio.fetch(options)`. Resolves the response — the caller never knows a refresh happened.
6. If the refresh fails (token expired, network down): `_tokenStorage.clearTokens()`. The handler calls `handler.next(err)` — the error propagates and the UI shows a login screen.

**`flutter_secure_storage`:** On Android, it stores data in the Android Keystore System. On iOS, in the Keychain. Unlike `SharedPreferences` (which writes plain text to an XML file readable on rooted devices), `flutter_secure_storage` encrypts data at rest. The two keys stored are `'access_token'` and `'refresh_token'`.

**`wakeServer()`:** Calls `GET /health` with a 90-second timeout and silently ignores any error. Called in `AuthProvider.register()` before the registration request, because Railway free tier sleeps after inactivity. This pre-warms the server. The 90-second timeout is intentionally generous to account for cold start time.

### 3.4 — Each feature explained

**Auth feature:**
- **Screens:** `LoginScreen` (email + password form), `EmailPasswordScreen` (step 1 of registration), `RegisterScreen` (personal info), `PhysicalMetricsScreen` (weight, height), `FitnessLevelScreen`, `ProfileSummaryScreen` (review before submit).
- **Provider:** `AuthProvider` — holds `_currentUser`, `_isLoggedIn`, `_isLoading`. `OnboardingProvider` holds multi-step form data across the registration screens.
- **Models:** `UserModel.fromJson` handles both `full_name` and `fullName` keys for robustness.
- **Key widgets:** `AuthTextField` — a reusable styled text field with obscure-text toggle for password fields.
- **Navigation:** Registration is a linear flow (5 screens) using `buildSlideRoute` — the same as `MaterialPageRoute` but with a slide-in transition from the right.

**Workout feature:**
- **Screens:** `LogWorkoutScreen` (active session with exercise list, live timer, set logging), `WorkoutListScreen` (history), `WorkoutDetailScreen` (past workout detail), `WorkoutCompleteScreen` (post-workout summary with muscle map and PR count), `ExerciseDetailScreen` (GIF + instructions), `CalendarScreen`, `EditSessionScreen`, `ProgramDetailScreen`, `ProgramDayScreen`, `CreateProgramScreen`.
- **Provider:** `WorkoutProvider` — manages both live workout state (`_activeExercises`, `_workoutTimer`, `_activeWorkoutElapsed`) and the workout history list (`_workouts`). Contains in-memory exercise search via ExerciseDB.
- **Models:** `WorkoutModel` (parsed from the `/workouts/` list), `WorkoutSetDetail` (from the detailed `/workouts/{id}` response), `ActiveExercise` / `ActiveSet` (in-memory only during a session, never serialized as their own models).

**Nutrition feature:**
- **Screens:** `NutritionScreen` (donut chart + meal cards), `AddFoodScreen` (search + quick-add), `FoodDetailScreen` (quantity adjustment + macro detail), `MacroTargetsScreen` (slider-based goal setting), `MicronutrientDashboardScreen` (full vitamin/mineral breakdown), `BarcodeScannerScreen`.
- **Provider:** `NutritionProvider` — holds `_todayLogs`, `_todaySummary`, `_nutrientCache`. Exposes `loadTodayNutrition`, `logFood`, `deleteLog`, `searchFood`, `getNutrients`.
- **Models:** `NutritionModel` (single food log), `DailyNutritionSummary` (aggregated totals).

**Progress feature:**
- **Screens:** `ProgressScreen` — shows `WeeklyVolumeChart`, `NutritionTrendChart`, and a personal records list.
- **Provider:** `StatsProvider` — `loadAllStats()` fires 3 parallel API calls via `Future.wait`.
- **Models:** `WeeklyVolumeModel`, `MacroTrendModel`, `PersonalRecordModel` — all parsed via `fromJson`.
- **Key widgets:** `WeeklyVolumeChart` and `NutritionTrendChart` use `fl_chart`'s `BarChart` and `LineChart` respectively.

**Home feature:**
- **Screens:** `HomeScreen` — the main bottom-nav shell. Shows greeting, quick stats, today's nutrition snapshot, and a "Today's Focus" card for the active program.
- **Key widgets:** `GreetingHeader`, `NutritionSnapshotWidget` (reads from `NutritionProvider`), `TodaysFocusCard` (reads from `ProgramProvider`), `ProgressRingWidget`.

### 3.5 — Navigation

**`onGenerateRoute` in `main.dart`:** Instead of declaring routes as a static `Map<String, WidgetBuilder>`, `onGenerateRoute` is a function that receives `RouteSettings` (containing the name and arguments) and returns a `Route`. This allows passing typed arguments to screens, which the static map syntax cannot do.

**Three real examples of argument passing:**
1. **Workout detail:** `Navigator.pushNamed(context, '/workout-detail', arguments: 'workout_id_string')`. In `_generateRoute`: `final workoutId = settings.arguments as String; return MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workoutId: workoutId))`.
2. **Add food with meal target:** `Navigator.pushNamed(context, '/nutrition/add-food', arguments: 'breakfast')`. Route handler: `final meal = settings.arguments as String? ?? 'breakfast'; return MaterialPageRoute(builder: (_) => AddFoodScreen(initialMeal: meal))`.
3. **Food detail with full data:** `Navigator.pushNamed(context, '/nutrition/food-detail', arguments: {'foodData': food, 'targetMeal': 'lunch'})`. Route handler: `final args = settings.arguments as Map<String, dynamic>; final foodData = args['foodData'] as Map<String, dynamic>`.

**Why named routes instead of `Navigator.push` directly:** Named routes allow deeplinks and make navigation declarable in one place. `onGenerateRoute` in `main.dart` is the single source of truth for what screens exist and what arguments they require.

### 3.6 — The nutrition tab in detail

**Full Add Food flow:**
1. Tap meal card → `Navigator.pushNamed('/nutrition/add-food', arguments: 'breakfast')` → `AddFoodScreen(initialMeal: 'breakfast')`.
2. `initState()` calls `_loadHistory()` (last 30 days of logs) and `_loadCommonSources()` (fetches macros for 7 common foods via `searchFood`).
3. User types in search field → `_onSearchChanged` debounces 400ms → `setState(() => _isSearching = true)` → `NutritionProvider.searchFood(query)` → API call → `setState(() => _searchResults = results)`.
4. User taps a result → `_openFoodDetail(food)` → `showModalBottomSheet` with a quantity slider. Quantity defaults to 100g. Macros scale linearly: `cal = (food['calories'] * quantity / 100)`.
5. User taps "Add to Breakfast" → `NutritionProvider.postNutritionLog(body)` → `POST /nutrition/` → then `loadTodayNutrition()`.
6. `setState(() => _addedCount++)` → green "Done" bar appears.
7. User taps "Done" or hits the back arrow → both call `loadTodayNutrition()` before `Navigator.pop()`.

**How the donut chart is built with fl_chart:**
`_DonutChart` is a `StatelessWidget` in `nutrition_screen.dart`. It uses `fl_chart`'s `PieChart` with `PieChartData`. Three `PieChartSectionData` entries represent protein (blue, flex = protein grams), carbs (orange, flex = carb grams), and fat (purple, flex = fat grams). The center displays consumed vs goal calories. `_getCalorieColor()` applies traffic-light coloring: green at 60–120% of goal, amber at 40–60% or 120–140%, red outside those bounds. `AnimatedDefaultTextStyle` wraps the center text with a 600ms color transition.

**Macro goals — SharedPreferences:**
`MacroTargetsScreen` saves four values: `macro_calorie_goal` (int), `macro_protein_goal` (int), `macro_carbs_goal` (int), `macro_fat_goal` (int). `NutritionScreen._loadMacroGoals()` reads them on `initState`. A sanity clamp guards against corruption: `calorieGoal = calorieGoal.clamp(500, 10000)`. A one-time migration check resets any goal above 10,000 to 2600 (the default).

**Micronutrient dashboard aggregation:**
`_loadData()` reads `NutritionProvider.todayLogs`. For each log, it calls `getNutrients(fdcId: log.fdcId, foodName: log.foodName)` — these are all fired as `Future.wait` (parallel). `getNutrients` tries `fdcId` first; if null or the lookup fails, it searches by food name via `GET /food/search` to resolve an `fdc_id`, then calls `GET /food/{id}/nutrients`. Results are aggregated into a `Map<int, Map>` keyed by USDA nutrient ID. Each nutrient's amount is scaled by `log.amount / 100` (since USDA values are per 100g).

**The `fdc_id` fallback lookup chain:**
1. `log.fdcId != null` → try `GET /food/{fdcId}/nutrients` directly.
2. `fdcId == null` or request failed → search `GET /food/search?q={log.foodName}`.
3. Take `results.first['fdc_id']` → call `GET /food/{resolvedId}/nutrients`.
4. Cache result under key `'name:{foodName}'` for future calls.
5. If all fails → return `[]` (log contributes nothing to the dashboard).

**The meal name mapping:**
The backend `meal_name` column is a plain string since the enum-to-string migration. Old data may have `"Snack"`, new data `"snacks"`. The Flutter side uses `toBackendMealName()` in `add_food_screen.dart`: `{'breakfast': 'Breakfast', 'lunch': 'Lunch', 'dinner': 'Dinner', 'snacks': 'Snack'}`. The lowercase key `'snacks'` maps to the singular `'Snack'` because the backend was originally an enum with `snack = "Snack"`. Custom meal names pass through with first-letter capitalization.

---

## PART 4 — KNOWN ISSUES AND HONEST ASSESSMENT

### 4.1 — Current bugs and limitations

**1. Double `MultiProvider` in `main.dart`**
- What it is: The app wraps providers in `MultiProvider` at the top level, then re-wraps them inside `MaterialApp`'s `builder` using `.value` constructors.
- What breaks: Nothing crashes, but every widget lookup traverses two provider layers. It's architecturally redundant.
- Fix: Remove the inner `MultiProvider` in `builder`. Ensure the outer `MultiProvider` wraps `MaterialApp` directly, or use `navigatorKey` to access context from within routes.

**2. The `forgot-password` stub**
- What it is: `POST /auth/forgot-password` (line 133 in `auth.py`) returns a static success message without generating or emailing a reset code.
- What breaks: Users who forget their password cannot recover their account.
- Fix: Generate a 6-digit code via `secrets.token_hex(3)`, hash it with `pwd_context.hash(code)`, store it in `user.reset_password_code` with a 15-minute expiry, and call `send_password_reset_email(user.email, code)`.

**3. Exercise storage by name, not stable ID**
- What it is: `WorkoutSet.exercise_name` (a String) is used as the identifier for personal records, exercise history, and "last session" lookups. The ExerciseDB `exerciseId` is stored in `exercise_id` but is optional and often null.
- What breaks: If an exercise is ever renamed or spelled differently across sessions (e.g. "Barbell Squat" vs "barbell squat"), they count as different exercises. Stats and streaks are fragmented.
- Fix: Enforce storing the `exerciseId` alongside every set. Use `exerciseId` (not name) as the primary key for history and PRs.

**4. `revoked_tokens` table grows forever**
- What it is: Every logout appends two rows. Every token refresh appends one. No cleanup job removes expired entries.
- What breaks: The table size slowly inflates. `get_current_user` queries it on every request. Eventually it becomes a full-table-scan performance problem.
- Fix: Add a periodic cleanup job (or Alembic migration adding a scheduler) that deletes rows where `revoked_at + token_ttl < now`. Alternatively, check token expiry first and skip the DB lookup for already-expired tokens.

**5. In-memory caches lost on redeploy**
- What it is: `_search_cache`, `_nutrients_cache`, `_detail_cache` in `food_search.py` and the `_search_cache`/`_detail_cache` in `exercises.py` are Python dictionaries in process memory.
- What breaks: After every Railway deployment, all users experience cache misses for the first ~1 hour. During high-traffic periods multiple parallel requests for the same food hit USDA simultaneously.
- Fix: Move to Redis (Railway has a Redis add-on). Use `redis.get(key)` / `redis.setex(key, ttl, value)` in place of `TTLCache`.

**6. No test suite**
- What it is: There are no unit tests, integration tests, or widget tests anywhere in either codebase.
- What breaks: Regressions are caught manually. Breaking changes to an API endpoint or a provider method are discovered in production.
- Fix: Add `pytest` + `httpx.AsyncClient` for FastAPI route tests. Add Flutter `widget_test.dart` for critical widgets. At minimum, test the auth flow and nutrition log CRUD.

**7. N+1 query in `get_personal_records`**
- What it is: In `stats.py` `get_personal_records`, the main query gets one row per exercise (max weight). Then for each exercise, a second DB query finds the date. With N exercises, this is N+1 total queries.
- What breaks: Slow response time as the user's exercise library grows.
- Fix: Use a single query with a window function: `SELECT exercise_name, weight_kg, date FROM workout_sets ... WHERE (exercise_name, weight_kg) IN (SELECT exercise_name, MAX(weight_kg) FROM ...)`.

**8. `calories_burned` column missing from `Workout` model**
- What it is: `WorkoutUpdate` schema has `calories_burned: Optional[int]` and `update_workout` in `workouts.py` tries to set `workout.calories_burned = data.calories_burned`. But `Workout` model in `models/workout.py` has no `calories_burned` column.
- What breaks: The `PUT /workouts/{id}` handler silently fails when setting this field — SQLAlchemy sets a non-column attribute that doesn't persist.
- Fix: Add `calories_burned = Column(Integer, default=0)` to `models/workout.py` and run a migration.

**9. `UserModel` stores `id` as a String**
- What it is: `UserModel.fromJson` does `id: (json['id'] ?? json['_id'] ?? '').toString()`. The backend sends `id` as an integer. Converting to String works fine but means int comparisons require parsing.
- Fix: Store as `int`. Minor issue but inconsistent with the backend schema.

### 4.2 — What you would do differently

If I were presenting to the jury, I would say:

The biggest early architectural mistake was using `exercise_name` as the identifier for exercises everywhere. It seemed simple at the start — just store the name as a string — but it created a hidden dependency between the search results, the workout logs, the personal records, and the exercise history. The moment a name has a typo or a capitalization difference, the data fragments. If I were starting over, I would commit immediately to always storing the ExerciseDB `exerciseId` alongside every set and building all PRs and history around the stable ID.

The second thing I would do differently is start with Alembic from day one. Using `Base.metadata.create_all()` was fine for prototyping, but adding even one column to an existing table required manual `ALTER TABLE` in `main.py` as a workaround. That code is gone now, but the habit of using migrations from the beginning would have saved hours of confusion.

For Flutter state management, I learned that Provider works cleanly as long as providers are truly independent. The `WorkoutProvider` grew to nearly 700 lines because it manages too many concerns: active session state, exercise search, the timer, notifications, and workout history. If I were starting over I would split this into `ActiveWorkoutProvider` (session-only) and `WorkoutHistoryProvider` (past workouts).

The three most important next improvements:
1. **Implement forgot-password** — it is a missing feature that blocks any real-world user from recovering their account.
2. **Replace in-memory caches with Redis** — the current caches vanish on every deploy, meaning the USDA API is hammered for the first hour after every deployment.
3. **Add a test suite** — at minimum, automated tests for auth, food logging, and workout creation to catch regressions before they reach users.

### 4.3 — Security assessment

**JWT implementation:**
- The secret key is read from the `SECRET_KEY` environment variable and guarded by a startup `RuntimeError` if missing — this is correct.
- HS256 is symmetric (same key signs and verifies). This is fine for a single-server setup but would be a problem for microservices (all services need the secret). RS256 would be better long-term.
- The `jti` claim provides per-token revocation without database involvement for the signature check — this is a good practice.
- Access tokens expire in 30 minutes and are stored in `flutter_secure_storage` (encrypted) — correct.
- **Missing:** The refresh token rotation logic is correct (old token is revoked on each refresh), but the `revoked_tokens` table growing forever means the revocation check becomes slower over time.

**CORS configuration:**
- Origins are read from `CORS_ORIGINS` env var (comma-separated). Defaults to `http://localhost:3000`.
- `allow_credentials=True` with `allow_methods=["*"]` and `allow_headers=["*"]` is permissive but acceptable for a first deployment. In production, you would restrict to specific origins (your app's distribution URL).
- **Issue:** The mobile app does not have an "origin" in the traditional browser sense — CORS is irrelevant for native mobile API calls. CORS only matters for browser-based access to the API.

**Rate limiting:**
- `slowapi` applies `5/minute` on `/auth/register` and `/auth/login`, `3/minute` on `/auth/forgot-password` and `/auth/reset-password` — this is implemented and correct.
- No rate limiting on workout or nutrition endpoints — an authenticated user could spam the DB with thousands of log entries.

**API key exposure:**
- `USDA_API_KEY` is stored in environment variables on Railway — not in code. This is correct.
- The key is never returned to the client — always server-side only. Correct.
- `EXERCISEDB_URL` is an open API without authentication — no key to protect.

**What a basic security audit would flag:**
1. The `forgot-password` stub — a user can be fooled into thinking a reset email was sent when none was.
2. No HTTPS enforcement at the application level (Railway handles TLS at the platform level — acceptable).
3. The `revoked_tokens` table with no TTL cleanup is a slow denial-of-service vector.
4. Password validation is server-side only — no client-side password strength indicator.
5. No audit log — no record of who logged in when from where.

---

## PART 5 — JURY PREPARATION

### 5.1 — Likely jury questions and model answers

**Q1: Why did you use Provider instead of Bloc?**
Bloc uses streams and events — for every action you define an Event class, a State class, process the event in a Bloc, and map it to a state. For a CRUD fitness app with straightforward data loading patterns, that's significant boilerplate. Provider with `ChangeNotifier` lets you call `loadTodayNutrition()` directly and `notifyListeners()`. The logic is easier to follow and easier to debug. Bloc would be the right choice for a team project where strict separation of events and state is important for code review. Provider was the right choice here.

**Q2: How does your JWT refresh mechanism work?**
The `AuthInterceptor` in `auth_interceptor.dart` intercepts every Dio response. When a 401 arrives, `_tryRefreshToken()` calls `POST /auth/refresh` using a separate, fresh `Dio()` instance (to avoid triggering the interceptor recursively). The backend in `auth.py` decodes the refresh token, checks it's not revoked, inserts the old refresh token's `jti` into `revoked_tokens`, and issues a new access/refresh pair. The interceptor saves the new tokens and retries the original request transparently. The user never sees a logout.

**Q3: What happens if the USDA API goes down?**
The search endpoint in `food_search.py` catches `httpx.TimeoutException`, `httpx.ConnectError`, and `httpx.HTTPStatusError`. If a stale result exists in `_stale_search_cache` (a plain dict that survives even after the TTLCache expires), it returns the stale data. If there's no cached result at all, it returns HTTP 503 "USDA food search service is temporarily unavailable." The Flutter client sees this as an empty search result with an error message.

**Q4: How do you prevent SQL injection?**
SQLAlchemy's ORM uses parameterized queries everywhere. When you write `db.query(User).filter(User.email == email)`, SQLAlchemy generates `SELECT * FROM users WHERE email = $1` with the email value as a bound parameter. The value is never interpolated into the SQL string. Raw SQL strings are never used in this codebase. Pydantic schemas also validate types before they reach the ORM.

**Q5: Why are exercises stored by name instead of ID?**
This was an early design decision driven by simplicity — it meant the exercise search results (which have an ExerciseDB ID) could be discarded after adding the exercise. In practice it created fragmentation in personal records and last-session lookups. The `exercise_id` column exists in `workout_sets` as an optional field for future use, but the business logic — including PRs and history — still keys on `exercise_name`. This is one of the top things I would change.

**Q6: What is the purpose of the `revoked_tokens` table?**
JWTs are stateless by design — they're valid until they expire. If you don't want to wait for expiry (e.g. user logs out and you want that token dead immediately), you need a blocklist. When a user logs out, both the access and refresh token's `jti` (unique ID) are inserted into `revoked_tokens`. Every subsequent request calls `is_token_revoked(jti, db)` which queries this table. If the jti is there, the request is rejected even if the token hasn't expired yet.

**Q7: How does your donut chart update in real time?**
The donut chart in `nutrition_screen.dart` is inside a `Consumer<NutritionProvider>` widget. When `NutritionProvider.loadTodayNutrition()` completes, it calls `notifyListeners()`. Flutter rebuilds all `Consumer<NutritionProvider>` subtrees with the new data. The `PieChart` widget from `fl_chart` receives new `PieChartSectionData` values with updated flex proportions. `fl_chart` animates the transition between old and new values automatically using its built-in interpolation.

**Q8: What would you need to do to add a second user on the same device?**
`flutter_secure_storage` stores exactly one `access_token` and one `refresh_token`. To support multiple users: store tokens under user-specific keys (e.g. `access_token_<user_id>`), add a "switch account" UI that reads the correct token, and update `AuthInterceptor.onRequest` to use the active session's token. The backend already handles multiple users correctly — each query filters by `current_user.id`.

**Q9: How are calories burned calculated?**
The backend uses the MET (Metabolic Equivalent of Task) formula: `calories = (MET * body_weight_kg * duration_minutes) / 60`. MET for weight training is hardcoded at 3.5. The user's `weight_kg` from their profile is used, defaulting to 75.0 kg if not set. The workout `duration_seconds` is divided by 60. This is an approximation — real calorie burn depends on exercise intensity, rest periods, and physiological factors not tracked.

**Q10: What happens when ExerciseDB is down?**
`search_exercises` in `exercises.py` returns an empty list `[]` and logs a warning. No error is propagated to the client. This means if ExerciseDB is down, users get an empty search result with no explanation. A better design would return a 503 with a user-visible message. When loading a past workout that has exercises, the GIF images simply don't load — the Flutter `Image.network` widget shows an error icon which is handled by `errorBuilder`.

**Q11: How do you handle token expiry during a workout?**
If the access token expires mid-workout (30-minute sessions are uncommon but possible for long workouts), the first API call that gets a 401 triggers `AuthInterceptor._tryRefreshToken()`. This calls `POST /auth/refresh` and retries the request. From the user's perspective, the set save completes after a brief delay. If the refresh also fails (expired refresh token after 30 days), the request fails and the error propagates — the user would need to log in again but would lose the in-progress workout state since it's in memory.

**Q12: How do you handle the Railway cold start problem?**
`ApiClient.wakeServer()` calls `GET /health` with a 90-second `receiveTimeout` and swallows any error. This is called at the start of the registration flow (`AuthProvider.register()` line 85). The health endpoint is: `@app.get("/health") def health_check(): return {"status": "ok"}`. This warms the server before the actual API request.

**Q13: What is the `fdc_id` column in `nutrition_logs` and why was it added?**
USDA FoodData Central uses a numeric `fdcId` to uniquely identify each food. Adding `fdc_id` to the `nutrition_logs` table allows the app to look up the full micronutrient profile for a logged food without searching by name. Before this column was added, the micronutrient dashboard had no link from a log entry to USDA nutrient data. The column is nullable because older log entries were created before this feature.

**Q14: How does the rate limiter work?**
`slowapi` wraps `limits` library. `@limiter.limit("5/minute")` decorates a route. `app.state.limiter = limiter` and `app.add_exception_handler(RateLimitExceeded, ...)` wire it into FastAPI. The limiter uses the client's IP address (extracted from the `Request` object) as the key. After 5 requests in a minute from one IP, subsequent requests get HTTP 429 "Too Many Requests". The counter resets after 60 seconds. State is stored in memory — it resets on server restart.

**Q15: How are macro goals persisted between app sessions?**
`MacroTargetsScreen` uses `SharedPreferences` to write four integers: `macro_calorie_goal`, `macro_protein_goal`, `macro_carbs_goal`, `macro_fat_goal`. `NutritionScreen._loadMacroGoals()` reads them in `initState`. `SharedPreferences` on Android writes to a platform XML file in the app's private data directory. It survives app restarts but is cleared on app uninstall. There's a clamp (500–10,000 for calories) and a one-time migration to reset corrupted values to defaults.

**Q16: Why is the `NutritionProvider._setLoading()` method using `addPostFrameCallback`?**
```dart
void _setLoading(bool value) {
  _isLoading = value;
  WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
}
```
If `notifyListeners()` is called synchronously during a widget's `build()` phase, Flutter throws an assertion error because you can't trigger a rebuild while one is in progress. `addPostFrameCallback` defers the notification until after the current frame completes — safe at any point in the lifecycle.

**Q17: Can two users' data ever be mixed up?**
No. Every backend query filters by `user_id = current_user.id`. The `current_user` is extracted from the JWT — it's the user whose email is in the token's `sub` claim. A user cannot forge another user's ID because the JWT signature would be invalid without the `SECRET_KEY`.

**Q18: How does the micronutrient `pct_rda` calculation work?**
In `food_search.py`, for each nutrient: `pct_rda = round((amount / rda) * 100, 1)`. `amount` is the value from USDA per 100g. The frontend scales this by `log.amount / 100`. So a 250g serving of food with 30mg Iron (per 100g) contributes `30 * (250/100) = 75mg` to the dashboard, which is `75/18 * 100 = 417%` of the RDA.

**Q19: What's the difference between `logFood` and `postNutritionLog` in NutritionProvider?**
`postNutritionLog(Map payload)` takes a raw body map — used by `AddFoodScreen` when building the body manually with exact field names. `logFood(NutritionModel nutrition)` takes a `NutritionModel` — it decides to `POST` (new entry, `id.isEmpty`) or `PUT` (update existing, `id` is populated). Both call `loadTodayNutrition()` after the API call to refresh the UI.

**Q20: What would break first if you got 1000 concurrent users?**
The in-memory caches would not scale — each Railway instance has its own cache, so 1000 users across multiple instances would all miss each other's caches and hammer USDA. The `revoked_tokens` table would grow quickly and every request would query it with an increasingly expensive scan. The `personal_records` endpoint's N+1 query would become very slow. Railway's free tier PostgreSQL connection limit would be exhausted.

### 5.2 — Concepts to master before the presentation

**1. JWT (JSON Web Token)**
A JWT is a signed, base64-encoded string containing a payload of claims. The server signs it with a secret key and can verify any token without a database lookup. It's stateless — the token itself proves identity. This project uses HS256 (HMAC-SHA256), a symmetric algorithm where the same key signs and verifies.

**2. FastAPI Dependency Injection**
FastAPI's `Depends()` system calls functions automatically before a route runs. `get_db` opens and closes a DB session. `get_current_user` authenticates and returns the user. These run for every request to any route that declares them, guaranteeing auth and DB setup happen consistently.

**3. SQLAlchemy ORM**
SQLAlchemy maps Python classes to database tables. Relations like `Workout.sets = relationship("WorkoutSet", cascade="all, delete-orphan")` let you access related rows as Python lists. The session tracks changes and `db.commit()` flushes them to PostgreSQL as a transaction.

**4. Flutter's Build Cycle**
Flutter's rendering pipeline calls `build()` whenever a widget is marked dirty. `setState()` marks a `StatefulWidget` dirty. `notifyListeners()` in a `ChangeNotifier` marks all watching `Consumer`/`watch` widgets dirty. Flutter then rebuilds only the dirty subtrees, not the whole screen.

**5. Provider Pattern**
Provider makes objects available anywhere in the widget tree. `ChangeNotifierProvider` wraps a `ChangeNotifier` and makes it accessible via `context.read()` (one-time) or `context.watch()` (subscribing). It solves "prop drilling" — passing data down through many widget constructors.

**6. Dio Interceptors**
Interceptors run before requests (`onRequest`), after responses (`onResponse`), and on errors (`onError`). They allow cross-cutting concerns like auth headers and error parsing without duplicating code in every API call. The `AuthInterceptor` here handles both JWT injection and transparent token refresh.

**7. CORS (Cross-Origin Resource Sharing)**
Browsers block JavaScript from calling APIs on different origins (different domain/port). CORS headers tell the browser which origins are allowed. `CORSMiddleware` in FastAPI adds these headers. For native mobile apps, CORS is irrelevant — no browser sandbox applies.

**8. Bcrypt Password Hashing**
Bcrypt is a slow-by-design hashing algorithm that makes brute-force attacks impractical. `passlib.context.CryptContext` abstracts the hashing. `pwd_context.hash(password)` generates a unique salt per password. `pwd_context.verify(plain, hashed)` re-applies the hash and compares.

**9. Flutter Navigation with Named Routes**
`onGenerateRoute` is a function that handles all route transitions. It receives `RouteSettings` (with name and arguments), creates a `Route`, and Flutter handles the transition animation. Arguments pass typed data between screens.

**10. `Future.wait` for Parallel Requests**
`await Future.wait([future1, future2, future3])` fires all three simultaneously and returns when all complete. This is used in `StatsProvider.loadAllStats()` to load weekly volume, nutrition trend, and personal records in parallel rather than sequentially.

**11. `Dismissible` Widget**
A Flutter widget that detects swipe gestures and animates a child off-screen. `confirmDismiss` shows a dialog before the dismissal completes. `onDismissed` is called after the animation finishes. Used in the nutrition screen's food log rows for swipe-to-delete.

**12. SharedPreferences vs flutter_secure_storage**
`SharedPreferences` writes key-value pairs to a platform file (XML on Android, NSUserDefaults on iOS). It is not encrypted — readable on a rooted device. `flutter_secure_storage` uses the Android Keystore or iOS Keychain — hardware-backed encryption. JWT tokens go in secure storage; user preferences like macro goals go in SharedPreferences.

**13. `TTLCache` from cachetools**
`TTLCache(maxsize=500, ttl=3600)` is a dictionary that automatically evicts entries after `ttl` seconds. It bounds memory use with `maxsize`. Used in `food_search.py` to cache USDA responses for 1 hour (search) and 24 hours (nutrient detail). It resets on server restart.

**14. Pydantic `field_validator`**
Pydantic validators run when a model is instantiated from JSON. `@field_validator("password")` in `UserCreate` enforces minimum length, uppercase, lowercase, and digits. If any check fails, Pydantic raises a `ValidationError` which FastAPI converts to HTTP 422.

**15. SQLAlchemy `joinedload`**
`joinedload(Workout.sets)` tells SQLAlchemy to fetch `Workout` and all its `WorkoutSet` children in a single SQL JOIN query. Without it, accessing `workout.sets` triggers a lazy-load — a separate SQL query per workout (the N+1 problem). `joinedload` is used in the `list_workouts` and `get_workout` endpoints.

### 5.3 — The 5-minute project pitch

**[0:00–0:30] What the app does and who it's for**

ForgeFit is a full-stack personal fitness tracking application built for strength training athletes. It solves the problem of having your gym notebook, food diary, and progress graphs in three different places by bringing them into a single mobile app. The user can log workouts with real exercise data including animated demonstrations, track their daily nutrition against macro goals with a visual breakdown, and follow structured training programs — all from their phone.

**[0:30–1:30] Technical architecture overview**

The system is split into two layers. The backend is a Python FastAPI application running on Railway, backed by a PostgreSQL database. FastAPI gives us automatic input validation through Pydantic schemas, JWT-based authentication, and clean modular routing — each feature area has its own router file. The mobile frontend is built with Flutter, which compiles to both Android and iOS from a single Dart codebase. State management uses the Provider pattern — each feature area has a `ChangeNotifier` that holds its data and notifies the UI when to rebuild. The two layers communicate over HTTPS using the Dio HTTP client, which has an interceptor that automatically refreshes JWT tokens when they expire, making authentication completely transparent to the user.

**[1:30–3:00] The most technically interesting parts**

Three things I'm particularly proud of technically. First, the JWT refresh flow: when a user's 30-minute access token expires mid-session, the `AuthInterceptor` detects the 401, silently calls the refresh endpoint with the long-lived refresh token, saves fresh tokens, and retries the original request — the user never sees a logout dialog during an active workout. Second, the micronutrient dashboard: since older food log entries have no USDA food ID, I implemented a fallback lookup chain — when `fdc_id` is null, the system searches by food name, resolves the ID, then fetches the nutrient profile. All N lookups fire in parallel via `Future.wait` so the dashboard loads as fast as the slowest single request, not N times slower. Third, the calorie goal corruption fix: SharedPreferences had stored a 15,000 kcal goal from a previous bug. I added a one-time migration that detects values outside the valid range and resets them silently, with an in-code clamp as ongoing protection.

**[3:00–4:00] Challenges faced and how they were solved**

The hardest challenge was the exercise identity problem. Exercises are stored by name, and the "last session" feature — which shows what weight you lifted last time — needs to match exercises between workouts. A case mismatch or typo returns no data. I solved it at the query level using `func.lower(exercise_name) == name.lower()` in the ORM so "Bench Press" and "bench press" always match. The long-term fix — which I would implement next if continuing — is switching to stable ExerciseDB IDs as the primary key. The second challenge was Railway's cold start. The server sleeps after inactivity and takes up to 90 seconds to respond. I added a `wakeServer()` call that fires `GET /health` with a generous timeout before the registration request, so new users never hit a timeout on their first action.

**[4:00–5:00] What you learned and what you'd improve**

Building this project, I learned that simple data decisions made on day one create compounding consequences later. Storing exercise names as the identifier instead of stable IDs seemed convenient but made PRs and history unreliable the moment I had any inconsistency in naming. I also learned that in-memory caching on a PaaS platform is basically no caching at all — every deployment wipes it. The three improvements I'd make if continuing: implement the forgot-password flow (it's a stub today), migrate caches to Redis so they survive deployments, and add an Alembic migration system so adding database columns doesn't require manually running ALTER TABLE. The project taught me the full cycle of building a production API — auth, validation, external API integration, deployment, and the kind of bugs you only find when real data hits real code.
