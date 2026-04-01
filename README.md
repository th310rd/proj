You are a Senior Java 21 / Spring Boot Microservices Engineer and Software Architect.

Generate a production-style, clean, modular **Rental Service** for a P2P car-sharing platform similar to Turo, localized for **Uzbekistan**.

Tech constraints:
- Java 21
- Spring Boot 3.x
- PostgreSQL
- Maven
- Spring Data JPA
- Bean Validation
- Lombok
- REST API
- Docker-ready structure
- Clean Architecture / DDD-inspired package organization
- Use DTOs, service layer, repository layer, controller layer
- Code must be suitable for a **graduation project defense**
- Keep the code readable, modular, and easy to explain in viva

Main scope of this service:
1. Rental validation logic
2. Create booking endpoint
3. Booking state transition endpoints

This service must integrate logically with:
- **Car Service**
- **User Service**
- later **Payment Service**
- later **Notification Service**

Do not over-engineer. Keep it professional but defendable for a student graduation project.

==================================================
1. BUSINESS CONTEXT
==================================================
This is a car-sharing platform where:
- Owners register cars in Car Service
- Renters request cars through Rental Service
- Rental Service validates whether booking is allowed
- Owner may approve or reject the booking
- Payment will happen after approval
- Booking moves through clear state transitions

Rental Service must perform a **two-way validation** before creating a booking:
A. Vehicle-side validation
- car must be active
- car must be available for selected dates
- technical inspection must not be expired
- insurance must not be expired

B. Renter-side validation
- driver’s license must not be expired
- renter must satisfy car owner custom rules
  examples:
  - minimum 3 years experience
  - minimum age
  - verified profile required
  - city-only restriction

Important:
- Car Service already stores car data, rules, daily rate, and availability
- User Service already stores renter profile data
- Rental Service should call those services through interfaces/clients
- For now, external calls may be mocked or implemented with interfaces + stub implementations
- Keep external integration clean so Feign/WebClient can be added later

==================================================
2. PROJECT STRUCTURE
==================================================
Create a clean package structure like:

com.example.rentalservice
  - controller
  - service
  - domain
  - dto
  - repository
  - integration
      - car
      - user
  - rules
  - validation
  - exception
  - config

If feature-based organization is better, keep it simple and easy to defend.

==================================================
3. DOMAIN MODEL
==================================================
Design PostgreSQL entities for:

A. Rental
Fields:
- id : UUID
- carId : UUID
- ownerId : UUID
- renterId : UUID
- startDate : LocalDate
- endDate : LocalDate
- requestedDailyRate : BigDecimal
- currency : String
- status : enum
- statusReason : String nullable
- pickupCity : String nullable
- createdAt : LocalDateTime
- updatedAt : LocalDateTime
- version : Long for optimistic locking

B. RentalStatusHistory
Fields:
- id : UUID
- rentalId : UUID
- oldStatus : enum nullable
- newStatus : enum
- changedBy : UUID nullable
- note : String nullable
- changedAt : LocalDateTime

==================================================
4. ENUMS
==================================================
Generate enums for:
- RentalStatus
- ValidationFailureCode

RentalStatus should include at minimum:
- REQUESTED
- PENDING_OWNER_APPROVAL
- APPROVED
- REJECTED
- PAYMENT_PENDING
- CONFIRMED
- ACTIVE
- COMPLETED
- CANCELLED
- DISPUTED

ValidationFailureCode should include examples like:
- CAR_NOT_ACTIVE
- CAR_NOT_AVAILABLE
- TECH_INSPECTION_EXPIRED
- INSURANCE_EXPIRED
- DRIVER_LICENSE_EXPIRED
- RULE_MIN_EXPERIENCE_NOT_MET
- RULE_MIN_AGE_NOT_MET
- RULE_VERIFIED_PROFILE_REQUIRED
- RULE_CITY_ONLY_VIOLATION
- INVALID_DATE_RANGE

==================================================
5. DATABASE DESIGN
==================================================
Generate:
- JPA entities
- repositories
- suggested PostgreSQL schema overview
- useful indexes on:
  - carId
  - renterId
  - ownerId
  - status
  - rentalId in history

