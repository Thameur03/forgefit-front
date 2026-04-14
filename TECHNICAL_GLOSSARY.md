═══════════════════════════════════════════════════════════════
  FORGEFIT — COMPLETE TECHNICAL GLOSSARY
  A Senior-Engineer-Level Reference Guide for Everything in the Stack
═══════════════════════════════════════════════════════════════

PROJECT: ForgeFit
STACK: Flutter (Dart) Mobile App + FastAPI (Python) Backend + PostgreSQL Database
DATE GENERATED: April 2026
TOTAL TERMS: 167+
CATEGORIES: Web Fundamentals · Backend · Database · Frontend · Mobile · Security · DevOps · Programming Concepts · Design Patterns · Data Formats

HOW TO USE THIS GLOSSARY
────────────────────────────────────────────────────────────────
• Read each entry in the order suggested in the RECOMMENDED LEARNING ORDER (at the end).
• For each search query, paste Query 1 into YouTube first, then Query 3 into Google once comfortable.
• "UNDERSTAND THIS BEFORE" tells you the prerequisites — read those entries first if they're unfamiliar.
• The "HOW IT SHOWS UP IN FORGEFIT" section is always specific to actual files and features — cross-reference with the codebase as you read.

TABLE OF CONTENTS
────────────────────────────────────────────────────────────────
GROUP 1 — Web Fundamentals (Internet, HTTP, REST, JSON)
GROUP 2 — Backend (Python, FastAPI, Uvicorn, Pydantic, Middleware)
GROUP 3 — Database (PostgreSQL, SQLAlchemy, ORM, Alembic, Migrations)
GROUP 4 — Authentication & Security (JWT, bcrypt, Rate Limiting)
GROUP 5 — Flutter & Mobile Frontend (Widgets, Navigation, Providers)
GROUP 6 — State Management (State, Provider, Reactive UI)
GROUP 7 — External APIs & Data (USDA, ExerciseDB, Caching)
GROUP 8 — DevOps & Deployment (Railway, Environments, Scaling)
GROUP 9 — Programming Concepts (OOP, Async, Error Handling)
GROUP 10 — Design Patterns & Architecture (CRUD, DI, Observer)
RECOMMENDED LEARNING ORDER — 5-Stage Learning Path with Resources

# ForgeFit Complete Technical Glossary

═══════════════════════════════════════
GROUP 1 — WEB & INTERNET FUNDAMENTALS
═══════════════════════════════════════

──────────────────────────────
TERM: Internet
CATEGORY: Web Fundamentals
IN ONE SENTENCE: A massive worldwide network of computers that can talk to each other and share information at any time.
THE REAL-WORLD ANALOGY: Imagine every city on Earth connected by an invisible postal road system — any house (computer) can send a letter (data) to any other house instantly. The roads are cables and Wi-Fi signals; the postal system is a set of agreed-upon rules called protocols.
HOW IT SHOWS UP IN FORGEFIT: Everything ForgeFit does depends on the Internet. When the Flutter app sends your workout data to the FastAPI backend running on Railway, or when the backend fetches food nutrition info from the USDA API, all of that data travels over the Internet.
WHY IT EXISTS: Before the Internet, computers were isolated islands. Researchers needed a way to share data between universities in case a nuclear attack destroyed one site, so ARPANET was born in 1969 and eventually grew into the modern Internet.
SEARCH THIS ONLINE:
  → Query 1 (beginner): how does the internet work for beginners explained
  → Query 2 (intermediate): how data travels through the internet TCP IP explained
  → Query 3 (deep dive): internet infrastructure BGP routing explained
UNDERSTAND THIS BEFORE: Nothing — this is the starting point.
──────────────────────────────

──────────────────────────────
TERM: HTTP
CATEGORY: Web Fundamentals
IN ONE SENTENCE: The agreed-upon language that web browsers and servers use to ask for and send information to each other.
THE REAL-WORLD ANALOGY: Imagine a very formal restaurant. HTTP is the menu format and ordering ritual — the waiter (server) and customer (browser) follow an exact script: you say "GET me the pasta," the waiter says "200 OK" and brings it. Both sides have to speak the same language or nothing gets ordered.
HOW IT SHOWS UP IN FORGEFIT: Every call from the Flutter Dio HTTP client to the FastAPI backend uses HTTP. For example, POST /auth/login sends your credentials, and GET /nutrition/daily returns the day's food logs — all HTTP requests and responses.
WHY IT EXISTS: In the early 1990s, Tim Berners-Lee needed a simple, consistent way for web browsers to ask servers for web pages. HTTP gave every browser and server a shared language so that any browser could talk to any server.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is HTTP explained simply
  → Query 2 (intermediate): HTTP request response cycle explained
  → Query 3 (deep dive): HTTP 1.1 vs HTTP 2 vs HTTP 3 differences
UNDERSTAND THIS BEFORE: Internet
──────────────────────────────

