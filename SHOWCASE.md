# Run for project showcase

No Maven install needed – the project includes Maven Wrapper. You need **JDK 17**. For database you can use **H2 (no install)** or **MySQL**.

---

## Two ways to run

### Option 1: Without MySQL (H2 – good for quick demo)

- **Need:** JDK 17 only.
- **Run:** `.\run.ps1`
- Uses embedded H2; data is stored in the project `data/` folder.

### Option 2: With MySQL

- **Need:** JDK 17 + MySQL installed and running.
- **One-time setup:**
  1. In MySQL, run: `CREATE DATABASE IF NOT EXISTS crop_recommendation_db;`
  2. In `src/main/resources/application.properties` set:
     - `spring.datasource.username=root`
     - `spring.datasource.password=YOUR_MYSQL_PASSWORD`
- **Run:** `.\run-mysql.ps1`
- Uses MySQL; same app, different database.

---

## Steps (summary)

1. **Run the app** (from the project folder):
   - **No MySQL:** `.\run.ps1`
   - **With MySQL:** `.\run-mysql.ps1` (after creating DB and setting password as above)

2. Open **http://localhost:8080**  
   Login: **farmer@crop.com** / **password123**

---

## Demo logins (created on first run)

| Email             | Password    | Role   |
|-------------------|------------|--------|
| farmer@crop.com   | password123| FARMER |
| admin@crop.com    | password123| ADMIN  |
| officer@crop.com  | password123| OFFICER|

---

## Quick demo flow for evaluation

1. Login as **farmer@crop.com** / **password123**.
2. On the dashboard, use **Get Crop Recommendation**: enter N, P, K, pH, Moisture (e.g. 80, 40, 40, 6.5, 50), optionally a location like **London**, click **Get Recommendation**.
3. Show the recommended crop and confidence.
4. (Optional) Login as **admin@crop.com** and show the “Most recommended crops” chart; as **officer@crop.com** enter a location and show rainfall trend.

**OpenWeather:** If you add a free API key from [openweathermap.org](https://openweathermap.org/api) in `application.properties` as `openweather.api.key=your_key`, weather-based recommendation and officer rainfall data will work; otherwise recommendation works from soil only.
