# Fraud Detection System for Online Transactions

A comprehensive Spring Boot application that uses **Machine Learning** and **Rule-Based** approaches to detect fraudulent transactions in real-time for online payment systems including QR code payments.

## Features

### 1. **Hybrid Fraud Detection**
- **ML-Based Detection**: Neural network model for pattern recognition
- **Rule-Based Detection**: Business rules for known fraud patterns
- **Behavioral Analysis**: User behavior tracking and anomaly detection

### 2. **Real-Time Fraud Prevention**
- Pre-transaction fraud checks (before payment)
- Post-transaction fraud verification (after QR scan)
- Immediate blocking of high-risk transactions

### 3. **User Behavior Tracking**
- Transaction pattern analysis
- Time-based patterns (preferred hours/days)
- Location-based patterns
- Device fingerprinting
- Merchant category preferences

### 4. **Fraud Indicators**
- Unusual transaction amounts
- High transaction velocity
- New device/location detection
- Unusual transaction times
- Round amount detection
- Failed attempt tracking

### 5. **Risk Scoring**
- Dynamic trust score for users (0-100)
- Transaction fraud score (0-1)
- Risk levels: LOW, MEDIUM, HIGH, CRITICAL
- Automated recommendations: APPROVE, REVIEW, DECLINE

## Architecture

```
┌─────────────────┐
│  Client App     │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│   Spring Boot REST API              │
│  ┌──────────────────────────────┐  │
│  │  Transaction Controller       │  │
│  └──────────┬───────────────────┘  │
│             │                       │
│  ┌──────────▼───────────────────┐  │
│  │  Fraud Detection Service     │  │
│  │  ┌────────────┬────────────┐ │  │
│  │  │ ML Model   │ Rule-Based │ │  │
│  │  └────────────┴────────────┘ │  │
│  └──────────────────────────────┘  │
│             │                       │
│  ┌──────────▼───────────────────┐  │
│  │  User Behavior Service       │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│   PostgreSQL    │
│   Database      │
└─────────────────┘
```

## Tech Stack

- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Data JPA**
- **PostgreSQL** (or H2 for testing)
- **DeepLearning4J** - Neural Network ML framework
- **Apache Commons Math** - Statistical calculations
- **Redis** - Caching (optional)
- **Lombok** - Reduce boilerplate code

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- PostgreSQL 12+ (or use H2 for testing)
- Redis (optional, for caching)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd fraud-detection-system
```

### 2. Configure Database

Edit `src/main/resources/application.properties`:

```properties
# For PostgreSQL
spring.datasource.url=jdbc:postgresql://localhost:5432/frauddb
spring.datasource.username=your_username
spring.datasource.password=your_password

# For H2 (testing)
# spring.datasource.url=jdbc:h2:mem:frauddb
# spring.datasource.driver-class-name=org.h2.Driver
```

### 3. Create Database

```sql
CREATE DATABASE frauddb;
```

### 4. Build the Project

```bash
mvn clean install
```

### 5. Run the Application

```bash
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

## API Endpoints

### User Management

#### Register User
```http
POST /api/users/register
Content-Type: application/json

{
  "email": "user@example.com",
  "phoneNumber": "+1234567890",
  "name": "John Doe",
  "password": "securePassword123"
}
```

#### Get User
```http
GET /api/users/{userId}
```

### Transaction Processing

#### Process Transaction (Pre-Fraud Check)
```http
POST /api/transactions
Content-Type: application/json

{
  "userId": "USR-ABC12345",
  "amount": 1500.00,
  "currency": "USD",
  "transactionType": "UPI",
  "merchantId": "MERCH-001",
  "merchantName": "Amazon",
  "merchantCategory": "E-COMMERCE",
  "ipAddress": "192.168.1.1",
  "country": "USA",
  "city": "New York",
  "latitude": 40.7128,
  "longitude": -74.0060,
  "deviceId": "DEVICE-XYZ789",
  "deviceType": "MOBILE",
  "deviceFingerprint": "abc123def456",
  "userAgent": "Mozilla/5.0..."
}
```