──────────────────────────────
TERM: HTTPS
CATEGORY: Web Fundamentals
IN ONE SENTENCE: HTTP with a lock on it — it scrambles all the data so that only the sender and receiver can read it, not anyone spying in the middle.
THE REAL-WORLD ANALOGY: Sending a postcard is like HTTP — the postman can read it. HTTPS is like putting that postcard inside a locked safe: only the person with the key (the server's private certificate) can open it, even if someone intercepts the safe mid-delivery.
HOW IT SHOWS UP IN FORGEFIT: The Railway-hosted ForgeFit backend is served over HTTPS. When you log in through the app, your password travels over an encrypted HTTPS connection so no one snooping on the network can steal it.
WHY IT EXISTS: HTTP sent passwords and credit card numbers in plain readable text — anyone on the same Wi-Fi network could steal them. HTTPS was invented to make web communication private and tamper-proof.
SEARCH THIS ONLINE:
  → Query 1 (beginner): difference between HTTP and HTTPS for beginners
  → Query 2 (intermediate): how HTTPS TLS handshake works
  → Query 3 (deep dive): TLS 1.3 certificate pinning mobile apps
UNDERSTAND THIS BEFORE: HTTP, SSL/TLS
──────────────────────────────

──────────────────────────────
TERM: SSL / TLS
CATEGORY: Web Fundamentals
IN ONE SENTENCE: A security technology that wraps internet traffic in a secret code so that only the two parties communicating can understand it.
THE REAL-WORLD ANALOGY: SSL/TLS is like two spies agreeing on a secret codebook before having a conversation. Even if someone records every word they say, without the codebook it's pure gibberish. The "handshake" is when they first agree on which codebook to use.
HOW IT SHOWS UP IN FORGEFIT: Railway automatically provisions TLS certificates for the ForgeFit backend domain, meaning all HTTPS traffic between the Flutter app and the API is encrypted without any extra configuration.
WHY IT EXISTS: When e-commerce became popular in the 1990s, people needed to send credit card numbers over the internet safely. Netscape invented SSL (later improved and renamed TLS) to make that possible.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is SSL TLS certificate explained simply
  → Query 2 (intermediate): TLS handshake process step by step
  → Query 3 (deep dive): TLS 1.3 vs TLS 1.2 performance security improvements
UNDERSTAND THIS BEFORE: Internet, HTTP
──────────────────────────────

──────────────────────────────
TERM: Request
CATEGORY: Web Fundamentals
IN ONE SENTENCE: A message sent by an app or browser to a server asking it to do something or give back some information.
THE REAL-WORLD ANALOGY: A request is exactly like placing an order at a coffee shop — you specify what you want (a latte), any customisation (oat milk), and hand the order slip to the barista. The barista is the server. You don't make the coffee yourself; you ask someone else to.
HOW IT SHOWS UP IN FORGEFIT: The Flutter app sends requests constantly. When you open the Nutrition tab, it sends a GET request to /nutrition/daily. When you log a set in a workout, it sends a POST request to /workouts/{id}/sets. Every user action that needs data from the backend is wrapped in a request.
WHY IT EXISTS: Computers needed a standardised message format so that any client could ask any server for data and both sides would understand perfectly what was being asked.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is an HTTP request explained
  → Query 2 (intermediate): anatomy of an HTTP request headers body method
  → Query 3 (deep dive): HTTP request lifecycle from browser to server
UNDERSTAND THIS BEFORE: HTTP, Internet
──────────────────────────────

──────────────────────────────
TERM: Response
CATEGORY: Web Fundamentals
IN ONE SENTENCE: The server's answer to a request — it includes a status code saying whether it worked plus any data that was asked for.
THE REAL-WORLD ANALOGY: If a request is a question on a quiz show, a response is the host's answer sheet: it first says whether you got it right (status code), then reveals the correct answer (the data). Even "I don't know" (404) and "you're not allowed to know" (403) are valid responses.
HOW IT SHOWS UP IN FORGEFIT: When the Flutter app requests today's nutrition log, the FastAPI backend responds with a JSON object containing calories, macros, and meal entries. When login fails, the response carries a 401 status code and a detail message the app shows the user.
WHY IT EXISTS: Requests needed a matching answer format so clients knew immediately whether the operation succeeded, failed, or needs to be retried — along with the actual data they need.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is an HTTP response explained simply
  → Query 2 (intermediate): HTTP response status codes and body explained
  → Query 3 (deep dive): HTTP response headers caching content negotiation
UNDERSTAND THIS BEFORE: Request, HTTP
──────────────────────────────

──────────────────────────────
TERM: URL / Endpoint
CATEGORY: Web Fundamentals
IN ONE SENTENCE: A URL is the web address of a resource; an endpoint is a specific URL on an API that performs one action when called.
THE REAL-WORLD ANALOGY: A URL is like a street address — it tells you exactly where to go. An endpoint is like a specific room in an office building: https://api.forgefit.com/nutrition/daily is the "nutrition daily report room." Knock on that door with the right request and you get your macros back.
HOW IT SHOWS UP IN FORGEFIT: The FastAPI backend in main.py defines endpoints like /auth/login, /workouts, /food/search. The Flutter app's ApiClient stores the base URL and appends endpoint paths to construct complete URLs for each API call.
WHY IT EXISTS: Without addresses, the Internet would have no way to locate specific resources. URLs were invented so that every piece of information on the web has a unique, shareable, clickable address.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a URL explained simply parts of a URL
  → Query 2 (intermediate): what is an API endpoint vs URL difference
  → Query 3 (deep dive): URL design best practices REST API naming conventions
UNDERSTAND THIS BEFORE: HTTP, Internet
──────────────────────────────

──────────────────────────────
TERM: REST API
CATEGORY: Web Fundamentals
IN ONE SENTENCE: A very popular set of rules for how apps should talk to servers using the web's standard tools — simple, consistent, and readable.
THE REAL-WORLD ANALOGY: REST is like the standardised menu format all fast-food chains follow globally: you always have a menu (resources), you can order (GET), add an item (POST), replace an order (PUT), or cancel (DELETE). Different restaurants, same ordering style.
HOW IT SHOWS UP IN FORGEFIT: The entire ForgeFit backend is a REST API. Resources like /workouts and /nutrition follow REST conventions where GET retrieves data, POST creates new records, PUT updates them, and DELETE removes them — the Flutter app treats each URL as a named resource.
WHY IT EXISTS: Earlier APIs were inconsistent — every service had its own calling conventions. Roy Fielding defined REST in his 2000 PhD dissertation to give developers one universal style for building web APIs that is simple, scalable, and stateless.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a REST API explained simply
  → Query 2 (intermediate): REST API design principles tutorial
  → Query 3 (deep dive): REST vs GraphQL vs gRPC comparison
UNDERSTAND THIS BEFORE: HTTP, URL/Endpoint
──────────────────────────────

──────────────────────────────
TERM: API (Application Programming Interface)
CATEGORY: Web Fundamentals
IN ONE SENTENCE: A set of rules that lets two separate software programs talk to each other and share data without either knowing how the other is built inside.
THE REAL-WORLD ANALOGY: A TV remote is an API for your television. You press Volume Up (an agreed function), the TV increases volume — you don't need to know anything about the TV's internal electronics. The remote is the interface between you and the complex system.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit has multiple APIs in play: the custom FastAPI backend is an API the Flutter app talks to; ExerciseDB is a third-party API the backend calls for exercise data; and the USDA FoodData Central API provides nutrition information to the food_search router.
WHY IT EXISTS: Without APIs, every app would have to be built as one giant monolith, or duplicate data and logic across systems. APIs let teams build specialised components that any other software can safely use without sharing source code.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is an API explained simply no jargon
  → Query 2 (intermediate): how to call a REST API with code examples
  → Query 3 (deep dive): API design public vs private API versioning strategies
UNDERSTAND THIS BEFORE: Internet, HTTP
──────────────────────────────

──────────────────────────────
TERM: JSON
CATEGORY: Data Format
IN ONE SENTENCE: A simple text format that uses curly braces and key-value pairs that both humans and computers can easily read to exchange data.
THE REAL-WORLD ANALOGY: JSON is like a filled-in form with labelled fields. Instead of a blank sheet of paper, you have "name: Thameur, age: 25, weight: 80kg" — clearly organised, no ambiguity, can be read by anyone who knows the form layout.
HOW IT SHOWS UP IN FORGEFIT: Almost all data exchanged between the Flutter app and the FastAPI backend is JSON. When you log food, the app sends JSON like {"meal": "breakfast", "fdc_id": 123456, "quantity_g": 150}. FastAPI receives it, validates it with Pydantic, and saves it to the database.
WHY IT EXISTS: Before JSON, XML was the dominant data format — it was complex, verbose, and hard to parse in JavaScript. Douglas Crockford standardised JSON in the early 2000s as a lightweight alternative that maps directly to objects in almost every programming language.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is JSON explained simply with examples
  → Query 2 (intermediate): JSON format rules syntax tutorial
  → Query 3 (deep dive): JSON Schema validation API design
UNDERSTAND THIS BEFORE: API, Internet
──────────────────────────────

──────────────────────────────
TERM: HTTP Methods (GET, POST, PUT, DELETE, PATCH)
CATEGORY: Web Fundamentals
IN ONE SENTENCE: The five "verbs" that tell a server what action to perform — fetch, create, replace, delete, or partially update a resource.
THE REAL-WORLD ANALOGY: Think of HTTP methods as the verbs you use at a library: GET = "show me the book"; POST = "add this new book to the catalogue"; PUT = "replace this book with a new edition entirely"; PATCH = "just correct the misprint on page 42"; DELETE = "remove this book permanently."
HOW IT SHOWS UP IN FORGEFIT: In auth.py, @router.post("/login") handles logins. In workouts.py, @router.get("/") fetches all workouts and @router.delete("/{id}") deletes one. The Flutter app's ApiClient uses dio.get(), dio.post(), dio.put(), and dio.delete() to match these backend routes.
WHY IT EXISTS: Without standardised verbs, every API would invent its own language — "fetchUser", "grabUser", "retrieveUser" could all mean the same thing. REST borrowed HTTP's built-in verbs so all APIs speak one consistent grammar.
SEARCH THIS ONLINE:
  → Query 1 (beginner): HTTP methods GET POST PUT DELETE explained simply
  → Query 2 (intermediate): when to use PUT vs PATCH HTTP methods
  → Query 3 (deep dive): HTTP idempotency safe methods REST API design
UNDERSTAND THIS BEFORE: HTTP, REST API
──────────────────────────────

──────────────────────────────
TERM: HTTP Status Codes (200, 201, 400, 401, 403, 404, 422, 500, 503)
CATEGORY: Web Fundamentals
IN ONE SENTENCE: Three-digit numbers that a server sends back to instantly tell the app whether the request worked, failed, or hit a specific kind of problem.
THE REAL-WORLD ANALOGY: Status codes are like emoji reactions to a message: ✅ (200 OK = "here's your data"), 🆕 (201 Created = "I made the new record"), 🚫 (401 Unauthorised = "who are you?"), 🔒 (403 Forbidden = "I know who you are, but no"), ❓ (404 Not Found = "I can't find that"), 💥 (500 Server Error = "I crashed").
HOW IT SHOWS UP IN FORGEFIT: In routers/auth.py, registration returns status_code=201, a bad login returns 401, and Pydantic validation failures automatically return 422. The food_search router returns 503 when the USDA API is unreachable. The Flutter app reads these codes to decide what message to show the user.
WHY IT EXISTS: Without standardised result codes, every API would force clients to parse error messages as text to know what went wrong. Status codes give an immediate, language-independent signal about what happened.
SEARCH THIS ONLINE:
  → Query 1 (beginner): HTTP status codes 200 404 500 explained simply
  → Query 2 (intermediate): complete list HTTP status codes meaning
  → Query 3 (deep dive): HTTP status codes best practices REST API error handling
UNDERSTAND THIS BEFORE: HTTP, Response
──────────────────────────────

──────────────────────────────
TERM: Headers
CATEGORY: Web Fundamentals
IN ONE SENTENCE: Hidden metadata attached to every request and response that carries extra instructions like what language the data is in, who's asking, and how long to cache it.
THE REAL-WORLD ANALOGY: Headers are like the label on a package: the package is the request body (the actual letter inside), but the label on the outside tells the postman the sender's address, the recipient, the content type ("fragile"), and any special instructions — before they even open it.
HOW IT SHOWS UP IN FORGEFIT: The Flutter AuthInterceptor adds an "Authorization: Bearer <token>" header to every outgoing request so the FastAPI backend can identify who's making the call. FastAPI's CORSMiddleware inspects the "Origin" header to decide whether to allow cross-origin requests.
WHY IT EXISTS: HTTP needed a way to pass metadata separately from the content itself — things like authentication, compression type, and caching instructions shouldn't be mixed into the data payload. Headers provide that clean separation.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what are HTTP headers explained simply
  → Query 2 (intermediate): important HTTP request and response headers explained
  → Query 3 (deep dive): custom HTTP headers security CORS preflight requests
UNDERSTAND THIS BEFORE: HTTP, Request
──────────────────────────────

──────────────────────────────
TERM: Request Body
CATEGORY: Web Fundamentals
IN ONE SENTENCE: The section of an HTTP request that holds the actual data being sent to the server, like a form you've filled in and are submitting.
THE REAL-WORLD ANALOGY: If a request is an envelope, the request body is the letter inside. The envelope has an address (URL), postage (headers), and a return address (metadata), but the actual contents — the message you're sending — live inside the envelope as the body.
HOW IT SHOWS UP IN FORGEFIT: When you log food in ForgeFit, the Flutter app sends a POST request to /nutrition/log with a JSON body like {"fdc_id": 789, "meal": "lunch", "quantity_g": 200}. FastAPI reads this body and validates it against a Pydantic schema before saving it.
WHY IT EXISTS: GET requests can pass small amounts of data in the URL, but URLs have length limits and shouldn't carry sensitive data like passwords. Request bodies allow unlimited structured data to be sent securely on POST/PUT operations.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is HTTP request body explained
  → Query 2 (intermediate): request body vs query parameters when to use each
  → Query 3 (deep dive): HTTP request body multipart form-data vs JSON API design
UNDERSTAND THIS BEFORE: HTTP, Request, JSON
──────────────────────────────

──────────────────────────────
TERM: Query Parameters
CATEGORY: Web Fundamentals
IN ONE SENTENCE: Optional filters or options you tack onto the end of a URL after a question mark to narrow down or customise what the server returns.
THE REAL-WORLD ANALOGY: Query parameters are like search filters on a shopping website. The base URL is the store (/products), but adding ?category=shoes&size=42&color=black tells the store exactly what subset of products you want to see — the store's catalogue doesn't change, only the results shown.
HOW IT SHOWS UP IN FORGEFIT: The food search endpoint GET /food/search uses query parameters: ?q=chicken&limit=10. In food_search.py, FastAPI reads these with q: str = Query(...) and limit: int = Query(10). The Flutter app appends these when the user types in the search bar.
WHY IT EXISTS: Often you want one endpoint to handle many variations of the same request. Query parameters let clients customise requests without needing dozens of separate endpoints for every possible combination.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what are URL query parameters explained simply
  → Query 2 (intermediate): query parameters vs path parameters REST API
  → Query 3 (deep dive): REST API query parameter design filtering sorting pagination
UNDERSTAND THIS BEFORE: URL/Endpoint, HTTP
──────────────────────────────

──────────────────────────────
TERM: Path Parameters
CATEGORY: Web Fundamentals
IN ONE SENTENCE: Variable parts baked into the URL itself that identify a specific resource, like the ID of a workout or a food item.
THE REAL-WORLD ANALOGY: Path parameters are like the room number in a hotel address. "Please go to Floor 3, Room 47" — the floor and room number are path parameters embedded in the location itself, not written on a sticky note attached to the envelope.
HOW IT SHOWS UP IN FORGEFIT: The endpoint DELETE /workouts/{workout_id} in workouts.py uses {workout_id} as a path parameter. When the Flutter app wants to delete workout #42, it calls DELETE /workouts/42 and FastAPI automatically extracts 42 as the workout_id variable.
WHY IT EXISTS: REST API conventions require each resource to have a unique URL. Path parameters make it possible to address any individual record (workout #42 vs #43) without needing separate hard-coded endpoints for every possible ID.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what are path parameters in REST APIs explained
  → Query 2 (intermediate): path parameters vs query parameters when to use
  → Query 3 (deep dive): REST URL design resource identification best practices
UNDERSTAND THIS BEFORE: URL/Endpoint, REST API
──────────────────────────────

──────────────────────────────
TERM: Client
CATEGORY: Web Fundamentals
IN ONE SENTENCE: Any app or device that sends requests to a server asking for data or actions — in ForgeFit, this is the Flutter mobile app.
THE REAL-WORLD ANALOGY: A client is the customer at a restaurant. The customer (Flutter app) does not cook the food — they just ask for it, receive it, and present it nicely on the table (on screen). All the cooking happens in the kitchen (the server/backend).
HOW IT SHOWS UP IN FORGEFIT: The Flutter app is the client. It uses the Dio HTTP client (lib/core/network/api_client.dart) to send requests to the FastAPI backend. It never directly touches the PostgreSQL database — it always asks the server to do that.
WHY IT EXISTS: Separating client from server means you can have many different clients (iOS app, Android app, web browser) all talking to the same server without duplicating business logic in every client.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a client server model explained simply
  → Query 2 (intermediate): client server architecture explained with examples
  → Query 3 (deep dive): client server vs peer to peer vs serverless architecture
UNDERSTAND THIS BEFORE: Internet, HTTP
──────────────────────────────

──────────────────────────────
TERM: Server
CATEGORY: Web Fundamentals
IN ONE SENTENCE: A computer that sits and listens for incoming requests, processes them, and sends back responses — it does the heavy lifting.
THE REAL-WORLD ANALOGY: A server is the kitchen of the restaurant. It never approaches customers; it waits for orders, executes them (cook the meal, retrieve the data), and sends results back. It runs 24/7, handling potentially thousands of "orders" at once.
HOW IT SHOWS UP IN FORGEFIT: The FastAPI application running on Railway is the server for ForgeFit. Uvicorn is the process that actually listens on a port and hands incoming HTTP connections to FastAPI. The server holds all the business logic and is the only thing that touches the database directly.
WHY IT EXISTS: Keeping logic and data on a centralised server means every client sees the same data, security can be enforced in one place, and the powerful computing/storage stays on hardware you control rather than on every user's phone.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a web server explained simply
  → Query 2 (intermediate): how a web server handles requests explained
  → Query 3 (deep dive): web server vs application server vs database server
UNDERSTAND THIS BEFORE: Internet, HTTP, Client
──────────────────────────────

──────────────────────────────
TERM: Frontend
CATEGORY: Web Fundamentals
IN ONE SENTENCE: The part of an application that the user actually sees and touches — the screens, buttons, colours, and animations.
THE REAL-WORLD ANALOGY: Frontend is the dining room of a restaurant — the tablecloths, menus, lighting, and the waiter you interact with. It's everything visible to the guest. No matter how chaotic the kitchen is, if the dining room looks beautiful and works smoothly, guests are happy.
HOW IT SHOWS UP IN FORGEFIT: The Flutter app living in /home/thameur/forgefit is the frontend. Every screen — the Nutrition tab, the Workout Logger, the Barcode Scanner — is frontend code. It displays data, collects input, and calls the backend API to do the actual work.
WHY IT EXISTS: Applications need a human-facing layer that is easy to understand and interact with. Frontend separates "how data looks and feels" from "how data is stored and processed," letting designers and developers specialise.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is frontend development explained simply
  → Query 2 (intermediate): frontend vs backend developer roles explained
  → Query 3 (deep dive): frontend architecture patterns MVC MVVM Flutter
UNDERSTAND THIS BEFORE: Client
──────────────────────────────

──────────────────────────────
TERM: Backend
CATEGORY: Web Fundamentals
IN ONE SENTENCE: The invisible engine behind an app that handles data storage, business rules, security, and serves results back to the frontend.
THE REAL-WORLD ANALOGY: Backend is the kitchen of the restaurant — hidden, functional, and powerful. Chefs (server code) receive orders (requests), execute recipes (business logic), retrieve ingredients from the pantry (database), and plate the food (JSON response) to be carried out by the waiter (API).
HOW IT SHOWS UP IN FORGEFIT: The FastAPI application in /home/thameur/forgeFit-Back is the backend. It handles all authentication, workout logging, nutrition tracking, calorie calculations, and database operations. The Flutter app never does any of this work itself.
WHY IT EXISTS: You can't trust the frontend — users can modify app code on their device. The backend is where you enforce rules ("you can only delete your own workouts"), protect data, and centralise logic so it works identically for all clients.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is backend development explained simply
  → Query 2 (intermediate): backend API design with Python FastAPI tutorial
  → Query 3 (deep dive): backend architecture microservices vs monolith
UNDERSTAND THIS BEFORE: Server, API
──────────────────────────────

──────────────────────────────
TERM: Full-Stack
CATEGORY: Web Fundamentals
IN ONE SENTENCE: Someone (or a project) that covers both the frontend user interface AND the backend server and database — the entire technology stack from top to bottom.
THE REAL-WORLD ANALOGY: A full-stack developer is like a one-person restaurant owner who is also the chef, the waiter, and the accountant. They design the menu (UI), cook the food (backend logic), manage the pantry (database), and handle the books (deployment). Specialised restaurants have separate staff for each role.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit is a full-stack project. You built and maintain both the Flutter frontend (/home/thameur/forgefit) and the FastAPI backend (/home/thameur/forgeFit-Back), making you a full-stack developer on this project.
WHY IT EXISTS: The term "full-stack" emerged as web technology split into increasingly specialised disciplines. Companies and recruiters needed a way to describe developers comfortable working across the entire system rather than only one layer.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what does full stack developer mean explained
  → Query 2 (intermediate): full stack developer roadmap 2024
  → Query 3 (deep dive): frontend backend database DevOps full stack architecture overview
UNDERSTAND THIS BEFORE: Frontend, Backend
──────────────────────────────

═══════════════════════════════════════
GROUP 2 — BACKEND (FastAPI / Python)
═══════════════════════════════════════

──────────────────────────────
TERM: Python
CATEGORY: Backend
IN ONE SENTENCE: A beginner-friendly programming language known for its readable, plain-English-like code that powers everything from websites to AI.
THE REAL-WORLD ANALOGY: Python is like writing instructions in near-plain English instead of a dense legal contract. Compare "for each apple in the basket, if it's red, put it in the box" with the cryptic syntax of older languages. Python reads almost like that sentence.
HOW IT SHOWS UP IN FORGEFIT: The entire ForgeFit backend is written in Python — all routers, models, schemas, auth utilities, and database logic. Python was chosen for its simplicity, its massive library ecosystem (FastAPI, SQLAlchemy, Pydantic, passlib all exist as Python packages), and its speed of development.
WHY IT EXISTS: Early programming languages prioritised machine efficiency over human readability. Guido van Rossum created Python in 1991 to make programming more accessible and productive, prioritising developer happiness over raw performance.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python for beginners complete tutorial
  → Query 2 (intermediate): Python functions classes and modules explained
  → Query 3 (deep dive): Python async programming asyncio explained
UNDERSTAND THIS BEFORE: Nothing — Python is a starting point.
──────────────────────────────

──────────────────────────────
TERM: FastAPI
CATEGORY: Backend
IN ONE SENTENCE: A modern Python tool for building APIs quickly, with automatic documentation, data validation, and excellent performance built in.
THE REAL-WORLD ANALOGY: FastAPI is like a pre-assembled IKEA kitchen: all the major pieces (validation, routing, documentation, security) are included in the box with clear instructions. You focus on customising the layout rather than manufacturing every screw yourself.
HOW IT SHOWS UP IN FORGEFIT: main.py creates the FastAPI app instance, registers CORSMiddleware, rate limiter, and mounts all routers. Every route in auth.py, workouts.py, nutrition.py, etc., is FastAPI routing code. FastAPI also auto-generates the interactive docs at /docs.
WHY IT EXISTS: Flask and Django (older Python frameworks) required significant boilerplate for common API tasks like validation and serialisation. Sebastián Ramírez built FastAPI in 2018 to combine the speed of async Python with automatic validation via Pydantic and zero-effort documentation.
SEARCH THIS ONLINE:
  → Query 1 (beginner): FastAPI tutorial for beginners Python REST API
  → Query 2 (intermediate): FastAPI routing Pydantic validation dependency injection
  → Query 3 (deep dive): FastAPI performance benchmarks async database patterns
UNDERSTAND THIS BEFORE: Python, REST API, HTTP
──────────────────────────────

──────────────────────────────
TERM: Uvicorn
CATEGORY: Backend
IN ONE SENTENCE: The lightweight, high-speed program that actually starts the ForgeFit server and listens for incoming internet connections.
THE REAL-WORLD ANALOGY: Uvicorn is the front-door receptionist for the FastAPI building. FastAPI is the whole office complex, but without the receptionist standing at the door listening for visitors (HTTP requests) and directing them inside, nobody gets in. Uvicorn is that door-answering layer.
HOW IT SHOWS UP IN FORGEFIT: The Procfile in the backend root contains the command to start Uvicorn: "web: uvicorn main:app --host 0.0.0.0 --port $PORT". Railway reads this file and runs Uvicorn to serve the FastAPI app when the backend is deployed.
WHY IT EXISTS: FastAPI is a framework that defines what to do with requests — but it doesn't listen on a port itself. ASGI servers like Uvicorn handle the low-level work of receiving TCP connections and handing them to the framework.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is Uvicorn Python explained simply
  → Query 2 (intermediate): Uvicorn vs Gunicorn ASGI WSGI difference
  → Query 3 (deep dive): Uvicorn workers configuration production deployment
UNDERSTAND THIS BEFORE: FastAPI, Server
──────────────────────────────

──────────────────────────────
TERM: ASGI
CATEGORY: Backend
IN ONE SENTENCE: A standard interface that lets Python web frameworks like FastAPI communicate with web servers like Uvicorn in a way that supports modern async programming.
THE REAL-WORLD ANALOGY: ASGI is like a universal power adapter standard. Uvicorn (the plug) and FastAPI (the device) both comply with the ASGI standard, so they connect and work together without either needing to know the other's internal details.
HOW IT SHOWS UP IN FORGEFIT: FastAPI is an ASGI framework. When Railway runs the Procfile command, Uvicorn starts as an ASGI server and loads main:app — the app object is FastAPI's ASGI-compliant application. This lets ForgeFit handle async requests efficiently.
WHY IT EXISTS: The older WSGI standard couldn't handle WebSockets or async operations. ASGI was created to give Python web frameworks a way to support long-lived connections and async code, enabling modern, fast-response APIs.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is ASGI vs WSGI Python explained simply
  → Query 2 (intermediate): ASGI Python async web framework explained
  → Query 3 (deep dive): ASGI specification PEP async Python web servers
UNDERSTAND THIS BEFORE: Python, Uvicorn, Async/Await
──────────────────────────────

──────────────────────────────
TERM: Router (APIRouter)
CATEGORY: Backend
IN ONE SENTENCE: A way to split a large FastAPI application into separate organised files, each handling one feature's routes, then plugging them all together in the main app.
THE REAL-WORLD ANALOGY: An APIRouter is like a department in a company. The HR department (auth router) handles hiring and payroll; the operations department (workouts router) handles projects. The CEO's office (main.py) doesn't do the actual work — it just knows which department to forward each request to.
HOW IT SHOWS UP IN FORGEFIT: main.py imports routers from routers/auth.py, routers/workouts.py, routers/nutrition.py, etc. Each file creates its own router = APIRouter() and defines only its own routes. main.py mounts them all with app.include_router(auth_router, prefix="/auth").
WHY IT EXISTS: Putting all routes in one file is unmanageable in large apps. APIRouter lets teams split code by feature, work in parallel, and keep each module focused on one area without everything colliding in a single massive file.
SEARCH THIS ONLINE:
  → Query 1 (beginner): FastAPI APIRouter explained tutorial
  → Query 2 (intermediate): FastAPI router organisation project structure best practices
  → Query 3 (deep dive): FastAPI large application structure modular routers
UNDERSTAND THIS BEFORE: FastAPI, Python
──────────────────────────────

──────────────────────────────
TERM: Endpoint / Route
CATEGORY: Backend
IN ONE SENTENCE: A specific URL + HTTP method combination in the backend that executes a particular piece of code when called.
THE REAL-WORLD ANALOGY: An endpoint is like a specific button on a vending machine. Button A3 always gives you a Coke; button B7 always gives you crisps. Each combination (row + column) maps to one specific action. In APIs, the URL is the row and the HTTP method is the column.
HOW IT SHOWS UP IN FORGEFIT: @router.post("/login") in routers/auth.py is an endpoint — it handles POST requests to /auth/login specifically. @router.get("/daily") in routers/nutrition.py handles GET /nutrition/daily. There are dozens of such endpoints across all ForgeFit routers.
WHY IT EXISTS: Applications need to expose specific capabilities to clients in a predictable, addressable way. Endpoints define the public "contract" of what an API can do, making it usable by any client without guessing.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is an API endpoint explained simply
  → Query 2 (intermediate): FastAPI route endpoint definition tutorial
  → Query 3 (deep dive): REST endpoint design naming conventions versioning
UNDERSTAND THIS BEFORE: FastAPI, Router, URL/Endpoint
──────────────────────────────

──────────────────────────────
TERM: Decorator (@app.get, @router.post, etc.)
CATEGORY: Backend
IN ONE SENTENCE: A special Python label placed above a function that adds extra behaviour to it — in FastAPI, decorators register a function as an API endpoint.
THE REAL-WORLD ANALOGY: A decorator is like a badge you pin on a person that changes their role. Adding @router.post("/login") above a function is like pinning a "Login Handler: responds to POST /login" badge on it. From that moment on, FastAPI knows to call that function when that specific request arrives.
HOW IT SHOWS UP IN FORGEFIT: Every endpoint in the ForgeFit backend is created with a decorator. @router.post("/register") registers the register() function. @router.get("/me") registers get_me(). @limiter.limit("5/minute") is another decorator that adds rate limiting to that specific endpoint.
WHY IT EXISTS: Without decorators, developers would need to manually register every function with the routing system using verbose code. Decorators let frameworks add powerful behaviour like routing, validation, and documentation with a single line above each function.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python decorators explained simply for beginners
  → Query 2 (intermediate): Python decorators how they work with examples
  → Query 3 (deep dive): FastAPI decorators route registration under the hood
UNDERSTAND THIS BEFORE: Python, Function, FastAPI
──────────────────────────────

──────────────────────────────
TERM: Pydantic
CATEGORY: Backend
IN ONE SENTENCE: A Python library that automatically checks that incoming data matches the expected shape and type, rejecting anything that doesn't fit.
THE REAL-WORLD ANALOGY: Pydantic is like a strict customs agent at the border. You declare "I'm bringing a UserCreate: email (text), password (text), weight (number, 20–300)." Anything that doesn't match the declaration — a name where a number should go, a missing required field — is immediately rejected with a clear explanation of why.
HOW IT SHOWS UP IN FORGEFIT: All schemas in /forgeFit-Back/schemas/ are Pydantic models. UserCreate, Token, LoginBody — these define the exact shape of data FastAPI accepts and returns. When the Flutter app sends a request with a missing field or wrong type, Pydantic automatically rejects it with a 422 error before any business logic runs.
WHY IT EXISTS: Without input validation, malformed data silently corrupts databases or crashes servers. Pydantic was created to make validation declarative (describe the rules once in a class) rather than imperative (write if/else checks everywhere).
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is Pydantic Python explained simply
  → Query 2 (intermediate): Pydantic models validation tutorial FastAPI
  → Query 3 (deep dive): Pydantic v2 validators custom types performance
UNDERSTAND THIS BEFORE: Python, Class, JSON
──────────────────────────────

──────────────────────────────
TERM: Schema (Pydantic Schema)
CATEGORY: Backend
IN ONE SENTENCE: A blueprint that describes exactly what fields a piece of data must have, what type each field should be, and which fields are optional.
THE REAL-WORLD ANALOGY: A schema is like an official government form. The form specifies: Field 1 = "First Name (text, required)," Field 2 = "Age (number, 0-120, optional)." If you submit a form with the age field filled in with "banana," it's invalid. The form is the schema; your submission is the data.
HOW IT SHOWS UP IN FORGEFIT: The schemas/ directory contains Pydantic schemas for every feature. UserCreate defines what a registration request must contain. Token defines what a login response returns. NutritionLogCreate defines what logging food requires. These schemas are both validation tools and documentation.
WHY IT EXISTS: APIs need a contract between client and server: what will the client send, what will the server return? Schemas make this contract explicit in code, enabling automatic validation, clear error messages, and auto-generated API docs.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a data schema explained simply
  → Query 2 (intermediate): Pydantic schema models FastAPI request response
  → Query 3 (deep dive): API schema design OpenAPI specification
UNDERSTAND THIS BEFORE: Pydantic, Class, JSON
──────────────────────────────

──────────────────────────────
TERM: Validation
CATEGORY: Backend
IN ONE SENTENCE: The process of checking that incoming data meets all required rules before letting it into the system — like a bouncer at a club checking IDs.
THE REAL-WORLD ANALOGY: Validation is like a spell-checker for your data. Before a form is submitted, the system checks every field: "Is the email format correct? Is the weight a positive number? Is the password at least 8 characters?" Only data that passes all checks is allowed through.
HOW IT SHOWS UP IN FORGEFIT: FastAPI + Pydantic validate every incoming request automatically. If the Flutter app sends a registration request with no email field, Pydantic catches it and returns a 422 Unprocessable Entity response with a detailed error explaining which field is wrong, before any database code runs.
WHY IT EXISTS: Without validation, bad data enters your database — emails with no @ sign, negative weights, or injected SQL code. Validation is the first line of defence for data integrity and security.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is data validation programming explained
  → Query 2 (intermediate): FastAPI Pydantic input validation best practices
  → Query 3 (deep dive): server side vs client side validation security implications
UNDERSTAND THIS BEFORE: Pydantic, Schema
──────────────────────────────

──────────────────────────────
TERM: Depends() / Dependency Injection
CATEGORY: Backend
IN ONE SENTENCE: A system where a function declares "I need these things" and the framework automatically creates and provides them — no manual wiring needed.
THE REAL-WORLD ANALOGY: Dependency Injection is like a personal assistant who brings everything you need before you ask for it. When you walk into a meeting, they've already placed your notes, laptop, and coffee on the table. You didn't carry them yourself — you "depended" on the assistant, and they "injected" the dependencies.
HOW IT SHOWS UP IN FORGEFIT: Every protected endpoint uses Depends(get_current_user) and Depends(get_db). FastAPI automatically calls get_db() to create a database session and get_current_user() to validate the JWT token, then passes them as arguments to the endpoint function — the endpoint just declares it needs them.
WHY IT EXISTS: Without DI, every function would need to manually create its own database connections and parse its own tokens. That's repetitive, error-prone, and hard to test. DI centralises the creation of shared resources and injects them where needed.
SEARCH THIS ONLINE:
  → Query 1 (beginner): dependency injection explained simply no jargon
  → Query 2 (intermediate): FastAPI Depends dependency injection tutorial
  → Query 3 (deep dive): dependency injection pattern Python testing mocking
UNDERSTAND THIS BEFORE: Python, FastAPI, Function
──────────────────────────────

──────────────────────────────
TERM: Middleware
CATEGORY: Backend
IN ONE SENTENCE: Code that runs automatically on every single request and response, letting you add behaviour globally without modifying each individual route.
THE REAL-WORLD ANALOGY: Middleware is like airport security. Every passenger (request) must pass through the security checkpoint before they can board any flight (reach any endpoint). The airline doesn't check security at the gate; security is a shared layer all passengers pass through first.
HOW IT SHOWS UP IN FORGEFIT: main.py adds CORSMiddleware to the FastAPI app, which intercepts every incoming request to check its Origin header and add appropriate CORS response headers. The rate limiter also acts as middleware, checking request frequency before any route logic runs.
WHY IT EXISTS: Without middleware, you'd have to add CORS headers and security checks manually to every single endpoint — hundreds of lines of repeated code. Middleware lets you write cross-cutting concerns once and have them apply universally.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is middleware in web development explained
  → Query 2 (intermediate): FastAPI middleware CORSMiddleware tutorial
  → Query 3 (deep dive): middleware pattern request pipeline design
UNDERSTAND THIS BEFORE: FastAPI, HTTP, Request
──────────────────────────────

──────────────────────────────
TERM: CORS (Cross-Origin Resource Sharing)
CATEGORY: Backend
IN ONE SENTENCE: A browser security rule that blocks web pages from secretly making requests to a different website's server unless that server explicitly permits it.
THE REAL-WORLD ANALOGY: CORS is like a nightclub's guest list. The nightclub (server) maintains a list of approved VIPs (trusted origins like your Flutter app domain). If you're not on the list, the bouncer (browser/CORS) stops you at the door. The nightclub sets the rules, not the visitor.
HOW IT SHOWS UP IN FORGEFIT: In main.py, CORSMiddleware is configured with cors_origins from the CORS_ORIGINS environment variable. This tells browsers which origins (domains) are allowed to call the ForgeFit API. Without this, a browser-based client would be blocked from making requests.
WHY IT EXISTS: Without CORS, a malicious website could silently make authenticated API calls on behalf of a logged-in user (this is called CSRF). Browsers enforce CORS as a security mechanism; servers use it to whitelist trusted origins.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is CORS explained simply
  → Query 2 (intermediate): CORS error fix FastAPI CORSMiddleware tutorial
  → Query 3 (deep dive): CORS preflight requests same origin policy security
UNDERSTAND THIS BEFORE: HTTP, Middleware, Headers
──────────────────────────────

──────────────────────────────
TERM: CORSMiddleware
CATEGORY: Backend
IN ONE SENTENCE: The FastAPI plug-in that automatically handles CORS headers on every response so browsers know which origins are permitted to use the API.
THE REAL-WORLD ANALOGY: CORSMiddleware is like an automated stamp machine at the nightclub entrance. Instead of the bouncer manually stamping each approved guest, the machine (middleware) checks the guest list and auto-stamps everyone who is on it, on every request automatically.
HOW IT SHOWS UP IN FORGEFIT: In main.py: app.add_middleware(CORSMiddleware, allow_origins=cors_origins, allow_credentials=True, allow_methods=["*"], allow_headers=["*"]). This adds the necessary Access-Control-Allow-Origin headers to every response from the ForgeFit API.
WHY IT EXISTS: FastAPI doesn't handle CORS by default — it's a policy that must be configured. CORSMiddleware wraps that configuration into a reusable component so developers don't have to manually add CORS headers to every route.
SEARCH THIS ONLINE:
  → Query 1 (beginner): FastAPI CORSMiddleware setup tutorial
  → Query 2 (intermediate): CORS headers allow-origins allow-methods explained
  → Query 3 (deep dive): CORS security allow_credentials wildcard origins risks
UNDERSTAND THIS BEFORE: CORS, Middleware, FastAPI
──────────────────────────────

──────────────────────────────
TERM: Rate Limiting
CATEGORY: Backend
IN ONE SENTENCE: A rule that limits how many times a user or IP address can call an API endpoint within a time window to prevent abuse.
THE REAL-WORLD ANALOGY: Rate limiting is like a turnstile at a subway station that only lets 5 people through per minute. Even if 100 people rush at once, only 5 get through each minute. Everyone else has to wait. This prevents the station from being overwhelmed.
HOW IT SHOWS UP IN FORGEFIT: limiter.py creates a slowapi Limiter instance. The @limiter.limit("5/minute") decorator on /auth/login and /auth/register means a single IP can only attempt login 5 times per minute — preventing automated brute-force attacks on user accounts.
WHY IT EXISTS: Without rate limiting, a single script can hammer an API with thousands of requests per second, attempting to crack passwords (brute force), scrape all data, or simply crash the server (DoS attack). Rate limiting is the first defence against these automated attacks.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is API rate limiting explained simply
  → Query 2 (intermediate): FastAPI rate limiting slowapi tutorial
  → Query 3 (deep dive): rate limiting algorithms token bucket leaky bucket
UNDERSTAND THIS BEFORE: FastAPI, Middleware
──────────────────────────────

──────────────────────────────
TERM: slowapi
CATEGORY: Backend
IN ONE SENTENCE: A Python library that adds rate limiting to FastAPI applications with a simple decorator-based syntax.
THE REAL-WORLD ANALOGY: slowapi is like a pre-built traffic management system (already designed and tested) that you bolt onto your API. Instead of building your own turnstile from scratch, you snap in slowapi — it already knows how to count requests, identify users by IP, and block excess traffic.
HOW IT SHOWS UP IN FORGEFIT: limiter.py imports slowapi and creates Limiter(key_func=get_remote_address). main.py attaches it to the app as app.state.limiter and registers the rate limit exceeded error handler. Then @limiter.limit("5/minute") is applied to sensitive endpoints in auth.py.
WHY IT EXISTS: Implementing rate limiting correctly from scratch is complex — you need to track request counts per IP, handle time windows, and return the right 429 response. slowapi encapsulates all of that so you just write a decorator.
SEARCH THIS ONLINE:
  → Query 1 (beginner): slowapi Python rate limiting tutorial
  → Query 2 (intermediate): FastAPI slowapi rate limit per user IP setup
  → Query 3 (deep dive): distributed rate limiting Redis sliding window algorithm
UNDERSTAND THIS BEFORE: Rate Limiting, FastAPI, Decorator
──────────────────────────────

──────────────────────────────
TERM: Environment Variables
CATEGORY: Backend
IN ONE SENTENCE: Secret configuration values stored outside your code that the program reads at startup — like a combination to a safe that you never write on the safe itself.
THE REAL-WORLD ANALOGY: Environment variables are like the key code to a building's alarm system. You don't write the code on the front door — that would be insane. Instead, only authorised people (the deployed server environment) know the code. Visitors (public code on GitHub) never see it.
HOW IT SHOWS UP IN FORGEFIT: database.py reads DATABASE_URL = os.getenv("DATABASE_URL"). auth/utils.py reads SECRET_KEY = os.getenv("SECRET_KEY"). food_search.py reads USDA_API_KEY = os.getenv("USDA_API_KEY"). None of these secrets appear in the source code — they're set on Railway's deployment environment.
WHY IT EXISTS: Hardcoding passwords and API keys into source code is a catastrophic security mistake — anyone who reads the code gets the secrets. Environment variables separate secrets from code so you can safely share code publicly while keeping credentials private.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what are environment variables explained simply
  → Query 2 (intermediate): Python dotenv environment variables tutorial
  → Query 3 (deep dive): secrets management environment variables 12-factor app
UNDERSTAND THIS BEFORE: Python, Security
──────────────────────────────

──────────────────────────────
TERM: .env file
CATEGORY: Backend
IN ONE SENTENCE: A local text file that holds environment variables for development — loaded automatically and never committed to version control.
THE REAL-WORLD ANALOGY: A .env file is like Post-it notes stuck inside your desk drawer (not on the outside). It's your personal reference for all the secret codes and settings you need locally. You never photocopy those notes and hand them out — they stay in your drawer.
HOW IT SHOWS UP IN FORGEFIT: The .env file in /home/thameur/forgeFit-Back/.env holds DATABASE_URL, SECRET_KEY, and USDA_API_KEY for local development. database.py calls load_dotenv() at startup to read these values. The .gitignore file ensures .env is never pushed to GitHub.
WHY IT EXISTS: You need environment variables during local development too, but you can't set them permanently on your laptop for every project. The .env file convention (from the dotenv library) gives you a simple, project-specific way to manage local secrets.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a .env file Python tutorial
  → Query 2 (intermediate): python-dotenv load_dotenv tutorial
  → Query 3 (deep dive): .env file security gitignore secrets management
UNDERSTAND THIS BEFORE: Environment Variables
──────────────────────────────

──────────────────────────────
TERM: Procfile
CATEGORY: DevOps
IN ONE SENTENCE: A plain text file that tells a hosting platform exactly which command to run to start your application.
THE REAL-WORLD ANALOGY: A Procfile is like the ignition instructions left in a rental car's glove box: "Turn key, shift to Drive, press accelerator." The car rental company (Railway) reads these instructions every time to start the vehicle (the app) correctly.
HOW IT SHOWS UP IN FORGEFIT: The Procfile in /home/thameur/forgeFit-Back/ contains: "web: uvicorn main:app --host 0.0.0.0 --port $PORT". Railway reads this when deploying to know how to start the FastAPI backend with Uvicorn on the correct port.
WHY IT EXISTS: Cloud platforms deploy many different apps written in many languages. They can't guess how to start each one. The Procfile is a convention introduced by Heroku to give platforms a universal, language-agnostic way to know how to launch any application.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a Procfile explained simply Heroku
  → Query 2 (intermediate): Procfile FastAPI Railway deployment tutorial
  → Query 3 (deep dive): Procfile process types web worker dyno scaling
UNDERSTAND THIS BEFORE: Deployment, Uvicorn, Environment Variables
──────────────────────────────

──────────────────────────────
TERM: Startup / Shutdown events
CATEGORY: Backend
IN ONE SENTENCE: Special functions that run automatically when the server turns on or off — used for setting up or cleaning up resources.
THE REAL-WORLD ANALOGY: Startup/shutdown events are like an employee's morning and evening routines: on arrival (startup) they unlock the door, turn on the lights, and boot the register. On closing (shutdown) they count the cash, turn off the lights, and lock the door. These tasks happen reliably at the boundaries of the work day.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses startup events to ensure database tables exist (via Base.metadata.create_all). In production, Alembic migrations replace this, but the startup event pattern ensures the app is ready to serve requests the moment Uvicorn starts.
WHY IT EXISTS: Some resources (database connections, caches, third-party clients) need to be initialised once when the app starts, and shut down gracefully to avoid data loss. Lifecycle events provide the right hooks for this without making every request pay the initialisation cost.
SEARCH THIS ONLINE:
  → Query 1 (beginner): FastAPI startup shutdown events explained
  → Query 2 (intermediate): FastAPI lifespan events database connection pool
  → Query 3 (deep dive): FastAPI lifespan context manager async startup patterns
UNDERSTAND THIS BEFORE: FastAPI, Python
──────────────────────────────

──────────────────────────────
TERM: Async / Await
CATEGORY: Backend
IN ONE SENTENCE: A programming technique that lets code start a slow task (e.g. waiting for an API response) and do other work instead of just sitting idle waiting.
THE REAL-WORLD ANALOGY: A non-async chef gets one order, cooks it completely, then takes the next. An async chef puts bread in the toaster (starts a web request), immediately starts frying eggs (handles another request), and checks the toaster when it pops — never standing idle waiting for toast.
HOW IT SHOWS UP IN FORGEFIT: The get_food_nutrients endpoint in food_search.py uses async def and await client.get(...) — it starts the USDA API call, yields control while it waits, and resumes when the response arrives. Standard (synchronous) endpoints like search_food block until the response is ready.
WHY IT EXISTS: Web servers wait constantly for network responses, database queries, and file reads. If they blocked during each wait, one slow request could freeze the whole server. Async/await lets many requests be "in flight" simultaneously, multiplying throughput.
SEARCH THIS ONLINE:
  → Query 1 (beginner): async await explained simply for beginners
  → Query 2 (intermediate): Python async await asyncio tutorial
  → Query 3 (deep dive): FastAPI async vs sync endpoints performance concurrency
UNDERSTAND THIS BEFORE: Python, Function
──────────────────────────────

──────────────────────────────
TERM: Concurrency
CATEGORY: Backend
IN ONE SENTENCE: The ability of a program to handle many tasks at the same time, or at least make them appear simultaneous by switching between them rapidly.
THE REAL-WORLD ANALOGY: Concurrency is like a surgeon who is doing a procedure but also reviewing test results on a tablet between steps. They're not doing two surgeries simultaneously — they're switching attention strategically to use waiting time productively.
HOW IT SHOWS UP IN FORGEFIT: Uvicorn runs the FastAPI app with async support, meaning it can handle multiple simultaneous API requests from different ForgeFit users — one user's login, another user's food search, and a third user's workout log can all be in progress at the same time without queuing.
WHY IT EXISTS: A server with only one user at a time would be worthless. Concurrency — via async, threads, or processes — is what allows a single server to serve thousands of users "at once," making modern web services economically feasible.
SEARCH THIS ONLINE:
  → Query 1 (beginner): concurrency vs parallelism explained simply
  → Query 2 (intermediate): Python concurrency async threads multiprocessing explained
  → Query 3 (deep dive): event loop asyncio concurrency Python deep dive
UNDERSTAND THIS BEFORE: Async/Await, Server
──────────────────────────────

═══════════════════════════════════════
GROUP 3 — DATABASE
═══════════════════════════════════════

──────────────────────────────
TERM: Database
CATEGORY: Database
IN ONE SENTENCE: An organised place where information is stored on a server so it can be saved permanently, searched quickly, and retrieved reliably.
THE REAL-WORLD ANALOGY: A database is like an enormous, perfectly organised filing cabinet that never loses a paper, never misfiled anything, can instantly find any document by any detail, and can handle a thousand people searching it simultaneously without breaking a sweat.
HOW IT SHOWS UP IN FORGEFIT: PostgreSQL is the database for ForgeFit. It stores users, workout sessions, exercise sets, nutrition logs, macro targets, programs, and revoked tokens — every piece of data the app needs to persist between sessions. Without it, all data would vanish when the server restarts.
WHY IT EXISTS: Computer memory (RAM) is temporary — it vanishes when power is lost. Humans needed a way to store information persistently across power cycles, retrieved reliably by any authorised program. Databases were born from this need, evolving from paper ledgers to massive digital systems.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a database explained simply
  → Query 2 (intermediate): relational database vs NoSQL explained
  → Query 3 (deep dive): database internals storage engines B-tree index
UNDERSTAND THIS BEFORE: Nothing — fundamental concept.
──────────────────────────────

──────────────────────────────
TERM: Relational Database
CATEGORY: Database
IN ONE SENTENCE: A type of database that organises data into tables (like spreadsheets) and links them together using relationships and matching IDs.
THE REAL-WORLD ANALOGY: A relational database is like a school's record system: one table holds Students, another holds Courses, another holds Enrollments. Enrollments links students to courses via Student ID and Course ID. No student info is duplicated in the Enrollment table — you just reference the student by ID.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses PostgreSQL, a relational database. The users table links to workouts via user_id. The workout_exercises table links workouts to exercise_sets. These relationships let one SQL JOIN query pull a complete workout with all its exercises and sets.
WHY IT EXISTS: Storing the same information in multiple places (like putting the user's name in every workout record) causes update anomalies — change the name in one place, and all the others are now wrong. Relational databases eliminate this by storing each fact once and referencing it by ID.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a relational database explained simply
  → Query 2 (intermediate): relational database tables relationships primary foreign keys
  → Query 3 (deep dive): relational database normalisation 1NF 2NF 3NF
UNDERSTAND THIS BEFORE: Database
──────────────────────────────

──────────────────────────────
TERM: PostgreSQL
CATEGORY: Database
IN ONE SENTENCE: A powerful, free, open-source relational database that ForgeFit uses to permanently store all its user data, workouts, and nutrition logs.
THE REAL-WORLD ANALOGY: If a database is a filing cabinet, PostgreSQL is a premium industrial Steelcase unit with fingerprint locks, automatic organisation, fire resistance, and the ability to clone itself. It's battle-tested filing infrastructure trusted by companies from Instagram to NASA.
HOW IT SHOWS UP IN FORGEFIT: Railway provisions a PostgreSQL database for the ForgeFit backend. The DATABASE_URL environment variable points to this hosted database. All SQLAlchemy models map to PostgreSQL tables. The connection is established in database.py via create_engine(DATABASE_URL).
WHY IT EXISTS: Simple file-based storage can't handle concurrent users, complex queries, or large-scale data. PostgreSQL was developed at UC Berkeley in the 1980s to provide a fully featured, ACID-compliant, open-source alternative to expensive proprietary databases.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is PostgreSQL database tutorial for beginners
  → Query 2 (intermediate): PostgreSQL setup SQLAlchemy Python tutorial
  → Query 3 (deep dive): PostgreSQL performance tuning EXPLAIN ANALYZE index
UNDERSTAND THIS BEFORE: Relational Database, SQL
──────────────────────────────

──────────────────────────────
TERM: SQL
CATEGORY: Database
IN ONE SENTENCE: The special language used to talk to relational databases — to ask for data, insert records, update values, or delete rows.
THE REAL-WORLD ANALOGY: SQL is like the specific command language a very obedient librarian understands. "SELECT all books WHERE author = 'Dostoevsky' ORDER BY year" — the librarian (database) understands this exact phrasing and executes it perfectly, returning only what you asked for.
HOW IT SHOWS UP IN FORGEFIT: SQLAlchemy generates SQL automatically from Python code, so you rarely write raw SQL in ForgeFit. However, Alembic migration files contain raw SQL-like operations. Understanding SQL helps debug issues — you can run queries directly against PostgreSQL to investigate data.
WHY IT EXISTS: Before SQL, each database had its own proprietary query language. IBM researchers created SQL in the 1970s as a standardised language so any program could query any relational database using the same syntax, regardless of vendor.
SEARCH THIS ONLINE:
  → Query 1 (beginner): SQL basics tutorial SELECT FROM WHERE for beginners
  → Query 2 (intermediate): SQL joins explained inner outer left right
  → Query 3 (deep dive): SQL query optimisation execution plan indices
UNDERSTAND THIS BEFORE: Relational Database, Database
──────────────────────────────

──────────────────────────────
TERM: Table
CATEGORY: Database
IN ONE SENTENCE: A grid of data in a database, like a spreadsheet, where each column is a field and each row is one record.
THE REAL-WORLD ANALOGY: A database table is exactly like a spreadsheet tab. The "Users" tab has columns: ID, Email, Name, Password Hash. Each row is one user's data. Every person who registers gets a new row added to that tab.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit has tables including users, workouts, workout_exercises, exercise_sets, nutrition_logs, macro_targets, programs, program_days, and revoked_tokens. Each SQLAlchemy model class in the models/ directory maps directly to one of these tables.
WHY IT EXISTS: Unstructured data is impossible to query efficiently. Tables impose a consistent structure — every row of Users has the same columns — enabling fast searching, joining, and sorting across millions of records.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a database table explained row column
  → Query 2 (intermediate): SQL CREATE TABLE data types constraints
  → Query 3 (deep dive): database table partitioning performance large datasets
UNDERSTAND THIS BEFORE: Relational Database, SQL
──────────────────────────────

──────────────────────────────
TERM: Row / Record
CATEGORY: Database
IN ONE SENTENCE: A single entry in a database table representing one complete item — like one user, one workout, or one food log.
THE REAL-WORLD ANALOGY: If a table is a spreadsheet, each row is one filled-in form. The Users table has one row per registered user; the nutrition_logs table has one row per food item ever logged. Adding a new food log inserts a new row into that table.
HOW IT SHOWS UP IN FORGEFIT: When you log a meal in ForgeFit, a new row is inserted into the nutrition_logs table containing user_id, fdc_id, meal name, quantity, calories, protein, carbs, and fat. When you view your daily nutrition, all rows from that table for today are fetched and summed.
WHY IT EXISTS: Data about individual entities (users, products, events) must be stored as discrete, addressable records. Rows are the fundamental unit of storage in relational databases, each uniquely identifiable by its primary key.
SEARCH THIS ONLINE:
  → Query 1 (beginner): database row record column field explained simply
  → Query 2 (intermediate): SQL INSERT INTO add rows tutorial
  → Query 3 (deep dive): database row storage heap pages PostgreSQL internals
UNDERSTAND THIS BEFORE: Table, Database
──────────────────────────────

──────────────────────────────
TERM: Column / Field
CATEGORY: Database
IN ONE SENTENCE: A named, typed attribute of a table that every row must have — like "email" or "weight_kg" — defining the structure of the data.
THE REAL-WORLD ANALOGY: Columns are like the labelled fields on a printed form. Every form (row) has the same fields: Name, Date of Birth, Address. You fill in those same slots for every person. If a field doesn't apply, it may be left blank (NULL), but the column always exists.
HOW IT SHOWS UP IN FORGEFIT: The User SQLAlchemy model defines columns like email (String), hashed_password (String), weight_kg (Float), height_cm (Float), and fitness_level (String). Each becomes a column in the PostgreSQL users table. Every registered user has values for all these columns.
WHY IT EXISTS: Tables need consistent structure so queries work predictably. Defining columns in advance means every program that reads the table knows exactly what to expect — no surprises about what data might or might not be present.
SEARCH THIS ONLINE:
  → Query 1 (beginner): database column field explained simply
  → Query 2 (intermediate): SQL data types VARCHAR INTEGER FLOAT BOOLEAN
  → Query 3 (deep dive): database schema design nullable columns constraints
UNDERSTAND THIS BEFORE: Table, Row/Record
──────────────────────────────

──────────────────────────────
TERM: Primary Key
CATEGORY: Database
IN ONE SENTENCE: A unique identifier for every row in a table that ensures every record can be found unambiguously — usually an auto-incrementing integer or UUID.
THE REAL-WORLD ANALOGY: A primary key is like a passport number. Two people can have the same name, nationality, and birthday — but no two passports share the same number. The passport number (primary key) uniquely identifies one person in the entire system.
HOW IT SHOWS UP IN FORGEFIT: Every ForgeFit model (User, Workout, NutritionLog, etc.) has an id column as the primary key. When the Flutter app requests GET /workouts/42, the number 42 is the primary key used to look up that exact workout and no other.
WHY IT EXISTS: Without a unique identifier, there's no reliable way to refer to a specific record — especially when two records have identical data. Primary keys give every row a permanent, unique address used in references, joins, and updates.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a primary key database explained simply
  → Query 2 (intermediate): primary key UUID vs integer autoincrement
  → Query 3 (deep dive): primary key composite keys surrogate natural key design
UNDERSTAND THIS BEFORE: Table, Column, Row/Record
──────────────────────────────

──────────────────────────────
TERM: Foreign Key
CATEGORY: Database
IN ONE SENTENCE: A column in one table whose value matches the primary key of a row in another table, creating a link between the two tables.
THE REAL-WORLD ANALOGY: A foreign key is like writing your Employee ID on every timesheet you submit. The timesheet (nutrition_log) doesn't repeat all your personal info — it just references your ID (foreign key), and HR knows to look up your full record in the Employees table (users table) when needed.
HOW IT SHOWS UP IN FORGEFIT: The workouts table has a user_id foreign key column that references the id column of the users table. This links every workout to exactly one user. The nutrition_logs table has the same pattern — user_id ties each food log to the user who logged it.
WHY IT EXISTS: Relationships between entities must be explicitly encoded in the database. Foreign keys enforce referential integrity — the database refuses to let you save a workout for an imaginary user who doesn't exist in the users table.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a foreign key database explained
  → Query 2 (intermediate): SQL foreign key constraints relationships tutorial
  → Query 3 (deep dive): foreign key referential integrity cascade delete update
UNDERSTAND THIS BEFORE: Primary Key, Table, Relational Database
──────────────────────────────

──────────────────────────────
TERM: Relationship (one-to-many, many-to-many)
CATEGORY: Database
IN ONE SENTENCE: The way tables are connected — one-to-many means one record links to many others; many-to-many means any record on either side can link to many on the other.
THE REAL-WORLD ANALOGY: One-to-many: one Mother, many Children (one user → many workouts). Many-to-many: Students and Clubs — one student joins many clubs, one club has many students. In databases, many-to-many requires a middle "junction" table storing each combination as a row.
HOW IT SHOWS UP IN FORGEFIT: One-to-many: one user has many workouts; one workout has many exercise_sets. Many-to-many: programs and exercises are linked through program_day_exercises — a program day can have many exercises, and an exercise can appear in many program days.
WHY IT EXISTS: Real-world data is naturally relational. Without modelling these relationships explicitly, you'd have to repeat data everywhere or lose the connections between entities entirely. Relationships are the core power of relational databases.
SEARCH THIS ONLINE:
  → Query 1 (beginner): database relationships one to many many to many explained
  → Query 2 (intermediate): SQLAlchemy relationship one-to-many tutorial
  → Query 3 (deep dive): database relationship design junction table normalisation
UNDERSTAND THIS BEFORE: Foreign Key, Primary Key, Relational Database
──────────────────────────────

──────────────────────────────
TERM: JOIN
CATEGORY: Database
IN ONE SENTENCE: A SQL operation that combines rows from two or more tables based on a matching column, giving you combined data in one result.
THE REAL-WORLD ANALOGY: A JOIN is like merging two spreadsheets side by side using a common column as glue. You have a "Workouts" sheet and a "Users" sheet. A JOIN on user_id slides them together so each workout row now also shows the user's name and email next to the workout data.
HOW IT SHOWS UP IN FORGEFIT: SQLAlchemy's joinedload() mechanism performs JOINs automatically. When the workout router fetches a workout, it JOINs the workouts table with workout_exercises and exercise_sets to retrieve the complete workout structure in one database roundtrip.
WHY IT EXISTS: Relational databases deliberately split data across many tables to avoid repetition. JOIN is the mechanism for reassembling related data back together when you need to display or process it as a unified whole.
SEARCH THIS ONLINE:
  → Query 1 (beginner): SQL JOIN explained simply for beginners
  → Query 2 (intermediate): SQL INNER JOIN LEFT JOIN RIGHT JOIN differences
  → Query 3 (deep dive): SQL JOIN performance optimisation query planner
UNDERSTAND THIS BEFORE: SQL, Foreign Key, Table
──────────────────────────────

──────────────────────────────
TERM: Query
CATEGORY: Database
IN ONE SENTENCE: A request you send to a database asking it to find, insert, update, or delete data, written in SQL or generated automatically by an ORM.
THE REAL-WORLD ANALOGY: A database query is like asking the reference librarian a specific question: "Please find all books published after 2010, written by a female author, sorted by title A-Z." The librarian (database engine) searches all the shelves and brings back exactly that subset.
HOW IT SHOWS UP IN FORGEFIT: In routers/auth.py, db.query(User).filter(User.email == login_data.email).first() is a query that asks PostgreSQL: "Find the first user whose email matches this login email." Every database operation in ForgeFit uses SQLAlchemy queries.
WHY IT EXISTS: Applications constantly need to ask "what data do I have?" Rather than scanning every record manually, query languages let you describe exactly what you want and let the database engine — which is highly optimised — do the searching efficiently.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a database query explained simply
  → Query 2 (intermediate): SQLAlchemy query filter order tutorial
  → Query 3 (deep dive): query optimisation execution plan PostgreSQL
UNDERSTAND THIS BEFORE: SQL, Database, Table
──────────────────────────────

──────────────────────────────
TERM: ORM (Object-Relational Mapper)
CATEGORY: Database
IN ONE SENTENCE: A tool that lets you work with database tables using normal programming objects instead of writing SQL, automatically translating between the two.
THE REAL-WORLD ANALOGY: An ORM is like a universal translator between two languages. You speak Python (create a User object), and the ORM translates it into SQL ("INSERT INTO users...") that the database understands — and vice versa on reads. You never have to learn the other language perfectly.
HOW IT SHOWS UP IN FORGEFIT: SQLAlchemy is the ORM in ForgeFit. Instead of writing INSERT INTO users (email, password) VALUES (?, ?), the backend just creates a Python User() object and calls db.add(user); db.commit(). SQLAlchemy handles the SQL generation.
WHY IT EXISTS: Writing raw SQL for every operation is repetitive and error-prone. ORMs let developers work in their native programming language, gain type safety, and avoid SQL injection vulnerabilities by automatically using parameterised queries.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is an ORM explained simply
  → Query 2 (intermediate): SQLAlchemy ORM tutorial Python
  → Query 3 (deep dive): ORM vs raw SQL performance trade-offs
UNDERSTAND THIS BEFORE: Database, SQL, Object, Class
──────────────────────────────

──────────────────────────────
TERM: SQLAlchemy
CATEGORY: Database
IN ONE SENTENCE: The Python ORM library ForgeFit uses to define database models and interact with PostgreSQL using Python code instead of raw SQL.
THE REAL-WORLD ANALOGY: SQLAlchemy is the specific brand of universal translator ForgeFit chose. Just as Google Translate is one translator tool (not all translators), SQLAlchemy is one ORM (not all ORMs). It's simply the most popular and powerful Python ORM available.
HOW IT SHOWS UP IN FORGEFIT: database.py imports create_engine and sessionmaker from SQLAlchemy. All models in the models/ directory inherit from Base (DeclarativeBase) and use Column, String, Integer, ForeignKey from SQLAlchemy. Every query uses db.query(...).filter(...).
WHY IT EXISTS: Python had no built-in way to talk to relational databases in an object-oriented way. Michael Bayer created SQLAlchemy in 2006 to give Python developers a powerful, flexible ORM that could work with any relational database.
SEARCH THIS ONLINE:
  → Query 1 (beginner): SQLAlchemy Python tutorial beginners
  → Query 2 (intermediate): SQLAlchemy ORM models relationships queries
  → Query 3 (deep dive): SQLAlchemy core vs ORM performance connection pooling
UNDERSTAND THIS BEFORE: ORM, Python, PostgreSQL
──────────────────────────────

──────────────────────────────
TERM: Model (SQLAlchemy Model)
CATEGORY: Database
IN ONE SENTENCE: A Python class that represents a database table — each attribute in the class maps to a column, and each instance of the class maps to a row.
THE REAL-WORLD ANALOGY: A SQLAlchemy model is like a business card template. The template defines the layout (Name field, Email field, Phone field). Each printed card is an instance — a specific person's data filling in those fields. The template is the class; the printed card is the object/row.
HOW IT SHOWS UP IN FORGEFIT: models/user.py defines the User class with columns like email, hashed_password, weight_kg, fitness_level. models/workout.py defines Workout with user_id, started_at, completed_at. models/nutrition.py defines NutritionLog with fdc_id, meal, quantity_g. Each class = one PostgreSQL table.
WHY IT EXISTS: You need Python objects to work with database data in an object-oriented way. SQLAlchemy models define the mapping between the Python world (objects) and the database world (tables), making them the central truth for your data structure.
SEARCH THIS ONLINE:
  → Query 1 (beginner): SQLAlchemy model class table explained tutorial
  → Query 2 (intermediate): SQLAlchemy define model columns types relationships
  → Query 3 (deep dive): SQLAlchemy model inheritance table-per-class mapped columns
UNDERSTAND THIS BEFORE: SQLAlchemy, ORM, Class, Column
──────────────────────────────

──────────────────────────────
TERM: Session
CATEGORY: Database
IN ONE SENTENCE: A temporary workspace that tracks all your pending database changes until you decide to save them permanently or discard them.
THE REAL-WORLD ANALOGY: A database session is like a word processor document open in memory. You can type, delete, and rearrange text (make database changes) freely. Nothing is permanently saved until you hit Ctrl+S (commit). If you close without saving (rollback), all changes vanish.
HOW IT SHOWS UP IN FORGEFIT: database.py creates SessionLocal = sessionmaker(...). The get_db() generator yields a session to each endpoint via Depends(get_db). Every route uses this db session to query and modify data, then the session is automatically closed in the finally block.
WHY IT EXISTS: Databases work best in units of work — you make a series of related changes, then commit them all at once. Sessions provide the "scratch pad" for assembling those changes before committing, enabling transactions and rollback on failure.
SEARCH THIS ONLINE:
  → Query 1 (beginner): SQLAlchemy session explained simply
  → Query 2 (intermediate): SQLAlchemy session lifecycle add commit close
  → Query 3 (deep dive): SQLAlchemy session scoped session thread safety
UNDERSTAND THIS BEFORE: SQLAlchemy, Depends/DI, Transaction
──────────────────────────────

──────────────────────────────
TERM: Transaction
CATEGORY: Database
IN ONE SENTENCE: A group of database operations treated as one all-or-nothing unit — either every operation succeeds together, or none of them are saved.
THE REAL-WORLD ANALOGY: A transaction is like a bank transfer. Two operations happen: deduct £100 from Account A, add £100 to Account B. These must both succeed or both fail. If the system crashes after the deduction but before the addition, a transaction ensures the deduction is reversed automatically.
HOW IT SHOWS UP IN FORGEFIT: When a user registers, ForgeFit creates a User object, adds it to the session, and commits. If any part fails, SQLAlchemy rolls back automatically, ensuring no half-saved user record exists in the database.
WHY IT EXISTS: Complex operations often involve multiple related database changes. Without transactions, a crash mid-operation could leave data in an inconsistent state — money deducted but not received, or a user created without their profile.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a database transaction explained simply
  → Query 2 (intermediate): ACID properties transactions database explained
  → Query 3 (deep dive): distributed transactions two-phase commit database
UNDERSTAND THIS BEFORE: Database, Session, commit/rollback
──────────────────────────────

──────────────────────────────
TERM: commit() / rollback()
CATEGORY: Database
IN ONE SENTENCE: commit() permanently saves all changes made in the current session; rollback() cancels them all and restores the previous state.
THE REAL-WORLD ANALOGY: commit() is pressing "Save" on a document — changes are now permanent. rollback() is pressing "Undo All" — everything reverts to the last saved state. In databases, you choose when to save, and you can always undo before you save.
HOW IT SHOWS UP IN FORGEFIT: Every write operation in the ForgeFit backend ends with db.commit(). In routers/auth.py, after creating a new user: db.add(new_user); db.commit(); db.refresh(new_user). If an exception occurs, SQLAlchemy's session management ensures changes are rolled back.
WHY IT EXISTS: You need explicit control over when changes become permanent. commit() and rollback() give you transactional control — batch multiple changes together and either apply them atomically or discard them all if something goes wrong.
SEARCH THIS ONLINE:
  → Query 1 (beginner): SQLAlchemy commit rollback explained tutorial
  → Query 2 (intermediate): database transaction commit rollback ACID
  → Query 3 (deep dive): SQLAlchemy savepoint nested transactions
UNDERSTAND THIS BEFORE: Session, Transaction
──────────────────────────────

──────────────────────────────
TERM: autocommit
CATEGORY: Database
IN ONE SENTENCE: A database setting where every individual SQL operation is saved immediately without needing an explicit commit command — ForgeFit turns this OFF for safety.
THE REAL-WORLD ANALOGY: autocommit ON is like a pen that writes in permanent ink with every stroke — no erasing possible. autocommit OFF is like a pencil — you write everything out, review it, and then choose to trace over it in permanent ink (commit) or erase it all (rollback).
HOW IT SHOWS UP IN FORGEFIT: database.py sets autocommit=False in SessionLocal = sessionmaker(autocommit=False, ...). This means every change must be explicitly committed with db.commit(). This gives ForgeFit full transactional control and prevents accidental partial saves.
WHY IT EXISTS: autocommit ON is fine for simple scripts but dangerous in web applications where multiple operations must succeed together. Turning it off forces developers to think about transactions explicitly, preventing data corruption from partial failures.
SEARCH THIS ONLINE:
  → Query 1 (beginner): autocommit database explained simply
  → Query 2 (intermediate): SQLAlchemy autocommit False session management
  → Query 3 (deep dive): PostgreSQL autocommit transaction isolation levels
UNDERSTAND THIS BEFORE: Session, Transaction, commit/rollback
──────────────────────────────

──────────────────────────────
TERM: autoflush
CATEGORY: Database
IN ONE SENTENCE: A SQLAlchemy setting that automatically sends pending changes to the database before any query, so queries see the latest in-memory state.
THE REAL-WORLD ANALOGY: autoflush is like a librarian who automatically shelves the books you just returned before answering any search query. Without it, a search query might not see a book that was just returned (added to the session) if it hasn't been shelved yet.
HOW IT SHOWS UP IN FORGEFIT: database.py uses autoflush=False. This gives the backend full control over when pending objects are flushed to the DB within a transaction, preventing subtle bugs where a query "sees" partly constructed objects that haven't been committed yet.
WHY IT EXISTS: autoflush=True can cause confusing behaviour — SQLAlchemy sends SQL before you expect it, leading to errors mid-transaction. Setting it to False makes the session's behaviour more predictable in complex multi-step operations.
SEARCH THIS ONLINE:
  → Query 1 (beginner): SQLAlchemy autoflush explained
  → Query 2 (intermediate): SQLAlchemy session flush commit difference
  → Query 3 (deep dive): SQLAlchemy unit of work pattern flush timing
UNDERSTAND THIS BEFORE: Session, SQLAlchemy
──────────────────────────────

──────────────────────────────
TERM: Migration
CATEGORY: Database
IN ONE SENTENCE: A recorded, versioned change to the database structure — like adding a new column — that can be applied or reversed safely without losing existing data.
THE REAL-WORLD ANALOGY: A database migration is like a building renovation contract. It documents exactly what will change (add a new room, remove a wall), can be inspected before work begins, and can theoretically be reversed. Each renovation is numbered in sequence so you always know the building's current state.
HOW IT SHOWS UP IN FORGEFIT: The alembic/ directory in the backend contains numbered migration files. When a new column is added to a model (like adding fdc_id to NutritionLog), a migration file is created to ALTER the table in production without dropping and recreating it.
WHY IT EXISTS: Real databases have real data. You can't simply drop and recreate tables to make structural changes — all user data would be lost. Migrations apply precise, reversible structural changes to live databases without touching existing rows.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a database migration explained simply
  → Query 2 (intermediate): Alembic migration FastAPI SQLAlchemy tutorial
  → Query 3 (deep dive): database migration strategy zero-downtime production
UNDERSTAND THIS BEFORE: Database, SQLAlchemy, Alembic
──────────────────────────────

──────────────────────────────
TERM: Alembic
CATEGORY: Database
IN ONE SENTENCE: The official migration tool for SQLAlchemy — it auto-generates migration scripts when you change your models and applies or reverses them on the database.
THE REAL-WORLD ANALOGY: Alembic is like an automated building inspector who compares the building blueprint (current models) to the actual building (current DB schema), automatically writes up a renovation plan (migration script), and then executes it on the building safely.
HOW IT SHOWS UP IN FORGEFIT: The alembic/ directory and alembic.ini file exist in the backend root. When a ForgeFit model is modified (e.g., adding a column), running alembic revision --autogenerate creates a new migration file. Running alembic upgrade head applies it to the production database on Railway.
WHY IT EXISTS: SQLAlchemy models and the actual database schema can drift apart over time. Alembic bridges that gap by tracking all structural changes as version-controlled scripts that can be applied in order to any environment (development, staging, production).
SEARCH THIS ONLINE:
  → Query 1 (beginner): Alembic database migrations tutorial Python
  → Query 2 (intermediate): Alembic autogenerate migrations FastAPI tutorial
  → Query 3 (deep dive): Alembic production deployment zero-downtime migrations
UNDERSTAND THIS BEFORE: SQLAlchemy, Migration, PostgreSQL
──────────────────────────────

──────────────────────────────
TERM: create_all()
CATEGORY: Database
IN ONE SENTENCE: A SQLAlchemy function that looks at all your model definitions and creates any missing tables in the database automatically — used for development convenience.
THE REAL-WORLD ANALOGY: create_all() is like a new company setting up its office: it looks at the org chart (models) and creates every desk, filing cabinet, and phone extension needed (tables and columns) if they don't already exist. If they exist, it leaves them alone.
HOW IT SHOWS UP IN FORGEFIT: main.py calls Base.metadata.create_all(bind=engine) at startup. In development, this creates all tables from scratch. In production, Alembic migrations are used instead (as noted in the comment in the code), but create_all provides a quick setup for local testing.
WHY IT EXISTS: During early development, repeatedly writing SQL CREATE TABLE statements is tedious. create_all() lets developers iterate quickly on models without manually managing the database schema, with Alembic taking over for production safety.
SEARCH THIS ONLINE:
  → Query 1 (beginner): SQLAlchemy create_all tables tutorial
  → Query 2 (intermediate): SQLAlchemy Base metadata create_all explained
  → Query 3 (deep dive): create_all vs Alembic migrations production differences
UNDERSTAND THIS BEFORE: SQLAlchemy, Model, Database
──────────────────────────────

──────────────────────────────
TERM: Cascade Delete
CATEGORY: Database
IN ONE SENTENCE: A database rule that automatically deletes all related child records when a parent record is deleted, keeping data consistent.
THE REAL-WORLD ANALOGY: Cascade delete is like a demolition clause: if you tear down the main building (delete a user), all the rooms inside (workouts, nutrition logs) are automatically demolished too. Nothing is left dangling in mid-air referencing a building that no longer exists.
HOW IT SHOWS UP IN FORGEFIT: In ForgeFit's SQLAlchemy models, relationships use cascade="all, delete-orphan". Deleting a User cascades to delete all their Workouts. Deleting a Workout cascades to delete all its WorkoutExercises and ExerciseSets — so no orphaned rows pollute the database.
WHY IT EXISTS: When you delete a parent record, all child records that reference it become invalid (they point to a non-existent parent). Without cascade delete, these orphaned records waste storage, corrupt reports, and can cause mysterious query errors.
SEARCH THIS ONLINE:
  → Query 1 (beginner): database cascade delete explained simply
  → Query 2 (intermediate): SQLAlchemy cascade delete-orphan relationship
  → Query 3 (deep dive): PostgreSQL ON DELETE CASCADE referential integrity
UNDERSTAND THIS BEFORE: Foreign Key, Relationship, SQLAlchemy
──────────────────────────────

──────────────────────────────
TERM: joinedload()
CATEGORY: Database
IN ONE SENTENCE: A SQLAlchemy feature that tells the ORM to fetch related records in the same database query instead of making separate queries for each relationship.
THE REAL-WORLD ANALOGY: joinedload() is like ordering a combo meal instead of ordering each item separately. Without it, you'd order the burger, wait, then order the fries, wait, then order the drink (N+1 queries). With joinedload, one order brings everything at once.
HOW IT SHOWS UP IN FORGEFIT: When fetching a complete workout with all its exercises and sets, ForgeFit uses joinedload on WorkoutExercise and ExerciseSet relationships. This generates one SQL JOIN query instead of dozens of separate queries — critical for performance when loading a workout with many exercises.
WHY IT EXISTS: Without joinedload, an ORM would lazily load each relationship with a separate SQL query per object — if you have 20 exercises, that's 20+ extra queries just to load their sets (the N+1 problem). joinedload is the solution to this performance antipattern.
SEARCH THIS ONLINE:
  → Query 1 (beginner): SQLAlchemy joinedload lazy load explained
  → Query 2 (intermediate): SQLAlchemy eager loading joinedload subqueryload
  → Query 3 (deep dive): N+1 query problem SQLAlchemy solutions performance
UNDERSTAND THIS BEFORE: SQLAlchemy, JOIN, Relationship
──────────────────────────────

──────────────────────────────
TERM: N+1 Query Problem
CATEGORY: Database
IN ONE SENTENCE: A common performance bug where fetching a list of N items causes N additional separate database queries (one per item) instead of one joined query.
THE REAL-WORLD ANALOGY: Imagine asking a librarian for a list of 10 book titles. Then, instead of the librarian getting all their descriptions at once, you make 10 separate trips back to ask "what's the description of this one?" That's 1 + 10 = 11 trips (N+1) instead of 1 efficient trip.
HOW IT SHOWS UP IN FORGEFIT: Without joinedload, loading 15 workouts and then accessing each workout's exercises would generate 1 (for workouts) + 15 (for exercises) + up to 15×N (for sets) queries. Using joinedload in the workouts router prevents this, collapsing it to 1-3 queries total.
WHY IT EXISTS: ORMs with lazy loading fetch related data on demand — convenient for developers but catastrophic for performance in list views. Identifying and fixing N+1 is one of the most impactful database optimisations in any ORM-based application.
SEARCH THIS ONLINE:
  → Query 1 (beginner): N+1 query problem explained simply
  → Query 2 (intermediate): N+1 problem SQLAlchemy fix joinedload
  → Query 3 (deep dive): ORM N+1 detection Django SQLAlchemy Hibernate solutions
UNDERSTAND THIS BEFORE: JOIN, joinedload, SQLAlchemy, Query
──────────────────────────────

──────────────────────────────
TERM: Index (database index)
CATEGORY: Database
IN ONE SENTENCE: A separate, sorted data structure the database maintains behind the scenes to make certain queries dramatically faster — like the index at the back of a textbook.
THE REAL-WORLD ANALOGY: Without an index, finding "all workouts by user 42" means scanning every single row in the workouts table (full table scan). With an index on user_id, the database jumps directly to user 42's entries — like using the index at the back of a book instead of reading every page.
HOW IT SHOWS UP IN FORGEFIT: PostgreSQL automatically creates indexes on primary keys and foreign keys. User lookups by email (the most common query in auth) benefit from an index on the email column. The revoked_tokens table has an index on token_jti for fast token validation.
WHY IT EXISTS: As databases grow to millions of rows, scanning every row for every query becomes impossibly slow. Indexes trade storage space for query speed — a fundamental performance optimisation in any database-backed application.
SEARCH THIS ONLINE:
  → Query 1 (beginner): database index explained simply what it does
  → Query 2 (intermediate): PostgreSQL CREATE INDEX types B-tree hash
  → Query 3 (deep dive): database index strategy query planning EXPLAIN ANALYZE
UNDERSTAND THIS BEFORE: Database, Query, Table
──────────────────────────────

──────────────────────────────
TERM: NULL
CATEGORY: Database
IN ONE SENTENCE: A special value in a database that means "this field has no value" — it is NOT zero, NOT empty string, but the complete absence of a value.
THE REAL-WORLD ANALOGY: NULL is like an empty box, not a box containing a zero. An empty box (NULL) is different from a box with "0" written inside (integer zero) or a box with a blank label (empty string). Three completely different states — most bugs happen when people confuse them.
HOW IT SHOWS UP IN FORGEFIT: In ForgeFit models, optional columns like weight_kg, height_cm, and date_of_birth are nullable — a user can register without these values, and they're stored as NULL. The auth router checks user.reset_password_code is None (Python's NULL equivalent) before allowing a password reset.
WHY IT EXISTS: Real-world data is often incomplete. Not every user fills in every field. NULL lets databases represent "missing" or "not applicable" data distinctly from zero or empty, which is a meaningful difference in most applications.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is NULL in databases explained simply
  → Query 2 (intermediate): SQL NULL vs empty string vs zero difference
  → Query 3 (deep dive): NULL handling SQL three-valued logic IS NULL IS NOT NULL
UNDERSTAND THIS BEFORE: Column, Database, Table
──────────────────────────────

═══════════════════════════════════════
GROUP 4 — AUTHENTICATION & SECURITY
═══════════════════════════════════════

──────────────────────────────
TERM: Authentication
CATEGORY: Security
IN ONE SENTENCE: The process of verifying that someone is who they claim to be — typically by checking a username and password.
THE REAL-WORLD ANALOGY: Authentication is showing your ID at airport security. The agent checks your face matches the photo. They don't decide what you can do on the plane (that's authorisation) — they just confirm you are who you claim to be.
HOW IT SHOWS UP IN FORGEFIT: /auth/login in routers/auth.py is the authentication endpoint. It checks the submitted email exists in the database and that the password matches the stored bcrypt hash. If both match, it issues a JWT token proving the user is authenticated.
WHY IT EXISTS: Without authentication, anyone could access anyone's workout data. Systems need to verify identity before granting any access — authentication is the first gate every user must pass through.
SEARCH THIS ONLINE:
  → Query 1 (beginner): authentication vs authorisation explained simply
  → Query 2 (intermediate): JWT authentication FastAPI tutorial
  → Query 3 (deep dive): authentication methods OAuth2 JWT session tokens comparison
UNDERSTAND THIS BEFORE: HTTP, Password Hashing, JWT
──────────────────────────────

──────────────────────────────
TERM: Authorization
CATEGORY: Security
IN ONE SENTENCE: The process of deciding what an authenticated user is allowed to do — separate from proving who they are.
THE REAL-WORLD ANALOGY: After airport security confirms your identity (authentication), your boarding pass (authorisation) determines which plane and seat you can access. Two verified passengers can have very different permissions based on their ticket class.
HOW IT SHOWS UP IN FORGEFIT: Every protected endpoint uses Depends(get_current_user). After authentication, get_current_user ensures the JWT token belongs to a real user. Routes then check whether that user owns the requested resource — you cannot delete another user's workout.
WHY IT EXISTS: Knowing who someone is does not automatically mean they can do everything. Authorisation enforces boundaries — users can only modify their own data, admins get elevated access. Without it, authentication alone would be useless for data privacy.
SEARCH THIS ONLINE:
  → Query 1 (beginner): difference authentication authorisation explained
  → Query 2 (intermediate): FastAPI authorization role-based access control
  → Query 3 (deep dive): RBAC ABAC authorization patterns API security
UNDERSTAND THIS BEFORE: Authentication, JWT
──────────────────────────────

──────────────────────────────
TERM: JWT (JSON Web Token)
CATEGORY: Security
IN ONE SENTENCE: A compact, digitally signed text token that proves a user is logged in and carries basic info about them — checked on every request without hitting the database.
THE REAL-WORLD ANALOGY: A JWT is like a wristband at a festival. The organiser (server) puts it on your wrist when you pay (login). At every stage and bar, staff glance at your wristband and let you in — they don't call the box office (database) each time. The wristband itself proves your entry.
HOW IT SHOWS UP IN FORGEFIT: auth/utils.py creates JWTs with create_access_token(). The token is returned on login and stored by the Flutter app. Every subsequent API call attaches the token as a Bearer header. get_current_user() decodes it using the SECRET_KEY to identify the user.
WHY IT EXISTS: Session-based auth requires the server to remember every logged-in user in a database — expensive to scale. JWTs are self-contained: the token itself is the proof, verified cryptographically without any database lookup.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a JWT token explained simply
  → Query 2 (intermediate): JWT structure header payload signature explained
  → Query 3 (deep dive): JWT security best practices algorithm confusion attacks
UNDERSTAND THIS BEFORE: Authentication, JSON, HTTPS
──────────────────────────────

──────────────────────────────
TERM: Bearer Token
CATEGORY: Security
IN ONE SENTENCE: A type of token included in an HTTP Authorization header that grants access to whoever "bears" (holds) it — no questions asked beyond token validity.
THE REAL-WORLD ANALOGY: A bearer token is like a physical concert ticket — whoever holds it gets in. The venue doesn't ask for ID against the original buyer's name. "Bearer of this token" gets the access. This is why protecting the token is critical.
HOW IT SHOWS UP IN FORGEFIT: The Flutter AuthInterceptor adds "Authorization: Bearer <token>" to every outgoing API request. FastAPI's HTTPBearer extractor (security = HTTPBearer() in auth/utils.py) reads this header and passes the token string to get_current_user() for validation.
WHY IT EXISTS: HTTP has no built-in concept of "logged in." Bearer tokens extend the Authorization header standard (RFC 6750) to let APIs accept stateless credentials on each request without maintaining server-side sessions.
SEARCH THIS ONLINE:
  → Query 1 (beginner): bearer token explained simply HTTP Authorization header
  → Query 2 (intermediate): JWT bearer token FastAPI authentication flow
  → Query 3 (deep dive): OAuth2 bearer token RFC 6750 security
UNDERSTAND THIS BEFORE: JWT, HTTP, Headers
──────────────────────────────

──────────────────────────────
TERM: Token
CATEGORY: Security
IN ONE SENTENCE: A string of characters issued by a server that represents a user's identity or permission — sent back on every request to prove who you are.
THE REAL-WORLD ANALOGY: A token is like a cloakroom ticket. You hand in your coat (credentials), receive a numbered ticket (token). To get your coat back, you show the ticket — the cloakroom does not need to remember your face, just that the ticket number is valid.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses two tokens: an access token (short-lived, 30 min) for API calls and a refresh token (long-lived, 30 days) for getting new access tokens. Both are JWTs. They are returned together on login and stored securely by the Flutter app.
WHY IT EXISTS: Sending username and password on every request is insecure and slow. Tokens let users authenticate once and receive a timestamped credential they reuse — that expires automatically and can be revoked without changing the password.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is an authentication token explained simply
  → Query 2 (intermediate): access token refresh token difference explained
  → Query 3 (deep dive): token lifecycle management revocation rotation
UNDERSTAND THIS BEFORE: JWT, Authentication
──────────────────────────────

──────────────────────────────
TERM: Access Token
CATEGORY: Security
IN ONE SENTENCE: A short-lived token used for making API requests — expires after 30 minutes in ForgeFit, keeping sessions secure.
THE REAL-WORLD ANALOGY: An access token is like a day-pass to a gym. It gets you in all day, but expires at midnight. Short expiry means if someone steals it, the damage window is small — the thief only has until midnight.
HOW IT SHOWS UP IN FORGEFIT: create_access_token() in auth/utils.py creates a JWT that expires in ACCESS_TOKEN_EXPIRE_MINUTES = 30. The Flutter app includes this token in every API request header. When it expires, the app uses the refresh token to get a new one silently.
WHY IT EXISTS: Long-lived tokens are dangerous — if stolen, they give attackers access indefinitely. Access tokens are intentionally short-lived to limit damage from theft. The refresh token mechanism allows seamless renewal without re-login.
SEARCH THIS ONLINE:
  → Query 1 (beginner): access token vs refresh token explained simply
  → Query 2 (intermediate): JWT access token expiry best practices
  → Query 3 (deep dive): sliding session tokens token rotation security patterns
UNDERSTAND THIS BEFORE: Token, JWT, Authentication
──────────────────────────────

──────────────────────────────
TERM: Refresh Token
CATEGORY: Security
IN ONE SENTENCE: A long-lived token used only to obtain new access tokens — it is never sent to regular API endpoints, only to the /auth/refresh endpoint.
THE REAL-WORLD ANALOGY: A refresh token is like a membership card at a gym. Your day-pass (access token) expires daily, but you show your membership card (refresh token) at the front desk to get a new day-pass automatically — without re-registering each time.
HOW IT SHOWS UP IN FORGEFIT: create_refresh_token() generates a token with 30-day expiry. The Flutter app stores it in flutter_secure_storage. When an API call returns 401 (expired access token), the AuthInterceptor automatically calls POST /auth/refresh to get a new access token.
WHY IT EXISTS: Short-lived access tokens mean users would be logged out every 30 minutes without refresh tokens. Refresh tokens allow silent renewal of access tokens while maintaining security — only the /auth/refresh endpoint accepts them.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a refresh token explained
  → Query 2 (intermediate): refresh token rotation security FastAPI tutorial
  → Query 3 (deep dive): refresh token security storage mobile apps
UNDERSTAND THIS BEFORE: Access Token, Token Revocation
──────────────────────────────

──────────────────────────────
TERM: JTI (JWT ID)
CATEGORY: Security
IN ONE SENTENCE: A unique ID embedded in every JWT that allows the server to track and revoke specific tokens individually.
THE REAL-WORLD ANALOGY: A JTI is like a serial number on a concert ticket. Even if two people have identical-looking tickets, their serial numbers differ. If one ticket is reported stolen, security can invalidate specifically that serial number without cancelling all tickets.
HOW IT SHOWS UP IN FORGEFIT: create_access_token() adds "jti": str(uuid.uuid4()) to every token. On logout, the JTI is stored in the revoked_tokens table. The get_current_user() function calls is_token_revoked(jti, db) — if the JTI is in that table, the request is rejected.
WHY IT EXISTS: JWTs are stateless by design — you cannot "cancel" one without a revocation mechanism. JTI gives each token a fingerprint that can be blocklisted in the database, enabling proper logout functionality.
SEARCH THIS ONLINE:
  → Query 1 (beginner): JWT JTI claim what is it
  → Query 2 (intermediate): JWT revocation JTI blocklist implementation
  → Query 3 (deep dive): JWT stateless vs stateful revocation tradeoffs
UNDERSTAND THIS BEFORE: JWT, Token Revocation
──────────────────────────────

──────────────────────────────
TERM: Token Expiry
CATEGORY: Security
IN ONE SENTENCE: A timestamp embedded in a JWT that tells the server when to stop honouring that token — after which it is automatically invalid.
THE REAL-WORLD ANALOGY: Token expiry is like a parking ticket's validity period. After 2 hours, the ticket expires and a warden can fine you — the original permit is gone. The expiry is printed right on the ticket (in the token payload as "exp"), no external check needed.
HOW IT SHOWS UP IN FORGEFIT: Auth/utils.py sets expire = datetime.now(timezone.utc) + timedelta(minutes=30) and embeds it as "exp" in the JWT payload. When FastAPI decodes a token, the jose library automatically raises JWTError if the current time is past the exp timestamp.
WHY IT EXISTS: Credentials should not last forever. Token expiry limits the damage window if a token is stolen — an expired token is worthless. Combining short expiry with refresh tokens balances security and convenience.
SEARCH THIS ONLINE:
  → Query 1 (beginner): JWT token expiry explained simply
  → Query 2 (intermediate): JWT exp claim datetime Python implementation
  → Query 3 (deep dive): token expiry strategy sliding window refresh rotation
UNDERSTAND THIS BEFORE: JWT, Token
──────────────────────────────

──────────────────────────────
TERM: Token Revocation
CATEGORY: Security
IN ONE SENTENCE: The ability to permanently invalidate a specific token before it naturally expires — used in ForgeFit on logout.
THE REAL-WORLD ANALOGY: Token revocation is like cancelling a lost credit card. The card has an expiry date stamped on it, but you don't want to wait until then if it's stolen. You call the bank (add the JTI to the revoked_tokens table) and the card is rejected immediately.
HOW IT SHOWS UP IN FORGEFIT: The /auth/logout endpoint in routers/auth.py extracts the JTI from both the access and refresh tokens and saves both to the revoked_tokens table. is_token_revoked() checks this table on every protected request. Models/token.py defines the RevokedToken SQLAlchemy model.
WHY IT EXISTS: JWTs are self-contained and expire on their own schedule. Without a revocation mechanism, a "logged out" user's token still works until expiry. The JTI blocklist is the practical solution to give users a real logout experience.
SEARCH THIS ONLINE:
  → Query 1 (beginner): JWT revocation how to invalidate a token
  → Query 2 (intermediate): JWT blocklist revocation FastAPI implementation
  → Query 3 (deep dive): JWT revocation strategies Redis blocklist performance
UNDERSTAND THIS BEFORE: JWT, JTI, Token Expiry
──────────────────────────────

──────────────────────────────
TERM: HS256 (HMAC-SHA256)
CATEGORY: Security
IN ONE SENTENCE: The algorithm ForgeFit uses to digitally sign JWTs — it uses a secret key to create a unique signature that proves the token has not been tampered with.
THE REAL-WORLD ANALOGY: HS256 is like a wax seal on a letter. The sender stamps it with their unique seal (secret key). Anyone can read the letter, but if the seal is broken or fake, recipients know the letter was tampered with. Only the seal owner can create a valid original.
HOW IT SHOWS UP IN FORGEFIT: ALGORITHM = "HS256" is set in auth/utils.py. jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM) creates access and refresh tokens. jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM]) verifies them. If anyone changes the token's payload, the signature check fails.
WHY IT EXISTS: Without signing, anyone could modify a JWT payload to claim they are a different user. HS256 links the token content to the SECRET_KEY cryptographically — any modification invalidates the signature, and only the holder of the secret key can create valid new ones.
SEARCH THIS ONLINE:
  → Query 1 (beginner): HMAC SHA256 explained simply
  → Query 2 (intermediate): JWT HS256 vs RS256 signing algorithm difference
  → Query 3 (deep dive): HMAC-SHA256 cryptographic hash MAC implementation
