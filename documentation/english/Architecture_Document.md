# ICY Application Architecture

## Overview

ICY is a cross-platform mobile application built with Flutter, following a BLoC (Business Logic Component) pattern architecture. The backend is built with Node.js and Express, using MongoDB as the database.

## System Architecture

### High-Level Architecture

```mermaid
graph TD
    Client[Flutter Client App]
    Server[Node.js Server]
    Database[(MongoDB)]
    
    Client <--> Server
    Server <--> Database
    
    subgraph "Client Side"
        Client --> UILayer[UI Layer]
        Client --> BlocLayer[BLoC Layer]
        Client --> DataLayer[Data Layer]
        Client --> RepositoryLayer[Repository Layer]
    end
    
    subgraph "Server Side"
        Server --> Routes[API Routes]
        Server --> Controllers[Controllers]
        Server --> Services[Services]
        Server --> Models[Data Models]
        Server --> Middleware[Middleware]
    end
```

### Client-Server Communication Flow

```mermaid
sequenceDiagram
    participant User
    participant UI as UI Components
    participant BLoC as BLoC State Management
    participant Repo as Repository
    participant API as API Service
    participant Server as Node.js Server
    participant DB as MongoDB
    
    User->>UI: Interacts with app
    UI->>BLoC: Dispatches Event
    BLoC->>Repo: Calls repository method
    Repo->>API: Makes API request
    API->>Server: HTTP Request
    Server->>DB: Database query
    DB->>Server: Query results
    Server->>API: HTTP Response
    API->>Repo: Returns response data
    Repo->>BLoC: Returns processed data
    BLoC->>UI: Emits new State
    UI->>User: Updates display
```

## Architecture Layers

### Frontend Architecture (Flutter)

The frontend follows a Clean Architecture approach with the following layers:

1. **Presentation Layer**
   - **Widgets**: UI components
   - **Screens**: Complete app screens composed of widgets
   - **Blocs**: Business Logic Components that manage state

2. **Domain Layer**
   - **Repositories**: Abstract class definitions for data operations
   - **Models**: Data models representing business entities

3. **Data Layer**
   - **Repository Implementations**: Concrete implementations of repositories
   - **Data Sources**: API clients, local storage, etc.
   - **DTOs**: Data Transfer Objects for serialization/deserialization

### State Management

The application uses the BLoC pattern with the following components:

- **Events**: Input events triggered by user interactions
- **States**: Output states representing UI states
- **BLoCs**: Components connecting events to states through business logic

### Backend Architecture (Node.js)

The backend follows an MVC-like pattern:

1. **Routes**: Define API endpoints
2. **Controllers**: Handle request processing and response generation
3. **Models**: MongoDB schema definitions and data models
4. **Services**: Business logic implementation
5. **Middleware**: Request preprocessing (authentication, validation, etc.)
6. **Utils**: Helper functions and utilities

## Key Components and Their Relationships

### Client Components

```mermaid
classDiagram
    class AuthBloc {
        +AuthState state
        +emit(AuthState)
        +login(email, password)
        +signup(userDetails)
        +logout()
    }
    
    class UserModel {
        +id: String
        +name: String
        +email: String
        +avatar: String
        +department: String
    }
    
    class AuthRepository {
        +login(email, password)
        +signup(userDetails)
        +getCurrentUser()
        +logout()
    }
    
    class ApiService {
        +get(endpoint)
        +post(endpoint, data)
        +put(endpoint, data)
        +delete(endpoint)
    }
    
    AuthBloc --> AuthRepository : uses
    AuthRepository --> ApiService : uses
    AuthRepository --> UserModel : creates/returns
```

### Server Components

```mermaid
classDiagram
    class AuthController {
        +login(req, res)
        +signup(req, res)
        +verifyEmail(req, res)
        +logout(req, res)
    }
    
    class UserModel {
        +email: String
        +password: String
        +fullName: String
        +department: String
        +role: String
    }
    
    class AuthMiddleware {
        +protect(req, res, next)
        +authorize(roles)
    }
    
    class DepartmentModel {
        +name: String
        +description: String
        +active: Boolean
    }
    
    class DepartmentController {
        +getDepartments(req, res)
        +createDepartment(req, res)
        +updateDepartment(req, res)
    }
    
    AuthController --> UserModel : uses
    DepartmentController --> DepartmentModel : uses
    AuthMiddleware --> UserModel : verifies
```

## Data Flow

1. User interacts with the UI
2. UI dispatches an Event to the BLoC
3. BLoC processes the event and calls Repository methods
4. Repository communicates with API or local storage
5. API communicates with backend controllers
6. Controllers process requests using Models and Services
7. Response flows back to the UI through the same layers
8. UI updates based on new State from BLoC

## API Endpoints Overview

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/api/v1/auth/login` | POST | User login | No |
| `/api/v1/auth/register` | POST | User registration | No |
| `/api/v1/auth/verify-email` | POST | Email verification | No |
| `/api/v1/departments` | GET | Get all departments | No |
| `/api/v1/departments/:id` | GET | Get department by ID | No |
| `/api/v1/departments` | POST | Create department | Yes (Admin) |
| `/api/v1/surveys` | GET | Get all surveys | Yes |
| `/api/v1/achievements/badges` | GET | Get all badges | Yes |
| `/api/v1/marketplace/items` | GET | Get marketplace items | Yes |

## Key Technologies

### Frontend
- Flutter/Dart
- BLoC for state management
- HTTP package for API communication
- SharedPreferences for local storage
- JSON serialization

### Backend
- Node.js with Express
- MongoDB with Mongoose
- JWT for authentication
- bcrypt for password hashing
- Winston for logging

## Deployment Architecture

- Frontend: Built and deployed to iOS App Store and Google Play Store
- Backend: Deployed to cloud services (e.g., AWS, Azure, or GCP)
- Database: MongoDB Atlas (cloud-hosted MongoDB)

## Security Considerations

- JWT-based authentication
- Password hashing with bcrypt
- HTTPS for all API communications
- Input validation on both client and server
- Rate limiting on sensitive endpoints

## Performance Considerations

- API response caching
- Lazy loading for lists and images
- Pagination for large data sets
- Optimized database queries with proper indexing

## Scalability Considerations

- Stateless backend design for horizontal scaling
- Efficient database schema design
- CDN usage for static assets
