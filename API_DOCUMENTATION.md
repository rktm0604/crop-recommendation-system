# SmartCrop - REST API Documentation

## Base URL
```
http://localhost:8080/api
```

## Authentication
All endpoints (except `/auth/login`, `/auth/register`, and public routes) require JWT authentication.

### Headers
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

---

## Authentication Endpoints

### 1. Login
**POST** `/api/auth/login`

Request:
```json
{
  "email": "farmer@crop.com",
  "password": "password123"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "farmer@crop.com",
  "name": "John Farmer",
  "role": "FARMER",
  "userId": 1
}
```

---

### 2. Register
**POST** `/api/auth/register`

Request:
```json
{
  "name": "New Farmer",
  "email": "newfarmer@crop.com",
  "password": "password123"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "newfarmer@crop.com",
  "name": "New Farmer",
  "role": "FARMER",
  "userId": 6
}
```

---

## Soil Data Endpoints

### 3. Submit Soil Data
**POST** `/api/soil`

Request:
```json
{
  "nitrogen": 90,
  "phosphorus": 42,
  "potassium": 43,
  "ph": 6.5,
  "moisture": 55,
  "location": "Delhi"
}
```

Response:
```json
{
  "id": 21,
  "userId": 1,
  "nitrogen": 90,
  "phosphorus": 42,
  "potassium": 43,
  "ph": 6.5,
  "moisture": 55,
  "location": "Delhi",
  "recordedDate": "2024-05-15T10:30:00"
}
```

---

### 4. Get My Soil Data
**GET** `/api/soil`

Query Parameters:
- `page` (optional): Page number (default: 0)
- `size` (optional): Page size (default: 10)

Response:
```json
{
  "content": [
    {
      "id": 1,
      "nitrogen": 90,
      "phosphorus": 42,
      "potassium": 43,
      "ph": 6.5,
      "moisture": 55,
      "recordedDate": "2024-01-15T09:30:00"
    }
  ],
  "totalPages": 3,
  "totalElements": 21
}
```

---

## Recommendation Endpoints

### 5. Get Crop Recommendation
**POST** `/api/recommendation`

Request:
```json
{
  "soilData": {
    "nitrogen": 90,
    "phosphorus": 42,
    "potassium": 43,
    "ph": 6.5,
    "moisture": 50
  },
  "location": "Delhi"
}
```

Response:
```json
{
  "cropId": 1,
  "cropName": "Rice",
  "confidenceScore": 92.5,
  "nScore": 95,
  "pScore": 88,
  "kScore": 86,
  "phScore": 90,
  "rainfallScore": 80,
  "recommendationDate": "2024-05-15T10:30:00"
}
```

---

### 6. Get My Recommendations
**GET** `/api/recommendation`

Query Parameters:
- `page` (optional): Page number
- `size` (optional): Page size

Response:
```json
{
  "content": [
    {
      "id": 1,
      "cropName": "Rice",
      "confidenceScore": 92.5,
      "recommendationDate": "2024-01-15T10:00:00"
    }
  ],
  "totalPages": 2,
  "totalElements": 15
}
```

---

## Crop Endpoints

### 7. Get All Crops
**GET** `/api/crops`

Response:
```json
[
  {
    "id": 1,
    "cropName": "Rice",
    "idealNMin": 80,
    "idealNMax": 120,
    "idealPMin": 30,
    "idealPMax": 50,
    "idealKMin": 30,
    "idealKMax": 50,
    "idealPhMin": 5.0,
    "idealPhMax": 7.0,
    "idealRainfallMin": 150,
    "idealRainfallMax": 300
  }
]
```

---

## Weather Endpoints

### 8. Get Current Weather
**GET** `/api/weather/current?location=Delhi`

Response:
```json
{
  "temperature": 28.5,
  "humidity": 75,
  "rainfall": 120,
  "location": "Delhi",
  "recordedDate": "2024-05-15T06:00:00"
}
```

---

## Analytics Endpoints

### 9. Get Farmer Dashboard
**GET** `/api/dashboard/farmer`

Response:
```json
{
  "totalSoilTests": 21,
  "totalRecommendations": 15,
  "soilTrends": {
    "labels": ["Jan", "Feb", "Mar", "Apr"],
    "nitrogen": [90, 85, 95, 92],
    "phosphorus": [42, 38, 45, 44],
    "potassium": [43, 40, 48, 46]
  },
  "recentRecommendations": [
    {
      "cropName": "Rice",
      "confidenceScore": 92.5,
      "date": "2024-01-15"
    }
  ]
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "status": 400,
  "message": "Invalid input data",
  "timestamp": "2024-05-15T10:30:00"
}
```

### 401 Unauthorized
```json
{
  "status": 401,
  "message": "Invalid or expired token",
  "timestamp": "2024-05-15T10:30:00"
}
```

### 404 Not Found
```json
{
  "status": 404,
  "message": "Resource not found",
  "timestamp": "2024-05-15T10:30:00"
}
```

### 500 Internal Server Error
```json
{
  "status": 500,
  "message": "Internal server error",
  "timestamp": "2024-05-15T10:30:00"
}
```

---

## cURL Examples

### Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"farmer@crop.com","password":"password123"}'
```

### Get Recommendation (with token)
```bash
# First, get token from login response
curl -X POST http://localhost:8080/api/recommendation \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"soilData":{"nitrogen":90,"phosphorus":42,"potassium":43,"ph":6.5,"moisture":50}}'
```

### Get My Soil Data
```bash
curl -X GET http://localhost:8080/api/soil \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```