UNDERSTAND THIS BEFORE: JWT, SECRET_KEY, Symmetric Encryption
──────────────────────────────

──────────────────────────────
TERM: SECRET_KEY
CATEGORY: Security
IN ONE SENTENCE: A long, random private password the server uses to sign and verify JWTs — if it is leaked, all tokens can be forged.
THE REAL-WORLD ANALOGY: The SECRET_KEY is the master key to the entire building — whoever has it can create a copy of any door key. It must never leave the building or be shown to guests. If it is stolen, you must change the locks (rotate the secret key) immediately.
HOW IT SHOWS UP IN FORGEFIT: SECRET_KEY = os.getenv("SECRET_KEY") in auth/utils.py. The key is stored in the Railway environment (never in code or git). If not set, the server refuses to start with a RuntimeError. All JWT signing and verification in ForgeFit passes through this key.
WHY IT EXISTS: JWT signatures are only as secure as the key used to create them. The SECRET_KEY must stay private — stored in environment variables, rotated periodically, and never committed to source control.
SEARCH THIS ONLINE:
  → Query 1 (beginner): JWT secret key what it is and why it matters
  → Query 2 (intermediate): generate secure secret key Python JWT
  → Query 3 (deep dive): JWT secret key rotation strategy zero-downtime
UNDERSTAND THIS BEFORE: Environment Variables, JWT, HS256
──────────────────────────────