==================================================
6. INTEGRATION CONTRACTS
==================================================
Generate DTOs/interfaces for external service calls.

A. Car Service client
Need methods:
- getCarValidationSnapshot(UUID carId)
- isCarAvailable(UUID carId, LocalDate startDate, LocalDate endDate)
- getActiveRules(UUID carId)

Car validation snapshot should contain:
- carId
- ownerId
- dailyRate
- currency
- techInspectionExpiry
- insuranceExpiry
- status / active flag

B. User Service client
Need methods:
- getRenterProfile(UUID renterId)

Renter profile should contain:
- renterId
- dateOfBirth
- driverLicenseExpiry
- drivingExperienceYears
- verifiedProfile
- homeCity optional

Do not call real external services unless as stub/mock implementation.
Use interfaces so real HTTP clients can be plugged in later.

==================================================
7. VALIDATION LOGIC
==================================================
Implement a clean validation flow with dedicated classes.

Create:
- RentalValidationService
- ValidationResult
- ValidationError
- RulesEngine

Validation rules:
1. startDate must be before endDate
2. rental must be at least 1 day
3. car must be active
4. car must be available for requested date range
5. technical inspection must not be expired
6. insurance must not be expired
7. renter driver license must not be expired
8. evaluate owner custom rules:
   - MIN_DRIVER_EXPERIENCE_YEARS with GTE
   - MIN_AGE with GTE
   - REQUIRES_VERIFIED_PROFILE with BOOLEAN_TRUE
   - CITY_ONLY with EQ / city match
   - NO_BORDER_CROSSING can produce warning or be documented for future geo-tracking integration

Requirements:
- return all validation errors, not only first error
- keep validation explainable
- use dedicated rule evaluation methods
- design so new rule types can be added later

==================================================
8. CREATE BOOKING ENDPOINT
==================================================
Implement:

POST /api/rentals

Request body:
- carId
- renterId
- startDate
- endDate
- pickupCity optional

Behavior:
1. validate request
2. fetch car snapshot from Car Service
3. fetch renter profile from User Service
4. validate booking
5. if validation fails, return structured error response
6. if validation passes, create Rental
7. initial status should be:
   - PENDING_OWNER_APPROVAL

Response should include:
- rentalId
- carId
- ownerId
- renterId
- dates
- requestedDailyRate
- currency
- status
- createdAt

==================================================
9. STATE TRANSITION ENDPOINTS
==================================================
Implement state transition APIs.

A. Approve booking
POST /api/rentals/{rentalId}/approve

Behavior:
- allowed only from PENDING_OWNER_APPROVAL
- move to APPROVED
- optionally auto-move to PAYMENT_PENDING if you think it is better, but document clearly

B. Reject booking
POST /api/rentals/{rentalId}/reject

Request body:
{
  "reason": "Owner rejected due to scheduling conflict"
}

Behavior:
- allowed only from PENDING_OWNER_APPROVAL
- move to REJECTED
- save statusReason

C. Mark payment pending
POST /api/rentals/{rentalId}/payment-pending

Behavior:
- allowed only from APPROVED
- move to PAYMENT_PENDING

D. Confirm booking
POST /api/rentals/{rentalId}/confirm

Behavior:
- allowed only from PAYMENT_PENDING
- move to CONFIRMED

E. Start rental
POST /api/rentals/{rentalId}/start

Behavior:
- allowed only from CONFIRMED
- move to ACTIVE

F. Complete rental
POST /api/rentals/{rentalId}/complete

Behavior:
- allowed only from ACTIVE
- move to COMPLETED

G. Cancel rental
POST /api/rentals/{rentalId}/cancel

Request body:
{
  "reason": "Renter cancelled before handover"
}

Behavior:
- allowed from PENDING_OWNER_APPROVAL, APPROVED, PAYMENT_PENDING, CONFIRMED
- move to CANCELLED
- save reason

H. Open dispute
POST /api/rentals/{rentalId}/dispute

Request body:
{
  "reason": "Vehicle returned with damage"
}

