# Smart Crop Recommendation System

Industry-level full-stack application for crop recommendation based on soil data (NPK, pH, moisture) and optional real-time weather (OpenWeather API). Built with **Spring Boot**, **MySQL**, **JWT**, and **Thymeleaf + Bootstrap 5 + Chart.js**.

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | Spring Boot 3.2, Spring Web, Spring Data JPA, Spring Security |
| Build | Maven |
| Database | MySQL 8.x |
| Auth | JWT, BCrypt |
| Frontend | Thymeleaf, Bootstrap 5, Chart.js |
| External API | OpenWeather API |

---

## Project Structure

```
crop-recommendation-system/
├── src/main/java/com/crop/
│   ├── controller/     # REST + Thymeleaf controllers
│   ├── service/        # Business logic, weather, recommendation engine
│   ├── repository/     # JPA repositories
│   ├── entity/         # JPA entities
│   ├── dto/            # Request/response DTOs
│   ├── security/       # JWT filter, UserDetailsService
│   ├── config/         # Security, WebClient, DataLoader
│   ├── exception/      # Global exception handler
│   └── CropRecommendationApplication.java
├── src/main/resources/
│   ├── templates/      # Thymeleaf (login, register, dashboard)
│   ├── static/         # CSS/JS if any
│   └── application.properties
├── database/
│   └── schema.sql      # DDL, sample data, views, indexes
├── docs/
│   └── CNDC_Justification.md
├── Dockerfile
└── README.md
```

---

## Run with Docker (portable, git‑friendly)

Two steps: **build the JAR on your machine**, then **run app + MySQL in Docker**. The JAR is built locally to avoid a known Docker Desktop on Windows issue where long in-container builds drop the connection (`pipe/dockerDesktopLinuxEngine: file has already been closed`).

**Requirements:** [Docker Desktop](https://docs.docker.com/get-docker/), **JDK 17**, and **Maven** (to build the JAR once).

**Option A – one command (PowerShell):**

```powershell
cd d:\Project\crop-recommendation-system
.\build-and-run.ps1
```
*(Runs `mvn clean package -DskipTests` then `docker compose up -d --build`.)*

**Option B – manual:**

```powershell
cd d:\Project\crop-recommendation-system
mvn clean package -DskipTests
docker compose up -d --build
```

- App: **http://localhost:8080**  
- Login: `farmer@crop.com` / `password123`

**Optional:** Create a `.env` file with `OPENWEATHER_API_KEY=your_key` for weather features.

**Useful commands:**

```bash
docker compose up -d        # Start in background
docker compose logs -f app  # Follow app logs
docker compose down         # Stop and remove containers (data volume kept)
docker compose down -v      # Stop and remove containers + MySQL data
```

Data is stored in a Docker volume `crop-mysql-data` so it persists across restarts.

---

## Run locally (localhost)

If you prefer to run the app on your machine (e.g. for development) and only use Docker for MySQL:

1. **Start only MySQL:**  
   `docker compose up -d mysql`
2. **Run the app:**  
   `mvn spring-boot:run`  
   (requires JDK 17 and Maven; app will use `localhost:3306` and the same DB credentials.)

The repo works both ways: **Docker** (build JAR + `docker compose up -d`) or **local app + Docker MySQL** (`docker compose up -d mysql` then `mvn spring-boot:run`), and is safe to store in Git.

---

## Prerequisites (for non-Docker run)

- **JDK 17+**
- **Maven 3.8+**
- **MySQL 8.x** (running, with a user that can create DB and tables)

---

## MySQL Setup (when not using Docker)

1. Install and start MySQL.

2. Create database and user (optional; app can create DB if URL has `createDatabaseIfNotExist=true`):

```sql
CREATE DATABASE IF NOT EXISTS crop_recommendation_db;
CREATE USER IF NOT EXISTS 'cropuser'@'localhost' IDENTIFIED BY 'croppass';
GRANT ALL PRIVILEGES ON crop_recommendation_db.* TO 'cropuser'@'localhost';
FLUSH PRIVILEGES;
```

3. (Optional) Run the provided schema and sample data:

```bash
mysql -u root -p < database/schema.sql
```

Or run only the DDL/sample part in your MySQL client. If you skip this, the app will create tables via JPA `ddl-auto=update` and **DataLoader** will create default users (see below).

---

## application.properties Configuration

Edit `src/main/resources/application.properties`:

```properties
# Database (match your MySQL)
spring.datasource.url=jdbc:mysql://localhost:3306/crop_recommendation_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
spring.datasource.username=root
spring.datasource.password=root

# OpenWeather API (required for weather-based recommendation)
# Get key: https://openweathermap.org/api
openweather.api.key=YOUR_OPENWEATHER_API_KEY
```

- **MySQL:** Set `username` and `password` to your MySQL user.
- **OpenWeather:** Replace `YOUR_OPENWEATHER_API_KEY` with your API key; without it, weather fetch will fail (recommendation still works with soil-only or cached weather).

---

## How to Run the Project

**Windows (no Maven install):**
- **Without MySQL (H2):** `.\run.ps1` — uses embedded H2, no database setup.
- **With MySQL:** Create DB `crop_recommendation_db`, set `spring.datasource.password` in `application.properties`, then run `.\run-mysql.ps1`.

**With Maven:**

1. **Start MySQL** (if using MySQL; ensure database exists or create it).

2. **Build and run:**

```bash
cd crop-recommendation-system
mvn clean install
mvn spring-boot:run
# Or with H2 (no MySQL): mvn spring-boot:run -Dspring-boot.run.profiles=demo
```

3. **Access the app:**

- Web UI: **http://localhost:8080**
- You will be redirected to **http://localhost:8080/login**

---

## Default Users (Created by DataLoader)

If the DB is empty, the app creates these users (password for all: **password123**):

| Email | Role | Use |
|-------|------|-----|
| admin@crop.com | ADMIN | Admin dashboard, all APIs |
| farmer@crop.com | FARMER | Farmer dashboard, soil, recommendation |
| officer@crop.com | OFFICER | Officer dashboard, weather/rainfall trend |

---

## How to Test APIs

### 1. Login (get JWT)

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"farmer@crop.com\",\"password\":\"password123\"}"
```

Use the returned `token` in the next requests.

### 2. Get crop recommendation (with soil data)

```bash
curl -X POST http://localhost:8080/api/recommendation \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d "{
    \"soilData\": {
      \"nitrogen\": 90,
      \"phosphorus\": 42,
      \"potassium\": 43,
      \"ph\": 6.5,
      \"moisture\": 50
    },
    \"location\": \"London\"
  }"