──────────────────────────────
TERM: Symmetric Encryption
CATEGORY: Security
IN ONE SENTENCE: A type of encryption where the same key is used both to lock (sign) and unlock (verify) data — as opposed to asymmetric where two different keys are used.
THE REAL-WORLD ANALOGY: Symmetric encryption is like a lockbox with one key that both locks and unlocks it. You and your trusted friend each have a copy of the same key. Asymmetric is a padlock (public key) anyone can click shut, but only you have the key to open.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses HS256, which is symmetric — the same SECRET_KEY signs and verifies all JWTs. This means the backend is both issuer and verifier. If a third-party service needed to verify tokens, asymmetric RS256 would be needed instead.
WHY IT EXISTS: Most internal APIs only need one system to create and verify tokens. Symmetric algorithms like HS256 are simpler to implement and faster to compute, making them the right choice when only one party needs the key.
SEARCH THIS ONLINE:
  → Query 1 (beginner): symmetric vs asymmetric encryption explained simply
  → Query 2 (intermediate): HS256 vs RS256 JWT symmetric asymmetric
  → Query 3 (deep dive): cryptography symmetric key exchange TLS
UNDERSTAND THIS BEFORE: HS256, SECRET_KEY, JWT
──────────────────────────────

──────────────────────────────
TERM: Password Hashing
CATEGORY: Security
IN ONE SENTENCE: Converting a password into an irreversible scrambled code using a mathematical function — so the original password can never be recovered even if the database is stolen.
THE REAL-WORLD ANALOGY: Password hashing is like putting a letter through a shredder and keeping the shreds as the unique "fingerprint." You can compare two piles of shreds to see if they match, but you can never reassemble the original letter from either pile.
HOW IT SHOWS UP IN FORGEFIT: hash_password() in auth/utils.py calls pwd_context.hash(password) using bcrypt. The result (a 60-char hash) is stored in hashed_password column — never the plain password. verify_password() checks if a plain password, when hashed the same way, produces the same hash.
WHY IT EXISTS: Databases get hacked. If passwords were stored in plain text, every user's password would be immediately exposed. Hashing means attackers get useless scrambled data — they cannot reverse it to find the real passwords.
SEARCH THIS ONLINE:
  → Query 1 (beginner): password hashing explained simply why not encrypt
  → Query 2 (intermediate): bcrypt password hashing Python passlib tutorial
  → Query 3 (deep dive): password hashing algorithms bcrypt argon2 PBKDF2 comparison
UNDERSTAND THIS BEFORE: Authentication, bcrypt
──────────────────────────────

──────────────────────────────
TERM: bcrypt
CATEGORY: Security
IN ONE SENTENCE: A password hashing algorithm specifically designed to be deliberately slow, making brute-force attacks computationally expensive.
THE REAL-WORLD ANALOGY: bcrypt is like a combination lock that takes 10 minutes to check each attempt instead of 1 second. An attacker trying a million combinations would need thousands of years instead of a few hours. The deliberate slowness is the security feature.
HOW IT SHOWS UP IN FORGEFIT: CryptContext(schemes=["bcrypt"]) in auth/utils.py configures passlib to use bcrypt. When a user registers, hash_password() bcrypt-hashes the password. The resulting hash looks like $2b$12$... — the $12$ indicates the "work factor" (how slow to be).
WHY IT EXISTS: Fast hash functions (MD5, SHA-1) can be cracked by testing billions of passwords per second on modern GPUs. bcrypt was designed in 1999 specifically for passwords — its adjustable "cost factor" lets you make it slower as hardware gets faster.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is bcrypt and why use it for passwords
  → Query 2 (intermediate): bcrypt work factor cost explained Python passlib
  → Query 3 (deep dive): bcrypt vs argon2 vs scrypt password hashing comparison
UNDERSTAND THIS BEFORE: Password Hashing, cryptographic Salt
──────────────────────────────

──────────────────────────────
TERM: Salt (cryptographic)
CATEGORY: Security
IN ONE SENTENCE: A random string added to a password before hashing it, ensuring two users with the same password get completely different hashes.
THE REAL-WORLD ANALOGY: Salt is like adding a unique random seasoning blend before putting each burger through the "shredder." Two identical burgers become unrecognisably different after shredding because they each had different seasoning. An attacker cannot use pre-computed tables to crack them.
HOW IT SHOWS UP IN FORGEFIT: bcrypt automatically generates and embeds a unique random salt in every password hash. The stored hash for user A's password "abc123" looks nothing like user B's hash for the same "abc123" — because bcrypt added different salts. passlib handles this transparently.
WHY IT EXISTS: Without salt, all users with password "password123" hash to the same value. Attackers use "rainbow tables" (pre-computed hash→password maps) to crack them instantly. Unique salts make rainbow tables useless — every hash must be cracked individually.
SEARCH THIS ONLINE:
  → Query 1 (beginner): cryptographic salt explained simply password security
  → Query 2 (intermediate): bcrypt salt how it works passlib Python
  → Query 3 (deep dive): rainbow table attack salt countermeasure cryptography
UNDERSTAND THIS BEFORE: Password Hashing, bcrypt
──────────────────────────────

──────────────────────────────
TERM: passlib
CATEGORY: Security
IN ONE SENTENCE: A Python library that wraps many password hashing algorithms (including bcrypt) and provides a simple, safe API for hashing and verifying passwords.
THE REAL-WORLD ANALOGY: passlib is like a professional-grade knife set for a chef — you could sharpen a rusty blade yourself (implement hashing manually), but a quality tool set (passlib) is safer, better maintained, and prevents amateur mistakes.
HOW IT SHOWS UP IN FORGEFIT: from passlib.context import CryptContext is imported in auth/utils.py. pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto") creates a context that uses bcrypt and automatically handles scheme upgrades. hash_password and verify_password both use this context.
WHY IT EXISTS: Implementing cryptographic operations correctly from scratch is notoriously difficult — small mistakes lead to catastrophic vulnerabilities. passlib provides battle-tested, audited implementations with sane defaults so developers cannot accidentally weaken security.
SEARCH THIS ONLINE:
  → Query 1 (beginner): passlib Python password hashing tutorial
  → Query 2 (intermediate): passlib CryptContext bcrypt verify hash
  → Query 3 (deep dive): passlib deprecated scheme migration password rehashing
UNDERSTAND THIS BEFORE: bcrypt, Password Hashing, Python
──────────────────────────────

──────────────────────────────
TERM: Brute Force Attack
CATEGORY: Security
IN ONE SENTENCE: An attack where a computer automatically tries thousands or millions of password combinations until it finds the right one.
THE REAL-WORLD ANALOGY: A brute force attack is like trying every combination on a padlock — 000, 001, 002... all the way to 999. For a 3-digit lock, it takes 1,000 tries at most. For a good password with bcrypt and rate limiting, the same approach takes centuries of computing time.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit defends against brute force on /auth/login with two layers: @limiter.limit("5/minute") prevents more than 5 attempts per minute per IP, and bcrypt slows down each individual guess significantly. Together they make automated password cracking impractical.
WHY IT EXISTS: Computers can try millions of password guesses per second against a fast hash. Brute force attacks are the most direct method to crack accounts. Rate limiting and slow hashing algorithms like bcrypt are the primary defences.
SEARCH THIS ONLINE:
  → Query 1 (beginner): brute force attack password explained simply
  → Query 2 (intermediate): preventing brute force attacks rate limiting hashing
  → Query 3 (deep dive): brute force vs dictionary attack credential stuffing
UNDERSTAND THIS BEFORE: Rate Limiting, bcrypt, Authentication
──────────────────────────────

──────────────────────────────
TERM: SQL Injection
CATEGORY: Security
IN ONE SENTENCE: An attack where a hacker types specially crafted text into a form to trick the database into running harmful commands the developer never intended.
THE REAL-WORLD ANALOGY: SQL injection is like a forger slipping extra instructions into your fax. The bank expects "Transfer £100 to account 123" but the forger adds "...and transfer everything to account 999; ignore the rest." If the bank reads it literally, they execute both commands.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit is protected because SQLAlchemy uses parameterised queries automatically — user input is always treated as data, never as SQL code. No values from requests are ever directly concatenated into SQL strings, eliminating injection risk.
WHY IT EXISTS: Early web apps built SQL queries by concatenating user input directly: "SELECT * FROM users WHERE email = '" + email + "'". Attackers discovered they could break out of the string to inject arbitrary SQL. It remains OWASP's top web vulnerability.
SEARCH THIS ONLINE:
  → Query 1 (beginner): SQL injection explained simply what it is
  → Query 2 (intermediate): SQL injection prevention parameterised queries
  → Query 3 (deep dive): SQLAlchemy SQL injection safe ORM parameterisation
UNDERSTAND THIS BEFORE: SQL, Database, ORM
──────────────────────────────

──────────────────────────────
TERM: Parameterized Query
CATEGORY: Security
IN ONE SENTENCE: A database query where user input is sent separately from the SQL structure — the database engine treats input as pure data, never as executable SQL code.
THE REAL-WORLD ANALOGY: A parameterised query is like filling out a printed form — the form's structure (the SQL template) is fixed and printed, and you fill in the blanks (parameters) with a pen. The bank reads the fixed template and fills in your values — no one can add new sections to a printed form.
HOW IT SHOWS UP IN FORGEFIT: SQLAlchemy always uses parameterised queries automatically. db.query(User).filter(User.email == login_data.email) generates SQL like "WHERE email = ?" with the email value bound as a parameter — impossible to inject SQL through the email field.
WHY IT EXISTS: Parameterised queries are the definitive solution to SQL injection. By separating code from data at the database driver level, no amount of clever input formatting can break the query structure — the driver never interprets input as SQL syntax.
SEARCH THIS ONLINE:
  → Query 1 (beginner): parameterized query explained simply SQL injection prevention
  → Query 2 (intermediate): SQLAlchemy parameterized queries automatic security
  → Query 3 (deep dive): prepared statements bind parameters database security
UNDERSTAND THIS BEFORE: SQL Injection, SQL, ORM
──────────────────────────────

──────────────────────────────
TERM: HTTPBearer
CATEGORY: Security
IN ONE SENTENCE: A FastAPI security utility that automatically extracts Bearer tokens from the Authorization header of incoming requests.
THE REAL-WORLD ANALOGY: HTTPBearer is like a turnstile at a train station that has a built-in card reader. You don't have to explain how to read the card — the turnstile knows exactly how to parse the format and extract your passenger ID. FastAPI's HTTPBearer knows the Authorization: Bearer format.
HOW IT SHOWS UP IN FORGEFIT: security = HTTPBearer() is declared in auth/utils.py. get_current_user() has credentials: HTTPAuthorizationCredentials = Depends(security) — FastAPI automatically pulls the token from the Authorization header and passes it to the function. No manual header parsing needed.
WHY IT EXISTS: Every protected endpoint would need to manually parse "Authorization: Bearer <token>" from the request headers without HTTPBearer. FastAPI's security utilities standardise this extraction and integrate it cleanly with the Depends() system.
SEARCH THIS ONLINE:
  → Query 1 (beginner): FastAPI HTTPBearer security explained
  → Query 2 (intermediate): FastAPI Bearer token authentication HTTPBearer tutorial
  → Query 3 (deep dive): FastAPI security schemes OAuth2 HTTPBearer comparison
UNDERSTAND THIS BEFORE: Bearer Token, FastAPI, Depends/DI
──────────────────────────────

──────────────────────────────
TERM: Logout
CATEGORY: Security
IN ONE SENTENCE: The action of explicitly invalidating a user's tokens so their session ends immediately, even before the tokens would naturally expire.
THE REAL-WORLD ANALOGY: Logout is like actively handing your gym wristband back to the desk and having them cut it off and record its serial number as void. Even if you kept a copy, any attempt to use it at the gates would now trigger a "this wristband has been cancelled" alert.
HOW IT SHOWS UP IN FORGEFIT: POST /auth/logout in routers/auth.py revokes both the access token JTI and the refresh token JTI by inserting them into the revoked_tokens table. get_current_user() checks every token's JTI against this blocklist, so revoked tokens immediately stop working.
WHY IT EXISTS: Without a proper logout mechanism, users closing the app doesn't actually end their session from a security standpoint — the JWT is still valid. Real logout requires making the server refuse to honour the old tokens.
SEARCH THIS ONLINE:
  → Query 1 (beginner): JWT logout how does it work
  → Query 2 (intermediate): JWT token revocation logout FastAPI implementation
  → Query 3 (deep dive): stateless JWT logout blacklist Redis vs database comparison
UNDERSTAND THIS BEFORE: JWT, JTI, Token Revocation
──────────────────────────────

──────────────────────────────
TERM: Session vs Token Authentication
CATEGORY: Security
IN ONE SENTENCE: Two different ways to keep users logged in — sessions store login state on the server; tokens store it in the token itself and are verified statelessly.
THE REAL-WORLD ANALOGY: Session auth is like a hotel key card registered at the front desk — swipe it and the desk confirms your room number in a registry. Token auth is like a sealed notarised document you carry — the bouncer reads the document itself and trusts the notary's seal, no registry check needed.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses JWT token authentication (not sessions). The server stores no session state — each request is validated by decoding the JWT. The only "stateful" element is the revoked_tokens table for the JTI blocklist.
WHY IT EXISTS: Session state on the server is a scalability bottleneck — if you have 10 servers, they all need access to the same session store. Token auth is stateless and scales horizontally: any server can validate any token independently.
SEARCH THIS ONLINE:
  → Query 1 (beginner): session vs token authentication explained simply
  → Query 2 (intermediate): JWT vs session authentication pros cons
  → Query 3 (deep dive): stateless authentication horizontal scaling distributed systems
UNDERSTAND THIS BEFORE: Authentication, JWT, Session (as general concept)
──────────────────────────────

═══════════════════════════════════════
GROUP 5 — FLUTTER & MOBILE FRONTEND
═══════════════════════════════════════

──────────────────────────────
TERM: Flutter
CATEGORY: Mobile
IN ONE SENTENCE: Google's open-source toolkit for building beautiful mobile, web, and desktop apps from a single codebase using the Dart language.
THE REAL-WORLD ANALOGY: Flutter is like a universal construction kit: build the house once using special universal bricks, then snap it into an Android foundation OR an iOS foundation OR a web platform — same blueprint, multiple outputs.
HOW IT SHOWS UP IN FORGEFIT: The entire ForgeFit frontend — every screen, button, animation, and chart — is built with Flutter. The /home/thameur/forgefit directory is a Flutter project targeting Android. One codebase powers the full UI.
WHY IT EXISTS: Before Flutter, developers had to build separate apps in Java/Kotlin (Android) and Swift/Objective-C (iOS) — double the work. Flutter enables one codebase, one team, consistent UI across platforms.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter tutorial for beginners complete course
  → Query 2 (intermediate): Flutter widgets layout navigation tutorial
  → Query 3 (deep dive): Flutter rendering engine Skia Impeller performance
UNDERSTAND THIS BEFORE: Nothing — good starting point.
──────────────────────────────

──────────────────────────────
TERM: Dart
CATEGORY: Mobile
IN ONE SENTENCE: The programming language Flutter uses — designed by Google, similar to Java/JavaScript, and compiled for optimal mobile performance.
THE REAL-WORLD ANALOGY: Dart is the specific dialect spoken inside the Flutter construction kit. Just as Flutter bricks only snap together per the included manual (Dart syntax), you must speak Dart to work with Flutter — though it reads almost like modern JavaScript or Java.
HOW IT SHOWS UP IN FORGEFIT: Every .dart file in /home/thameur/forgefit/lib/ is Dart code. main.dart, all providers, all screens, all widgets — everything from the NutritionProvider to the BarcodeScannerScreen is written in Dart.
WHY IT EXISTS: Google created Dart in 2011 to be a structured, statically-typed language that compiles to fast native code for mobile and JavaScript for web — solving performance issues that JavaScript-based frameworks had on mobile.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Dart programming language basics tutorial
  → Query 2 (intermediate): Dart classes async await futures tutorial
  → Query 3 (deep dive): Dart null safety sound type system internals
UNDERSTAND THIS BEFORE: Flutter, Programming Concept basics
──────────────────────────────

──────────────────────────────
TERM: Widget
CATEGORY: Mobile
IN ONE SENTENCE: The fundamental building block of every Flutter UI — everything visible on screen is a widget, from buttons to entire pages.
THE REAL-WORLD ANALOGY: In Flutter, a widget is like a LEGO brick. Every element — the blue brick (button), the long flat brick (row), the container brick (card) — is a widget. Your entire UI is assembled by snapping thousands of these bricks together into a tree.
HOW IT SHOWS UP IN FORGEFIT: Every screen in ForgeFit is a widget. NutritionScreen, WorkoutLogScreen, HomeScreen — all are widgets. Inside them, every Text(), ElevatedButton(), PieChart(), Row(), Column() is also a widget. The entire UI is a tree of nested widgets.
WHY IT EXISTS: Flutter's creators wanted everything — layout, styling, animation, interaction — to be composable using one universal concept. Making everything a widget means you can customise, wrap, and combine anything without special cases.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter widgets explained simply for beginners
  → Query 2 (intermediate): Flutter widget tree stateless stateful widgets
  → Query 3 (deep dive): Flutter widget rendering layer composition performance
UNDERSTAND THIS BEFORE: Flutter, Dart
──────────────────────────────

──────────────────────────────
TERM: StatelessWidget
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter widget whose content never changes after it is created — it always displays the same output for the same input.
THE REAL-WORLD ANALOGY: A StatelessWidget is like a printed poster. Once printed, it never changes. It displays the same image forever. You can replace the whole poster with a different one, but the poster itself cannot update itself mid-display.
HOW IT SHOWS UP IN FORGEFIT: ForgeFitApp in main.dart is a StatelessWidget. Many simple display widgets (like the exercise card header, the macro label text) are StatelessWidgets — they receive data as parameters and just display it without managing any changing state.
WHY IT EXISTS: Many UI components don't need to change after being built — route configurations, static labels, layout containers. StatelessWidgets are simpler, lighter, and easier to test than StatefulWidgets. Using them where possible improves performance.
SEARCH THIS ONLINE:
  → Query 1 (beginner): StatelessWidget vs StatefulWidget Flutter explained
  → Query 2 (intermediate): when to use StatelessWidget Flutter best practices
  → Query 3 (deep dive): Flutter widget lifecycle immutability const widgets
UNDERSTAND THIS BEFORE: Widget, Flutter
──────────────────────────────

──────────────────────────────
TERM: StatefulWidget
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter widget that can redraw itself when its internal data changes — used for interactive elements like forms, loading states, or toggling views.
THE REAL-WORLD ANALOGY: A StatefulWidget is like a scoreboard at a sports game — it can update its displayed numbers throughout the game. Someone manages the score internally and pushes changes to the display. The display rerenders itself whenever the score changes.
HOW IT SHOWS UP IN FORGEFIT: Most ForgeFit screens are StatefulWidgets: LogWorkoutScreen tracks the ongoing workout session state, MacroTargetsScreen manages the slider values locally, and NutritionScreen rerenders when the logged food list changes. Any widget with loading spinners or local user input is StatefulWidget.
WHY IT EXISTS: User interfaces are inherently dynamic — forms change as you type, lists load asynchronously, toggles flip. StatefulWidgets provide the mechanism to tie UI redraws to data changes in a controlled way.
SEARCH THIS ONLINE:
  → Query 1 (beginner): StatefulWidget Flutter how it works explained
  → Query 2 (intermediate): setState Flutter StatefulWidget lifecycle
  → Query 3 (deep dive): Flutter state management StatefulWidget vs Provider
UNDERSTAND THIS BEFORE: StatelessWidget, Widget, setState
──────────────────────────────

──────────────────────────────
TERM: BuildContext
CATEGORY: Mobile
IN ONE SENTENCE: An object Flutter passes to every build() method that contains information about where a widget sits in the widget tree and lets it access inherited data.
THE REAL-WORLD ANALOGY: BuildContext is like a GPS coordinate inside a giant apartment building. It tells the widget exactly where it is — which floor (route), which apartment (parent widget), which room (widget tree position) — so it can find nearby resources like the electricity supply (Provider) without searching the whole building.
HOW IT SHOWS UP IN FORGEFIT: Every Widget's build(BuildContext context) method receives a context. ForgeFit uses context.watch<NutritionProvider>() and context.read<WorkoutProvider>() to access global state. Navigator.of(context).pushNamed('/home') uses context to navigate.
WHY IT EXISTS: Flutter widgets need to access shared resources (theme, locale, providers) and navigate to other screens. BuildContext provides the handle to the widget's position in the tree from which it can locate and consume these resources.
SEARCH THIS ONLINE:
  → Query 1 (beginner): BuildContext Flutter explained simply
  → Query 2 (intermediate): Flutter BuildContext context.watch context.read
  → Query 3 (deep dive): Flutter InheritedWidget BuildContext lookup tree
UNDERSTAND THIS BEFORE: Widget, Flutter, Widget Tree
──────────────────────────────

──────────────────────────────
TERM: Widget Tree
CATEGORY: Mobile
IN ONE SENTENCE: The hierarchical structure of all widgets that make up a Flutter screen — parent widgets contain child widgets, forming a tree from root to leaf.
THE REAL-WORLD ANALOGY: A widget tree is like a family tree but for UI elements. MaterialApp is the great-grandparent. Scaffold is a grandparent. AppBar and Column are parents. Inside Column live Text and Button children. Every element knows its ancestors and can inherit traits from them.
HOW IT SHOWS UP IN FORGEFIT: main.dart builds the root widget tree: MaterialApp → Scaffold → BottomNavigationBar + body. The body for the Nutrition tab expands to NutritionScreen → Column → PieChart + ListView → NutritionEntryCard. This nesting is the widget tree.
WHY IT EXISTS: Tree structures efficiently represent parent-child relationships in UIs. Flutter traverses this tree to know what to draw, what to rebuild on changes, and how to propagate inherited data (like theming and providers) from parent to child.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter widget tree explained simply
  → Query 2 (intermediate): Flutter widget tree rebuild optimisation
  → Query 3 (deep dive): Flutter element tree render tree three trees explained
UNDERSTAND THIS BEFORE: Widget, Flutter
──────────────────────────────

──────────────────────────────
TERM: setState()
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter method that tells the framework "my data changed, please redraw this widget" — triggering a rebuild of the StatefulWidget.
THE REAL-WORLD ANALOGY: setState() is like raising your hand in class to signal the teacher (Flutter framework) that something has changed. The teacher then asks the whole group (widget) to update their notes (rebuild). Without raising your hand, the teacher doesn't know anything changed.
HOW IT SHOWS UP IN FORGEFIT: In MacroTargetsScreen, moving a macro slider calls setState(() { _proteinPercent = newValue; }) to update the slider position. In the barcode scanner, setState triggers when a barcode is newly detected, updating the displayed result.
WHY IT EXISTS: Flutter only redraws widgets when explicitly told to. setState() is the signal mechanism for local state changes inside a StatefulWidget. Without it, data changes would be invisible to the UI.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter setState explained simply tutorial
  → Query 2 (intermediate): when to use setState vs Provider Flutter
  → Query 3 (deep dive): Flutter rebuild optimisation setState scope performance
UNDERSTAND THIS BEFORE: StatefulWidget, Widget
──────────────────────────────

──────────────────────────────
TERM: build()
CATEGORY: Mobile
IN ONE SENTENCE: The required method in every Flutter widget that describes what to display — Flutter calls it automatically whenever the widget needs to be drawn or redrawn.
THE REAL-WORLD ANALOGY: build() is like a recipe card. Every time the restaurant prepares your dish (every time Flutter redraws the widget), it executes the exact recipe. Flutter may cook this dish many times — the recipe stays the same unless you swap the recipe card (update state/props).
HOW IT SHOWS UP IN FORGEFIT: Every widget in ForgeFit has a build(BuildContext context) method. NutritionScreen's build() returns a Scaffold with the calorie rings, macro bars, and meal list. This method is called by Flutter whenever the screen needs to reflect updated state.
WHY IT EXISTS: Flutter's declarative model means you describe "what the UI should look like given the current data" rather than imperatively painting it step by step. build() is the place to express that description — Flutter handles the "when to draw" logic.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter build method explained widget lifecycle
  → Query 2 (intermediate): Flutter build method performance const widgets
  → Query 3 (deep dive): Flutter declarative UI paradigm vs imperative comparison
UNDERSTAND THIS BEFORE: Widget, StatelessWidget, StatefulWidget
──────────────────────────────

──────────────────────────────
TERM: initState()
CATEGORY: Mobile
IN ONE SENTENCE: A lifecycle method called once when a StatefulWidget is first inserted into the widget tree — used to trigger initial data loading.
THE REAL-WORLD ANALOGY: initState() is like the opening setup of a stage play — before the audience sees anything, stagehands prepare the props, position actors, and raise the curtain (load data). It happens once at the very start and never again during that performance.
HOW IT SHOWS UP IN FORGEFIT: NutritionScreen's initState() calls _loadDailyNutrition() immediately after the screen is created, triggering a GET /nutrition/daily API request. WorkoutDetailScreen's initState() fetches the specific workout data. This ensures data is ready when the user first sees the screen.
WHY IT EXISTS: Screens often need to fetch their initial data from an API before displaying anything. initState() provides the guaranteed-first-call hook where this can be triggered safely, before the first build() renders.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter initState explained lifecycle
  → Query 2 (intermediate): Flutter initState vs didChangeDependencies
  → Query 3 (deep dive): Flutter widget lifecycle initState build dispose order
UNDERSTAND THIS BEFORE: StatefulWidget, build()
──────────────────────────────

──────────────────────────────
TERM: dispose()
CATEGORY: Mobile
IN ONE SENTENCE: A lifecycle method called when a StatefulWidget is permanently removed from the tree — used to clean up controllers, timers, and subscriptions to prevent memory leaks.
THE REAL-WORLD ANALOGY: dispose() is like the cleanup crew after a stage play. When the play ends (widget removed), they pack away the props (cancel timers), disconnect equipment (close streams), and release the venue (free memory). Without cleanup, the equipment keeps running and costing money all night.
HOW IT SHOWS UP IN FORGEFIT: Widgets using TextEditingControllers (search fields in FoodSearchScreen) call controller.dispose() in their dispose() method. Debounce Timers in the food search are also cancelled here. Without this, controllers leak memory as the user navigates between screens.
WHY IT EXISTS: Flutter widgets are created and destroyed as users navigate. Resources allocated in initState() — controllers, animations, timers — must be freed when the widget dies. dispose() is the guaranteed cleanup hook that prevents memory leaks.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter dispose method explained memory leak
  → Query 2 (intermediate): Flutter dispose controllers timers streams cleanup
  → Query 3 (deep dive): Flutter memory leaks dispose lifecycle detection tools
UNDERSTAND THIS BEFORE: initState, StatefulWidget
──────────────────────────────

──────────────────────────────
TERM: Hot Reload
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter development feature that applies code changes to a running app instantly without restarting it — preserving the current app state.
THE REAL-WORLD ANALOGY: Hot Reload is like editing a live recipe cooking in front of you — you change "1 tsp salt" to "2 tsp salt" and the dish instantly tastes saltier without starting the cooking process over. The food (app state) is preserved; only the changed instruction is reapplied.
HOW IT SHOWS UP IN FORGEFIT: During development of ForgeFit, pressing 'r' in the terminal while flutter run is active applies any Flutter/Dart UI changes seen in the .dart files instantly. Changing a color scheme or widget layout appears on the emulator in under a second.
WHY IT EXISTS: Mobile app compilation cycles were historically slow — 30-60 seconds per change. Hot Reload was Flutter's killer feature at launch, reducing iteration loops to under 1 second. It dramatically speeds up UI development.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter hot reload vs hot restart difference
  → Query 2 (intermediate): Flutter hot reload how it works stateful reload
  → Query 3 (deep dive): Flutter hot reload Dart VM isolate reload mechanism
UNDERSTAND THIS BEFORE: Flutter, Widget
──────────────────────────────

