# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-02-21

### Added
- **Core recommendation engine** — Rule-based crop matching using soil NPK, pH, and weather data
- **JWT authentication** — Secure login/register with BCrypt passwords and HTTP-only cookies
- **Role-based access** — Admin, Farmer, and Officer roles with scoped dashboards
- **Interactive dashboards** — NPK trends (Farmer), crop analytics (Admin), weather trends (Officer) via Chart.js
- **OpenWeather integration** — Real-time weather data fetching and storage
- **Modern landing page** — Hero section with gradient design and feature cards
- **Redesigned dashboard UI** — Glassmorphism cards, input validation, animated confidence progress bar
- **Docker support** — Full-stack deployment with MySQL via Docker Compose
- **H2 demo mode** — Run without MySQL using `.\run.ps1 -Demo`
- **Database seeding** — DataLoader auto-creates 3 default users and 15 crops
- **Professional documentation** — README with badges, architecture diagram, API reference, and roadmap
- **RESTful API** — Complete endpoints for auth, recommendations, soil data, weather, and dashboard

### Infrastructure
- Spring Boot 3.2.5, Java 17, Maven
- MySQL 8.x (production) / H2 (demo)
- Dockerfile + docker-compose.yml
- PowerShell run script with `-Demo` flag
