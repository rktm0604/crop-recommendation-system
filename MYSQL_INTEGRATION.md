# MySQL Integration for Crop Recommendation System

This document outlines the steps to set up and integrate MySQL with the Crop Recommendation System project.

## 1. Installation
Make sure you have MySQL installed on your local development environment. You can download it from the [official MySQL website](https://www.mysql.com/downloads/).

## 2. Configuration Steps
1. Open the MySQL Workbench or your command-line interface for MySQL.
2. Create a new database for the Crop Recommendation System by executing:
   ```sql
   CREATE DATABASE crop_recommendation;
   ```
3. Create a user and grant privileges:
   ```sql
   CREATE USER 'your_username'@'localhost' IDENTIFIED BY 'your_password';
   GRANT ALL PRIVILEGES ON crop_recommendation.* TO 'your_username'@'localhost';
   FLUSH PRIVILEGES;
   ```

## 3. Connection Details
In your application, you will need to set up the database connection using the following details:
- **Host:** localhost
- **Username:** your_username
- **Password:** your_password
- **Database Name:** crop_recommendation

## 4. Database Schema
Below is a sample schema for the Crop Recommendation System:
```sql
CREATE TABLE crops (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50),
    yield_per_acre DECIMAL(10, 2)
);

CREATE TABLE recommendations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    crop_id INT,
    season VARCHAR(50),
    FOREIGN KEY (crop_id) REFERENCES crops(id)
);
```  

## 5. Local Development Setup Instructions
1. Clone the project repository:
   ```bash
   git clone https://github.com/rktm0604/crop-recommendation-system.git
   cd crop-recommendation-system
   ```
2. Install necessary dependencies (if applicable).
3. Ensure your database is running and accessible.
4. Update the database connection settings in your project configuration file (e.g., `.env`).

By following these instructions, you should be able to set up MySQL and integrate it with the Crop Recommendation System project successfully.