──────────────────────────────
TERM: Navigator
CATEGORY: Mobile
IN ONE SENTENCE: Flutter's system for managing a stack of screens — pushing new screens onto the stack when navigating forward and popping them off when going back.
THE REAL-WORLD ANALOGY: Navigator is like a stack of index cards in a filing box. Every screen you navigate to is a new card placed on top. Pressing Back removes the top card revealing the previous one. At the bottom is always your starting screen (the login or home screen).
HOW IT SHOWS UP IN FORGEFIT: main.dart defines all routes in _generateRoute(). Navigator.of(context).pushNamed('/nutrition/add-food') navigates to AddFoodScreen. Navigator.of(context).pop() goes back. The app uses Named Routes for clarity.
WHY IT EXISTS: Mobile apps need a consistent back-navigation model. Navigator implements the standard "stack of screens" pattern that matches user expectations — forward adds to the stack, back removes from it.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter Navigator push pop explained simply
  → Query 2 (intermediate): Flutter Navigator named routes navigation
  → Query 3 (deep dive): Flutter Navigator 2.0 Router declarative navigation
UNDERSTAND THIS BEFORE: Widget, BuildContext
──────────────────────────────

──────────────────────────────
TERM: Route
CATEGORY: Mobile
IN ONE SENTENCE: A mapping in Flutter between a name or object and the screen (widget) that should be displayed when navigating to it.
THE REAL-WORLD ANALOGY: A route is like a page number in a book's table of contents: "Chapter 5 = Page 142." In Flutter: "/nutrition" = NutritionScreen. You don't carry the page with you when flipping — you just say "go to Chapter 5" (pushNamed) and the book opens there.
HOW IT SHOWS UP IN FORGEFIT: _generateRoute() in main.dart maps route names like '/home' → HomeScreen, '/nutrition/barcode-scanner' → BarcodeScannerScreen. Arguments are passed via settings.arguments for screens that need parameters (like WorkoutDetailScreen receiving a workoutId).
WHY IT EXISTS: Without named routes, every navigation call requires importing and constructing the destination widget directly. Named routes create a central registry of all screens, making navigation intentions clear and testable.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter routes navigation explained tutorial
  → Query 2 (intermediate): Flutter named routes arguments onGenerateRoute
  → Query 3 (deep dive): Flutter route management deep linking
UNDERSTAND THIS BEFORE: Navigator, Widget
──────────────────────────────

──────────────────────────────
TERM: Named Route
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter navigation route identified by a string name like '/home' instead of a direct widget reference, making navigation more readable and centralised.
THE REAL-WORLD ANALOGY: Named routes are like dialling someone by their saved name ("Call Mum") instead of memorising their number (+44 7911 123456). The same person (screen) is reached, but using a readable name instead of explicit construction.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses named routes throughout — Navigator.pushNamed(context, '/nutrition/barcode-scanner') navigates to the barcode scanner. All route-to-screen mappings are centralised in _generateRoute() in main.dart, not scattered across the codebase.
WHY IT EXISTS: In large apps, navigating by directly constructing widget instances creates tight coupling between screens. Named routes decouple the calling screen from the destination, and centralise all routing logic in one place.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter named routes onGenerateRoute tutorial
  → Query 2 (intermediate): Flutter route arguments named routes best practices
  → Query 3 (deep dive): Flutter navigation patterns feature-first named routes
UNDERSTAND THIS BEFORE: Route, Navigator
──────────────────────────────

──────────────────────────────
TERM: Scaffold
CATEGORY: Mobile
IN ONE SENTENCE: A standard Flutter widget that provides the basic visual structure of a mobile screen — app bar, body, floating button, and bottom navigation.
THE REAL-WORLD ANALOGY: A Scaffold is like the steel framework of a building before the walls go in. It defines where the roof (AppBar), floors (body), and basement (BottomNavigationBar) are. You fill in the spaces with your own content.
HOW IT SHOWS UP IN FORGEFIT: Almost every screen in ForgeFit's build() method returns a Scaffold. HomeScreen uses Scaffold with a BottomNavigationBar. AddFoodScreen uses Scaffold with a custom AppBar and a ScrollView as body. NutritionScreen wraps everything in a Scaffold with floating action button.
WHY IT EXISTS: Building a screen with correct insets, safe areas, and standard layout regions from scratch every time is tedious. Scaffold provides these structural elements out of the box, ensuring every screen follows Material Design standards.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter Scaffold widget explained simply
  → Query 2 (intermediate): Flutter Scaffold AppBar body FloatingActionButton
  → Query 3 (deep dive): Flutter Scaffold customisation safe area insets
UNDERSTAND THIS BEFORE: Widget, Flutter
──────────────────────────────

──────────────────────────────
TERM: MaterialApp
CATEGORY: Mobile
IN ONE SENTENCE: The root widget of a Flutter app that connects the app to Material Design — it provides theming, navigation, and localization for the whole app.
THE REAL-WORLD ANALOGY: MaterialApp is like the corporate headquarters of a franchise chain. It defines the brand standards (theme), the master directory of all locations (routes), and the overall rules that every franchise location (screen) must follow.
HOW IT SHOWS UP IN FORGEFIT: ForgeFitApp's build() method returns a MaterialApp with theme: _buildDarkFitnessTheme(), initialRoute: isLoggedIn ? '/home' : '/login', and onGenerateRoute: _generateRoute. This single widget bootstraps the entire ForgeFit app experience.
WHY IT EXISTS: Flutter apps need a root that sets up shared configuration — theming, routing, localisation — that all child widgets inherit. MaterialApp is the standard Flutter root widget that handles all of this via a single declarative configuration.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter MaterialApp explained tutorial
  → Query 2 (intermediate): Flutter MaterialApp theme routes localization
  → Query 3 (deep dive): Flutter MaterialApp vs CupertinoApp vs WidgetsApp
UNDERSTAND THIS BEFORE: Widget, StatelessWidget, Flutter
──────────────────────────────

──────────────────────────────
TERM: Provider (Flutter package)
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter package that makes global app state — like the logged-in user's data — accessible from any widget in the tree without passing it through every parent.
THE REAL-WORLD ANALOGY: Provider is like a water pipe system in a building. Instead of each tenant carrying their own water from the street, pipes run through the walls and any room can tap into water at any point. The water (state) is available everywhere without explicit passing.
HOW IT SHOWS UP IN FORGEFIT: main.dart wraps the app in MultiProvider with AuthProvider, WorkoutProvider, NutritionProvider, StatsProvider, and ProgramProvider. Any screen can call context.watch<NutritionProvider>() to get live nutrition data without the screen needing it passed as a constructor argument.
WHY IT EXISTS: Passing state down through many layers of widgets ("prop drilling") makes code brittle and verbose. Provider lets any widget access shared state from anywhere in the tree, reducing boilerplate and coupling.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter Provider state management explained simply
  → Query 2 (intermediate): Flutter Provider ChangeNotifier tutorial
  → Query 3 (deep dive): Flutter Provider vs Riverpod vs Bloc comparison
UNDERSTAND THIS BEFORE: Widget, ChangeNotifier, BuildContext
──────────────────────────────

──────────────────────────────
TERM: ChangeNotifier
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter class that a provider (like NutritionProvider) extends, giving it the ability to announce data changes so all listening widgets automatically rebuild.
THE REAL-WORLD ANALOGY: ChangeNotifier is like a radio broadcaster in a studio. Whenever the news changes (data updates), the broadcaster announces it on air (notifyListeners). Every radio tuned to that station (every widget using context.watch) immediately receives the update.
HOW IT SHOWS UP IN FORGEFIT: AuthProvider, WorkoutProvider, NutritionProvider, StatsProvider, ProgramProvider all extend ChangeNotifier. When the backend returns new nutrition data, NutritionProvider stores it and calls notifyListeners(), causing every screen that watches it to rebuild with fresh data.
WHY IT EXISTS: UI needs to stay synchronised with data. ChangeNotifier implements the Observer pattern — interested parties subscribe, and the provider notifies all subscribers when data changes. This replaces ad-hoc callback chains with a clean, standardised mechanism.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter ChangeNotifier explained simply
  → Query 2 (intermediate): Flutter ChangeNotifier Provider notifyListeners tutorial
  → Query 3 (deep dive): Flutter ChangeNotifier performance selective rebuild
UNDERSTAND THIS BEFORE: Provider, Observer Pattern
──────────────────────────────

──────────────────────────────
TERM: notifyListeners()
CATEGORY: Mobile
IN ONE SENTENCE: The one method call that tells all listening widgets "my data changed, please rebuild yourself with the new data."
THE REAL-WORLD ANALOGY: notifyListeners() is like pressing the "send all" button on a group email. The moment you press it, everyone in the group (every widget watching this provider) receives the update and acts on it — no manual one-by-one calling needed.
HOW IT SHOWS UP IN FORGEFIT: In NutritionProvider, after fetchDailyNutrition() completes and stores the new data, it calls notifyListeners(). This causes every screen currently showing a Consumer<NutritionProvider> or context.watch<NutritionProvider>() to rebuild — updating the macro rings, food list, and calorie counters automatically.
WHY IT EXISTS: Providers update their internal data silently — no widget knows unless told. notifyListeners() is the signal that data changed. Without it, UI would show stale data even after a successful API response.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter notifyListeners explained
  → Query 2 (intermediate): Flutter Provider notifyListeners rebuild specific widgets
  → Query 3 (deep dive): Flutter selective rebuild ChangeNotifier performance
UNDERSTAND THIS BEFORE: ChangeNotifier, Provider
──────────────────────────────

──────────────────────────────
TERM: Consumer
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter widget that subscribes to a Provider and rebuilds only itself (not parent widgets) when the provider's data changes.
THE REAL-WORLD ANALOGY: Consumer is like a dedicated news ticker at the bottom of a TV screen. The rest of the screen (other widgets) stays static; only the ticker (Consumer) updates when breaking news (provider data changes) arrives. Surgical rebuilds instead of full-screen redraws.
HOW IT SHOWS UP IN FORGEFIT: In NutritionScreen, Consumer<NutritionProvider>(builder: (ctx, provider, child) { return Column(... showing provider.dailyCalories ...); }) ensures only the calorie display section rebuilds when nutrition data changes — not the entire screen layout.
WHY IT EXISTS: Rebuilding entire screens on minor data changes wastes processing power and causes visual jank. Consumer limits rebuilds to the smallest necessary subtree, making Flutter apps smooth even with frequent data updates.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter Consumer widget explained simply
  → Query 2 (intermediate): Flutter Consumer vs context.watch difference
  → Query 3 (deep dive): Flutter selective widget rebuild Consumer optimisation
UNDERSTAND THIS BEFORE: Provider, ChangeNotifier, Widget
──────────────────────────────

──────────────────────────────
TERM: context.watch()
CATEGORY: Mobile
IN ONE SENTENCE: A shorthand inside build() that subscribes the current widget to a provider — it rebuilds the widget whenever the provider changes.
THE REAL-WORLD ANALOGY: context.watch() is like subscribing to a YouTube channel. Every time the channel uploads (data changes), you automatically get notified and the content updates in your feed (the widget rebuilds).
HOW IT SHOWS UP IN FORGEFIT: In WorkoutScreen, final provider = context.watch<WorkoutProvider>() returns the current provider value and marks this widget as a subscriber. If the active workout updates a set count, the WorkoutScreen rebuilds to reflect the change.
WHY IT EXISTS: Consumer widgets add nesting. context.watch() achieves the same subscription with less code — simply read the provider inside build() and Flutter handles the rebuild subscription automatically.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter context.watch vs Consumer
  → Query 2 (intermediate): Flutter Provider context.watch context.read usage
  → Query 3 (deep dive): Flutter Provider rebuild scope watch read select
UNDERSTAND THIS BEFORE: Provider, BuildContext, Consumer
──────────────────────────────

──────────────────────────────
TERM: context.read()
CATEGORY: Mobile
IN ONE SENTENCE: A way to access a provider's current value inside build() without subscribing to updates — used when you want to call a method but don't need to rebuild on changes.
THE REAL-WORLD ANALOGY: context.read() is like checking the menu at a restaurant once when you sit down (to pick your meal), without subscribing to get notified every time the menu changes throughout the day. You read once; you don't watch forever.
HOW IT SHOWS UP IN FORGEFIT: Button press handlers in ForgeFit use context.read<WorkoutProvider>().logSet(exerciseId, reps, weight). The button doesn't need to rebuild when the provider changes — it just needs to call the method once. Using context.watch() here would cause unnecessary rebuilds.
WHY IT EXISTS: Not every widget that uses a provider needs to rebuild when it changes. context.read() provides one-time access for event handlers and callbacks, avoiding unnecessary rebuilds that would hurt performance.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter context.read vs context.watch explained
  → Query 2 (intermediate): Flutter Provider read watch listen difference
  → Query 3 (deep dive): Flutter Provider performance optimisation read vs watch
UNDERSTAND THIS BEFORE: context.watch, Provider, BuildContext
──────────────────────────────

──────────────────────────────
TERM: MultiProvider
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter widget that registers multiple providers at once, making all of them available to every child widget below it in the tree.
THE REAL-WORLD ANALOGY: MultiProvider is like a hotel's utility panel in the wall — one panel provides electricity (AuthProvider), water (WorkoutProvider), internet (NutritionProvider), and TV signal (StatsProvider) simultaneously. Every room (screen) taps into whichever utility it needs.
HOW IT SHOWS UP IN FORGEFIT: main.dart wraps ForgeFitApp in a MultiProvider containing instances of AuthProvider, WorkoutProvider, ProgramProvider, NutritionProvider, StatsProvider, and OnboardingProvider. Every screen anywhere in the app can access any of these six providers.
WHY IT EXISTS: Nesting multiple Provider widgets manually creates deep indentation ("Pyramid of Doom"). MultiProvider is a convenience widget that flattens this nesting into a clean list while preserving all the same functionality.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter MultiProvider explained tutorial
  → Query 2 (intermediate): Flutter MultiProvider setup providers main.dart
  → Query 3 (deep dive): Flutter Provider tree architecture scaling patterns
UNDERSTAND THIS BEFORE: Provider, ChangeNotifier, Widget
──────────────────────────────

──────────────────────────────
TERM: Future
CATEGORY: Mobile
IN ONE SENTENCE: A Dart object representing a value that doesn't exist yet — a promise that a result will be available when some async operation completes.
THE REAL-WORLD ANALOGY: A Future is like a restaurant pager. You order (start an async operation), the cashier gives you a pager (Future), and you sit down. When the food is ready (operation completes), the pager buzzes (Future resolves with a value). You don't stand blocking the cashier the whole time.
HOW IT SHOWS UP IN FORGEFIT: Every API call in NutritionProvider returns a Future: Future<void> fetchDailyNutrition(). The Flutter UI uses FutureBuilder to display a loading spinner while this Future is pending, then shows the data when it resolves.
WHY IT EXISTS: Network requests take unpredictable time. Programming would halt completely if every API call blocked execution until complete. Future allows the app to "start the request and do other things," checking back when the result arrives.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Dart Future explained simply
  → Query 2 (intermediate): Dart Future async await tutorial
  → Query 3 (deep dive): Dart Future microtask queue event loop
UNDERSTAND THIS BEFORE: Dart, Async/Await
──────────────────────────────

──────────────────────────────
TERM: async / await (Dart)
CATEGORY: Mobile
IN ONE SENTENCE: Dart keywords that make asynchronous code look and behave like synchronous code — await pauses execution until a Future completes.
THE REAL-WORLD ANALOGY: In a non-async kitchen, you'd start heating the sauce, then stand frozen staring at the pot until it boils before doing anything else. With async/await, you start the sauce (await apiClient.get()), go prep the salad (handle other operations), and the await automatically resumes when the sauce is ready.
HOW IT SHOWS UP IN FORGEFIT: Virtually every method in ForgeFit's providers is async and uses await: Future<void> fetchDailyNutrition() async { final response = await apiClient.get('/nutrition/daily'); ... }. This keeps the UI responsive while waiting for API responses.
WHY IT EXISTS: Manually chaining callbacks (the alternative before async/await) created deeply nested "callback hell" code. Dart's async/await syntax lets developers write asynchronous code that reads linearly from top to bottom, dramatically improving readability.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Dart async await explained for beginners
  → Query 2 (intermediate): Dart Future async await error handling
  → Query 3 (deep dive): Dart async isolates concurrency model
UNDERSTAND THIS BEFORE: Future, Dart
──────────────────────────────

──────────────────────────────
TERM: Stream
CATEGORY: Mobile
IN ONE SENTENCE: A Dart object that delivers a sequence of values over time — like a continuous pipeline of events rather than a single result.
THE REAL-WORLD ANALOGY: A Future is like ordering a pizza (one delivery). A Stream is like a YouTube subscription — content keeps arriving over time, event by event. You subscribe once and handle each new item as it comes.
HOW IT SHOWS UP IN FORGEFIT: The barcode scanner in BarcodeScannerScreen uses a Stream from mobile_scanner — each time the camera detects a barcode, a new scan event is emitted to the Stream. The UI listens and processes each detection event.
WHY IT EXISTS: Some data sources produce values continuously — sensors, real-time chats, WebSockets. Futures only deliver one value. Streams extend the async model to handle sequences of values over time, essential for camera, GPS, and live data scenarios.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Dart Stream explained simply vs Future
  → Query 2 (intermediate): Flutter Stream StreamBuilder usage tutorial
  → Query 3 (deep dive): Dart Stream broadcast sincle-subscription controllers
UNDERSTAND THIS BEFORE: Future, Dart, Async/Await
──────────────────────────────

──────────────────────────────
TERM: FutureBuilder
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter widget that automatically handles the loading, error, and success states of a Future — displaying different UI depending on the current state.
THE REAL-WORLD ANALOGY: FutureBuilder is like a smart digital photo frame that shows "Loading..." while downloading a photo, shows the photo when it arrives, and shows an error message if the download fails — all without manual programming for each state.
HOW IT SHOWS UP IN FORGEFIT: Some ForgeFit screens use FutureBuilder to display a CircularProgressIndicator while an API call is pending. When the Future resolves, the builder function checks snapshot.hasData and renders the content or an error widget accordingly.
WHY IT EXISTS: Without FutureBuilder, developers would manually setIsLoading, setHasError, and setData using setState in separate try/catch/finally blocks — verbose and error-prone. FutureBuilder encapsulates this pattern elegantly.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter FutureBuilder explained tutorial
  → Query 2 (intermediate): Flutter FutureBuilder ConnectionState loading error data
  → Query 3 (deep dive): FutureBuilder vs StreamBuilder vs Consumer Provider
UNDERSTAND THIS BEFORE: Future, Widget, StatelessWidget
──────────────────────────────

──────────────────────────────
TERM: SharedPreferences
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter plugin for storing small, simple key-value data (like settings and preferences) that persists after the app is closed.
THE REAL-WORLD ANALOGY: SharedPreferences is like a sticky note on your fridge. It's great for small reminders — "milk, eggs, bread" (simple settings). You wouldn't paste your entire tax return on a sticky note. Small, quick access, survives power cuts (app restarts).
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses SharedPreferences to store non-sensitive preferences like the user's preferred unit system or last-viewed macro targets screen. It's explicitly NOT used for JWT tokens — those go in flutter_secure_storage for security reasons.
WHY IT EXISTS: Apps need to remember simple user preferences across sessions. SharedPreferences wraps the platform-native key-value stores (Android SharedPreferences, iOS NSUserDefaults) in a cross-platform Flutter API.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter SharedPreferences explained tutorial
  → Query 2 (intermediate): Flutter SharedPreferences vs secure storage difference
  → Query 3 (deep dive): Flutter SharedPreferences performance large data alternatives
UNDERSTAND THIS BEFORE: Flutter, Dart
──────────────────────────────

──────────────────────────────
TERM: flutter_secure_storage
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter plugin that stores sensitive data (like authentication tokens) in the platform's encrypted hardware-backed secure storage.
THE REAL-WORLD ANALOGY: If SharedPreferences is a sticky note on your fridge, flutter_secure_storage is a biometric-locked safe bolted to the floor. Tokens stored here are encrypted by the phone's hardware chip — even a stolen phone does not immediately expose them.
HOW IT SHOWS UP IN FORGEFIT: TokenStorage (core/storage/token_storage.dart) uses flutter_secure_storage to save and read the JWT access token and refresh token. This ensures tokens survive app restarts but cannot be extracted by other apps or by reading the phone's filesystem.
WHY IT EXISTS: Regular storage (SharedPreferences, files) is accessible to anyone with device access or other apps. Sensitive credentials like authentication tokens need hardware-level encryption — flutter_secure_storage delegates to Android Keystore and iOS Keychain for this.
SEARCH THIS ONLINE:
  → Query 1 (beginner): flutter_secure_storage tutorial JWT token storage
  → Query 2 (intermediate): Flutter secure storage vs SharedPreferences security
  → Query 3 (deep dive): Android Keystore iOS Keychain flutter_secure_storage implementation
UNDERSTAND THIS BEFORE: SharedPreferences, JWT, Authentication
──────────────────────────────

──────────────────────────────
TERM: Android Keystore / iOS Keychain
CATEGORY: Mobile
IN ONE SENTENCE: Operating system-level secure vaults that store cryptographic keys and sensitive data, hardware-encrypted and accessible only to the owning application.
THE REAL-WORLD ANALOGY: The Android Keystore and iOS Keychain are like a bank's safe deposit boxes — only the box's owner (the specific app) has the key, the bank (OS) uses hardware to secure the vault, and even bank employees (other apps or root access) cannot open your specific box without your key.
HOW IT SHOWS UP IN FORGEFIT: flutter_secure_storage automatically uses Android Keystore on Android and iOS Keychain on iOS when TokenStorage writes JWT tokens. This is transparent to the ForgeFit code — the storage plugin handles platform selection.
WHY IT EXISTS: Apps need to store credentials that survive app restarts but cannot be stolen by malware or by someone with physical device access. Platform-level hardware security provides this guarantee that app-level encryption alone cannot match.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Android Keystore iOS Keychain explained simply
  → Query 2 (intermediate): Flutter secure storage Android Keystore implementation
  → Query 3 (deep dive): Android Keystore hardware-backed keys StrongBox
UNDERSTAND THIS BEFORE: flutter_secure_storage, Authentication, JWT
──────────────────────────────

──────────────────────────────
TERM: Dio (HTTP client)
CATEGORY: Mobile
IN ONE SENTENCE: A powerful Flutter HTTP client library used to make API requests, with built-in support for interceptors, timeouts, and JSON serialisation.
THE REAL-WORLD ANALOGY: Dio is like a premium courier service instead of the basic postal system. It handles everything: certified delivery (interceptors), guaranteed arrival time (timeouts), package tracking (request logging), and automatic formatting of your parcel (JSON encoding/decoding). Plain HTTP is the basic mail; Dio is FedEx.
HOW IT SHOWS UP IN FORGEFIT: api_client.dart creates a Dio instance configured with the base URL, default headers, and timeout settings. The AuthInterceptor is added to Dio's interceptors list. Every API call (fetchWorkouts, logFood, login) goes through this Dio instance.
WHY IT EXISTS: Dart's built-in http package is minimal. Dio adds interceptors (for auth headers and token refresh), request cancellation, form data handling, and progress indicators — features required by real-world mobile apps.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter Dio HTTP client explained tutorial
  → Query 2 (intermediate): Flutter Dio interceptors auth headers tutorial
  → Query 3 (deep dive): Dio advanced usage interceptors retry token refresh
UNDERSTAND THIS BEFORE: HTTP, Flutter, Dart, Future
──────────────────────────────

──────────────────────────────
TERM: Interceptor (Dio)
CATEGORY: Mobile
IN ONE SENTENCE: A piece of code that automatically runs before every request or after every response in Dio — used for adding headers, handling errors, or refreshing tokens.
THE REAL-WORLD ANALOGY: A Dio Interceptor is like a customs officer at a border crossing. Every car (request) passes through before entering the destination. The officer checks documents (adds auth headers), and on the way back (response), checks what was brought back — flagging issues (401 errors) for token refresh.
HOW IT SHOWS UP IN FORGEFIT: AuthInterceptor in core/network/api_client.dart intercepts every Dio request to add "Authorization: Bearer <token>" from TokenStorage. On a 401 response, it automatically calls the refresh endpoint, gets a new token, and retries the original request — all transparent to the screen.
WHY IT EXISTS: Without interceptors, every API call would need to manually add auth headers and handle token expiry. Interceptors centralise this cross-cutting behaviour in one place — write it once and it applies to every request automatically.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Dio interceptor Flutter explained
  → Query 2 (intermediate): Flutter Dio AuthInterceptor token refresh tutorial
  → Query 3 (deep dive): Dio interceptor queue concurrent request refresh race condition
UNDERSTAND THIS BEFORE: Dio, Bearer Token, Refresh Token
──────────────────────────────

──────────────────────────────
TERM: AuthInterceptor
CATEGORY: Mobile
IN ONE SENTENCE: ForgeFit's specific Dio interceptor that adds Bearer tokens to every request and automatically refreshes expired tokens without requiring user re-login.
THE REAL-WORLD ANALOGY: AuthInterceptor is the dedicated passport control officer specifically trained for ForgeFit's border rules. They know exactly which stamp (token) to put on every outgoing traveller, and when a stamp expires (401 error), they issue a fresh stamp (refresh token) and let the traveller continue without turning them back.
HOW IT SHOWS UP IN FORGEFIT: Defined in core/network/api_client.dart. Every outgoing Dio request gets "Authorization: Bearer $accessToken" added. If the response is 401, the interceptor calls POST /auth/refresh with the stored refresh token, saves the new access token, and retries the original failed request invisibly.
WHY IT EXISTS: Token expiry would otherwise cause sudden app failures requiring the user to manually log in again every 30 minutes. AuthInterceptor makes the 30-minute expiry completely invisible to users by silently renewing tokens in the background.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter Dio AuthInterceptor token refresh explained
  → Query 2 (intermediate): implementing token refresh interceptor Dio Flutter
  → Query 3 (deep dive): Dio interceptor concurrent request queue token refresh race
UNDERSTAND THIS BEFORE: Dio, Interceptor, Refresh Token, Bearer Token
──────────────────────────────

──────────────────────────────
TERM: fl_chart
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter charting library that provides pie charts, bar charts, and line charts — used in ForgeFit to visualise macros, workout volume, and nutrition trends.
THE REAL-WORLD ANALOGY: fl_chart is like a pre-built chart template factory. Instead of drawing every segment, axis, and data point from scratch with a pencil ruler, you hand your data to the factory and it produces a beautifully formatted chart automatically.
HOW IT SHOWS UP IN FORGEFIT: The Nutrition tab's circular macro display uses PieChart from fl_chart. The workout volume overview and calorie trend graphs use BarChart and LineChart respectively. Charts are configured by providing data lists (PieChartSectionData, BarChartGroupData) and styling parameters.
WHY IT EXISTS: Data visualisation in mobile apps requires complex mathematics and rendering. fl_chart abstracts this so developers just provide their data and styling preferences — the library handles the bezier curves, axis calculations, and touch interactions.
SEARCH THIS ONLINE:
  → Query 1 (beginner): fl_chart Flutter tutorial pie bar line chart
  → Query 2 (intermediate): fl_chart PieChart BarChart data configuration
  → Query 3 (deep dive): fl_chart custom painter touch interactions animations
UNDERSTAND THIS BEFORE: Flutter, Widget, Dart
──────────────────────────────

──────────────────────────────
TERM: PieChart / PieChartSectionData
CATEGORY: Mobile
IN ONE SENTENCE: fl_chart's circular chart widget and its data model — each PieChartSectionData represents one slice with a value, colour, and label.
THE REAL-WORLD ANALOGY: PieChart is the circular chart itself (the whole wheel). PieChartSectionData is the recipe for each slice — "protein: 30%, blue, labelled '30g.'" You create one section per macro, hand them to PieChart, and it renders the circle.
HOW IT SHOWS UP IN FORGEFIT: The NutritionScreen's macro ring is built with PieChart(data: PieChartData(sections: [PieChartSectionData(value: proteinCalories, color: proteinColor), ...])). Three sections (carbs, fat, protein) form the donut chart showing the macro balance.
WHY IT EXISTS: The donut/pie chart is the most intuitive way to show proportional breakdowns. PieChartSectionData provides the data model that cleanly separates data definition from rendering logic.
SEARCH THIS ONLINE:
  → Query 1 (beginner): fl_chart PieChart Flutter tutorial
  → Query 2 (intermediate): fl_chart PieChart sections colours donut chart
  → Query 3 (deep dive): fl_chart PieChart touch interaction callback custom radius
UNDERSTAND THIS BEFORE: fl_chart, Flutter, Widget
──────────────────────────────

──────────────────────────────
TERM: BarChart
CATEGORY: Mobile
IN ONE SENTENCE: fl_chart's bar chart widget for showing discrete data as vertical bars across a categorical or time axis.
THE REAL-WORLD ANALOGY: A bar chart is like a row of measuring cups lined up side by side — each cup represents one day's or one exercise's value, and the height of the liquid shows the magnitude. Comparing heights makes trends immediately obvious.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit's stats screen uses BarChart to visualise weekly workout volume — each bar represents one day's total sets or volume. BarChartGroupData and BarChartRodData configure each bar's position and height from the workout stats API response.
WHY IT EXISTS: Discrete category comparisons (day-by-day, exercise-by-exercise) are clearest as bar charts. fl_chart's BarChart handles axis rendering, touch detection, and animation automatically when data changes.
SEARCH THIS ONLINE:
  → Query 1 (beginner): fl_chart BarChart Flutter tutorial
  → Query 2 (intermediate): fl_chart grouped bar chart BarChartGroupData
  → Query 3 (deep dive): fl_chart BarChart animation touch events customisation
UNDERSTAND THIS BEFORE: fl_chart, Widget, Flutter
──────────────────────────────

──────────────────────────────
TERM: LineChart
CATEGORY: Mobile
IN ONE SENTENCE: fl_chart's line chart widget for showing continuous trends over time — like body weight progression or calorie intake history.
THE REAL-WORLD ANALOGY: A line chart is like a hiking trail map viewed from above — it connects data points with a path, making upward and downward trends instantly visible. A bar chart (discrete steps) vs line chart (continuous path) is the visual difference between stairs and a ramp.
HOW IT SHOWS UP IN FORGEFIT: Progress screens in ForgeFit use LineChart to display calorie intake trends over the past week or month. LineChartBarData defines the line style, and FlSpot(x, y) objects represent each data point (day, calorie total).
WHY IT EXISTS: Time-series data (weight over weeks, calories over days) is best visualised as connected curves showing the trend. fl_chart's LineChart handles bezier curves between data points, providing smooth, professional-looking trend graphs.
SEARCH THIS ONLINE:
  → Query 1 (beginner): fl_chart LineChart Flutter tutorial
  → Query 2 (intermediate): fl_chart LineChart FlSpot time series data
  → Query 3 (deep dive): fl_chart LineChart gradient fill bezier curves
UNDERSTAND THIS BEFORE: fl_chart, Widget, Flutter
──────────────────────────────

──────────────────────────────
TERM: Barcode Scanner
CATEGORY: Mobile
IN ONE SENTENCE: A feature that uses the phone's camera to read barcode numbers from food packaging, then automatically looks up the nutritional information.
THE REAL-WORLD ANALOGY: The barcode scanner is like a cashier's laser gun at the supermarket — instead of typing a product number, you point the camera at the barcode on your protein bar, the number is read instantly, and ForgeFit fetches everything you need to know about that food automatically.
HOW IT SHOWS UP IN FORGEFIT: BarcodeScannerScreen (features/nutrition/screens/barcode_scanner_screen.dart) uses the mobile_scanner package (pubspec.yaml). The camera stream detects barcodes, the UPC code is extracted, and the app calls the food search API with that code to look up nutritional data.
WHY IT EXISTS: Manually searching for food by typing product names is slow and inaccurate. Barcode scanning provides instant, precise product identification — the UPC code maps directly to a specific product in the USDA/food database.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter barcode scanner mobile_scanner tutorial
  → Query 2 (intermediate): Flutter QR barcode scanner MobileScanner integration
  → Query 3 (deep dive): Flutter camera barcode detection performance frame rate
UNDERSTAND THIS BEFORE: Flutter, Camera, Stream (Dart)
──────────────────────────────

