-- =============================================================================
-- SmartCrop - Production SQL Schema
-- Database: MySQL 8.x
-- Normalized to 3NF/BCNF with proper constraints and indexes
-- =============================================================================

-- Drop and recreate database
DROP DATABASE IF EXISTS crop_recommendation_db;
CREATE DATABASE crop_recommendation_db;
USE crop_recommendation_db;

-- =============================================================================
-- TABLE: app_users (Farmers)
-- =============================================================================
CREATE TABLE app_users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_user_email UNIQUE (email),
    INDEX idx_user_email (email),
    INDEX idx_user_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- TABLE: crops
-- =============================================================================
CREATE TABLE crops (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    crop_name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
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
    ideal_temp_min DOUBLE,
    ideal_temp_max DOUBLE,
    growing_season VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT uk_crop_name UNIQUE (crop_name),
    INDEX idx_crop_name (crop_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- TABLE: soil_data
-- =============================================================================
CREATE TABLE soil_data (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    nitrogen DOUBLE NOT NULL CHECK (nitrogen >= 0),
    phosphorus DOUBLE NOT NULL CHECK (phosphorus >= 0),
    potassium DOUBLE NOT NULL CHECK (potassium >= 0),
    ph DOUBLE NOT NULL CHECK (ph >= 0 AND ph <= 14),
    moisture DOUBLE NOT NULL CHECK (moisture >= 0 AND moisture <= 100),
    temperature DOUBLE,
    location VARCHAR(255),
    recorded_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_soil_user FOREIGN KEY (user_id) 
        REFERENCES app_users(id) ON DELETE CASCADE,
    INDEX idx_soil_user (user_id),
    INDEX idx_soil_date (recorded_date),
    INDEX idx_soil_user_date (user_id, recorded_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- TABLE: weather_data
-- =============================================================================
CREATE TABLE weather_data (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    temperature DOUBLE NOT NULL,
    humidity DOUBLE NOT NULL CHECK (humidity >= 0 AND humidity <= 100),
    rainfall DOUBLE NOT NULL CHECK (rainfall >= 0),
    wind_speed DOUBLE,
    description VARCHAR(255),
    location VARCHAR(255) NOT NULL,
    recorded_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_weather_location (location),
    INDEX idx_weather_date (recorded_date),
    INDEX idx_weather_loc_date (location, recorded_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- TABLE: recommendations
-- =============================================================================
CREATE TABLE recommendations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    crop_id BIGINT NOT NULL,
    soil_data_id BIGINT,
    confidence_score DOUBLE NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 100),
    n_score DOUBLE,
    p_score DOUBLE,
    k_score DOUBLE,
    ph_score DOUBLE,
    rainfall_score DOUBLE,
    recommendation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_rec_user FOREIGN KEY (user_id) 
        REFERENCES app_users(id) ON DELETE CASCADE,
    CONSTRAINT fk_rec_crop FOREIGN KEY (crop_id) 
        REFERENCES crops(id) ON DELETE RESTRICT,
    CONSTRAINT fk_rec_soil FOREIGN KEY (soil_data_id) 
        REFERENCES soil_data(id) ON DELETE SET NULL,
    INDEX idx_rec_user (user_id),
    INDEX idx_rec_crop (crop_id),
    INDEX idx_rec_date (recommendation_date),
    INDEX idx_rec_user_date (user_id, recommendation_date),
    INDEX idx_rec_score (confidence_score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SEED DATA: Users (Password: password123 - bcrypt hash)
-- =============================================================================
INSERT INTO app_users (name, email, password) VALUES
('John Farmer', 'farmer@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0'),
('Ramesh Kumar', 'ramesh@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0'),
('Priya Sharma', 'priya@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0'),
('Amit Singh', 'amit@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0'),
('Sunita Devi', 'sunita@crop.com', '$2a$10$X9K3Q5N5Z7Q8R9S0T1U2V3W4X5Y6Z7A8B9C0D1E2F3G4H5I6J7K8L9M0');

-- =============================================================================
-- SEED DATA: Crops (15 crops with ideal NPK/pH/rainfall ranges)
-- =============================================================================
INSERT INTO crops (crop_name, description, ideal_n_min, ideal_n_max, ideal_p_min, ideal_p_max, 
                   ideal_k_min, ideal_k_max, ideal_ph_min, ideal_ph_max, 
                   ideal_rainfall_min, ideal_rainfall_max, ideal_temp_min, ideal_temp_max, growing_season) VALUES
('Rice', 'Staple cereal crop requiring high moisture', 80, 120, 30, 50, 30, 50, 5.0, 7.0, 150, 300, 20, 35, 'Kharif'),
('Wheat', 'Rabi cereal crop, second most important', 60, 100, 25, 45, 25, 45, 6.0, 7.5, 50, 100, 15, 25, 'Rabi'),
('Maize', 'Versatile cereal used for food and feed', 90, 150, 40, 80, 40, 80, 5.5, 7.5, 60, 120, 18, 30, 'Kharif'),
('Cotton', 'Cash crop for textile industry', 70, 120, 35, 60, 35, 60, 5.5, 8.0, 50, 100, 20, 35, 'Kharif'),
('Sugarcane', 'Major sugar producing crop', 100, 180, 45, 90, 45, 90, 5.0, 8.5, 120, 250, 20, 35, 'Annual'),
('Jute', 'Fiber crop for packaging', 50, 90, 20, 40, 20, 40, 6.0, 7.5, 150, 300, 20, 35, 'Kharif'),
('Coconut', 'Tropical oilseed crop', 40, 80, 20, 35, 40, 80, 5.0, 8.0, 100, 250, 20, 32, 'Perennial'),
('Papaya', 'Tropical fruit crop', 60, 100, 30, 50, 40, 70, 5.5, 7.0, 100, 200, 20, 30, 'Perennial'),
('Orange', 'Citrus fruit for juice', 70, 110, 35, 55, 40, 75, 5.5, 7.5, 60, 150, 15, 30, 'Perennial'),
('Apple', 'Temperate fruit crop', 50, 90, 25, 45, 50, 90, 5.5, 7.0, 50, 120, 10, 25, 'Perennial'),
('Grapes', 'Wine and table fruit', 60, 100, 30, 50, 50, 90, 5.5, 7.5, 40, 100, 15, 30, 'Perennial'),
('Mango', 'King of tropical fruits', 55, 95, 25, 45, 40, 75, 5.5, 7.5, 80, 200, 20, 35, 'Perennial'),
('Bean', 'Leguminous pulse crop', 40, 80, 25, 45, 35, 65, 6.0, 7.5, 50, 150, 15, 30, 'Rabi'),
('Lentil', 'Protein-rich pulse crop', 30, 70, 20, 40, 25, 55, 5.5, 7.5, 40, 100, 10, 25, 'Rabi'),
('Chickpea', 'Major pulse crop', 35, 75, 25, 45, 30, 60, 5.5, 7.5, 40, 100, 15, 30, 'Rabi');

-- =============================================================================
-- SEED DATA: Soil Data Samples
-- =============================================================================
INSERT INTO soil_data (user_id, nitrogen, phosphorus, potassium, ph, moisture, location, recorded_date) VALUES
(1, 90, 42, 43, 6.5, 55, 'Delhi', '2024-01-15 09:30:00'),
(1, 85, 38, 40, 6.2, 50, 'Delhi', '2024-02-20 10:15:00'),
(1, 95, 45, 48, 6.8, 60, 'Delhi', '2024-03-10 11:00:00'),
(2, 70, 35, 38, 6.0, 45, 'Pune', '2024-01-18 08:45:00'),
(2, 75, 40, 42, 6.3, 52, 'Pune', '2024-02-25 09:20:00'),
(2, 80, 44, 45, 6.5, 58, 'Pune', '2024-03-15 10:30:00'),
(3, 100, 55, 60, 5.5, 65, 'Hyderabad', '2024-01-22 14:00:00'),
(3, 105, 58, 65, 5.8, 70, 'Hyderabad', '2024-02-28 15:30:00'),
(3, 110, 62, 68, 6.0, 72, 'Hyderabad', '2024-03-20 16:00:00'),
(4, 60, 30, 32, 6.5, 40, 'Mumbai', '2024-01-25 07:30:00'),
(4, 65, 34, 36, 6.8, 45, 'Mumbai', '2024-02-18 08:00:00'),
(4, 68, 38, 40, 7.0, 48, 'Mumbai', '2024-03-22 09:15:00'),
(5, 55, 28, 35, 6.2, 35, 'Chennai', '2024-01-28 12:00:00'),
(5, 58, 32, 38, 6.4, 40, 'Chennai', '2024-02-15 13:30:00'),
(5, 62, 36, 42, 6.6, 44, 'Chennai', '2024-03-25 14:45:00'),
(1, 92, 44, 46, 6.4, 56, 'Delhi', '2024-04-05 08:30:00'),
(2, 88, 42, 44, 6.1, 54, 'Pune', '2024-04-10 09:00:00'),
(3, 108, 60, 66, 5.6, 68, 'Hyderabad', '2024-04-15 10:30:00'),
(4, 72, 36, 38, 6.6, 46, 'Mumbai', '2024-04-20 11:00:00'),
(5, 65, 34, 40, 6.5, 42, 'Chennai', '2024-04-25 12:15:00');

-- =============================================================================
-- SEED DATA: Weather Data Samples
-- =============================================================================
INSERT INTO weather_data (temperature, humidity, rainfall, wind_speed, description, location, recorded_date) VALUES
(28.5, 75, 120, 12.5, 'Clear sky', 'Delhi', '2024-01-15 06:00:00'),
(25.0, 80, 145, 10.0, 'Light rain', 'Delhi', '2024-02-20 06:00:00'),
(32.0, 70, 80, 15.0, 'Sunny', 'Delhi', '2024-03-10 06:00:00'),
(22.5, 85, 180, 8.0, 'Heavy rain', 'Mumbai', '2024-01-18 06:00:00'),
(24.0, 82, 160, 9.0, 'Rainy', 'Mumbai', '2024-02-25 06:00:00'),
(26.5, 78, 140, 11.0, 'Cloudy', 'Mumbai', '2024-03-15 06:00:00'),
(30.0, 65, 60, 14.0, 'Dry', 'Chennai', '2024-01-22 06:00:00'),
(31.5, 62, 45, 16.0, 'Hot', 'Chennai', '2024-02-28 06:00:00'),
(33.0, 60, 35, 18.0, 'Very hot', 'Chennai', '2024-03-20 06:00:00'),
(18.0, 90, 95, 6.0, 'Cold', 'Ludhiana', '2024-01-25 06:00:00'),
(20.5, 88, 85, 7.0, 'Foggy', 'Ludhiana', '2024-02-18 06:00:00'),
(23.0, 85, 70, 8.0, 'Clear', 'Ludhiana', '2024-03-22 06:00:00'),
(26.0, 72, 110, 12.0, 'Pleasant', 'Hyderabad', '2024-01-28 06:00:00'),
(28.0, 68, 95, 13.0, 'Clear', 'Hyderabad', '2024-02-15 06:00:00'),
(30.5, 65, 75, 15.0, 'Warm', 'Hyderabad', '2024-03-25 06:00:00'),
(27.5, 76, 130, 10.0, 'Rainy', 'Pune', '2024-02-01 06:00:00'),
(29.0, 74, 115, 11.0, 'Cloudy', 'Pune', '2024-02-20 06:00:00'),
(31.0, 71, 90, 14.0, 'Clear', 'Pune', '2024-03-18 06:00:00'),
(24.5, 82, 155, 9.0, 'Monsoon', 'Kolkata', '2024-04-05 06:00:00'),
(26.0, 79, 135, 10.0, 'Rainy', 'Kolkata', '2024-04-10 06:00:00');

-- =============================================================================
-- SEED DATA: Recommendations
-- =============================================================================
INSERT INTO recommendations (user_id, crop_id, soil_data_id, confidence_score, n_score, p_score, k_score, ph_score, rainfall_score, recommendation_date) VALUES
(1, 1, 1, 92.5, 95, 88, 86, 90, 80, '2024-01-15 10:00:00'),
(1, 1, 2, 88.0, 90, 80, 80, 80, 85, '2024-02-20 11:30:00'),
(1, 3, 3, 85.5, 85, 85, 80, 88, 90, '2024-03-10 12:15:00'),
(2, 2, 4, 78.0, 70, 70, 76, 80, 70, '2024-01-18 09:30:00'),
(2, 2, 5, 82.5, 75, 80, 84, 85, 75, '2024-02-25 10:45:00'),
(2, 1, 6, 90.0, 80, 88, 90, 90, 85, '2024-03-15 11:20:00'),
(3, 5, 7, 94.0, 100, 95, 100, 75, 96, '2024-01-22 15:00:00'),
(3, 5, 8, 91.5, 95, 96, 100, 85, 90, '2024-02-28 16:30:00'),
(3, 5, 9, 89.0, 90, 98, 100, 90, 75, '2024-03-20 17:00:00'),
(4, 2, 10, 75.5, 60, 60, 64, 90, 90, '2024-01-25 08:00:00'),
(4, 2, 11, 80.0, 65, 68, 72, 95, 85, '2024-02-18 09:15:00'),
(4, 2, 12, 83.5, 68, 76, 80, 100, 90, '2024-03-22 10:30:00'),
(5, 7, 13, 86.0, 55, 80, 70, 90, 100, '2024-01-28 13:00:00'),
(5, 7, 14, 84.5, 58, 80, 76, 95, 95, '2024-02-15 14:30:00'),
(5, 7, 15, 88.0, 62, 90, 84, 98, 100, '2024-03-25 15:45:00'),
(1, 3, 16, 89.0, 92, 88, 92, 88, 95, '2024-04-05 09:45:00'),
(2, 3, 17, 86.5, 88, 84, 88, 85, 90, '2024-04-10 10:30:00'),
(3, 5, 18, 93.0, 98, 100, 100, 80, 92, '2024-04-15 11:45:00'),
(4, 2, 19, 81.0, 72, 72, 76, 95, 90, '2024-04-20 12:30:00'),
(5, 7, 20, 87.5, 65, 85, 80, 95, 100, '2024-04-25 13:45:00');

-- =============================================================================
-- VALIDATION QUERIES
-- =============================================================================

-- 1. Verify data integrity
SELECT 'Users' as table_name, COUNT(*) as row_count FROM app_users
UNION ALL
SELECT 'Crops', COUNT(*) FROM crops
UNION ALL
SELECT 'Soil Data', COUNT(*) FROM soil_data
UNION ALL
SELECT 'Weather Data', COUNT(*) FROM weather_data
UNION ALL
SELECT 'Recommendations', COUNT(*) FROM recommendations;

-- 2. Verify foreign key relationships
SELECT 'Recommendations with valid users' as check_name, 
       COUNT(*) as valid_count 
FROM recommendations r 
JOIN app_users u ON r.user_id = u.id;

-- 3. Verify unique constraints
SELECT 'Unique emails', COUNT(DISTINCT email) FROM app_users;
SELECT 'Unique crop names', COUNT(DISTINCT crop_name) FROM crops;

-- 4. Check constraint violations
SELECT 'Crops with invalid ranges' as check_name, COUNT(*) as count 
FROM crops WHERE ideal_n_min > ideal_n_max;

-- =============================================================================
-- ANALYTICAL QUERIES
-- =============================================================================

-- Most recommended crops
SELECT c.crop_name, COUNT(r.id) as total_recommendations, 
       ROUND(AVG(r.confidence_score), 2) as avg_confidence
FROM crops c
LEFT JOIN recommendations r ON c.id = r.crop_id
GROUP BY c.id, c.crop_name
ORDER BY total_recommendations DESC;

-- Farmer activity
SELECT u.name, COUNT(DISTINCT s.id) as soil_tests, 
       COUNT(DISTINCT r.id) as recommendations
FROM app_users u
LEFT JOIN soil_data s ON u.id = s.user_id
LEFT JOIN recommendations r ON u.id = r.user_id
GROUP BY u.id, u.name
ORDER BY soil_tests DESC;

-- Crop suitability for specific soil (N=90, P=42, K=43, pH=6.5)
SELECT crop_name, 
       (CASE WHEN ideal_n_min <= 90 AND ideal_n_max >= 90 THEN 1 ELSE 0 END +
        CASE WHEN ideal_p_min <= 42 AND ideal_p_max >= 42 THEN 1 ELSE 0 END +
        CASE WHEN ideal_k_min <= 43 AND ideal_k_max >= 43 THEN 1 ELSE 0 END +
        CASE WHEN ideal_ph_min <= 6.5 AND ideal_ph_max >= 6.5 THEN 1 ELSE 0 END) as match_count
FROM crops
ORDER BY match_count DESC;
