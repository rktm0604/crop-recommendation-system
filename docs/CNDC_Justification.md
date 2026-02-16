# CNDC Justification Document  
## Smart Crop Recommendation System

**Document Purpose:** Technical justification for client-server architecture, protocol selection (HTTP vs MQTT), data flow, scalability, and security for the Smart Crop Recommendation System in agricultural contexts.

---

## 1. Client-Server Architecture

The system is designed around a **client-server architecture**. The server (Spring Boot backend) hosts business logic, persistence, and external integrations; clients (web browsers, future mobile or IoT clients) send requests and consume responses.

**Rationale:**

- **Centralised control:** Crop recommendation rules, user management, and weather integration are maintained in one place, ensuring consistent behaviour and easier updates.
- **Scalability:** Adding new clients does not require changing the core logic; the server can be scaled horizontally behind a load balancer.
- **Security:** Sensitive operations (authentication, database access, API keys) remain on the server; clients receive only authorised data and tokens (e.g. JWT).
- **Interoperability:** Any client that can perform HTTP requests (browser, mobile app, IoT gateway) can integrate with the same API, supporting future expansion (e.g. field sensors, mobile apps).

This choice aligns with industry practice for web and API-driven agricultural decision-support systems where a single backend serves multiple user types (farmers, officers, admins).

---

## 2. HTTP vs MQTT Comparison and Choice

| Aspect | HTTP/HTTPS | MQTT |
|--------|------------|------|
| **Model** | Request-response; client initiates | Publish-subscribe; broker mediates |
| **Latency** | Typically one RTT per request | Low latency for small messages |
| **Use case** | CRUD, user actions, REST APIs | Telemetry, events, many small publishers |
| **Infrastructure** | Standard web servers, CDNs, firewalls | Broker (e.g. Mosquitto) required |
| **Security** | TLS, OAuth2, JWT well established | TLS + auth; pattern less common in agri stacks |
| **Adoption in agri web apps** | Dominant for dashboards and APIs | Common for sensor streams and IoT |

**Why HTTP was chosen for this system:**

1. **Primary use case:** The system is a **web application** where users log in, submit soil data, request recommendations, and view dashboards. These are discrete, user-initiated actions that map naturally to HTTP request-response (GET/POST/PUT/DELETE).
2. **Simplicity:** No extra broker or MQTT infrastructure is required; existing knowledge of REST and Spring simplifies development and deployment.
3. **Integration:** OpenWeather API and typical web/mobile clients are HTTP-based; using HTTP end-to-end avoids protocol translation and keeps the stack consistent.
4. **Security and tooling:** TLS, JWT, and cookie-based auth are standard with HTTP; monitoring, load balancing, and API gateways are widely available for HTTP traffic.
5. **Current scope:** The system does not (yet) require high-frequency, low-latency telemetry from large numbers of constrained devices; when such requirements arise, MQTT or a hybrid (HTTP for user-facing, MQTT for sensors) can be considered.

**Conclusion:** HTTP is the appropriate choice for the current Smart Crop Recommendation System. MQTT can be revisited for future IoT integration (e.g. continuous soil or weather sensor feeds).

---

## 3. Data Flow Diagram (Conceptual)

```
┌─────────────┐     HTTPS      ┌──────────────────┐     JDBC      ┌──────────┐
│   Client    │ ◄────────────► │  Spring Boot     │ ◄────────────► │  MySQL   │
│ (Browser /  │   (REST +      │  (Controllers,   │               │  DB      │
│  Future     │    JWT/Cookie) │   Services,      │               │          │
│  Mobile)    │                │   Security)      │               └──────────┘
└─────────────┘                └────────┬─────────┘
                                        │
                                        │ HTTPS (timeout, retry)
                                        ▼
                               ┌──────────────────┐
                               │ OpenWeather API  │
                               │ (weather data)   │
                               └──────────────────┘
```

**Explanation:**