──────────────────────────────
TERM: debounce
CATEGORY: Mobile
IN ONE SENTENCE: A programming technique that delays executing a function until the user has stopped performing an action for a set period — preventing excessive API calls from rapid typing.
THE REAL-WORLD ANALOGY: Debounce is like a smart elevator that waits 3 seconds after the last button press before moving. If you press a floor button twice quickly, it doesn't make two trips — it waits for you to finish pressing, then acts once. This saves energy (API calls).
HOW IT SHOWS UP IN FORGEFIT: FoodSearchScreen uses a debounce Timer set to 500ms. When a user types quickly in the search box ("chick"..."chicken"..."chicken breast"), the API is not called after each letter. It waits until the user pauses for 500ms, then sends one clean search request.
WHY IT EXISTS: The USDA API has rate limits and response latency. Without debouncing, every keystroke would fire an API request — 12 letters = 12 calls for "chicken breast." Debouncing collapses this to 1-2 meaningful calls, reducing load and improving responsiveness.
SEARCH THIS ONLINE:
  → Query 1 (beginner): debounce programming explained simply
  → Query 2 (intermediate): Flutter debounce Timer search field implementation
  → Query 3 (deep dive): debounce vs throttle difference use cases
UNDERSTAND THIS BEFORE: Timer, Async/Await, Flutter
──────────────────────────────

──────────────────────────────
TERM: Timer
CATEGORY: Mobile
IN ONE SENTENCE: A Dart class that executes a function after a delay or on a repeating interval — used in ForgeFit for the debounce mechanism in food search.
THE REAL-WORLD ANALOGY: A Dart Timer is like a kitchen timer. You set it for 500ms. If you reset it before it rings (another keypress), it starts counting again from zero. Only when it rings undisturbed (user pauses typing) does the action (API call) fire.
HOW IT SHOWS UP IN FORGEFIT: In FoodSearchScreen, _debounceTimer?.cancel(); _debounceTimer = Timer(const Duration(milliseconds: 500), () { _search(value); }); — the timer is cancelled and restarted on every keystroke. Only when 500ms pass without a new keystroke does _search() execute.
WHY IT EXISTS: Dart's async programming doesn't have a built-in sleep that works on the UI thread. Timer provides a non-blocking delayed execution mechanism that integrates with Flutter's event loop without freezing the UI.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Dart Timer class explained Flutter
  → Query 2 (intermediate): Flutter Timer debounce search field implementation
  → Query 3 (deep dive): Dart Timer periodic event loop async
UNDERSTAND THIS BEFORE: Dart, debounce, Async/Await
──────────────────────────────

──────────────────────────────
TERM: AnimatedDefaultTextStyle
CATEGORY: Mobile
IN ONE SENTENCE: A Flutter widget that smoothly animates text style changes — like font size or colour — over a defined duration when the style properties change.
THE REAL-WORLD ANALOGY: AnimatedDefaultTextStyle is like a dimmer switch on a light instead of a hard on/off switch. Instead of text snapping from small to large, it glides smoothly between sizes over a fraction of a second — a subtle but premium-feeling animation.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses AnimatedDefaultTextStyle for the calorie count display in the Nutrition tab — when the calorie total updates, the number animates its size transition rather than jumping, creating a polished feel that matches the dark fitness aesthetic.
WHY IT EXISTS: Abrupt UI changes feel jarring and cheap. Animated transitions signal to users that data has changed while maintaining visual continuity. AnimatedDefaultTextStyle provides this for text without requiring a custom animation controller.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter AnimatedDefaultTextStyle explained
  → Query 2 (intermediate): Flutter implicit animation widgets animated tutorial
  → Query 3 (deep dive): Flutter animation explicit vs implicit AnimatedWidget
UNDERSTAND THIS BEFORE: Flutter, Widget, StatefulWidget
──────────────────────────────

═══════════════════════════════════════
GROUP 6 — STATE MANAGEMENT
═══════════════════════════════════════

──────────────────────────────
TERM: State
CATEGORY: Programming Concept
IN ONE SENTENCE: Any data that can change over time and affects what the UI displays — like the current calorie count, whether a button is loading, or which tab is active.
THE REAL-WORLD ANALOGY: State is like the current balance on a scoreboard. It's always some value right now, and the display must always reflect the current value accurately. Every time the score changes, the board must update. The scoreboard without a current number is meaningless.
HOW IT SHOWS UP IN FORGEFIT: In ForgeFit, state includes: the list of today's food logs, the current workout's exercises and sets, the logged-in user's profile, and macro targets. Every piece of data that can change and needs to be reflected on-screen is state.
WHY IT EXISTS: UIs are not static documents — they reflect the current situation. "State" is the formal name for this snapshot of current data that drives the display. Managing state is the central challenge of any interactive application.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is state in programming explained simply
  → Query 2 (intermediate): Flutter state management overview types of state
  → Query 3 (deep dive): UI state management reactive programming concepts
UNDERSTAND THIS BEFORE: Widget, Flutter, Variable
──────────────────────────────

──────────────────────────────
TERM: State Management
CATEGORY: Programming Concept
IN ONE SENTENCE: The system and patterns used to organise, update, and share state across different parts of an application in a predictable way.
THE REAL-WORLD ANALOGY: State management is like a city's traffic control system. Without it, every intersection manages itself (chaos). With it, a central system (Provider, in ForgeFit) coordinates signal timing, shares information across intersections, and keeps traffic flowing predictably in all directions.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses the Provider pattern for state management. Each feature domain (auth, workout, nutrition, stats) has its own Provider class derived from ChangeNotifier. These are registered in MultiProvider at the app root and consumed by screens via context.watch.
WHY IT EXISTS: As apps grow, sharing state between screens becomes chaotic without a system. State management patterns emerged to answer "where does state live, who can change it, and how do others know it changed?" — making large apps maintainable.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter state management explained simply
  → Query 2 (intermediate): Flutter Provider state management tutorial complete
  → Query 3 (deep dive): Flutter state management comparison Provider Riverpod Bloc
UNDERSTAND THIS BEFORE: State, Provider, ChangeNotifier
──────────────────────────────

──────────────────────────────
TERM: Local State
CATEGORY: Programming Concept
IN ONE SENTENCE: State that lives inside a single widget and doesn't need to be shared with other parts of the app — managed with setState().
THE REAL-WORLD ANALOGY: Local state is like the settings on your personal TV remote. Whether the mute is on or off only affects that TV — nobody else in the building needs to know. It's private, local, and self-contained.
HOW IT SHOWS UP IN FORGEFIT: The macro slider position in MacroTargetsScreen is local state — only that screen needs to know where the sliders are. bool _isLoading in individual screens tracks loading spinners. These use setState() because they don't need to be shared globally.
WHY IT EXISTS: Not all state needs to be global. Using the lightest appropriate state mechanism (local setState for small things, Provider for shared things) keeps code simple and avoids unnecessary rebuilds across the widget tree.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter local state setState explained
  → Query 2 (intermediate): local vs global state Flutter when to use each
  → Query 3 (deep dive): Flutter state scope ephemeral state app state
UNDERSTAND THIS BEFORE: State, setState, StatefulWidget
──────────────────────────────

──────────────────────────────
TERM: Global State
CATEGORY: Programming Concept
IN ONE SENTENCE: State that is shared across multiple screens or widgets — managed with Provider in ForgeFit so any part of the app can access and react to it.
THE REAL-WORLD ANALOGY: Global state is like the temperature setting for an entire hotel's central heating system. Any room (screen) can read the current temperature, and when the manager at the front desk adjusts it (updates state), all rooms warm up simultaneously.
HOW IT SHOWS UP IN FORGEFIT: The currently logged-in user's data (AuthProvider), today's nutrition totals (NutritionProvider), and the active workout session (WorkoutProvider) are all global state. The HomeScreen tab and the Nutrition detail screen both read from NutritionProvider simultaneously.
WHY IT EXISTS: Many features need access to the same data. The logged-in user's identity, for example, is needed by every screen. Without global state management, this data would have to be passed down through every widget in the tree — impractical at scale.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter global state management explained
  → Query 2 (intermediate): Flutter Provider global state MultiProvider
  → Query 3 (deep dive): Flutter global state architecture patterns
UNDERSTAND THIS BEFORE: State, Provider, ChangeNotifier
──────────────────────────────

──────────────────────────────
TERM: Reactive UI
CATEGORY: Programming Concept
IN ONE SENTENCE: A UI that automatically updates itself whenever the underlying data changes — without needing manual code to synchronise the display with the data.
THE REAL-WORLD ANALOGY: A reactive UI is like a digital stock ticker. You don't press "refresh" — whenever a price changes in the market, the display updates automatically. The display is always a live reflection of the data, not a static snapshot.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit's NutritionScreen is reactive — when NutritionProvider calls notifyListeners() after fetching data, the macro rings, calorie totals, and food list all update automatically without any button press. The screen is always a live view of the provider's current state.
WHY IT EXISTS: Imperative UI updates (manually calling "show this data here" after every change) are error-prone and verbose. Reactive UIs flip the model — data drives the UI automatically, eliminating a whole class of synchronisation bugs.
SEARCH THIS ONLINE:
  → Query 1 (beginner): reactive programming UI explained simply
  → Query 2 (intermediate): Flutter reactive UI Provider ChangeNotifier explained
  → Query 3 (deep dive): reactive programming RxDart streams Flutter
UNDERSTAND THIS BEFORE: State, notifyListeners, Provider
──────────────────────────────

──────────────────────────────
TERM: Rebuild / Re-render
CATEGORY: Programming Concept
IN ONE SENTENCE: The process of Flutter calling build() again on a widget to generate an updated UI — triggered by state changes or provider notifications.
THE REAL-WORLD ANALOGY: A rebuild is like a live TV studio stage manager calling "reset!" — the camera (Flutter renderer) looks at the set again and repaints everything that has changed since the last shot. Unchanged parts of the set are not repainted (Flutter diffing).
HOW IT SHOWS UP IN FORGEFIT: When WorkoutProvider.notifyListeners() is called after logging a new set, every widget in the workout logging screen that uses context.watch<WorkoutProvider>() is rebuilt. Flutter compares the new build output to the previous one and only updates what changed on-screen.
WHY IT EXISTS: Computers can't edit pixels selectively in raw mode — you build the whole description and the framework figures out what actually changed. Rebuilds are Flutter's way of reconciling "what the code describes" with "what is on screen," with efficiency via diffing.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Flutter widget rebuild explained when does it happen
  → Query 2 (intermediate): Flutter rebuild optimisation const widgets keys
  → Query 3 (deep dive): Flutter element tree reconciliation diffing algorithm
UNDERSTAND THIS BEFORE: build(), State, Widget Tree
──────────────────────────────

═══════════════════════════════════════
GROUP 7 — EXTERNAL APIS & DATA
═══════════════════════════════════════

──────────────────────────────
TERM: External API
CATEGORY: Web Fundamentals
IN ONE SENTENCE: An API provided by a third party — a separate company's service that your app calls to get data or functionality you don't build yourself.
THE REAL-WORLD ANALOGY: Using an external API is like buying electricity from the power grid instead of building your own generator. The power company (external API) provides a standardised socket (API interface) — you plug in and get power (data) without understanding their power plant.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit's backend calls two external APIs: ExerciseDB for exercise data and GIF URLs, and the USDA FoodData Central for nutritional information. Neither dataset is stored locally — the backend fetches and caches it from these external sources.
WHY IT EXISTS: Building your own database of 10,000 exercises or 600,000 food items from scratch would take years. External APIs give developers instant access to rich, maintained datasets — accelerating development by orders of magnitude.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a third party API explained simply
  → Query 2 (intermediate): how to call an external API Python requests httpx
  → Query 3 (deep dive): third party API integration error handling caching
UNDERSTAND THIS BEFORE: API, HTTP, REST API
──────────────────────────────

──────────────────────────────
TERM: Third-Party API
CATEGORY: Web Fundamentals
IN ONE SENTENCE: Synonymous with external API — a service built and maintained by someone else that you integrate into your project via HTTP calls.
THE REAL-WORLD ANALOGY: A third-party API is like hiring a specialist subcontractor. The general contractor (your app) doesn't do electrical work (nutrition data) themselves — they hire an electrician (USDA API) who is certified, experienced, and maintains their own tools.
HOW IT SHOWS UP IN FORGEFIT: The USDA FoodData Central API and ExerciseDB API are third-party APIs. ForgeFit's backend acts as a proxy, calling these APIs on behalf of the Flutter client, adding authentication and caching before returning the data.
WHY IT EXISTS: Specialised data domains (food science, exercise science, weather, maps) require dedicated teams and massive datasets to maintain. Third-party APIs let you access this specialisation as a service, paying per use rather than building everything yourself.
SEARCH THIS ONLINE:
  → Query 1 (beginner): third party API explained what does it mean
  → Query 2 (intermediate): integrating third party API Python best practices
  → Query 3 (deep dive): third party API reliability fallback caching strategy
UNDERSTAND THIS BEFORE: API, External API
──────────────────────────────

──────────────────────────────
TERM: API Key
CATEGORY: Security
IN ONE SENTENCE: A secret code provided by an external API service that identifies your application and grants access to the API's data or functionality.
THE REAL-WORLD ANALOGY: An API key is like a library card. The library (external API) issues you a card with a unique number. Present the card to access their collection. If you lose it, someone can use the library in your name — and if you use up your borrowing limit, they know it was you.
HOW IT SHOWS UP IN FORGEFIT: USDA_API_KEY is read from environment variables in food_search.py. Every request to the USDA FoodData Central API includes params={"api_key": USDA_API_KEY}. Without this key, the USDA API returns 403 forbidden. The key is stored in .env and Railway's environment variables.
WHY IT EXISTS: External APIs need to identify who is calling them for billing, rate limiting, and abuse prevention. API keys provide this identification without requiring OAuth or complex authentication flows.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is an API key explained simply
  → Query 2 (intermediate): API key authentication security best practices
  → Query 3 (deep dive): API key vs OAuth2 authentication comparison
UNDERSTAND THIS BEFORE: API, Environment Variables, Security
──────────────────────────────

──────────────────────────────
TERM: ExerciseDB API
CATEGORY: Web Fundamentals
IN ONE SENTENCE: A third-party REST API that provides a database of exercises with descriptions, muscle targets, and animated GIF demonstrations.
THE REAL-WORLD ANALOGY: ExerciseDB is like a pre-built encyclopaedia of exercises that ForgeFit licenses. Instead of photographing and documenting 1,300 exercises, ForgeFit just queries the encyclopaedia when needed — "show me all chest exercises" — and displays the result.
HOW IT SHOWS UP IN FORGEFIT: The routers/exercises.py backend proxies requests to ExerciseDB. The Flutter exercise search screen sends queries to GET /exercises?search=bench+press, the backend fetches from ExerciseDB, caches the result, and returns it to the Flutter app.
WHY IT EXISTS: Exercise data (names, muscle groups, GIF animations, equipment) requires enormous effort to create and maintain. ExerciseDB provides this as a service, letting fitness apps focus on their unique features rather than a commodity dataset.
SEARCH THIS ONLINE:
  → Query 1 (beginner): ExerciseDB API tutorial how to use
  → Query 2 (intermediate): ExerciseDB API endpoints exercises muscle groups
  → Query 3 (deep dive): self-hosting exercise database vs third party API tradeoffs
UNDERSTAND THIS BEFORE: API, REST API, External API
──────────────────────────────

──────────────────────────────
TERM: USDA FoodData Central API
CATEGORY: Web Fundamentals
IN ONE SENTENCE: The U.S. Department of Agriculture's free REST API providing detailed nutritional data for hundreds of thousands of foods and branded products.
THE REAL-WORLD ANALOGY: The USDA FoodData Central is like the U.S. government's official food nutrition library. Every food item ever lab-tested and documented is in there — calories, macros, 24 vitamins and minerals. ForgeFit queries this library instead of building its own nutrition database.
HOW IT SHOWS UP IN FORGEFIT: food_search.py calls https://api.nal.usda.gov/fdc/v1/foods/search for text searches and /fdc/v1/food/{fdc_id} for individual food details. Results are cached in TTLCache objects. The NUTRIENT_MAP dictionary maps USDA nutrient IDs to human-readable names and RDA values.
WHY IT EXISTS: Nutritional science requires laboratory analysis of thousands of samples per food item. The USDA maintains this data as a public service and exposes it via API so developers worldwide can build nutrition-focused applications for free.
SEARCH THIS ONLINE:
  → Query 1 (beginner): USDA FoodData Central API tutorial
  → Query 2 (intermediate): USDA FoodData Central API search nutrients tutorial
  → Query 3 (deep dive): USDA FDC API nutrient IDs food category filtering
UNDERSTAND THIS BEFORE: API, External API, API Key
──────────────────────────────

──────────────────────────────
TERM: Caching
CATEGORY: Backend
IN ONE SENTENCE: Storing a copy of data after the first fetch so that future requests return the stored copy instantly, without re-fetching from the slow original source.
THE REAL-WORLD ANALOGY: Caching is like a cheat sheet. Instead of deriving the formula from first principles every exam (making an API call every request), you write the answer on a legal cheat sheet (cache) and read it directly next time. Same result, fraction of the time.
HOW IT SHOWS UP IN FORGEFIT: food_search.py uses three TTLCache objects: _search_cache (1 hour), _detail_cache (24 hours), and _nutrients_cache (24 hours). After the first USDA API call for a food, results are cached. Subsequent requests for the same food return cached data instantly without hitting USDA.
WHY IT EXISTS: External APIs are slow (network latency), rate-limited (limited calls per day), and cost money per call. Caching eliminates redundant calls for frequently requested data, improving response times and avoiding rate limits.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is caching explained simply
  → Query 2 (intermediate): Python caching strategies TTLCache cachetools
  → Query 3 (deep dive): cache invalidation strategies HTTP caching headers
UNDERSTAND THIS BEFORE: API, External API
──────────────────────────────

──────────────────────────────
TERM: TTLCache
CATEGORY: Backend
IN ONE SENTENCE: A cache that automatically removes entries after a specified "time to live" period — ensuring stale data doesn't persist indefinitely.
THE REAL-WORLD ANALOGY: A TTLCache is like a whiteboard where notes automatically erase themselves after 1 hour. Fresh information is written when first needed; after the TTL expires the slot empties; the next request fetches fresh data and writes it again.
HOW IT SHOWS UP IN FORGEFIT: from cachetools import TTLCache. In food_search.py: _search_cache = TTLCache(maxsize=500, ttl=3600) stores up to 500 search results, each valid for 1 hour. _nutrients_cache uses ttl=86400 (24 hours) since nutritional data rarely changes.
WHY IT EXISTS: Unlimited or permanent caches eventually become huge and stale. TTL (time to live) bounds cache size temporally — data older than the TTL is considered potentially outdated and will be re-fetched, balancing freshness with efficiency.
SEARCH THIS ONLINE:
  → Query 1 (beginner): TTL cache explained simply time to live
  → Query 2 (intermediate): Python cachetools TTLCache tutorial
  → Query 3 (deep dive): cache TTL strategy choosing values API freshness
UNDERSTAND THIS BEFORE: Caching, TTL
──────────────────────────────

──────────────────────────────
TERM: Cache Hit / Cache Miss
CATEGORY: Backend
IN ONE SENTENCE: A cache hit means the requested data was found in cache and returned instantly; a cache miss means it wasn't found and had to be fetched from the original source.
THE REAL-WORLD ANALOGY: Cache hit: you ask the cheat-sheet writer "what is the area of a circle?" and find it written there — instant answer. Cache miss: you ask for a formula not on the cheat sheet — you have to derive it (call the API) and write it down for next time.
HOW IT SHOWS UP IN FORGEFIT: In food_search.py: if cache_key in _search_cache: return _search_cache[cache_key] — this is checking for a cache hit. If it's a hit, the USDA API is never called. If it's a miss (the key is not in cache), httpx makes the actual API request.
WHY IT EXISTS: The distinction matters because optimising cache hit rate is how you reduce external API dependency. A 90% hit rate means 90% of requests are served from memory instantly — the external API only sees 10% of the actual traffic.
SEARCH THIS ONLINE:
  → Query 1 (beginner): cache hit cache miss explained simply
  → Query 2 (intermediate): improving cache hit rate strategies
  → Query 3 (deep dive): cache hit ratio monitoring eviction policies
UNDERSTAND THIS BEFORE: Caching, TTLCache
──────────────────────────────

──────────────────────────────
TERM: Stale Data
CATEGORY: Backend
IN ONE SENTENCE: Cached data that is older than the TTL and may no longer reflect the current truth in the original source.
THE REAL-WORLD ANALOGY: Stale data is like last week's newspaper. It was accurate when printed, but the stock prices, sports scores, and weather on its pages no longer reflect reality. Using stale data gives you outdated information presented as fresh fact.
HOW IT SHOWS UP IN FORGEFIT: food_search.py maintains a _stale_search_cache dictionary. If the USDA API is unavailable, ForgeFit falls back to returning data from this stale cache rather than returning an error — better to show slightly old nutritional data than no data at all.
WHY IT EXISTS: Perfect freshness at all times is impossible when you depend on external services. The stale-while-revalidate pattern acknowledges that slightly outdated data is often better than an error message, especially for relatively stable data like nutritional information.
SEARCH THIS ONLINE:
  → Query 1 (beginner): stale data cache programming explained
  → Query 2 (intermediate): stale-while-revalidate caching pattern explained
  → Query 3 (deep dive): cache consistency strategies eventual consistency
UNDERSTAND THIS BEFORE: Caching, TTL, Cache Hit/Miss
──────────────────────────────

──────────────────────────────
TERM: TTL (Time To Live)
CATEGORY: Backend
IN ONE SENTENCE: The maximum age allowed for a piece of cached data before it is considered expired and must be refreshed from its original source.
THE REAL-WORLD ANALOGY: TTL is like a "best before" date stamped on a jar. The jam (cached data) is still good up to that date. After it, you throw the jar away and buy a fresh one. The date doesn't tell you if the jam went bad; it tells you when to stop trusting it.
HOW IT SHOWS UP IN FORGEFIT: The USDA food search results use TTL of 3,600 seconds (1 hour). Individual food nutrient breakdowns use TTL of 86,400 seconds (24 hours). These values reflect how often the underlying USDA data actually changes — rarely, allowing aggressive caching.
WHY IT EXISTS: Without TTL, cached data could persist forever — showing users nutritional information that has been updated in the source database years ago. TTL balances the efficiency of caching with the accuracy of relatively fresh data.
SEARCH THIS ONLINE:
  → Query 1 (beginner): TTL time to live explained simply
  → Query 2 (intermediate): cache TTL setting strategies Python cachetools
  → Query 3 (deep dive): HTTP cache-control max-age TTL headers
UNDERSTAND THIS BEFORE: Caching, TTLCache
──────────────────────────────

──────────────────────────────
TERM: cachetools
CATEGORY: Backend
IN ONE SENTENCE: A Python library providing ready-made cache data structures including TTLCache, LRUCache, and others with configurable size and expiry.
THE REAL-WORLD ANALOGY: cachetools is like a set of pre-built safe deposit box systems. Instead of welding your own vault from scratch, you choose the model that fits your use case (TTLCache = self-erasing boxes), configure its capacity and timing, and it manages everything automatically.
HOW IT SHOWS UP IN FORGEFIT: from cachetools import TTLCache is imported in food_search.py. Three TTLCache instances (_search_cache, _detail_cache, _nutrients_cache) are created with different maxsize and ttl values. cachetools handles cache eviction, TTL tracking, and thread-safe access automatically.
WHY IT EXISTS: Building a thread-safe in-memory cache with TTL expiry from scratch involves complex timing and concurrency logic. cachetools provides well-tested, production-ready cache implementations as a simple package import.
SEARCH THIS ONLINE:
  → Query 1 (beginner): cachetools Python package tutorial
  → Query 2 (intermediate): Python cachetools TTLCache LRUCache usage
  → Query 3 (deep dive): cachetools thread safety expiry eviction strategies
UNDERSTAND THIS BEFORE: Python, TTLCache, Caching
──────────────────────────────

──────────────────────────────
TERM: In-Memory Cache
CATEGORY: Backend
IN ONE SENTENCE: A cache stored in the running program's RAM — extremely fast to access, but lost if the server restarts or crashes.
THE REAL-WORLD ANALOGY: In-memory cache is like notes on a sticky note on your desk — instantly readable and writable, but if you step away from your desk (server restart), the cleaners might throw it away (memory cleared). Permanent storage requires writing to a notebook (database or Redis).
HOW IT SHOWS UP IN FORGEFIT: ForgeFit's TTLCache objects live in the Python process's memory — fast, but cleared on every deployment to Railway. This is acceptable because USDA data is fetched again on first access after a restart. For higher traffic, Redis would replace this with a persistent shared cache.
WHY IT EXISTS: Database queries and external API calls add milliseconds to every response. In-memory caches reduce this to microseconds for cached items — no network round-trip required. The tradeoff is volatility: memory is lost on process restart.
SEARCH THIS ONLINE:
  → Query 1 (beginner): in-memory cache explained simply
  → Query 2 (intermediate): in-memory cache Python vs Redis comparison
  → Query 3 (deep dive): in-memory cache distributed systems Redis Memcached
UNDERSTAND THIS BEFORE: Caching, TTLCache, Redis
──────────────────────────────

──────────────────────────────
TERM: Micronutrients / Macronutrients
CATEGORY: Data Format
IN ONE SENTENCE: Macronutrients (protein, carbs, fat) are needed in large amounts for energy; micronutrients (vitamins, minerals) are needed in tiny amounts for body functions.
THE REAL-WORLD ANALOGY: Macros are like the main structural materials of a house (concrete, wood, steel — large volumes needed). Micronutrients are like the electricity, plumbing, and internet wiring — tiny in volume but absolutely essential; without them the house cannot function.
HOW IT SHOWS UP IN FORGEFIT: The NutritionLog model tracks macros (protein_g, carbs_g, fat_g, calories) for every food entry. The /food/{fdc_id}/nutrients endpoint returns detailed micronutrient data. The MicronutrientDashboardScreen displays vitamin and mineral RDA percentages.
WHY IT EXISTS: People track macros for weight and muscle goals, but micronutrient deficiencies cause real health problems (iron anaemia, vitamin D deficiency). ForgeFit covering both gives users a complete nutritional picture, not just calorie counting.
SEARCH THIS ONLINE:
  → Query 1 (beginner): macronutrients vs micronutrients explained simply
  → Query 2 (intermediate): tracking macros and micros nutrition app explained
  → Query 3 (deep dive): USDA nutrient database nutrient IDs micronutrient tracking
UNDERSTAND THIS BEFORE: USDA FoodData Central API, RDA
──────────────────────────────

──────────────────────────────
TERM: RDA (Recommended Daily Allowance)
CATEGORY: Data Format
IN ONE SENTENCE: The scientifically recommended amount of a nutrient an average person should consume per day, used as a benchmark for nutrition tracking.
THE REAL-WORLD ANALOGY: RDA is like a budget allocation for your body's departments. The Ministry of Energy (calories) gets a £2000 budget; the Ministry of Calcium gets a £1000mg budget. ForgeFit tracks how much of each budget you've spent today and shows the percentage used.
HOW IT SHOWS UP IN FORGEFIT: In food_search.py's NUTRIENT_MAP, every nutrient has an rda value (e.g., Calcium: 1000mg, Vitamin C: 90mg). The /food/{fdc_id}/nutrients endpoint calculates pct_rda = (amount / rda) * 100, which the MicronutrientDashboard displays as progress bars.
WHY IT EXISTS: Raw milligrams or micrograms of nutrients are meaningless without context. "50mg of Vitamin C" conveys little — "56% of your daily Vitamin C" is immediately understandable. RDA percentages translate scientific quantities into actionable daily targets.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is RDA recommended daily allowance nutrients
  → Query 2 (intermediate): how to calculate percentage of RDA nutrition tracking
  → Query 3 (deep dive): RDA vs AI vs UL nutrient reference values comparison
UNDERSTAND THIS BEFORE: Micronutrients/Macronutrients, USDA FoodData Central
──────────────────────────────

──────────────────────────────
TERM: FDC ID (Food Data Central ID)
CATEGORY: Data Format
IN ONE SENTENCE: The unique numeric identifier that USDA assigns to every food item in the FoodData Central database — used to fetch detailed nutrition for a specific food.
THE REAL-WORLD ANALOGY: An FDC ID is like a library ISBN number. Just as ISBN 9780143127796 identifies one specific edition of one book across all libraries worldwide, FDC ID 2003587 identifies one specific food item (e.g., "Chicken breast, raw") in the USDA database.
HOW IT SHOWS UP IN FORGEFIT: When a user selects a food from search results, its fdc_id is stored in the NutritionLog table. The Flutter app uses this ID to call GET /food/{fdc_id} for detail and GET /food/{fdc_id}/nutrients for micronutrient breakdown. The schema stores fdc_id as an Integer column.
WHY IT EXISTS: Food names are ambiguous — "apple" could be dozens of different entries. FDC IDs provide unambiguous food identification that links the nutrition log to the exact USDA record, enabling reproducible nutritional calculations.
SEARCH THIS ONLINE:
  → Query 1 (beginner): USDA FoodData Central FDC ID explained
  → Query 2 (intermediate): USDA FDC API food search fdcId usage
  → Query 3 (deep dive): USDA FoodData Central food categories data types
UNDERSTAND THIS BEFORE: USDA FoodData Central API, Primary Key concept
──────────────────────────────

──────────────────────────────
TERM: Barcode / UPC
CATEGORY: Data Format
IN ONE SENTENCE: A machine-readable pattern of black bars (or QR squares) printed on product packaging that encodes a unique product identifier number.
THE REAL-WORLD ANALOGY: A barcode (UPC) is like a product's fingerprint. Every package of "Nature Valley Oat & Honey Granola Bars 150g" in every supermarket worldwide shares the same barcode — the same fingerprint. Scan it anywhere and you get the same product record.
HOW IT SHOWS UP IN FORGEFIT: BarcodeScannerScreen uses the mobile_scanner package to read UPC barcodes from food packaging. The scanned number is passed to the food search API — the USDA database can look up foods by their GTIN-UPC barcode. This enables one-scan food logging.
WHY IT EXISTS: Manually typing food names is slow and often inaccurate (different users spell "yoghurt" differently). Barcodes are standardised, universally printed on packaged food, and map to unique product records — enabling instant, accurate food identification.
SEARCH THIS ONLINE:
  → Query 1 (beginner): barcode UPC explained simply how it works
  → Query 2 (intermediate): Flutter barcode scanner food lookup USDA
  → Query 3 (deep dive): UPC EAN barcode standards GTIN food databases
UNDERSTAND THIS BEFORE: Barcode Scanner, USDA FoodData Central API
──────────────────────────────

═══════════════════════════════════════
GROUP 8 — DEVOPS & DEPLOYMENT
═══════════════════════════════════════

──────────────────────────────
TERM: Deployment
CATEGORY: DevOps
IN ONE SENTENCE: The process of taking your application code and making it run on a server that is accessible to real users over the Internet.
THE REAL-WORLD ANALOGY: Deployment is like opening a restaurant to the public after months of testing in a closed kitchen. You move from "private testing" to "publicly accessible" — the code that worked on your laptop now runs on a server anyone can reach.
HOW IT SHOWS UP IN FORGEFIT: The ForgeFit FastAPI backend is deployed to Railway. When code changes are pushed to the git repository, Railway automatically rebuilds the container, runs the Procfile command, and serves the new version at the production URL — the Flutter app immediately points to this live server.
WHY IT EXISTS: Code running only on a developer's laptop is useless to other users. Deployment is the final step that transforms private development work into a public service. The challenge is doing this consistently, reliably, and without downtime.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is app deployment explained simply
  → Query 2 (intermediate): deploying FastAPI to Railway tutorial
  → Query 3 (deep dive): deployment strategies blue-green canary rolling update
UNDERSTAND THIS BEFORE: Server, Backend, Environment Variables
──────────────────────────────

──────────────────────────────
TERM: PaaS (Platform as a Service)
CATEGORY: DevOps
IN ONE SENTENCE: A cloud hosting model where the provider manages the underlying infrastructure (servers, OS, networking) and you just deploy your application code.
THE REAL-WORLD ANALOGY: PaaS is like renting a fully equipped restaurant kitchen by the hour — the building, ovens, refrigerators, and dishwashers are provided and maintained. You just bring your chefs and ingredients (app code and dependencies) and start cooking.
HOW IT SHOWS UP IN FORGEFIT: Railway is a PaaS. ForgeFit doesn't manage any servers, operating systems, or network configuration — Railway handles all of that. You just push code, configure environment variables, and Railway runs the app. PostgreSQL on Railway is also PaaS-provided database.
WHY IT EXISTS: Managing your own servers (IaaS) requires DevOps expertise — networking, security patching, scaling, load balancing. For small teams and early products, PaaS eliminates this complexity so developers focus entirely on the application.
SEARCH THIS ONLINE:
  → Query 1 (beginner): PaaS platform as a service explained simply
  → Query 2 (intermediate): Railway PaaS vs Heroku vs Render comparison
  → Query 3 (deep dive): IaaS vs PaaS vs SaaS cloud models comparison
