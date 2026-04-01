You are a Senior Software Architect, Senior Java 21 Microservices Engineer, and Solution Designer.

I already have or am generating these services for a P2P car-sharing platform similar to Turo, localized for **Uzbekistan**:

1. User Service
2. Car Service
3. Listing Service
4. Rental Service
5. Payment Service
6. Notification Service
7. Geo-Tracking Service

Your task is to help me **merge them into one well-designed microservice architecture** at the system level.

Important:
- Do NOT merge them into one monolith
- Keep them as separate microservices
- “Merge” here means:
  - align the service boundaries
  - define communication contracts
  - remove duplicated responsibilities
  - design shared flows between services
  - standardize architecture, DTO conventions, database ownership, and integration style
  - make the entire system look like one coherent, professional graduation project

Tech stack:
- Java 21
- Spring Boot 3.x
- PostgreSQL
- Maven
- React + Tailwind CSS frontend
- REST-based microservices
- Docker / Docker Compose ready
- suitable for later API Gateway integration
- suitable for graduation defense

Main business domain:
A localized Uzbekistan P2P car-sharing platform where:
- owners register cars
- renters search and book cars
- system validates both renter and vehicle
- booking goes through approval/payment/tracking/notification lifecycle
- escrow deposit is held during the rental
- live or simulated geo-tracking is supported
- notifications are sent to renter and owner

==================================================
1. GOAL
==================================================
Design the entire system as a **clean, professional microservice architecture**.

I want you to produce a **system-level architecture and integration blueprint** for these services:
- User Service
- Car Service
- Listing Service
- Rental Service
- Payment Service
- Notification Service
- Geo-Tracking Service

The result must feel like:
- one consistent platform
- professionally architected
- modular
- scalable enough for a graduation project
- easy to explain during defense

==================================================
2. WHAT I NEED FROM YOU
==================================================
Please generate a complete architecture blueprint that includes:

A. Final service responsibilities
For each microservice, clearly define:
- what it owns
- what it should NOT own
- what data it stores
- what APIs it exposes
- what other services depend on it

B. Shared end-to-end business flows
Design the main platform flows:
1. User registration flow
2. Owner car registration flow
3. Listing search flow
4. Booking request flow
5. Booking approval flow
6. Payment + escrow flow
7. Rental start flow
8. Geo-tracking flow
9. Rental completion flow
10. Escrow release / dispute flow
11. Notification flow across all events

C. Inter-service communication design
Specify:
- which services call which services
- request/response flow
- synchronous REST calls
- where asynchronous events should be introduced later
- what should remain source of truth vs projection/read model

D. Data ownership rules
For each domain object, define exactly which service owns it.
Examples:
- user profile
- driver license
- car
- car rules
- availability blocks
- listing projection
- rental booking
- payment
- escrow
- notification
- location history

E. API contract consistency
Standardize:
- endpoint naming conventions
- DTO naming
- error response format
- success response format
- pagination style
- audit field naming
- ID usage (UUID)
- date/time conventions

F. Shared architecture standards
Define:
- package style for every service
- service layer conventions
- validation style
- exception handling style
- integration client style
- mapper style
- audit fields
- optimistic locking usage
- configuration style

G. Deployment architecture
Design:
- docker-compose level overview
- service-to-service connectivity
- PostgreSQL strategy:
  - one database per service
  - or separate schemas
- recommend the best graduation-project-friendly option and explain why
- optional API Gateway
- optional service discovery
- keep it realistic, not overcomplicated

H. Defense-ready architectural decisions
Explain:
- why each service exists
- why Listing Service is separate from Rental Service
- why Payment/Escrow is separate from Rental
- why Notification is separate
- why Geo-Tracking is separate
- why Car Service owns rules
- why Rental Service is the validation and booking core

==================================================
3. SERVICES TO ALIGN
==================================================
Use these responsibilities as the baseline and improve/refine them.

--------------------------------------------------
A. User Service
--------------------------------------------------
Current purpose:
- user registration
- profile management
- driver license data
- driving experience
- verified profile
- renter profile / owner profile data

Likely ownership:
- user
- user profile
- driver license
- roles

--------------------------------------------------
B. Car Service
--------------------------------------------------
Current purpose:
- vehicle registration
- vehicle updates
- daily rent rate
- car rules
- document expiry tracking
- basic availability blocks

Likely ownership:
- cars
- car rules
- availability blocks
- vehicle insurance expiry
- technical inspection expiry

--------------------------------------------------
C. Listing Service
--------------------------------------------------
Current purpose:
- display eligible cars
- search/filter cars
- pre-filter by renter qualifications
- projection/read model for fast listing search

Likely ownership:
- car listing projection
- rule snapshots for search/read optimization

--------------------------------------------------
D. Rental Service
--------------------------------------------------
Current purpose:
- booking validation
- create booking
- state transitions
- owner approval/rejection
- booking lifecycle

Likely ownership:
- rentals
- rental status history
- booking validation orchestration

--------------------------------------------------
E. Payment Service
--------------------------------------------------
Current purpose:
- pricing calculation
- payment lifecycle
- discounts
- penalties
- escrow
- escrow ledger

Likely ownership:
- payments
- escrow accounts
- escrow ledger

