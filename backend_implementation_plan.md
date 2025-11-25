# Backend Phase 1 Implementation Plan (NestJS)

## Goal
Initialize a robust, scalable NestJS backend and implement Phase 1 APIs (Authentication & Profile Management) to replace the legacy backend. This phase focuses on fixing architectural flaws like the mandatory password on profile update and ensuring secure data handling.

## User Review Required
> [!IMPORTANT]
> **Database Choice**: I will use **SQLite** for local development to keep it simple and portable. We can easily switch to PostgreSQL for production.
> **ORM**: I recommend **Prisma** for its type safety and ease of use, or **TypeORM** if you prefer traditional class-based entities. I will proceed with **Prisma** unless you object.

## Proposed Changes

### 1. Initialization & Setup
#### [NEW] `backend/`
- Initialize NestJS project: `nest new backend`
- Install dependencies: `prisma`, `@prisma/client`, `class-validator`, `class-transformer`, `passport`, `passport-jwt`, `@nestjs/jwt`, `@nestjs/passport`, `bcrypt`, `multer`.

### 2. Database Schema (Prisma)
#### [NEW] `backend/prisma/schema.prisma`
- Define `Student` model matching the fields identified in `StudentModel.dart`.
- Add `createdAt`, `updatedAt`.
- Ensure proper data types (e.g., `DateTime` for DOB if possible, or String to match legacy for now).

### 3. Auth Module
#### [NEW] `backend/src/auth/`
- **Controller**: `auth.controller.ts`
    - `POST /auth/login/otp`
    - `POST /auth/login/verify`
    - `POST /auth/login/password`
    - `POST /auth/register`
    - `POST /auth/password/forgot`
    - `POST /auth/password/reset`
    - `POST /auth/password/change` (New endpoint for password change)
- **Service**: `auth.service.ts`
    - Handle business logic, password hashing (bcrypt), JWT generation.
- **Strategies**: `jwt.strategy.ts`

### 4. Profile Module
#### [NEW] `backend/src/profile/`
- **Controller**: `profile.controller.ts`
    - `GET /profile`
    - `PUT /profile` (Updates fields *excluding* password)
    - `POST /profile/image` (Handles file uploads)
- **Service**: `profile.service.ts`

## Verification Plan
### Automated Tests
- Use NestJS built-in Jest testing.
- Create e2e tests for Auth flows.

### Manual Verification
- Use `curl` or Postman to test endpoints.
- Verify that `PUT /profile` allows updating name/address without sending a password.
- Verify that `POST /auth/register` correctly creates a user with a hashed password.