**Response:**
```json
{
  "transactionId": "TXN-A1B2C3D4",
  "userId": "USR-ABC12345",
  "amount": 1500.00,
  "currency": "USD",
  "transactionType": "UPI",
  "status": "APPROVED",
  "fraudStatus": "SAFE",
  "fraudScore": 0.15,
  "fraudReason": "Transaction appears normal",
  "approved": true,
  "message": "Transaction approved successfully",
  "transactionTime": "2024-02-06T10:30:00",
  "fraudAnalysis": {
    "mlScore": 0.12,
    "ruleBasedScore": 0.20,
    "riskLevel": "LOW",
    "triggeredRules": [],
    "recommendation": "APPROVE",
    "behaviorAnalysis": {
      "unusualAmount": false,
      "unusualTime": false,
      "unusualLocation": false,
      "unusualDevice": false,
      "highVelocity": false,
      "deviationFromNormal": 0.5
    }
  }
}
```

#### Process QR Code Transaction
```http
POST /api/transactions/qr
Content-Type: application/json

{
  "userId": "USR-ABC12345",
  "amount": 500.00,
  "currency": "USD",
  "transactionType": "QR_CODE",
  "qrCodeId": "QR-123456",
  "qrCodeData": "merchant_upi_id@bank",
  "deviceId": "DEVICE-XYZ789",
  "ipAddress": "192.168.1.1"
}
```

#### Verify QR Transaction (Post-Scan)
```http
POST /api/transactions/qr/verify?qrCodeId=QR-123456&userId=USR-ABC12345
```

#### Get User Transactions
```http
GET /api/transactions/user/{userId}
```

### Fraud Detection

#### Get User Fraud Statistics
```http
GET /api/fraud/statistics/{userId}
```

**Response:**
```json
{
  "userId": "USR-ABC12345",
  "trustScore": 95.5,
  "totalFraudAlerts": 2,
  "fraudulentTransactions": 1,
  "accountLocked": false
}
```

#### Get Fraud Alerts
```http
GET /api/fraud/alerts/{userId}
```

#### Get Unreviewed Alerts
```http
GET /api/fraud/alerts/unreviewed
```

#### Review Fraud Alert
```http
PUT /api/fraud/alerts/{alertId}/review?reviewedBy=admin&confirmedFraud=true&comments=Verified fraud
```

## Fraud Detection Rules

### Rule-Based Detection

1. **High Amount Rule**: Flags transactions > 3 standard deviations from user's average
2. **Velocity Rule**: Flags > 10 transactions/hour or > 50/day
3. **Unusual Time Rule**: Flags transactions between 2 AM - 6 AM
4. **New Location Rule**: Flags transactions from new countries
5. **New Device Rule**: Flags transactions from unrecognized devices
6. **Low Trust Score**: Flags users with trust score < 50
7. **New Account**: Flags transactions from accounts < 7 days old
8. **Failed Attempts**: Flags accounts with > 3 recent failed attempts
9. **Round Amount**: Flags suspiciously round amounts (1000, 5000)
10. **Amount Limit**: Flags transactions exceeding configured limit

### ML Model Features

The neural network model uses 20 features:
- Transaction amount (normalized)
- Amount ratio to user average
- Hour of day
- Day of week
- Unusual time flag
- Transactions in last hour
- Transactions in last day
- Velocity score
- Unusual location flag
- Device type
- Transaction type
- User consistency score
- Failed attempts
- And more...

## How It Works

### Transaction Flow

1. **User initiates transaction** (before payment or QR scan)
2. **System extracts features** from transaction data
3. **Behavioral enrichment** - adds user behavior patterns
4. **Rule-based check** - applies business rules
5. **ML prediction** - neural network analyzes patterns
6. **Score combination** - 60% ML + 40% Rules
7. **Risk assessment** - determines risk level
8. **Decision** - APPROVE, REVIEW, or DECLINE
9. **Update user profile** - adjusts trust score
10. **Alert creation** - if suspicious activity detected

### Fraud Score Interpretation

- **0.0 - 0.4**: SAFE - Transaction approved
- **0.4 - 0.7**: SUSPICIOUS - Flagged for review
- **0.7 - 0.9**: FRAUD - Transaction declined
- **0.9 - 1.0**: CRITICAL - Account blocked

### Trust Score System

- New users start with 100 points
- Successful transactions: +0.5 points
- Suspicious activity: -5 points
- Confirmed fraud: -20 points
- Account locked when fraud detected repeatedly