--------------------------------------------------
F. Notification Service
--------------------------------------------------
Current purpose:
- in-app notification
- simulated email
- simulated SMS
- message templates
- communication between renter and owner

Likely ownership:
- notifications
- notification templates
- communication messages

--------------------------------------------------
G. Geo-Tracking Service
--------------------------------------------------
Current purpose:
- current vehicle location
- route history
- simulated live tracking
- geofence awareness

Likely ownership:
- tracking sessions
- location points
- geofence snapshots/events

==================================================
4. MAIN FUNCTIONAL RULES
==================================================
Your architecture must support these rules:

1. User Service is the source of truth for user identity and license data
2. Car Service is the source of truth for car data, daily rate, rules, and availability blocks
3. Listing Service is read-optimized and should not make final booking decisions
4. Rental Service performs the final booking validation
5. Payment Service owns financial calculations and escrow lifecycle
6. Geo-Tracking Service only works for eligible/active rentals
7. Notification Service can be triggered by booking/payment/tracking events
8. Each service should own its own database
9. Services should not directly modify each other’s database
10. Integration must remain simple enough for a student project

==================================================
5. IMPORTANT ARCHITECTURE DECISIONS TO MAKE
==================================================
Please make and document decisions for:

A. Should Listing Service store full copies of car data or only listing projections?
B. Should Rental Service call Car Service and User Service synchronously during validation?
C. Should Payment Service calculate pricing from Rental snapshot or store duplicated booking amounts?
D. Should Geo-Tracking start from Rental status CONFIRMED or ACTIVE?
E. When should Notification Service be called directly, and when should events be used?
F. Which services should expose public APIs to frontend directly, and which should ideally go behind an API Gateway?
G. Should Car Service or Rental Service own date-range availability truth?
H. How should rule evaluation be split between Listing Service and Rental Service?
I. Which data should be duplicated as snapshot data for audit/history reasons?
J. What is the simplest good production-like architecture for a graduation defense?

==================================================
6. SYSTEM FLOWS TO DESIGN
==================================================
Design these flows step by step.

--------------------------------------------------
FLOW 1: User registration
--------------------------------------------------
Frontend -> User Service
Include:
- default roles
- profile creation
- driver license later or during registration

--------------------------------------------------
FLOW 2: Owner registers a car
--------------------------------------------------
Frontend -> Car Service
Include:
- car creation
- document expiries
- daily rate
- rules

--------------------------------------------------
FLOW 3: Renter searches for available cars
--------------------------------------------------
Frontend -> Listing Service
Listing Service -> User Service
Listing Service -> Car Service
Explain:
- search filtering
- rule pre-checking
- date availability pre-checking
- result projection

--------------------------------------------------
FLOW 4: Renter creates booking request
--------------------------------------------------
Frontend -> Rental Service
Rental Service -> Car Service
Rental Service -> User Service
Explain:
- final validation
- why validation is repeated here even if Listing Service already filtered

--------------------------------------------------
FLOW 5: Owner approves booking
--------------------------------------------------
Frontend -> Rental Service
Then what happens next?

--------------------------------------------------
FLOW 6: Payment and escrow
--------------------------------------------------
Frontend or Rental flow -> Payment Service
Payment Service -> Rental Service
Explain:
- pricing calculation
- payment creation
- authorization
- capture
- escrow hold

--------------------------------------------------
FLOW 7: Rental start
--------------------------------------------------
Rental -> Geo-Tracking + Notification
Explain:
- when tracking session begins
- who is notified

--------------------------------------------------
FLOW 8: Rental completion
--------------------------------------------------
Rental -> Payment -> Geo-Tracking -> Notification
Explain:
- completion
- escrow release
- dispute handling possibility

--------------------------------------------------
FLOW 9: Dispute / damage case
--------------------------------------------------
Rental or Payment -> Notification
Explain:
- escrow deduction
- disputed state
- notifications

==================================================
7. STANDARDIZED OUTPUT REQUIRED
==================================================
Return the result in this exact order:

1. High-level architecture overview
2. Final responsibility matrix for all services
3. Data ownership matrix
4. Recommended inter-service communication map
5. Main end-to-end flows
6. Shared API and DTO conventions
7. Error response standard
8. Shared package/module structure standard
9. Database strategy recommendation
10. Docker/deployment architecture overview
11. Event-driven extension plan for later
12. Graduation defense explanation section
13. Recommended implementation order
14. Biggest architecture mistakes to avoid

==================================================
8. OUTPUT QUALITY RULES
==================================================
Requirements:
- Keep the architecture realistic and defendable
- Do not overcomplicate with Kubernetes, Kafka, service mesh, distributed tracing, etc. unless mentioned as future optional improvements
- Prefer synchronous REST for current version, but mention where events can later help
- Make strong architectural decisions instead of giving vague options
- Explain tradeoffs clearly
- Keep naming consistent
- Use microservice best practices, but adapted for a student graduation project
- Make the answer coherent enough that I can directly use it to guide Codex and my implementation

==================================================
9. VERY IMPORTANT
==================================================
Please do NOT generate only theory.
I need a practical blueprint that I can implement.

Make the answer concrete and specific:
- concrete service boundaries
- concrete flows
- concrete ownership
- concrete integration rules
- concrete deployment recommendation

Now generate the full architecture blueprint for merging all these services into one well-designed microservice system.
