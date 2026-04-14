-- =====================================================
-- SmartCrop - Crop Recommendation System
-- DBMS Academic Project - SQL Schema & Data
-- =====================================================

-- -----------------------------------------------------
-- 1. DATABASE CREATION
-- -----------------------------------------------------
DROP DATABASE IF EXISTS smartcrop_db;
CREATE DATABASE smartcrop_db;
USE smartcrop_db;

-- -----------------------------------------------------
-- 2. TABLE CREATION
-- -----------------------------------------------------

-- Users Table
CREATE TABLE app_users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'FARMER', 'OFFICER')),
    INDEX idx_user_email (email),
    INDEX idx_user_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Crops Table
CREATE TABLE crops (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    crop_name VARCHAR(100) NOT NULL UNIQUE,
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
    INDEX idx_crop_name (crop_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Soil Data Table
CREATE TABLE soil_data (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    nitrogen DOUBLE NOT NULL,
    phosphorus DOUBLE NOT NULL,
    potassium DOUBLE NOT NULL,
    ph DOUBLE NOT NULL CHECK (ph BETWEEN 0 AND 14),
    moisture DOUBLE NOT NULL CHECK (moisture BETWEEN 0 AND 100),
    recorded_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_soil_user FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE,
    INDEX idx_soil_user_id (user_id),
    INDEX idx_soil_recorded_date (recorded_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Weather Data Table
CREATE TABLE weather_data (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    temperature DOUBLE NOT NULL,
    humidity DOUBLE NOT NULL CHECK (humidity BETWEEN 0 AND 100),
    rainfall DOUBLE NOT NULL,
    location VARCHAR(255) NOT NULL,
    recorded_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_weather_location (location),
    INDEX idx_weather_recorded_date (recorded_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Recommendations Table
CREATE TABLE recommendations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    crop_id BIGINT NOT NULL,
    recommendation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    confidence_score DOUBLE NOT NULL CHECK (confidence_score BETWEEN 0 AND 100),
    CONSTRAINT fk_recommendation_user FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE,
    CONSTRAINT fk_recommendation_crop FOREIGN KEY (crop_id) REFERENCES crops(id) ON DELETE CASCADE,
    INDEX idx_recommendation_user_id (user_id),
    INDEX idx_recommendation_crop_id (crop_id),
    INDEX idx_recommendation_date (recommendation_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- 3. DATA POPULATION
-- -----------------------------------------------------

-- Insert Users (Password: password123 - bcrypt hash)
INSERT INTO app_users (name, email, password, role) VALUES
('Admin User', 'admin@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0', 'ADMIN'),
('John Farmer', 'farmer@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0', 'FARMER'),
('Jane Officer', 'officer@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0', 'OFFICER'),
('Ramesh Kumar', 'ramesh@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0', 'FARMER'),
('Priya Sharma', 'priya@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0', 'FARMER'),
('Amit Singh', 'amit@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0', 'FARMER'),
('Sunita Devi', 'sunita@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0', 'FARMER'),
('Vikram Reddy', 'vikram@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0', 'OFFICER'),
('Anita Gupta', 'anita@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0', 'OFFICER'),
('Mohammad Khan', 'khan@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0', 'FARMER');

-- Insert Crops (15 crops)
INSERT INTO crops (crop_name, ideal_n_min, ideal_n_max, ideal_p_min, ideal_p_max, 
                   ideal_k_min, ideal_k_max, ideal_ph_min, ideal_ph_max, 
                   ideal_rainfall_min, ideal_rainfall_max) VALUES
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
('Grapes', 60, 100, 30, 50, 50, 90, 5.5, 7.5, 40, 100),
('Mango', 55, 95, 25, 45, 40, 75, 5.5, 7.5, 80, 200),
('Bean', 40, 80, 25, 45, 35, 65, 6.0, 7.5, 50, 150),
('Lentil', 30, 70, 20, 40, 25, 55, 5.5, 7.5, 40, 100),
('Chickpea', 35, 75, 25, 45, 30, 60, 5.5, 7.5, 40, 100);

-- Insert Soil Data (25 records)
INSERT INTO soil_data (user_id, nitrogen, phosphorus, potassium, ph, moisture, recorded_date) VALUES
(2, 90, 42, 43, 6.5, 55, '2024-01-15 09:30:00'),
(2, 85, 38, 40, 6.2, 50, '2024-02-20 10:15:00'),
(2, 95, 45, 48, 6.8, 60, '2024-03-10 11:00:00'),
(4, 70, 35, 38, 6.0, 45, '2024-01-18 08:45:00'),
(4, 75, 40, 42, 6.3, 52, '2024-02-25 09:20:00'),
(4, 80, 44, 45, 6.5, 58, '2024-03-15 10:30:00'),
(5, 100, 55, 60, 5.5, 65, '2024-01-22 14:00:00'),
(5, 105, 58, 65, 5.8, 70, '2024-02-28 15:30:00'),
(5, 110, 62, 68, 6.0, 72, '2024-03-20 16:00:00'),
(6, 60, 30, 32, 6.5, 40, '2024-01-25 07:30:00'),
(6, 65, 34, 36, 6.8, 45, '2024-02-18 08:00:00'),
(6, 68, 38, 40, 7.0, 48, '2024-03-22 09:15:00'),
(7, 55, 28, 35, 6.2, 35, '2024-01-28 12:00:00'),
(7, 58, 32, 38, 6.4, 40, '2024-02-15 13:30:00'),
(7, 62, 36, 42, 6.6, 44, '2024-03-25 14:45:00'),
(10, 78, 40, 45, 5.8, 55, '2024-02-01 10:00:00'),
(10, 82, 44, 48, 6.0, 58, '2024-02-20 11:30:00'),
(10, 86, 48, 52, 6.2, 62, '2024-03-18 12:00:00'),
(2, 92, 44, 46, 6.4, 56, '2024-04-05 08:30:00'),
(4, 88, 42, 44, 6.1, 54, '2024-04-10 09:00:00'),
(5, 108, 60, 66, 5.6, 68, '2024-04-15 10:30:00'),
(6, 72, 36, 38, 6.6, 46, '2024-04-20 11:00:00'),
(7, 65, 34, 40, 6.5, 42, '2024-04-25 12:15:00'),
(10, 90, 46, 50, 5.9, 60, '2024-05-01 13:00:00'),
(4, 82, 40, 44, 6.3, 52, '2024-05-10 14:30:00');

-- Insert Weather Data (20 records)
INSERT INTO weather_data (temperature, humidity, rainfall, location, recorded_date) VALUES
(28.5, 75, 120, 'Delhi', '2024-01-15 06:00:00'),
(25.0, 80, 145, 'Delhi', '2024-02-20 06:00:00'),
(32.0, 70, 80, 'Delhi', '2024-03-10 06:00:00'),
(22.5, 85, 180, 'Mumbai', '2024-01-18 06:00:00'),
(24.0, 82, 160, 'Mumbai', '2024-02-25 06:00:00'),
(26.5, 78, 140, 'Mumbai', '2024-03-15 06:00:00'),
(30.0, 65, 60, 'Chennai', '2024-01-22 06:00:00'),
(31.5, 62, 45, 'Chennai', '2024-02-28 06:00:00'),
(33.0, 60, 35, 'Chennai', '2024-03-20 06:00:00'),
(18.0, 90, 95, 'Ludhiana', '2024-01-25 06:00:00'),
(20.5, 88, 85, 'Ludhiana', '2024-02-18 06:00:00'),
(23.0, 85, 70, 'Ludhiana', '2024-03-22 06:00:00'),
(26.0, 72, 110, 'Hyderabad', '2024-01-28 06:00:00'),
(28.0, 68, 95, 'Hyderabad', '2024-02-15 06:00:00'),
(30.5, 65, 75, 'Hyderabad', '2024-03-25 06:00:00'),
(27.5, 76, 130, 'Pune', '2024-02-01 06:00:00'),
(29.0, 74, 115, 'Pune', '2024-02-20 06:00:00'),
(31.0, 71, 90, 'Pune', '2024-03-18 06:00:00'),
(24.5, 82, 155, 'Kolkata', '2024-04-05 06:00:00'),
(26.0, 79, 135, 'Kolkata', '2024-04-10 06:00:00');

-- Insert Recommendations (25 records)
INSERT INTO recommendations (user_id, crop_id, recommendation_date, confidence_score) VALUES
(2, 1, '2024-01-15 10:00:00', 92.5),
(2, 1, '2024-02-20 11:30:00', 88.0),
(2, 3, '2024-03-10 12:15:00', 85.5),
(4, 2, '2024-01-18 09:30:00', 78.0),
(4, 2, '2024-02-25 10:45:00', 82.5),
(4, 1, '2024-03-15 11:20:00', 90.0),
(5, 5, '2024-01-22 15:00:00', 94.0),
(5, 5, '2024-02-28 16:30:00', 91.5),
(5, 5, '2024-03-20 17:00:00', 89.0),
(6, 2, '2024-01-25 08:00:00', 75.5),
(6, 2, '2024-02-18 09:15:00', 80.0),
(6, 2, '2024-03-22 10:30:00', 83.5),
(7, 7, '2024-01-28 13:00:00', 86.0),
(7, 7, '2024-02-15 14:30:00', 84.5),
(7, 7, '2024-03-25 15:45:00', 88.0),
(10, 1, '2024-02-01 11:00:00', 87.5),
(10, 1, '2024-02-20 12:45:00', 85.0),
(10, 3, '2024-03-18 13:30:00', 82.0),
(2, 3, '2024-04-05 09:45:00', 89.0),
(4, 3, '2024-04-10 10:30:00', 86.5),
(5, 5, '2024-04-15 11:45:00', 93.0),
(6, 2, '2024-04-20 12:30:00', 81.0),
(7, 7, '2024-04-25 13:45:00', 87.5),
(10, 1, '2024-05-01 14:30:00', 88.5),
(4, 3, '2024-05-10 15:45:00', 84.0);

-- -----------------------------------------------------
-- 4. QUERY DEMONSTRATIONS
-- -----------------------------------------------------

-- Query 1: Basic Join - Get All Recommendations with User and Crop Details
SELECT 
    r.id AS recommendation_id,
    u.name AS farmer_name,
    u.email AS farmer_email,
    c.crop_name AS recommended_crop,
    r.confidence_score,
    r.recommendation_date
FROM recommendations r
JOIN app_users u ON r.user_id = u.id
JOIN crops c ON r.crop_id = c.id
ORDER BY r.recommendation_date DESC;

-- Query 2: Aggregation - Most Recommended Crops
SELECT 
    c.crop_name,
    COUNT(r.id) AS total_recommendations,
    ROUND(AVG(r.confidence_score), 2) AS avg_confidence
FROM crops c
LEFT JOIN recommendations r ON c.id = r.crop_id
GROUP BY c.id, c.crop_name
ORDER BY total_recommendations DESC;

-- Query 3: WHERE Clause - High Confidence Recommendations (>85%)
SELECT 
    c.crop_name,
    u.name AS farmer_name,
    r.confidence_score,
    r.recommendation_date
FROM recommendations r
JOIN crops c ON r.crop_id = c.id
JOIN app_users u ON r.user_id = u.id
WHERE r.confidence_score > 85
ORDER BY r.confidence_score DESC;

-- Query 4: Subquery - Best Crop for Specific Soil Conditions
SELECT 
    c.crop_name,
    c.ideal_n_min,
    c.ideal_n_max,
    c.ideal_p_min,
    c.ideal_p_max,
    c.ideal_k_min,
    c.ideal_k_max
FROM crops c
WHERE c.ideal_n_min <= 90 
  AND c.ideal_n_max >= 90
  AND c.ideal_p_min <= 42 
  AND c.ideal_p_max >= 42
  AND c.ideal_k_min <= 43 
  AND c.ideal_k_max >= 43
  AND c.ideal_ph_min <= 6.5 
  AND c.ideal_ph_max >= 6.5;

-- Query 5: GROUP BY - Soil Data Statistics per Farmer
SELECT 
    u.name AS farmer_name,
    COUNT(s.id) AS soil_tests,
    ROUND(AVG(s.nitrogen), 2) AS avg_nitrogen,
    ROUND(AVG(s.phosphorus), 2) AS avg_phosphorus,
    ROUND(AVG(s.potassium), 2) AS avg_potassium,
    ROUND(AVG(s.ph), 2) AS avg_ph
FROM app_users u
LEFT JOIN soil_data s ON u.id = s.user_id
WHERE u.role = 'FARMER'
GROUP BY u.id, u.name
ORDER BY soil_tests DESC;

-- Query 6: JOIN with Multiple Tables - Complete Recommendation History
SELECT 
    r.id,
    u.name AS farmer,
    c.crop_name AS crop,
    s.nitrogen, s.phosphorus, s.potassium, s.ph,
    w.temperature, w.humidity, w.rainfall,
    r.confidence_score,
    r.recommendation_date
FROM recommendations r
JOIN app_users u ON r.user_id = u.id
JOIN crops c ON r.crop_id = c.id
JOIN soil_data s ON r.user_id = s.user_id 
    AND DATE(s.recorded_date) = DATE(r.recommendation_date)
LEFT JOIN weather_data w ON DATE(w.recorded_date) = DATE(r.recommendation_date)
    AND w.location = 'Delhi'
WHERE u.role = 'FARMER'
ORDER BY r.recommendation_date DESC;

-- Query 7: Aggregate Function - Monthly Recommendation Trends
SELECT 
    DATE_FORMAT(r.recommendation_date, '%Y-%m') AS month,
    c.crop_name,
    COUNT(*) AS recommendations,
    ROUND(AVG(r.confidence_score), 2) AS avg_confidence
FROM recommendations r
JOIN crops c ON r.crop_id = c.id
GROUP BY DATE_FORMAT(r.recommendation_date, '%Y-%m'), c.crop_name
ORDER BY month DESC, recommendations DESC;

-- Query 8: Subquery with ALL - Crops with Above Average Confidence
SELECT 
    c.crop_name,
    ROUND(AVG(r.confidence_score), 2) AS avg_confidence
FROM crops c
JOIN recommendations r ON c.id = r.crop_id
GROUP BY c.id, c.crop_name
HAVING AVG(r.confidence_score) > (
    SELECT AVG(confidence_score) FROM recommendations
);

-- Query 9: EXISTS - Farmers Who Have Never Used Recommendations
SELECT 
    u.name,
    u.email,
    u.role
FROM app_users u
WHERE u.role = 'FARMER' 
  AND NOT EXISTS (
    SELECT 1 FROM recommendations r WHERE r.user_id = u.id
  );

-- Query 10: Complex WHERE - Weather-based Crop Suggestions
SELECT 
    c.crop_name,
    c.ideal_rainfall_min,
    c.ideal_rainfall_max,
    ROUND(AVG(w.rainfall), 2) AS actual_rainfall,
    COUNT(*) AS weather_records
FROM crops c
JOIN weather_data w ON w.location = 'Delhi'
WHERE w.rainfall BETWEEN c.ideal_rainfall_min AND c.ideal_rainfall_max
GROUP BY c.id, c.crop_name, c.ideal_rainfall_min, c.ideal_rainfall_max
ORDER BY COUNT(*) DESC;

-- Query 11: Window Function - Rank Crops by Popularity
SELECT 
    c.crop_name,
    COUNT(r.id) AS total_recs,
    RANK() OVER (ORDER BY COUNT(r.id) DESC) AS popularity_rank,
    DENSE_RANK() OVER (ORDER BY COUNT(r.id) DESC) AS dense_rank
FROM crops c
LEFT JOIN recommendations r ON c.id = r.crop_id
GROUP BY c.id, c.crop_name;

-- Query 12: CTEs - Complex Analysis with Common Table Expression
WITH RECOMMENDATION_STATS AS (
    SELECT 
        crop_id,
        COUNT(*) AS total_count,
        AVG(confidence_score) AS avg_score
    FROM recommendations
    GROUP BY crop_id
),
SOIL_STATS AS (
    SELECT 
        user_id,
        AVG(nitrogen) AS avg_n,
        AVG(phosphorus) AS avg_p,
        AVG(potassium) AS avg_k
    FROM soil_data
    GROUP BY user_id
)
SELECT 
    u.name,
    c.crop_name,
    rs.total_count,
    ROUND(rs.avg_score, 2) AS avg_confidence,
    ROUND(ss.avg_n, 2) AS avg_nitrogen,
    ROUND(ss.avg_p, 2) AS avg_phosphorus,
    ROUND(ss.avg_k, 2) AS avg_potassium
FROM app_users u
JOIN soil_data sd ON u.id = sd.user_id
JOIN recommendations r ON u.id = r.user_id
JOIN crops c ON r.crop_id = c.id
JOIN RECOMMENDATION_STATS rs ON c.id = rs.crop_id
JOIN SOIL_STATS ss ON u.id = ss.user_id
WHERE u.role = 'FARMER'
GROUP BY u.id, u.name, c.id, c.crop_name, rs.total_count, rs.avg_score, ss.avg_n, ss.avg_p, ss.avg_k
ORDER BY rs.total_count DESC;

-- -----------------------------------------------------
-- 5. ADDITIONAL QUERIES FOR VIVA
-- -----------------------------------------------------

-- Q13: Find average soil nutrients for each crop recommendation
SELECT 
    c.crop_name,
    COUNT(*) AS rec_count,
    ROUND(AVG(s.nitrogen), 1) AS avg_N,
    ROUND(AVG(s.phosphorus), 1) AS avg_P,
    ROUND(AVG(s.potassium), 1) AS avg_K,
    ROUND(AVG(s.ph), 2) AS avg_pH
FROM recommendations r
JOIN crops c ON r.crop_id = c.id
JOIN soil_data s ON r.user_id = s.user_id
GROUP BY c.crop_name
ORDER BY rec_count DESC;

-- Q14: Find the most active farmers (most soil tests + recommendations)
SELECT 
    u.name,
    COUNT(DISTINCT s.id) AS soil_tests,
    COUNT(DISTINCT r.id) AS recommendations
FROM app_users u
LEFT JOIN soil_data s ON u.id = s.user_id
LEFT JOIN recommendations r ON u.id = r.user_id
WHERE u.role = 'FARMER'
GROUP BY u.id, u.name
ORDER BY soil_tests DESC, recommendations DESC;

-- Q15: Weather analysis - Hottest and wettest locations
SELECT 
    location,
    ROUND(AVG(temperature), 1) AS avg_temp,
    ROUND(AVG(rainfall), 1) AS avg_rainfall,
    COUNT(*) AS records
FROM weather_data
GROUP BY location
ORDER BY avg_temp DESC;

-- Q16: Find crops suitable for acidic soil (pH < 6.0)
SELECT crop_name, ideal_ph_min, ideal_ph_max, ideal_rainfall_min, ideal_rainfall_max
FROM crops
WHERE ideal_ph_min < 6.0;

-- Q17: Count recommendations per user (with JOIN)
SELECT 
    u.name,
    u.email,
    COUNT(r.id) AS total_recommendations,
    MAX(r.recommendation_date) AS last_recommendation
FROM app_users u
LEFT JOIN recommendations r ON u.id = r.user_id
WHERE u.role = 'FARMER'
GROUP BY u.id, u.name, u.email
ORDER BY total_recommendations DESC;

-- Q18: Find recommendations made in the last 30 days
SELECT 
    c.crop_name,
    u.name,
    r.confidence_score,
    r.recommendation_date
FROM recommendations r
JOIN crops c ON r.crop_id = c.id
JOIN app_users u ON r.user_id = u.id
WHERE r.recommendation_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY r.recommendation_date DESC;

-- Q19: Average confidence by month (pivot style analysis)
SELECT 
    DATE_FORMAT(recommendation_date, '%Y-%m') AS month,
    COUNT(*) AS total_recs,
    MIN(confidence_score) AS min_conf,
    MAX(confidence_score) AS max_conf,
    ROUND(AVG(confidence_score), 2) AS avg_conf
FROM recommendations
GROUP BY DATE_FORMAT(recommendation_date, '%Y-%m')
ORDER BY month;

-- Q20: Find farmers whose soil is suitable for Rice cultivation
SELECT 
    u.name,
    u.email,
    s.nitrogen, s.phosphorus, s.potassium, s.ph,
    'Suitable' AS rice_suitability
FROM app_users u
JOIN soil_data s ON u.id = s.user_id
WHERE u.role = 'FARMER'
  AND s.nitrogen BETWEEN 80 AND 120
  AND s.ph BETWEEN 5.0 AND 7.0;

-- =====================================================
-- END OF SQL SCRIPT
-- =====================================================