Behavior:
- allowed from ACTIVE or COMPLETED
- move to DISPUTED

==================================================
10. STATE TRANSITION RULES
==================================================
Implement a clear transition policy.

Allowed transitions:
- null -> PENDING_OWNER_APPROVAL when booking is created
- PENDING_OWNER_APPROVAL -> APPROVED
- PENDING_OWNER_APPROVAL -> REJECTED
- APPROVED -> PAYMENT_PENDING
- PAYMENT_PENDING -> CONFIRMED
- CONFIRMED -> ACTIVE
- ACTIVE -> COMPLETED
- PENDING_OWNER_APPROVAL -> CANCELLED
- APPROVED -> CANCELLED
- PAYMENT_PENDING -> CANCELLED
- CONFIRMED -> CANCELLED
- ACTIVE -> DISPUTED
- COMPLETED -> DISPUTED

Rejected transitions must throw business exception.

Create:
- RentalStateMachine or RentalTransitionPolicy

Also write history records into RentalStatusHistory on every state change.

==================================================
11. DTOs
==================================================
Generate DTOs for:
- CreateRentalRequest
- RentalResponse
- RejectRentalRequest
- CancelRentalRequest
- DisputeRentalRequest
- ValidationResultResponse
- ValidationErrorResponse
- StatusTransitionResponse

Use Bean Validation annotations.

==================================================
12. SERVICE LAYER
==================================================
Create services with clear responsibilities:

- RentalApplicationService
  - createRental
  - approveRental
  - rejectRental
  - markPaymentPending
  - confirmRental
  - startRental
  - completeRental
  - cancelRental
  - disputeRental

- RentalValidationService
  - validate(CreateRentalRequest)

- RulesEngine
  - evaluateRules(...)

- RentalStatusHistoryService
  - recordStatusChange(...)

- RentalTransitionPolicy
  - ensureTransitionAllowed(from, to)

Keep methods clean and understandable.

==================================================
13. CONTROLLER LAYER
==================================================
Generate REST controllers for:
- create rental
- get rental by id
- get rentals by renter
- get rentals by owner
- all state transition endpoints

Possible endpoints:
- GET /api/rentals/{rentalId}
- GET /api/rentals/renter/{renterId}
- GET /api/rentals/owner/{ownerId}

==================================================
14. EXCEPTION HANDLING
==================================================
Generate:
- ResourceNotFoundException
- BusinessValidationException
- InvalidRentalStateException
- GlobalExceptionHandler with @RestControllerAdvice

Validation failure responses should be clean JSON like:
{
  "message": "Rental validation failed",
  "errors": [
    {
      "code": "DRIVER_LICENSE_EXPIRED",
      "message": "Renter driver's license is expired"
    }
  ],
  "timestamp": "..."
}

==================================================
15. CODE STYLE
==================================================
Requirements:
- clean code
- modular
- no unnecessary complexity
- beginner-defensible but professional
- use comments only where useful
- methods should be explainable line by line in defense
- do not skip implementations
- provide full code, not only interfaces/stubs unless clearly marked as integration placeholder

==================================================
16. OUTPUT FORMAT
==================================================
Return the result in this exact order:

1. Short architecture explanation
2. Package structure
3. Entity classes
4. Enums
5. DTO classes
6. Integration DTOs and client interfaces
7. Validation classes
8. State transition policy
9. Repository interfaces
10. Service classes
11. Controller classes
12. Exception handling
13. Example application.yml
14. Example PostgreSQL schema overview
15. Example request/response JSON
16. Short explanation of how Payment Service and Notification Service will integrate later

==================================================
17. IMPORTANT IMPLEMENTATION NOTES
==================================================
- Use Java 21 features where appropriate, but do not make code too advanced
- Use LocalDate for booking dates and expiry dates
- Use LocalDateTime for audit fields
- Use UUID properly
- Use BigDecimal for money
- Implement optimistic locking in Rental entity
- Keep external integrations replaceable
- Make sure code compiles logically
- Do not omit key classes
- If output is too long, continue in multiple parts without skipping code

Now generate the full Rental Service implementation.