```

### 3. Fetch and store weather

```bash
curl -X GET "http://localhost:8080/api/weather/current?location=London" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 4. Submit soil data

```bash
curl -X POST http://localhost:8080/api/soil \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d "{
    \"nitrogen\": 85,
    \"phosphorus\": 40,
    \"potassium\": 45,
    \"ph\": 6.2,
    \"moisture\": 55
  }"
```

### 5. Dashboard data (for Chart.js / frontend)

- Farmer: `GET /api/dashboard/farmer` (with JWT or cookie)
- Admin: `GET /api/dashboard/admin`
- Officer: `GET /api/dashboard/officer?location=London`

Use the same JWT in `Authorization: Bearer <token>` or log in via the web UI (cookie-based).

---

## Demo Steps for Presentation

1. **Start app and MySQL** as above.
2. **Login (web):** Open http://localhost:8080 → Login with `farmer@crop.com` / `password123`.
3. **Dashboard:** You are redirected to `/dashboard`; Farmer sees NPK trend and recommendations (after data exists).
4. **Recommendation (API or UI):** Use the recommendation API with soil + optional `location`; show response with recommended crop and confidence.
5. **Weather:** Call `/api/weather/current?location=London` (with auth); show that data is stored and used in recommendation/officer dashboard.
6. **Roles:** Log in as Admin → show “Most recommended crops” chart; as Officer → show rainfall/temperature trend (after loading data for a location).
7. **Security:** Show that `/api/dashboard/farmer` without token returns 401.

---

## Docker details

- **`docker-compose.yml`** – Defines `mysql` and `app` services. The app waits for MySQL to be healthy before starting.
- **`Dockerfile`** – Multi-stage: Maven builds the JAR **inside Docker** (Debian-based image, no local Java/Maven needed), then a JRE 17 image runs the app.
- **`.dockerignore`** – Keeps build context small (excludes `target/`, IDE files, etc.).
- **Optional:** Copy `.env.example` to `.env` and set `OPENWEATHER_API_KEY` for weather; otherwise leave empty (recommendation still works without weather).

---

## Features Summary

- **User management:** Register, login (JWT + cookie for web), roles ADMIN / FARMER / OFFICER.
- **Soil data:** Submit and list NPK, pH, moisture per user.
- **Weather:** OpenWeather API integration; store in DB; use in recommendation.
- **Recommendation engine:** Rule-based match of soil (and optional weather) to crop ideal ranges; persist recommendation and return best crop + confidence.
- **Dashboards:** Farmer (NPK + recommendations), Admin (most recommended crops), Officer (rainfall/temperature trend) using Chart.js.
- **Database:** JPA entities, constraints, indexes; `schema.sql` with sample data, joins, aggregation, nested query examples, and views.
- **Security:** BCrypt, JWT, role-based access, global exception handling, validation.
- **Docs:** `docs/CNDC_Justification.md` (architecture, HTTP vs MQTT, data flow, scalability, security, future IoT).

---

## License

This project is for educational and demonstration purposes.