- **Client → Server:** User credentials (login), soil data, recommendation requests, and dashboard requests are sent over HTTPS. Authentication is via JWT (header or cookie); session state is minimal (stateless where possible).
- **Server → Database:** Spring Data JPA performs CRUD on MySQL (users, soil data, weather data, crops, recommendations). Constraints (PK, FK, NOT NULL, UNIQUE, INDEX) enforce integrity and query performance.
- **Server → OpenWeather:** The server calls the external weather API with timeout and error handling; results are stored in `WeatherData` and used in the recommendation engine and dashboards.
- **Server → Client:** JSON responses (e.g. recommendation, weather, dashboard aggregates) and HTML (Thymeleaf) are returned; Chart.js on the client renders charts from dashboard API data.

---

## 4. Scalability

- **Vertical:** The Spring Boot application can be run on larger instances; connection pooling and async capabilities (e.g. WebClient for weather) help utilise resources.
- **Horizontal:** Stateless design (JWT, no server-side session store) allows multiple instances behind a load balancer; MySQL can be scaled (replicas, read replicas) as needed.
- **Database:** Indexes on frequently queried columns (e.g. user_id, recorded_date, location) and normalised schema support growth; views and aggregation queries are used for dashboards without overloading the DB.
- **Future:** Caching (e.g. Redis for sessions or weather), read replicas, and optional MQTT for sensor ingestion can be added as usage grows.

---

## 5. LAN/WAN Agricultural Connectivity

- **WAN:** The primary deployment assumes farm offices or users with internet access; HTTPS ensures secure communication over public networks. The client (browser) can be used from any location with connectivity to the server.
- **LAN:** The same server can be deployed inside a local network (e.g. farm or cooperative) with internal DNS; access control remains role-based (ADMIN, FARMER, OFFICER). No protocol change is required.
- **Offline / poor connectivity:** The current design assumes online operation; future enhancements could include offline-capable clients with sync when connected, or edge caching for critical data.

---

## 6. Secure Data Transmission

- **Transport:** HTTPS (TLS) is required in production for all client-server and server–external-API traffic to protect credentials, tokens, and personal/soil data.
- **Authentication:** JWT signed with a server-held secret; tokens are transmitted in headers or HTTP-only cookies to reduce XSS exposure. Passwords are hashed with BCrypt and never stored in plain text.
- **Authorization:** Role-based access (Spring Security) restricts endpoints (e.g. admin-only, officer-only) so that only authorised roles can access sensitive operations and data.

---

## 7. Data Integrity Measures

- **Database:** Primary keys, foreign keys, NOT NULL, and UNIQUE constraints enforce referential and entity integrity. Indexes support consistent performance and reduce risk of ad-hoc full scans.
- **Application:** Validation annotations (e.g. Jakarta Validation) and service-layer checks ensure that only valid soil parameters and user inputs are persisted; the recommendation engine uses validated ranges.
- **Auditability:** Timestamps (e.g. `recordedDate`, `recommendationDate`) and user associations allow tracing of who submitted data and when, supporting accountability and debugging.

---

## 8. Fault Tolerance

- **External API:** OpenWeather calls use timeouts and exception handling; failures do not crash the application. Recommendation can still run with cached or missing weather (e.g. rainfall defaulted or omitted).
- **Database:** Connection pooling and transactional boundaries (e.g. `@Transactional`) ensure that partial writes are avoided; deployment with replicated MySQL can address DB node failures.
- **Logging and monitoring:** Structured logging and global exception handling (e.g. `GlobalExceptionHandler`) support quick diagnosis and operational response.

---

## 9. Future IoT Integration

- **Sensors:** Future soil or weather sensors can push data via MQTT to a broker; a bridge service (subscribing to MQTT and posting to the existing HTTP API) would allow the same recommendation and dashboard logic to consume IoT data without rewriting the core.
- **Protocol coexistence:** HTTP remains for user-facing and management operations; MQTT can be introduced for high-frequency, device-originated streams, with clear boundaries and security (TLS, client certs or tokens) at the broker and bridge.

---

*This document provides the technical justification for the Smart Crop Recommendation System’s architecture and design choices in an academic and industry-oriented context.*