## Configuration

Key configuration properties in `application.properties`:

```properties
# Fraud Detection Thresholds
fraud.max.transaction.amount=10000
fraud.max.transactions.per.hour=10
fraud.max.transactions.per.day=50

# ML Model Settings
ml.model.path=models/fraud_detection_model.zip
ml.model.confidence.threshold=0.7
ml.model.retrain.threshold=1000

# Feature Flags
fraud.velocity.check.enabled=true
fraud.location.check.enabled=true
fraud.device.fingerprint.enabled=true
```

## Testing

### Sample Test Cases

```bash
# Test 1: Normal transaction
curl -X POST http://localhost:8080/api/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USR-TEST001",
    "amount": 50.00,
    "currency": "USD",
    "transactionType": "UPI",
    "deviceId": "DEVICE-001",
    "ipAddress": "192.168.1.1"
  }'

# Test 2: High amount (fraud trigger)
curl -X POST http://localhost:8080/api/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USR-TEST001",
    "amount": 50000.00,
    "currency": "USD",
    "transactionType": "UPI",
    "deviceId": "DEVICE-001",
    "ipAddress": "192.168.1.1"
  }'

# Test 3: New device (fraud trigger)
curl -X POST http://localhost:8080/api/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "USR-TEST001",
    "amount": 100.00,
    "currency": "USD",
    "transactionType": "UPI",
    "deviceId": "DEVICE-NEW-999",
    "ipAddress": "192.168.1.1"
  }'
```

## Database Schema

### Main Tables

- **users**: User account information and trust scores
- **transactions**: All transaction records with fraud scores
- **user_behavior**: Behavioral patterns and statistics
- **fraud_alerts**: Fraud detection alerts for review

## Machine Learning Model

### Model Architecture

- **Input Layer**: 20 features
- **Hidden Layer 1**: 64 neurons (ReLU activation)
- **Hidden Layer 2**: 32 neurons (ReLU activation)
- **Output Layer**: 2 neurons (Softmax - Fraud/Not Fraud)

### Training

The model is initially created with random weights. To train with real data:

```java
// Collect labeled transaction data
List<Transaction> transactions = ...;
List<Boolean> labels = ...; // true = fraud, false = legitimate

// Train the model
mlFraudDetectionService.trainModel(transactions, labels);
```

### Model Updates

- Model automatically saves after training
- Retraining triggered after N new fraud confirmations
- Can be manually retrained via admin endpoint

## Security Considerations

⚠️ **Important for Production:**

1. **Password Hashing**: Implement BCrypt for password storage
2. **JWT Authentication**: Add JWT tokens for API security
3. **HTTPS**: Enable SSL/TLS
4. **Rate Limiting**: Add request rate limiting
5. **Input Validation**: Enhanced validation for all inputs
6. **SQL Injection**: Use parameterized queries (already implemented)
7. **XSS Protection**: Implement content security policies

## Monitoring & Alerts

### Metrics to Monitor

- Fraud detection accuracy
- False positive rate
- False negative rate
- Average processing time
- Transaction volume
- Alert volume

### Integration Options

- Email alerts for high-risk transactions
- SMS notifications for account locks
- Webhook notifications to external systems
- Dashboard for real-time monitoring

## Future Enhancements

1. **Advanced ML Models**: LSTM, Transformer models
2. **Graph-Based Fraud Detection**: Network analysis
3. **Real-time Streaming**: Apache Kafka integration
4. **A/B Testing**: Model comparison framework
5. **Explainable AI**: Feature importance visualization
6. **Multi-currency Support**: Enhanced currency handling
7. **Geo-fencing**: Advanced location validation
8. **Biometric Integration**: Face/fingerprint verification

## Troubleshooting

### Common Issues

**Issue**: Model not loading
- **Solution**: Check model path in application.properties

**Issue**: High false positive rate
- **Solution**: Adjust confidence threshold or retrain model

**Issue**: Slow transaction processing
- **Solution**: Enable Redis caching, optimize database queries

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

MIT License

## Support

For issues and questions:
- Create GitHub issue
- Email: support@frauddetection.com
- Documentation: [Wiki](wiki-url)

---

**Built with ❤️ using Spring Boot and Machine Learning**