UNDERSTAND THIS BEFORE: Deployment, Server, Cloud Hosting
──────────────────────────────

──────────────────────────────
TERM: Railway
CATEGORY: DevOps
IN ONE SENTENCE: The cloud PaaS platform where ForgeFit's FastAPI backend and PostgreSQL database are hosted and deployed.
THE REAL-WORLD ANALOGY: Railway is like a fully managed office park. You sign up, get your own unit (container), plug your coffee machine and computers in (deploy your app), and the park management takes care of electricity, internet, security, and maintenance (infrastructure).
HOW IT SHOWS UP IN FORGEFIT: The ForgeFit backend runs on Railway. It reads the Procfile to start Uvicorn, reads environment variables for DATABASE_URL and SECRET_KEY, and provides a PostgreSQL database instance. Railway serves the app at a public HTTPS URL the Flutter app calls.
WHY IT EXISTS: Developers need somewhere to host their apps that isn't their laptop. Railway provides simple git-push deployment, automatic HTTPS, managed databases, and reasonable free tiers — balancing simplicity with professional features.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Railway app deployment tutorial FastAPI
  → Query 2 (intermediate): Railway environment variables PostgreSQL setup
  → Query 3 (deep dive): Railway vs Render vs Fly.io deployment comparison
UNDERSTAND THIS BEFORE: PaaS, Deployment, Environment Variables
──────────────────────────────

──────────────────────────────
TERM: Cloud Hosting
CATEGORY: DevOps
IN ONE SENTENCE: Running applications on remote servers owned by a cloud provider (AWS, Google Cloud, Railway) rather than on a physical computer you own.
THE REAL-WORLD ANALOGY: Cloud hosting is like a storage unit facility for clothes. Instead of building a closet in your house (your own server), you rent a unit in a secure facility (the cloud) that is maintained 24/7, fire-proof, and accessible whenever you need it (24/7 uptime).
HOW IT SHOWS UP IN FORGEFIT: ForgeFit's backend and database are cloud-hosted on Railway. The Flutter app itself is not "hosted" — it runs on the user's phone. But the backend that the app talks to is always running in Railway's cloud, accessible to anyone with the app installed.
WHY IT EXISTS: Before cloud hosting, companies rented expensive physical servers in data centres. Cloud democratised this — anyone can run a server for dollars per month, scale up instantly, and not worry about hardware failures.
SEARCH THIS ONLINE:
  → Query 1 (beginner): cloud hosting explained simply what is the cloud
  → Query 2 (intermediate): cloud hosting comparison AWS GCP Railway pricing
  → Query 3 (deep dive): cloud infrastructure regions availability zones SLAs
UNDERSTAND THIS BEFORE: Server, Deployment, Internet
──────────────────────────────

──────────────────────────────
TERM: Cold Start
CATEGORY: DevOps
IN ONE SENTENCE: The delay that occurs when a server that was idle (asleep to save resources) receives its first request and must start up before it can respond.
THE REAL-WORLD ANALOGY: A cold start is like a car that has been parked in the cold all night. When you turn the key, it takes a few seconds before it runs smoothly. A warm car (warm server) starts instantly. Free-tier cloud apps often "sleep" between requests and suffer cold starts.
HOW IT SHOWS UP IN FORGEFIT: Railway's free tier may put idle ForgeFit deployments to sleep. The /health endpoint (GET /health returns {"status": "ok"}) is used to "ping" the server regularly (using uptime monitors) to prevent cold starts and keep the server warm for user requests.
WHY IT EXISTS: Cloud providers save money by deallocating idle server resources. When traffic resumes, they spin up a new instance — but this takes time. Cold starts are the user-facing consequence of this resource optimisation.
SEARCH THIS ONLINE:
  → Query 1 (beginner): cold start serverless explained simply
  → Query 2 (intermediate): prevent cold starts Railway free tier keep warm
  → Query 3 (deep dive): cold start mitigation strategies provisioned concurrency
UNDERSTAND THIS BEFORE: Deployment, Cloud Hosting, Startup Events
──────────────────────────────

──────────────────────────────
TERM: Health Check endpoint
CATEGORY: DevOps
IN ONE SENTENCE: A simple API endpoint (GET /health) that returns "OK" — used by monitoring tools and deployment platforms to verify the server is running and responsive.
THE REAL-WORLD ANALOGY: A health check endpoint is like a building's fire alarm test button. Every week the fire brigade presses it — if it rings, the alarm system is working. If no ring, something is wrong and needs fixing. The server's health check does the same for cloud monitoring.
HOW IT SHOWS UP IN FORGEFIT: In main.py: @app.get("/health") def health_check(): return {"status": "ok", "app": "ForgeFit API"}. Railway pings this endpoint periodically. If it stops responding, Railway treats the deployment as unhealthy and restarts it automatically.
WHY IT EXISTS: Without health checks, a server could appear to be "running" (process alive) while actually being unable to serve requests (database disconnected, deadlocked). Health endpoints give load balancers and platforms a reliable way to detect real failures.
SEARCH THIS ONLINE:
  → Query 1 (beginner): health check endpoint API explained simply
  → Query 2 (intermediate): FastAPI health check endpoint Railway deployment
  → Query 3 (deep dive): health check patterns liveness readiness kubernetes
UNDERSTAND THIS BEFORE: Endpoint/Route, Deployment, FastAPI
──────────────────────────────

──────────────────────────────
TERM: Timeout
CATEGORY: DevOps
IN ONE SENTENCE: A limit set on how long a request can wait for a response before giving up and returning an error — preventing requests from hanging indefinitely.
THE REAL-WORLD ANALOGY: A timeout is like a restaurant rule: "If your food hasn't arrived within 30 minutes, we cancel the order and issue a refund." The kitchen (external API) might be overwhelmed, but you won't wait forever — after the deadline, you move on.
HOW IT SHOWS UP IN FORGEFIT: In food_search.py, every httpx call to the USDA API uses timeout=10.0 seconds. If USDA doesn't respond within 10 seconds, a TimeoutException is raised, caught in the except block, and a 503 Service Unavailable response is returned to the Flutter app.
WHY IT EXISTS: External services can hang, become slow, or go down entirely. Without timeouts, requests waiting for a response would tie up server resources indefinitely. Timeouts keep the system responsive — failing fast is better than failing slowly.
SEARCH THIS ONLINE:
  → Query 1 (beginner): API timeout explained simply
  → Query 2 (intermediate): httpx timeout FastAPI external API calls
  → Query 3 (deep dive): timeout circuit breaker retry backoff patterns
UNDERSTAND THIS BEFORE: Request, External API, Error Handling
──────────────────────────────

──────────────────────────────
TERM: Connection Pool
CATEGORY: DevOps
IN ONE SENTENCE: A pre-created set of reusable database connections — instead of creating a new connection for every request, the app reuses connections from the pool.
THE REAL-WORLD ANALOGY: A connection pool is like a taxi stand with 10 always-waiting taxis. When a passenger (request) arrives, they get a waiting taxi (connection) immediately. When done, the taxi returns to the stand (pool) — ready for the next passenger. No need to summon a new taxi (new connection) from the factory each time.
HOW IT SHOWS UP IN FORGEFIT: SQLAlchemy's create_engine() implicitly maintains a connection pool. ForgeFit's database.py doesn't configure custom pool settings, but SQLAlchemy's default pool prevents the overhead of establishing a new PostgreSQL TCP connection for every single API request.
WHY IT EXISTS: Opening a new database connection per request is expensive — TCP handshake, authentication, SSL negotiation all add 50-300ms. Connection pools reuse established connections, reducing per-request overhead to near zero.
SEARCH THIS ONLINE:
  → Query 1 (beginner): database connection pool explained simply
  → Query 2 (intermediate): SQLAlchemy connection pool configuration
  → Query 3 (deep dive): PostgreSQL connection pool limits PgBouncer
UNDERSTAND THIS BEFORE: Database, SQLAlchemy, Session
──────────────────────────────

──────────────────────────────
TERM: Horizontal Scaling
CATEGORY: DevOps
IN ONE SENTENCE: Adding more server instances to handle increased traffic, rather than making one server more powerful — spreading load across many machines.
THE REAL-WORLD ANALOGY: Horizontal scaling is like opening more checkout lanes at a supermarket when queues get long, instead of making the one cashier work faster. More lanes (servers) handle more shoppers (requests) simultaneously without making any single lane superhuman.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit's stateless JWT authentication is designed with horizontal scaling in mind — any new instance can validate any token independently (no shared session store needed). In-memory caching would not scale horizontally (each instance has its own cache), which is why Redis is mentioned as the next-step upgrade.
WHY IT EXISTS: A single server has hardware limits. When user traffic grows beyond one machine's capacity, you either upgrade to a bigger machine (vertical scaling, expensive and has limits) or add more machines (horizontal scaling, virtually unlimited and cost-effective).
SEARCH THIS ONLINE:
  → Query 1 (beginner): horizontal vs vertical scaling explained simply
  → Query 2 (intermediate): stateless API horizontal scaling JWT authentication
  → Query 3 (deep dive): load balancing horizontal scaling Kubernetes auto-scaling
UNDERSTAND THIS BEFORE: Deployment, Server, Session vs Token Authentication
──────────────────────────────

──────────────────────────────
TERM: Redis
CATEGORY: DevOps
IN ONE SENTENCE: An extremely fast in-memory data store used as a distributed cache and message broker — the production-grade upgrade to ForgeFit's current in-process cache.
THE REAL-WORLD ANALOGY: Redis is like a shared whiteboard in a shared office versus individual sticky notes at each desk. Every worker (server instance) can read and write the same whiteboard. Personal sticky notes (in-process cache) are not shared — if two workers need the same note, they each write their own.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit currently uses Python in-memory TTLCache. The project documentation notes Redis as the recommended upgrade for production scale — it would allow multiple Railway instances to share one cache and also enable distributed rate limiting (slowapi supports Redis backends).
WHY IT EXISTS: In-process caches are lost on restart and not shared between multiple server instances. Redis provides a persistent, high-speed, network-accessible cache that survives restarts and can be shared across any number of application servers.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is Redis explained simply
  → Query 2 (intermediate): Redis caching Python FastAPI tutorial
  → Query 3 (deep dive): Redis data structures cache patterns pub-sub
UNDERSTAND THIS BEFORE: Caching, In-Memory Cache, Horizontal Scaling
──────────────────────────────

