-- Smart Crop Recommendation System - Database Schema
-- MySQL 8.x compatible

CREATE DATABASE IF NOT EXISTS crop_recommendation_db;
USE crop_recommendation_db;

-- Users table
CREATE TABLE IF NOT EXISTS app_users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    CONSTRAINT uq_user_email UNIQUE (email),
    INDEX idx_user_email (email),
    INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Crops table (reference data)
CREATE TABLE IF NOT EXISTS crops (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    crop_name VARCHAR(100) NOT NULL,
    ideal_n_min DOUBLE NOT NULL,
    ideal_n_max DOUBLE NOT NULL,
    ideal_p_min DOUBLE NOT NULL,
    ideal_p_max DOUBLE NOT NULL,
    ideal_k_min DOUBLE NOT NULL,
    ideal_k_max DOUBLE NOT NULL,
    ideal_ph_min DOUBLE NOT NULL,
    ideal_ph_max DOUBLE NOT NULL,
    ideal_rainfall_min DOUBLE NOT NULL,
    ideal_rainfall_max DOUBLE NOT NULL,
    CONSTRAINT uq_crop_name UNIQUE (crop_name),
    INDEX idx_crop_name (crop_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Soil data (user submissions)
CREATE TABLE IF NOT EXISTS soil_data (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    nitrogen DOUBLE NOT NULL,
    phosphorus DOUBLE NOT NULL,
    potassium DOUBLE NOT NULL,
    ph DOUBLE NOT NULL,
    moisture DOUBLE NOT NULL,
    recorded_date DATETIME NOT NULL,
    CONSTRAINT fk_soil_user FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE,
    INDEX idx_soil_user_id (user_id),
    INDEX idx_soil_recorded_date (recorded_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Weather data (from OpenWeather API)
CREATE TABLE IF NOT EXISTS weather_data (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    temperature DOUBLE NOT NULL,
    humidity DOUBLE NOT NULL,
    rainfall DOUBLE NOT NULL,
    location VARCHAR(255) NOT NULL,
    recorded_date DATETIME NOT NULL,
    INDEX idx_weather_location (location),
    INDEX idx_weather_recorded_date (recorded_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Recommendations (user x crop)
CREATE TABLE IF NOT EXISTS recommendations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    crop_id BIGINT NOT NULL,
    recommendation_date DATETIME NOT NULL,
    confidence_score DOUBLE NOT NULL,
    CONSTRAINT fk_recommendation_user FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE,
    CONSTRAINT fk_recommendation_crop FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE,
    INDEX idx_recommendation_user_id (user_id),
    INDEX idx_recommendation_crop_id (crop_id),
    INDEX idx_recommendation_date (recommendation_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Optional: sample users. App DataLoader creates admin@crop.com, farmer@crop.com, officer@crop.com with password 'password123'.
-- Uncomment and set BCrypt password if not using the application to create users:
-- INSERT INTO app_users (name, email, password, role) VALUES
-- ('Admin User', 'admin@crop.com', '<bcrypt>', 'ADMIN'),
-- ('John Farmer', 'farmer@crop.com', '<bcrypt>', 'FARMER'),
-- ('Jane Officer', 'officer@crop.com', '<bcrypt>', 'OFFICER') ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Crops with ideal ranges (N, P, K, pH, rainfall)
INSERT INTO crops (crop_name, ideal_n_min, ideal_n_max, ideal_p_min, ideal_p_max, ideal_k_min, ideal_k_max, ideal_ph_min, ideal_ph_max, ideal_rainfall_min, ideal_rainfall_max) VALUES
('Rice', 80, 120, 30, 50, 30, 50, 5.0, 7.0, 150, 300),
('Wheat', 60, 100, 25, 45, 25, 45, 6.0, 7.5, 50, 100),
('Maize', 90, 150, 40, 80, 40, 80, 5.5, 7.5, 60, 120),
('Cotton', 70, 120, 35, 60, 35, 60, 5.5, 8.0, 50, 100),
('Sugarcane', 100, 180, 45, 90, 45, 90, 5.0, 8.5, 120, 250),
('Jute', 50, 90, 20, 40, 20, 40, 6.0, 7.5, 150, 300),
('Coconut', 40, 80, 20, 35, 40, 80, 5.0, 8.0, 100, 250),
('Papaya', 60, 100, 30, 50, 40, 70, 5.5, 7.0, 100, 200),
('Orange', 70, 110, 35, 55, 40, 75, 5.5, 7.5, 60, 150),
('Apple', 50, 90, 25, 45, 50, 90, 5.5, 7.0, 50, 120),
('Muskmelon', 55, 95, 25, 45, 35, 65, 6.0, 7.5, 40, 100),
('Watermelon', 50, 90, 25, 45, 35, 65, 5.5, 7.0, 50, 150),
('Grapes', 60, 100, 30, 50, 50, 90, 5.5, 7.5, 40, 100),
('Mango', 55, 95, 25, 45, 40, 75, 5.5, 7.5, 80, 200),
('Bean', 40, 80, 25, 45, 35, 65, 6.0, 7.5, 50, 150),
('Lentil', 30, 70, 20, 40, 25, 55, 5.5, 7.5, 40, 100),
('Blackgram', 35, 75, 20, 40, 25, 55, 6.0, 7.5, 50, 120),
('Moth Beans', 30, 70, 20, 40, 25, 55, 6.0, 7.5, 40, 100),
('Pigeon Peas', 35, 75, 20, 40, 30, 60, 5.5, 7.5, 60, 150),
('Chickpea', 35, 75, 25, 45, 30, 60, 5.5, 7.5, 40, 100)
ON DUPLICATE KEY UPDATE ideal_n_min = VALUES(ideal_n_min);

-- Example: JOIN query - users with their latest soil data
-- SELECT u.name, u.email, s.nitrogen, s.phosphorus, s.potassium, s.recorded_date
-- FROM app_users u
-- LEFT JOIN soil_data s ON u.id = s.user_id
-- WHERE s.id IN (SELECT MAX(id) FROM soil_data GROUP BY user_id);

-- Example: AGGREGATION - average NPK by user
-- SELECT user_id, AVG(nitrogen) AS avg_n, AVG(phosphorus) AS avg_p, AVG(potassium) AS avg_k
-- FROM soil_data
-- GROUP BY user_id;

-- Example: NESTED QUERY - crops recommended more than 5 times
-- SELECT crop_name FROM crops WHERE id IN (
--   SELECT crop_id FROM recommendations GROUP BY crop_id HAVING COUNT(*) > 5
-- );

-- View: recommendation summary
CREATE OR REPLACE VIEW v_recommendation_summary AS
SELECT
    r.id,
    u.name AS user_name,
    u.email,
    c.crop_name,
    r.recommendation_date,
    r.confidence_score
FROM recommendations r
JOIN app_users u ON r.user_id = u.id
JOIN crops c ON r.crop_id = c.id
ORDER BY r.recommendation_date DESC;

-- View: soil trend by user
CREATE OR REPLACE VIEW v_soil_trend AS
SELECT
    user_id,
    recorded_date,
    nitrogen,
    phosphorus,
    potassium,
    ph,
    moisture
FROM soil_data
ORDER BY user_id, recorded_date DESC;