──────────────────────────────
TERM: In-Memory vs Persistent Cache
CATEGORY: DevOps
IN ONE SENTENCE: In-memory cache (ForgeFit's current approach) is lightning-fast but lost on restart; persistent cache (Redis) survives restarts and is shared across multiple servers.
THE REAL-WORLD ANALOGY: In-memory cache is a chalkboard — write and erase instantly, but cleaning the board (server restart) loses everything. Persistent cache is a whiteboard with a photograph taken every few seconds — you can wipe it and restore from the last photo.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses Python-process TTLCache (in-memory). Each Railway deployment restart clears all cached USDA data, requiring re-fetching on the first requests. A Redis upgrade would make the cache survive deployments and be shared across multiple instances.
WHY IT EXISTS: The choice matters at scale. Small apps can tolerate in-memory caches. As traffic grows and multiple server instances are needed, shared persistent caches become necessary to avoid each instance making redundant external API calls.
SEARCH THIS ONLINE:
  → Query 1 (beginner): in-memory cache vs Redis difference explained
  → Query 2 (intermediate): Redis vs Python dict cache comparison FastAPI
  → Query 3 (deep dive): distributed caching Redis architecture patterns
UNDERSTAND THIS BEFORE: Caching, In-Memory Cache, Redis
──────────────────────────────

──────────────────────────────
TERM: Logs
CATEGORY: DevOps
IN ONE SENTENCE: A timestamped record of events, errors, and operations written by a running application — used to debug problems and monitor system health.
THE REAL-WORLD ANALOGY: Logs are like a ship's captain's log — a chronological record of everything that happened. "07:12 — departed port. 09:45 — engine warning. 10:00 — weather changed course." When something goes wrong, you read the log backwards to find the cause.
HOW IT SHOWS UP IN FORGEFIT: FastAPI and Uvicorn automatically log every incoming request with timestamp, path, status code, and duration. When Railway deployment has issues or a user reports an error, the Railway dashboard's logs tab shows the full event history for debugging.
WHY IT EXISTS: When a bug occurs in production, you weren't watching. Logs are the post-mortem evidence that shows exactly what happened, in what order, at what time — essential for debugging production issues that can't be reproduced locally.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what are server logs explained simply
  → Query 2 (intermediate): FastAPI logging configuration Uvicorn logs
  → Query 3 (deep dive): structured logging JSON logs observability
UNDERSTAND THIS BEFORE: Server, Deployment
──────────────────────────────

──────────────────────────────
TERM: CI/CD (brief mention)
CATEGORY: DevOps
IN ONE SENTENCE: Continuous Integration / Continuous Deployment — an automated pipeline that tests and deploys code changes automatically whenever a developer pushes to the repository.
THE REAL-WORLD ANALOGY: CI/CD is like an automated factory production line. Every time a new part design (code change) arrives from the engineers (git push), the line automatically stamps it, stress-tests it, and if it passes, ships it to customers (deploys to production) — no manual steps required.
HOW IT SHOWS UP IN FORGEFIT: Railway provides basic CD — every push to the connected git branch triggers an automatic redeploy. Full CI (automated testing, linting, coverage checks before deploy) is not yet implemented in ForgeFit but is the natural next step.
WHY IT EXISTS: Manual deployment is slow, error-prone, and requires developer availability. CI/CD pipelines standardise the build, test, and deploy process, running it automatically and consistently every time code changes — enabling teams to ship multiple times per day safely.
SEARCH THIS ONLINE:
  → Query 1 (beginner): CI CD explained simply beginners
  → Query 2 (intermediate): GitHub Actions CI CD FastAPI deployment tutorial
  → Query 3 (deep dive): CI CD pipeline testing deployment strategies
UNDERSTAND THIS BEFORE: Deployment, Git, Testing
──────────────────────────────

═══════════════════════════════════════
GROUP 9 — PROGRAMMING CONCEPTS
═══════════════════════════════════════

──────────────────────────────
TERM: Function
CATEGORY: Programming Concept
IN ONE SENTENCE: A named, reusable block of code that performs a specific task — you call it by name, it executes, and optionally returns a result.
THE REAL-WORLD ANALOGY: A function is like a recipe. The recipe "MakeCoffee" always follows the same steps: boil water, add grounds, steep, pour. You don't rewrite the steps each time — you just say "MakeCoffee" and it runs. Parameters are like specifying "strong or mild."
HOW IT SHOWS UP IN FORGEFIT: hash_password(), verify_password(), create_access_token(), is_token_revoked() in auth/utils.py are all functions. Each performs one job. The endpoints call these functions by name rather than duplicating the logic — making the code DRY (Don't Repeat Yourself).
WHY IT EXISTS: Without functions, every piece of code would be written once in-place and repeated everywhere it's needed. Functions make code reusable, readable, and maintainable — the most fundamental building block of all programming.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is a function in programming explained simply
  → Query 2 (intermediate): Python functions parameters return values tutorial
  → Query 3 (deep dive): pure functions side effects functional programming
UNDERSTAND THIS BEFORE: Nothing — foundational concept.
──────────────────────────────

──────────────────────────────
TERM: Class
CATEGORY: Programming Concept
IN ONE SENTENCE: A blueprint for creating objects that bundle related data (attributes) and functions (methods) together into one reusable unit.
THE REAL-WORLD ANALOGY: A class is like the blueprint for a specific model of car. The blueprint defines: colour (attribute), speed (attribute), accelerate() (method), brake() (method). Each physical car manufactured from that blueprint is an object (instance). Same blueprint, many cars.
HOW IT SHOWS UP IN FORGEFIT: SQLAlchemy models (User, Workout, NutritionLog) are classes. Pydantic schemas (UserCreate, Token) are classes. Flutter's WorkoutProvider, NutritionProvider are Dart classes. Every provider, every model, every schema is a class.
WHY IT EXISTS: As programs grow, grouping related data and behaviour into classes prevents code from becoming a chaotic jumble of unrelated functions and variables. Classes enable object-oriented programming — modelling the real world as named, encapsulated entities.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python class explained simply tutorial
  → Query 2 (intermediate): Python class methods attributes inheritance
  → Query 3 (deep dive): OOP design principles SOLID classes
UNDERSTAND THIS BEFORE: Function
──────────────────────────────

──────────────────────────────
TERM: Object
CATEGORY: Programming Concept
IN ONE SENTENCE: A specific instance of a class — a concrete thing created from the blueprint with its own unique data values.
THE REAL-WORLD ANALOGY: If User is the class (blueprint), then user_42 = User(email="alice@example.com", weight=65.0) is an object — a specific Alice, with specific values, living in memory. The blueprint defines the shape; the object is the actual thing.
HOW IT SHOWS UP IN FORGEFIT: new_user = User(email=user_data.email, hashed_password=...) in routers/auth.py creates a User object. This is a real, specific user in memory. db.add(new_user) hands this specific object to SQLAlchemy to generate the INSERT SQL for that user's data.
WHY IT EXISTS: Classes describe possibility; objects are reality. You need instances (objects) to actually store and manipulate specific data at runtime. Every user, workout, and nutrition log in ForgeFit is an object instantiated from its corresponding class.
SEARCH THIS ONLINE:
  → Query 1 (beginner): class vs object explained simply Python
  → Query 2 (intermediate): Python objects instantiation attributes tutorial
  → Query 3 (deep dive): object identity equality Python memory model
UNDERSTAND THIS BEFORE: Class
──────────────────────────────

──────────────────────────────
TERM: Inheritance
CATEGORY: Programming Concept
IN ONE SENTENCE: When one class automatically gets all the attributes and methods of another class it "inherits from" — enabling code reuse and specialisation.
THE REAL-WORLD ANALOGY: Inheritance is like a family business. The parent company (base class) has established processes, brands, and equipment. A new branch (child class) inherits all of these automatically and only needs to define what is unique to their location.
HOW IT SHOWS UP IN FORGEFIT: Every SQLAlchemy model inherits from Base: class User(Base):. All Pydantic schemas inherit from BaseModel. In Flutter, WorkoutProvider(ChangeNotifier) inherits all of ChangeNotifier's notification capabilities without reimplementing them.
WHY IT EXISTS: Without inheritance, every class would need to duplicate common code. A shared base class holds common behaviour; subclasses only define what makes them unique — reducing repetition and creating a logical hierarchy of related types.
SEARCH THIS ONLINE:
  → Query 1 (beginner): inheritance programming explained simply
  → Query 2 (intermediate): Python class inheritance parent child example
  → Query 3 (deep dive): multiple inheritance MRO Python design patterns
UNDERSTAND THIS BEFORE: Class, Object
──────────────────────────────

──────────────────────────────
TERM: Instance
CATEGORY: Programming Concept
IN ONE SENTENCE: A synonym for object — a specific realisation of a class created in memory with its own unique data.
THE REAL-WORLD ANALOGY: An instance is one specific coffee mug. "Mug" is the class (the concept). The blue mug on your desk right now is an instance — a specific mug with specific dimensions, colour, and contents, existing in the physical world.
HOW IT SHOWS UP IN FORGEFIT: Every time a user registers, a new User instance is created. Every time a workout is started, a new Workout instance is created and added to the session. In Flutter, the AuthProvider instance is created once in MultiProvider and shared across the entire app.
WHY IT EXISTS: The distinction between class and instance matters in every object-oriented program. "Instance" emphasises that this is one specific object created from a class — especially important when multiple instances of the same class exist simultaneously.
SEARCH THIS ONLINE:
  → Query 1 (beginner): instance vs class Python explained simply
  → Query 2 (intermediate): Python creating instances class constructor
  → Query 3 (deep dive): Python instance attribute vs class attribute memory
UNDERSTAND THIS BEFORE: Class, Object
──────────────────────────────

──────────────────────────────
TERM: Constructor
CATEGORY: Programming Concept
IN ONE SENTENCE: The special method (__init__ in Python, const ClassName() in Dart) automatically called when a new object is created to set its initial values.
THE REAL-WORLD ANALOGY: A constructor is like the setup wizard for new software. When you first launch (instantiate the class), the wizard runs automatically, asking for your name, preferences, and language — setting the initial state before you start using the program.
HOW IT SHOWS UP IN FORGEFIT: Dart's ForgeFitApp class has a const constructor with required: tokenStorage, apiClient, authProvider, initialRoute parameters. Python's Pydantic models use __init__ implicitly — you pass keyword arguments and Pydantic validates and assigns them automatically.
WHY IT EXISTS: Objects need initial values when created. Constructors guarantee that every instance is properly initialised from the moment it exists — preventing the "partially constructed object" bug where an object is used before all its required data is set.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python constructor __init__ explained
  → Query 2 (intermediate): Python class constructor parameters default values
  → Query 3 (deep dive): Dart const constructor compile-time constant performance
UNDERSTAND THIS BEFORE: Class, Object, Instance
──────────────────────────────

──────────────────────────────
TERM: Decorator (Python)
CATEGORY: Programming Concept
IN ONE SENTENCE: A Python feature using the @ symbol that wraps a function with additional behaviour without modifying the function's own code.
THE REAL-WORLD ANALOGY: A Python decorator is like wrapping a plain gift box with fancy wrapping paper. The gift inside (the function) is unchanged. The wrapping (decorator) adds external presentation — like a bow (logging), a card (rate limiting), or a lock (authentication check).
HOW IT SHOWS UP IN FORGEFIT: @router.post("/register") decorates the register function, making FastAPI register it as a POST route. @limiter.limit("5/minute") adds rate limiting. These decorators are applied at import time, wrapping the function with framework behaviour before the server even starts taking requests.
WHY IT EXISTS: Cross-cutting concerns (routing, rate limiting, authentication) shouldn't pollute every function's core logic. Decorators allow these concerns to be applied declaratively with a single line, keeping functions focused on their primary responsibility.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python decorators explained simply
  → Query 2 (intermediate): Python decorator functions custom decorators
  → Query 3 (deep dive): Python decorator internals functools wraps closure
UNDERSTAND THIS BEFORE: Function, Class, Python
──────────────────────────────

──────────────────────────────
TERM: Generator (Python yield)
CATEGORY: Programming Concept
IN ONE SENTENCE: A special Python function that uses yield to produce values one at a time, pausing between each — more memory-efficient than returning all values at once.
THE REAL-WORLD ANALOGY: A generator is like a vending machine vs a delivery truck. A delivery truck brings all 100 items at once (regular function returning a list). A vending machine dispenses one item per request, holding the rest until needed — using far less immediate space.
HOW IT SHOWS UP IN FORGEFIT: The get_db() function in database.py is a generator that uses yield: it creates a database session, yields it (passes it to the calling function), and then continues after the yield to close the session in the finally block. FastAPI's Depends() system understands and uses this pattern.
WHY IT EXISTS: Database sessions shouldn't be created all at once or left open forever. The generator/yield pattern lets get_db() control the session lifecycle precisely — create on yield, cleanup on the other side of yield — with guaranteed cleanup even if an exception occurs.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python yield generator explained simply
  → Query 2 (intermediate): Python generator functions yield tutorial
  → Query 3 (deep dive): FastAPI dependency yield generators context managers
UNDERSTAND THIS BEFORE: Function, Python, Depends/DI
──────────────────────────────

──────────────────────────────
TERM: Exception / Error Handling
CATEGORY: Programming Concept
IN ONE SENTENCE: A mechanism to catch unexpected errors that occur during execution and handle them gracefully instead of crashing the program.
THE REAL-WORLD ANALOGY: Error handling is like a pilot's emergency procedure manual. When an unexpected situation occurs (engine fault = exception), the pilot doesn't freeze — they follow the protocol (except block): check instruments, communicate with ATC, attempt restart, and if needed, land safely (return a meaningful error response).
HOW IT SHOWS UP IN FORGEFIT: food_search.py wraps every httpx call in try/except blocks: except (httpx.TimeoutException, httpx.ConnectError, httpx.HTTPStatusError): if cache_key in _stale_search_cache: return stale_data ... raise HTTPException(503). This ensures USDA API failures return a clean error rather than crashing the server.
WHY IT EXISTS: In real applications, things go wrong — networks fail, databases disconnect, users send bad data. Without error handling, any unexpected situation crashes the entire program. Try/except lets the code anticipate failure modes and respond meaningfully.
SEARCH THIS ONLINE:
  → Query 1 (beginner): exception handling Python explained simply
  → Query 2 (intermediate): Python try except finally error handling tutorial
  → Query 3 (deep dive): FastAPI exception handlers custom error responses
UNDERSTAND THIS BEFORE: Function, Python
──────────────────────────────

──────────────────────────────
TERM: try / except / finally
CATEGORY: Programming Concept
IN ONE SENTENCE: Python's three-part error handling structure — try the risky code, except catches specific errors if they occur, finally always runs for cleanup.
THE REAL-WORLD ANALOGY: Try is like attempting to open a locked door. Except catches the "door is locked" outcome and handles it (find the key). Finally is like always putting the doorknob cover back regardless — whether the door opened or not.
HOW IT SHOWS UP IN FORGEFIT: get_db() in database.py: try: yield db finally: db.close() — the session is always closed even if the endpoint raises an exception. food_search.py wraps USDA API calls in try/except to catch network errors and return stale cache or 503 status.
WHY IT EXISTS: Resources like database connections and file handles must be released even when errors occur. The try/except/finally pattern guarantees cleanup code runs regardless of how the try block exits — by success, exception, or return.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python try except finally tutorial
  → Query 2 (intermediate): Python exception handling best practices patterns
  → Query 3 (deep dive): Python exception hierarchy custom exceptions context managers
UNDERSTAND THIS BEFORE: Exception/Error Handling, Python
──────────────────────────────

──────────────────────────────
TERM: Type Hints (Python)
CATEGORY: Programming Concept
IN ONE SENTENCE: Optional annotations that declare the expected data type of variables, function parameters, and return values — making code self-documenting and enabling automatic validation.
THE REAL-WORLD ANALOGY: Type hints are like labels on file folders. "This folder holds Invoices (Invoice type)." Without labels, you'd open every folder to guess its content. With labels, both humans and automated systems can instantly know what belongs where.
HOW IT SHOWS UP IN FORGEFIT: Every function in auth/utils.py uses type hints: def hash_password(password: str) -> str:, def get_current_user(...) -> User:. FastAPI reads these hints to generate API documentation automatically and validates parameter types on incoming requests.
WHY IT EXISTS: Python is dynamically typed — you can pass any type as any argument without restriction. Type hints restore predictability, enable IDE autocompletion, catch type errors before runtime with static analysis tools, and let FastAPI/Pydantic do automatic validation.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python type hints explained simply tutorial
  → Query 2 (intermediate): Python typing module Optional List Dict type hints
  → Query 3 (deep dive): Python type hints mypy static analysis runtime vs static
UNDERSTAND THIS BEFORE: Python, Function
──────────────────────────────

──────────────────────────────
TERM: Enum
CATEGORY: Programming Concept
IN ONE SENTENCE: A fixed set of named constants representing all valid values for a particular variable — like meal types or fitness levels.
THE REAL-WORLD ANALOGY: An Enum is like a multiple-choice question on a form. The answer must be exactly one of the listed options — you cannot write in your own. "What is your fitness level? (A) Beginner (B) Intermediate (C) Advanced." No "superhuman" option exists.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit originally used a MealType Enum for meals (breakfast, lunch, dinner, snack). This was later migrated to a plain string to allow custom meal names. Fitness level (beginner/intermediate/advanced) is stored as a string with validation at the Pydantic schema level.
WHY IT EXISTS: Without Enums, any string could be stored as a meal type — including typos ("brEakfast"), invalid values ("pizza"), or inconsistencies ("Lunch" vs "lunch"). Enums enforce that only defined, valid options are used, preventing data integrity issues.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python Enum explained simply tutorial
  → Query 2 (intermediate): Python Enum FastAPI Pydantic integration
  → Query 3 (deep dive): Python Enum string vs int enum best practices
UNDERSTAND THIS BEFORE: Python, Class, Validation
──────────────────────────────

──────────────────────────────
TERM: Dictionary / Map
CATEGORY: Programming Concept
IN ONE SENTENCE: A data structure that stores key-value pairs — look up a value instantly by its unique key, like looking up a word's definition in a dictionary.
THE REAL-WORLD ANALOGY: A Python dictionary is exactly like a real dictionary: "calcium" → "a mineral for bones." You look up the key (word) and get the value (definition) instantly. Unlike a list, you don't scan from page 1 — you jump directly to the right entry.
HOW IT SHOWS UP IN FORGEFIT: NUTRIENT_MAP in food_search.py is a dict: {1003: {"name": "Protein", "unit": "g", "rda": 50}, ...} — nutrient IDs (keys) map to metadata (values). JWT payloads are dicts. API responses are parsed as dicts before being validated by Pydantic schemas.
WHY IT EXISTS: When you need to retrieve data by a known identifier (nutrient ID, username, config key), dictionaries return the value in O(1) constant time — no scanning required. They are the most versatile and frequently used data structure in Python.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python dictionary explained simply tutorial
  → Query 2 (intermediate): Python dict methods get update keys values
  → Query 3 (deep dive): Python dictionary hash table implementation time complexity
UNDERSTAND THIS BEFORE: Python, List/Array
──────────────────────────────

──────────────────────────────
TERM: List / Array
CATEGORY: Programming Concept
IN ONE SENTENCE: An ordered collection of items where you can access any item by its position number (index) — the most basic "collection of things" data structure.
THE REAL-WORLD ANALOGY: A list is like a numbered queue at the deli counter. Position 0 is first in line, position 1 is second, etc. You can skip to any position directly, add someone to the end, or remove someone from the middle.
HOW IT SHOWS UP IN FORGEFIT: The USDA API returns foods as a JSON array. In food_search.py, results = [_parse_food_item(item) for item in data.get("foods", [])] creates a list of parsed food dicts. Pydantic schemas use List[SomeSchema] to define endpoints that return lists. The NutritionProvider stores daily_logs as a list.
WHY IT EXISTS: Data often comes in collections — many exercises, many nutrition logs, many workouts. Lists provide the ordered, indexable container for aggregating and iterating over multiple items — the most natural way to represent "a collection of things."
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python list explained simply tutorial
  → Query 2 (intermediate): Python list comprehension map filter
  → Query 3 (deep dive): Python list vs tuple vs array performance
UNDERSTAND THIS BEFORE: Python
──────────────────────────────

──────────────────────────────
TERM: Null / None
CATEGORY: Programming Concept
IN ONE SENTENCE: Python's (and Dart's) representation of "no value" — the programming equivalent of database NULL.
THE REAL-WORLD ANALOGY: None is like an empty chair at a dinner table. The chair is reserved (the variable exists), but nobody is sitting there (no value is assigned). An empty chair is different from a chair with an invisible person — None is definitively the absence of anything.
HOW IT SHOWS UP IN FORGEFIT: In Python auth/utils.py: if email is None or jti is None: raise credentials_exception. In the User model, optional fields like date_of_birth: Optional[date] = None can be None if not provided during registration. Flutter/Dart uses null for the same concept.
WHY IT EXISTS: Variables must be able to represent "not set" or "not applicable."  None/null is the universal programming convention for this absence of value — distinct from zero, false, or empty string, each of which carries a specific meaning.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python None explained simply null in programming
  → Query 2 (intermediate): Python Optional None type hints NoneType
  → Query 3 (deep dive): Dart null safety sound null system
UNDERSTAND THIS BEFORE: Python, NULL (database)
──────────────────────────────

──────────────────────────────
TERM: Boolean
CATEGORY: Programming Concept
IN ONE SENTENCE: A value that can only be True or False — the simplest data type, used for conditions, flags, and binary choices.
THE REAL-WORLD ANALOGY: A Boolean is like a light switch — it's either on (True) or off (False). No degrees in between. Every if statement in programming ultimately evaluates to a Boolean — "should this code run? True/False."
HOW IT SHOWS UP IN FORGEFIT: user.is_verified is a Boolean column in the User model. verify_password() returns True or False. Many state flags in Flutter providers use Boolean: _isLoading = true before an API call, _isLoading = false after it completes.
WHY IT EXISTS: Programs constantly need to make binary decisions — is this user authenticated? Is the app loading? Did the request succeed? Booleans provide the clearest, most efficient representation for these yes/no states.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Boolean explained simply programming
  → Query 2 (intermediate): Boolean logic AND OR NOT Python if conditions
  → Query 3 (deep dive): Boolean algebra truth tables bitwise operations
UNDERSTAND THIS BEFORE: Nothing — foundational concept.
──────────────────────────────

──────────────────────────────
TERM: Callback
CATEGORY: Programming Concept
IN ONE SENTENCE: A function passed as an argument to another function, to be called later when an event occurs or an async operation completes.
THE REAL-WORLD ANALOGY: A callback is like giving a delivery driver your phone number and saying "call me when the package arrives." You continue your day (other code runs). When the package arrives (event fires), they call you (the callback function executes).
HOW IT SHOWS UP IN FORGEFIT: fl_chart's PieChart uses callbacks: onTap: (index) { setState(() { _touchedIndex = index; }); } — when a user taps a pie slice, PieChart calls this callback with the section index. The callback updates state to highlight the tapped segment.
WHY IT EXISTS: Async systems (UI events, network responses) need a way to notify your code when something happens. Callbacks are the original async notification mechanism — "when this thing happens, call this function." Modern async/await builds on this concept.
SEARCH THIS ONLINE:
  → Query 1 (beginner): callback function programming explained simply
  → Query 2 (intermediate): Flutter callback functions onTap onPressed
  → Query 3 (deep dive): callback vs Future vs Stream callback hell async
UNDERSTAND THIS BEFORE: Function, Async/Await
──────────────────────────────

──────────────────────────────
TERM: Lambda
CATEGORY: Programming Concept
IN ONE SENTENCE: A small, anonymous function defined inline without a name — typically used for short, one-time operations like sorting or filtering.
THE REAL-WORLD ANALOGY: A lambda is like a sticky note instruction: "sort by this." It's too small and context-specific to deserve a full recipe card (named function). You write "sort by last name" directly on the context where it's needed.
HOW IT SHOWS UP IN FORGEFIT: result.sort(key=lambda x: x["id"]) in food_search.py sorts nutrient results by their ID using a lambda — the sort key is a tiny inline function that extracts the "id" field from each nutrient dict. Writing a full named function for this one-liner would be verbose.
WHY IT EXISTS: Many operations (sorting, filtering, mapping) require short custom functions. Named functions create unnecessary ceremony for trivial logic. Lambdas let developers express simple logic concisely exactly where it's needed.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Python lambda function explained simply
  → Query 2 (intermediate): Python lambda sort filter map tutorial
  → Query 3 (deep dive): lambda vs named function performance readability Python
UNDERSTAND THIS BEFORE: Function, Python
──────────────────────────────

──────────────────────────────
TERM: Parallel Execution
CATEGORY: Programming Concept
IN ONE SENTENCE: Running multiple operations at the same time rather than waiting for each one to finish before starting the next.
THE REAL-WORLD ANALOGY: Parallel execution is like a restaurant kitchen where multiple chefs cook different dishes simultaneously. If one chef makes the soup, another fries the steak, and a third bakes the bread all at once, the meal arrives in 20 minutes instead of 60 (sequential).
HOW IT SHOWS UP IN FORGEFIT: When the home screen loads, ForgeFit fires multiple API requests simultaneously — fetchDailyNutrition(), fetchActiveWorkout(), fetchStats() — using Future.wait([futures]). Instead of waiting 300ms + 400ms + 200ms sequentially (900ms total), they complete in ~400ms in parallel.
WHY IT EXISTS: Network requests are slow and independent. Sequential execution wastes time waiting. Parallel execution saturates available I/O bandwidth, dramatically reducing perceived loading time — critical for mobile app responsiveness.
SEARCH THIS ONLINE:
  → Query 1 (beginner): parallel vs sequential programming explained
  → Query 2 (intermediate): Dart Future.wait parallel async requests
  → Query 3 (deep dive): parallelism vs concurrency CPU-bound I/O-bound
UNDERSTAND THIS BEFORE: Async/Await, Future, Concurrency
──────────────────────────────

──────────────────────────────
TERM: Future.wait() (Dart)
CATEGORY: Mobile
IN ONE SENTENCE: A Dart method that runs multiple Futures simultaneously and waits for all of them to complete before continuing — enabling parallel async operations.
THE REAL-WORLD ANALOGY: Future.wait() is like a project manager who assigns tasks to three team members simultaneously and waits at the door until everyone submits their work. Nobody waits for someone else to finish before starting — all work happens in parallel, and the manager proceeds when the last person is done.
HOW IT SHOWS UP IN FORGEFIT: When the HomeScreen initialises, it calls await Future.wait([nutritionProvider.fetch(), workoutProvider.fetchActive(), statsProvider.fetchSummary()]). All three API calls fire simultaneously, and the UI shows data when all three complete — typically 2-3x faster than sequential calls.
WHY IT EXISTS: Dart is single-threaded but uses async I/O. Future.wait() allows multiple I/O operations to be in-flight simultaneously without threads. Without it, a screen waiting for 3 API calls would take the sum of all their times; with it, it only takes the maximum.
SEARCH THIS ONLINE:
  → Query 1 (beginner): Dart Future.wait explained tutorial
  → Query 2 (intermediate): Flutter parallel API calls Future.wait performance
  → Query 3 (deep dive): Dart isolates vs Future.wait concurrency model
UNDERSTAND THIS BEFORE: Future, Async/Await, Parallel Execution
──────────────────────────────

──────────────────────────────
TERM: MET Formula (metabolic equivalent)
CATEGORY: Programming Concept
IN ONE SENTENCE: A scientific formula that estimates calories burned during an activity based on its intensity (MET value), the person's weight, and the duration.
THE REAL-WORLD ANALOGY: The MET formula is like a fuel efficiency rating for human activities. Running has a "fuel rating" of 9 METs (burns 9x more than resting). Weigh that against your body weight for the duration, and you know approximately how much "fuel" (calories) you burned.
HOW IT SHOWS UP IN FORGEFIT: The stats router (routers/stats.py) uses the MET formula to estimate calories burned per workout: calories_burned = MET × weight_kg × duration_hours. MET values are assigned per exercise type (cardio vs strength). This gives users an estimated calorie expenditure for each workout session.
WHY IT EXISTS: Direct calorie measurement requires lab equipment. MET values are published by sports science research for every activity type and validated across populations. The formula makes reasonable calorie burn estimates accessible in any software without sensors.
SEARCH THIS ONLINE:
  → Query 1 (beginner): what is MET metabolic equivalent explained
  → Query 2 (intermediate): MET formula calories burned exercise calculation
  → Query 3 (deep dive): MET values compendium physical activity research
UNDERSTAND THIS BEFORE: Python, Function
──────────────────────────────

═══════════════════════════════════════
GROUP 10 — DESIGN PATTERNS & ARCHITECTURE
═══════════════════════════════════════

──────────────────────────────
TERM: Separation of Concerns
CATEGORY: Design Pattern
IN ONE SENTENCE: The principle that different parts of a program should handle different responsibilities and not know too much about each other's internals.
THE REAL-WORLD ANALOGY: A hospital separates concerns: the pharmacy knows drugs, surgery knows operations, billing knows finances. No one department does all three. If billing performed surgery, it would be chaos. Each area is expert in its own concern.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit separates concerns at every level: models/ handle data structure, schemas/ handle validation, routers/ handle HTTP routing, auth/ handles security, database.py handles connections. The Flutter frontend knows nothing about how the database works — it only calls API endpoints.
WHY IT EXISTS: When code mixes responsibilities (a route that also handles auth, validation, DB queries, and response formatting all in one place), any change requires understanding and modifying everything together. Separation makes each piece independently understandable, testable, and replaceable.
SEARCH THIS ONLINE:
  → Query 1 (beginner): separation of concerns programming explained
  → Query 2 (intermediate): separation of concerns FastAPI project structure
  → Query 3 (deep dive): SOLID principles single responsibility separation
UNDERSTAND THIS BEFORE: Modular Architecture
──────────────────────────────

──────────────────────────────
TERM: Modular Architecture
CATEGORY: Design Pattern
IN ONE SENTENCE: Organising code into self-contained modules by feature or responsibility, each with its own files, so teams can work them independently.
THE REAL-WORLD ANALOGY: Modular architecture is like a LEGO set of prefabricated room modules. The bedroom module, kitchen module, and bathroom module are built separately and snapped together to form the house. You can renovate one room without touching the others.
HOW IT SHOWS UP IN FORGEFIT: The Flutter app in lib/ is organised by features: features/auth/, features/workout/, features/nutrition/, features/progress/. Each feature has its own screens/, providers/, and widgets/ subdirectories. The backend mirrors this with separate routers by feature.
WHY IT EXISTS: A single-file application becomes unmaintainable past a few hundred lines. Modular organisation lets developers find code intuitively ("where is the nutrition logic? features/nutrition/"), work on modules independently, and understand the system through its structure.
SEARCH THIS ONLINE:
  → Query 1 (beginner): modular architecture explained simply
  → Query 2 (intermediate): Flutter feature-first folder structure tutorial
  → Query 3 (deep dive): vertical slice architecture vs layered architecture
UNDERSTAND THIS BEFORE: Separation of Concerns
──────────────────────────────

──────────────────────────────
TERM: Repository Pattern (brief)
CATEGORY: Design Pattern
IN ONE SENTENCE: A design pattern where all data access logic is isolated in a "repository" class, so the rest of the code never talks directly to the database.
THE REAL-WORLD ANALOGY: The repository pattern is like a librarian system. All book retrieval goes through the librarian (repository) — you never go to the stacks yourself. The librarian knows exactly where everything is; you just ask for "workout #42" and get it.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit doesn't use formal repository classes — SQLAlchemy queries are written directly in router functions. However, the principle appears informally: the Flutter app never touches the database directly; it always goes through the API (which acts as a repository layer between the app and data).
WHY IT EXISTS: When business logic directly calls the database, swapping databases requires changing every piece of business logic. Repositories abstract the data source — you could swap PostgreSQL for MongoDB and only change the repository, not all the business logic.
SEARCH THIS ONLINE:
  → Query 1 (beginner): repository pattern explained simply programming
  → Query 2 (intermediate): repository pattern Python SQLAlchemy tutorial
  → Query 3 (deep dive): repository pattern vs active record DDD
UNDERSTAND THIS BEFORE: Separation of Concerns, ORM, SQLAlchemy
──────────────────────────────

──────────────────────────────
TERM: Dependency Injection
CATEGORY: Design Pattern
IN ONE SENTENCE: A design pattern where a class or function receives its dependencies from outside rather than creating them itself — making code more testable and flexible.
THE REAL-WORLD ANALOGY: Dependency Injection is like a contractor who brings their own tools rather than you buying tools and storing them in your house. You need the contractor to have tools — but they manage and provide their own. You're not responsible for creating or maintaining them.
HOW IT SHOWS UP IN FORGEFIT: FastAPI's Depends(get_db) and Depends(get_current_user) inject the database session and authenticated user into every endpoint. Flutter's MultiProvider injects AuthProvider, WorkoutProvider, etc., making them accessible without each widget creating its own instances.
WHY IT EXISTS: When functions create their own dependencies (new DatabaseSession(), new HttpClient()), testing is hard — you can't substitute mock versions. DI lets tests inject fake dependencies (mock database, test user) without modifying the production code.
SEARCH THIS ONLINE:
  → Query 1 (beginner): dependency injection explained simply
  → Query 2 (intermediate): FastAPI Depends dependency injection examples
  → Query 3 (deep dive): DI containers IoC inversion of control patterns
UNDERSTAND THIS BEFORE: Depends/DI, Function, Class
──────────────────────────────

──────────────────────────────
TERM: Interceptor Pattern
CATEGORY: Design Pattern
IN ONE SENTENCE: A design pattern where a component sits in the processing pipeline and executes code before or after the main operation — without the main operation needing to know.
THE REAL-WORLD ANALOGY: An interceptor is like a toll booth on a highway. Every car (request) must pass through — the toll booth checks the tag (auth header), logs the passage (request logging), and lets compliant cars through. The driver doesn't interact with the toll booth logic; it runs transparently.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit uses the interceptor pattern in two places: FastAPI middleware (CORSMiddleware, rate limiting) intercepts every server request, and Dio's AuthInterceptor intercepts every outgoing HTTP request from Flutter to add auth headers and handle token refresh.
WHY IT EXISTS: Cross-cutting concerns (authentication, logging, CORS, rate limiting) should not be embedded in every individual route or API call. The interceptor pattern centralises these concerns so they run transparently on every request without repetition.
SEARCH THIS ONLINE:
  → Query 1 (beginner): interceptor pattern explained simply
  → Query 2 (intermediate): Dio interceptor Flutter middleware FastAPI pattern
  → Query 3 (deep dive): middleware interceptor pipeline chain of responsibility
UNDERSTAND THIS BEFORE: Middleware, Interceptor (Dio)
──────────────────────────────

──────────────────────────────
TERM: Observer Pattern (what Provider uses)
CATEGORY: Design Pattern
IN ONE SENTENCE: A design pattern where objects (observers) register interest in a subject; when the subject changes, it automatically notifies all registered observers.
THE REAL-WORLD ANALOGY: The Observer pattern is like a newspaper subscription. The newspaper publisher (ChangeNotifier) maintains a list of subscribers (widgets using context.watch). When the news changes (notifyListeners), every subscriber automatically receives the new edition — no subscriber has to check manually if there's new news.
HOW IT SHOWS UP IN FORGEFIT: Provider's entire model is the Observer pattern implemented in Flutter. NutritionProvider (subject) maintains state. NutritionScreen (observer) calls context.watch<NutritionProvider>(). When notifyListeners() runs, Flutter notifies the screen to rebuild — exactly the textbook Observer pattern.
WHY IT EXISTS: Without the Observer pattern, every part of the UI that needs to reflect data changes would have to periodically poll "has anything changed?" — wasteful and slow. The Observer pattern reverses this: the data pushes changes to interested parties automatically.
SEARCH THIS ONLINE:
  → Query 1 (beginner): observer pattern explained simply
  → Query 2 (intermediate): observer pattern Flutter Provider ChangeNotifier
  → Query 3 (deep dive): observer pattern vs event emitter vs reactive streams
UNDERSTAND THIS BEFORE: ChangeNotifier, notifyListeners, Provider
──────────────────────────────

──────────────────────────────
TERM: CRUD (Create, Read, Update, Delete)
CATEGORY: Design Pattern
IN ONE SENTENCE: The four fundamental database operations that most features in any information system are built on.
THE REAL-WORLD ANALOGY: CRUD is like managing employee records in an HR system. Create = hire a new employee (INSERT). Read = look up their record (SELECT). Update = give them a raise (UPDATE). Delete = process their resignation (DELETE). Every HR action maps to one of these four.
HOW IT SHOWS UP IN FORGEFIT: Every ForgeFit feature implements CRUD. Workouts: POST /workouts (Create), GET /workouts (Read), PUT /workouts/{id} (Update), DELETE /workouts/{id} (Delete). Nutrition logs: POST /nutrition/log, GET /nutrition/daily, PUT /nutrition/log/{id}, DELETE /nutrition/log/{id}.
WHY IT EXISTS: CRUD formalises the universal operations on data. REST API design maps these directly to HTTP methods (POST=Create, GET=Read, PUT/PATCH=Update, DELETE=Delete), creating a predictable, learnable convention for any API.
SEARCH THIS ONLINE:
  → Query 1 (beginner): CRUD operations explained simply
  → Query 2 (intermediate): REST API CRUD operations HTTP methods tutorial
  → Query 3 (deep dive): CRUD vs CQRS event sourcing patterns
UNDERSTAND THIS BEFORE: REST API, HTTP Methods, Database
──────────────────────────────

──────────────────────────────
TERM: Proxy (backend as proxy for ExerciseDB/USDA)
CATEGORY: Design Pattern
IN ONE SENTENCE: A proxy is an intermediary that sits between a client and a server, forwarding requests and adding value (caching, auth, transformation) along the way.
THE REAL-WORLD ANALOGY: A proxy is like a concierge hotel service. Instead of guests phoning restaurants directly (Flutter calling USDA), they call the concierge (FastAPI backend). The concierge knows all the restaurants, already has reservations (cached results), and handles the details on your behalf.
HOW IT SHOWS UP IN FORGEFIT: ForgeFit's backend is a proxy for both ExerciseDB and USDA APIs. The Flutter app never calls these APIs directly — it calls ForgeFit's own /exercises and /food endpoints. The backend fetches from the external APIs, caches results, and returns cleaned-up data to Flutter.
WHY IT EXISTS: Exposing external API keys to a mobile app is a security risk (anyone can decompile the app and steal the key). By proxying through the backend, the key stays server-side. The backend also adds caching and normalisation that would be wasteful to implement on each client device.
SEARCH THIS ONLINE:
  → Query 1 (beginner): proxy server explained simply
  → Query 2 (intermediate): API proxy pattern backend for frontend BFF
  → Query 3 (deep dive): reverse proxy API gateway pattern microservices
UNDERSTAND THIS BEFORE: Client, Server, Caching, API Key
──────────────────────────────

──────────────────────────────
TERM: Single Source of Truth
CATEGORY: Design Pattern
IN ONE SENTENCE: The principle that every piece of data should exist in exactly one authoritative location — all components read from that location rather than maintaining their own copy.
THE REAL-WORLD ANALOGY: Single source of truth is like a company having one official org chart maintained by HR. Other departments don't keep their own copies — they all refer to HR's chart. If two departments had different charts, confusion and mistakes would follow.
HOW IT SHOWS UP IN FORGEFIT: NutritionProvider is the single source of truth for the day's nutrition data. Whether the HomeScreen summary widget or the detailed NutritionScreen both pull from NutritionProvider.dailyCalories — they can't show different totals because there's only one place the data lives.
WHY IT EXISTS: When multiple components maintain their own copies of the same data, they inevitably diverge — one updates while others stagnate. Single source of truth prevents inconsistency and makes reasoning about app state dramatically simpler.
SEARCH THIS ONLINE:
  → Query 1 (beginner): single source of truth explained simply
  → Query 2 (intermediate): single source of truth Flutter Provider pattern
  → Query 3 (deep dive): single source of truth Redux immutable state management
UNDERSTAND THIS BEFORE: State Management, Provider, ChangeNotifier
──────────────────────────────

──────────────────────────────
TERM: Vertical Slice (feature-first structure)
CATEGORY: Design Pattern
IN ONE SENTENCE: An architecture where code is organised by feature (nutrition, workout, auth) rather than by technical layer (all models, all services, all controllers together).
THE REAL-WORLD ANALOGY: A layer-first structure is like a bakery where all flour is in one room, all butter in another, and all ovens in a third — to bake a cake you run between all three rooms. A feature-first (vertical slice) bakery has a "Cakes room" with its own flour, butter, and oven — everything for one product together.
HOW IT SHOWS UP IN FORGEFIT: The Flutter app uses vertical slices: lib/features/nutrition/ contains NutritionScreen + NutritionProvider + nutrition widgets. lib/features/workout/ contains WorkoutScreen + WorkoutProvider + workout widgets. Each feature is a self-contained slice through the technology stack.
WHY IT EXISTS: Layer-first structures (all models together, all views together) mean every feature change touches multiple directories. Vertical slices co-locate everything for a feature, making it easy to find all relevant code in one place and minimising cross-feature dependencies.
SEARCH THIS ONLINE:
  → Query 1 (beginner): vertical slice architecture explained simply
  → Query 2 (intermediate): Flutter feature-first folder structure
  → Query 3 (deep dive): vertical slice architecture vs layered architecture DDD
UNDERSTAND THIS BEFORE: Modular Architecture, Separation of Concerns
──────────────────────────────

══════════════════════════════════════════════════════
RECOMMENDED LEARNING ORDER
══════════════════════════════════════════════════════

List all terms in the optimal order someone completely new to programming should learn them, grouped into 5 stages:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STAGE 1 — The Internet & How Websites Work
(Learn these first, zero coding required)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1.  Internet                        → YouTube: "Crash Course Computer Science" playlist
2.  Client                          → YouTube: "Fireship" channel – How the Web Works
3.  Server                          → YouTube: "NetworkChuck" – What is a Server?
4.  HTTP                            → MDN Web Docs (developer.mozilla.org) – HTTP overview
5.  HTTPS                           → YouTube: "TechQuickie" – HTTPS explained
6.  SSL / TLS                       → Cloudflare Learning (cloudflare.com/learning)
7.  Request                         → MDN Web Docs – HTTP Messages
8.  Response                        → MDN Web Docs – HTTP Messages
9.  Headers                         → MDN Web Docs – HTTP Headers
10. HTTP Status Codes               → httpstatuses.com (interactive reference)
11. URL / Endpoint                  → MDN Web Docs – What is a URL?
12. HTTP Methods                    → MDN Web Docs – HTTP request methods
13. Query Parameters                → YouTube: "Web Dev Simplified" – REST API crash course
14. Path Parameters                 → YouTube: "freeCodeCamp" – REST API tutorial
15. Request Body                    → YouTube: "Postman" YouTube channel – API tutorials
16. JSON                            → json.org (official) + YouTube: "Programming with Mosh"
17. API (Application Programming Interface) → YouTube: "MuleSoft" – What is an API?
18. REST API                        → YouTube: "Caleb Curry" – REST API crash course
19. Frontend                        → YouTube: "Kevin Powell" – Frontend explained
20. Backend                         → YouTube: "Traversy Media" – Backend explained
21. Full-Stack                      → YouTube: "Traversy Media" – Full Stack roadmap
22. External API / Third-Party API  → YouTube: "freeCodeCamp" – API integrations tutorial
23. API Key                         → YouTube: "Postman" – API key authentication

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STAGE 2 — Programming Basics
(Before touching any framework)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

24. Boolean                         → Python.org – Official Tutorial
25. Null / None                     → YouTube: "Corey Schafer" – Python basics
26. Function                        → YouTube: "Corey Schafer" – Python functions
27. List / Array                    → YouTube: "Corey Schafer" – Python lists
28. Dictionary / Map                → YouTube: "Corey Schafer" – Python dictionaries
29. Class                           → YouTube: "Corey Schafer" – Python OOP series
30. Object                          → YouTube: "Programming with Mosh" – Python OOP
31. Instance                        → YouTube: "Corey Schafer" – Python OOP
32. Constructor                     → YouTube: "Corey Schafer" – Python __init__
33. Inheritance                     → YouTube: "Corey Schafer" – Python inheritance
34. Enum                            → docs.python.org – enum module
35. Lambda                          → YouTube: "Corey Schafer" – Python lambda
36. Callback                        → YouTube: "Fireship" – callbacks explained
37. Exception / Error Handling      → YouTube: "Corey Schafer" – Python exceptions
38. try / except / finally          → docs.python.org – exceptions tutorial
39. Type Hints (Python)             → docs.python.org – type hints PEP 484
40. Decorator (Python)              → YouTube: "Corey Schafer" – Python decorators
41. Generator (Python yield)        → YouTube: "Corey Schafer" – Python generators
42. Async / Await (Python/Dart)     → YouTube: "Arjan Codes" – Python async
43. Concurrency                     → YouTube: "Arjan Codes" – async concurrency
44. Parallel Execution              → YouTube: "Arjan Codes" – asyncio parallel
45. Python (language overview)      → docs.python.org – official tutorial

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STAGE 3 — Backend Foundations
(Python + APIs + Databases)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

46. Database                        → YouTube: "CS Dojo" – database intro
47. Relational Database             → YouTube: "freeCodeCamp" – relational DB tutorial
48. Table                           → YouTube: "Bro Code" – SQL tables
49. Row / Record                    → YouTube: "Bro Code" – SQL basics
50. Column / Field                  → YouTube: "Bro Code" – SQL basics
51. NULL (database)                 → YouTube: "freeCodeCamp" – SQL NULL handling
52. Primary Key                     → YouTube: "freeCodeCamp" – SQL keys
53. Foreign Key                     → YouTube: "freeCodeCamp" – SQL relationships
54. Relationship (one-to-many, many-to-many) → YouTube: "freeCodeCamp" – SQL joins
55. SQL                             → YouTube: "freeCodeCamp" – SQL full course
56. JOIN                            → YouTube: "freeCodeCamp" – SQL JOINs tutorial
57. Query                           → sqlzoo.net – interactive SQL practice
58. ORM                             → YouTube: "Amigoscode" – ORM explained
59. Index (database index)          → YouTube: "Hussein Nasser" – DB indexes
60. PostgreSQL                      → postgresql.org – official docs
61. SQLAlchemy                      → docs.sqlalchemy.org – official tutorial
62. Model (SQLAlchemy)              → fastapi.tiangolo.com – SQL databases tutorial
63. Session                         → docs.sqlalchemy.org – sessions
64. Transaction                     → YouTube: "Hussein Nasser" – DB transactions
65. commit() / rollback()           → docs.sqlalchemy.org – ORM sessions
66. autocommit / autoflush          → docs.sqlalchemy.org – session configuration
67. Migration                       → YouTube: "ArjanCodes" – Alembic tutorial
68. Alembic                         → alembic.sqlalchemy.org – official docs
69. create_all()                    → docs.sqlalchemy.org – metadata
70. Cascade Delete                  → YouTube: "freeCodeCamp" – SQL CASCADE
71. N+1 Query Problem               → YouTube: "Hussein Nasser" – N+1 explained
72. joinedload()                    → docs.sqlalchemy.org – eager loading
73. Environment Variables           → YouTube: "Corey Schafer" – Python dotenv
74. .env file                       → pypi.org – python-dotenv docs
75. ASGI                            → asgi.readthedocs.io – ASGI spec
76. Uvicorn                         → uvicorn.org – official docs
77. FastAPI                         → fastapi.tiangolo.com – official tutorial
78. Router (APIRouter)              → fastapi.tiangolo.com – bigger applications
79. Endpoint / Route                → fastapi.tiangolo.com – path operations
80. Decorator (@app.get etc.)       → fastapi.tiangolo.com – path operations
81. Pydantic                        → docs.pydantic.dev – official docs
82. Schema (Pydantic)               → docs.pydantic.dev – models
83. Validation                      → docs.pydantic.dev – validators
84. Depends() / Dependency Injection → fastapi.tiangolo.com – dependencies
85. Middleware                      → fastapi.tiangolo.com – middleware
86. CORS / CORSMiddleware           → fastapi.tiangolo.com – CORS
87. Rate Limiting / slowapi         → slowapi.readthedocs.io – docs
88. Startup / Shutdown events       → fastapi.tiangolo.com – events
89. Procfile                        → devcenter.heroku.com – Procfile docs
90. Caching                         → YouTube: "ArjanCodes" – Python caching
91. TTLCache / cachetools            → cachetools.readthedocs.io – docs
92. TTL / Cache Hit / Cache Miss / Stale Data → YouTube: "Hussein Nasser" – caching deep dive
93. In-Memory Cache                 → YouTube: "ByteByteGo" – caching explained
94. USDA FoodData Central API       → fdc.nal.usda.gov – API docs
95. ExerciseDB API                  → rapidapi.com – ExerciseDB docs
96. FDC ID / Barcode / UPC / Macronutrients / Micronutrients / RDA → USDA FDC docs
97. MET Formula                     → nih.gov – compendium of physical activities

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STAGE 4 — Frontend & Mobile
(Flutter, Dart, State Management)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

98.  Dart                           → dart.dev – official language tour
99.  Flutter                        → flutter.dev – official codelabs
100. Widget                         → flutter.dev – widgets intro
101. StatelessWidget                → flutter.dev – intro to widgets
102. StatefulWidget                 → flutter.dev – managing state
103. build()                        → flutter.dev – widget lifecycle
104. BuildContext                   → flutter.dev – BuildContext
105. Widget Tree                    → flutter.dev – widget intro
106. setState()                     → flutter.dev – interactive widgets
107. initState()                    → flutter.dev – widget lifecycle
108. dispose()                      → flutter.dev – widget lifecycle
109. Hot Reload                     → flutter.dev – hot reload docs
110. Scaffold                       → api.flutter.dev – Scaffold class
111. MaterialApp                    → api.flutter.dev – MaterialApp class
112. Navigator                      → flutter.dev – navigation
113. Route / Named Route            → flutter.dev – named routes
114. Future (Dart)                  → dart.dev – futures tutorial
115. async / await (Dart)           → dart.dev – async programming
116. Stream                         → dart.dev – streams tutorial
117. FutureBuilder                  → api.flutter.dev – FutureBuilder
118. SharedPreferences              → pub.dev – shared_preferences
119. flutter_secure_storage         → pub.dev – flutter_secure_storage
120. Android Keystore / iOS Keychain → YouTube: "Flutter Mapp" – secure storage
121. Dio (HTTP client)              → pub.dev – Dio package docs
122. Interceptor / AuthInterceptor  → YouTube: "Rivaan Ranawat" – Dio interceptors
123. State / State Management       → flutter.dev – state management overview
124. Local State / Global State     → flutter.dev – ephemeral vs app state
125. ChangeNotifier                 → api.flutter.dev – ChangeNotifier
126. notifyListeners()              → api.flutter.dev – ChangeNotifier
127. Provider (package)             → pub.dev – Provider package docs
128. Consumer                       → pub.dev – Provider docs consumers
129. context.watch() / context.read() → pub.dev – Provider usage
130. MultiProvider                  → pub.dev – MultiProvider docs
131. Reactive UI / Rebuild / Re-render → YouTube: "Flutter" – reactive programming
132. Callback                       → flutter.dev – gestures
133. Future.wait() (Dart)           → dart.dev – Future.wait docs
134. AnimatedDefaultTextStyle       → api.flutter.dev – AnimatedDefaultTextStyle
135. fl_chart / PieChart / BarChart / LineChart → pub.dev – fl_chart
136. Barcode Scanner                → pub.dev – mobile_scanner
137. debounce / Timer               → YouTube: "Flutter Mapp" – debounce tutorial

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STAGE 5 — Advanced Topics
(Security, Deployment, Architecture, Performance)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

138. Authentication / Authorization → YouTube: "Fireship" – auth explained
139. Password Hashing               → YouTube: "Computerphile" – password storage
140. bcrypt / Salt / passlib        → stackexchange.com – security answers
141. Brute Force Attack             → YouTube: "LiveOverflow" – security basics
142. SQL Injection / Parameterized Query → YouTube: "LiveOverflow" – SQL injection
143. JWT (JSON Web Token)           → jwt.io – interactive decoder
144. Bearer Token                   → YouTube: "Postman" – JWT auth tutorial
145. Token / Access Token / Refresh Token → YouTube: "Fireship" – JWT deep dive
146. JTI / Token Expiry / Token Revocation → YouTube: "Toptal" – JWT security
147. HS256 / Symmetric Encryption   → YouTube: "Computerphile" – HMAC
148. SECRET_KEY                     → owasp.org – secrets management
149. HTTPBearer / Logout            → fastapi.tiangolo.com – security tutorial
150. Session vs Token Authentication → YouTube: "Fireship" – sessions vs JWT
151. Deployment                     → YouTube: "TechWorld with Nana" – deployment basics
152. PaaS / Railway / Cloud Hosting → railway.app – official docs
153. Cold Start / Health Check      → YouTube: "ByteByteGo" – cold start
154. Timeout                        → YouTube: "ArjanCodes" – resilience patterns
155. Connection Pool                → YouTube: "Hussein Nasser" – DB connection pools
156. Horizontal Scaling             → YouTube: "ByteByteGo" – scaling tutorial
157. Redis / In-Memory vs Persistent Cache → YouTube: "ByteByteGo" – Redis explained
158. Logs / CI/CD                   → YouTube: "TechWorld with Nana" – CI/CD explained
159. Separation of Concerns         → YouTube: "Arjan Codes" – clean architecture
160. Modular Architecture / Vertical Slice → YouTube: "Milan Jovanovic" – architecture
161. Repository Pattern             → YouTube: "Arjan Codes" – repository pattern
162. Proxy (backend as proxy)       → YouTube: "Hussein Nasser" – reverse proxy
163. Observer Pattern               → YouTube: "Christopher Okhravi" – Observer pattern
164. Interceptor Pattern            → YouTube: "Christopher Okhravi" – patterns
165. Dependency Injection           → YouTube: "Arjan Codes" – DI in Python
166. Single Source of Truth         → YouTube: "Academind" – state management patterns
167. CRUD                           → YouTube: "freeCodeCamp" – CRUD API tutorial
