# AIUB Sports Portal – Version 1.1

Full-stack web application for **AIUB Sports Management**.  
This system allows **students to register for sports tournaments, manage
profiles, and participate in events**, while **administrators manage
tournaments, games, and registrations**.

The project is designed so that **anyone can clone the repository and run it
step-by-step**, even on a **modern 64-bit Windows system using Oracle 10g**.

---

# Project Features

### Student Features

- Microsoft Azure AD Login (AIUB Email)
- Profile Management
- Sports Tournament Registration
- Game Participation
- Registration Status Tracking

### Admin Features

- Tournament Creation & Management
- Game Management (Solo / Duo / Custom)
- Player Registration Monitoring
- Payment Status Tracking
- Tournament Status Control

---

# Tech Stack

### Frontend

- HTML
- CSS
- JavaScript

### Backend

- Node.js
- Express.js

### Database

- Oracle 10g
- PL/SQL
- Sequences & Triggers
- Stored Procedures

### Authentication

- Microsoft Azure Active Directory (OAuth)

---

# Project Structure

aiub-sports-portal/ │ ├── backend/ # Node.js backend API │ ├── frontend/ # HTML
/ CSS / JavaScript frontend │ ├── database/ # Database scripts and dump │ ├──
webuser_backup.dmp │ └── schema.sql │ ├── docs/ # Project documentation │ └──
README.md

---

# Database Schema Overview

The database includes several main modules:

### Users

Stores AIUB student information.

Fields include:

- student_id
- email
- full_name
- gender
- profile completion
- login tracking

Includes:

- Email validation function
- Profile update procedure
- Name edit restriction (max 3 times)

---

### Admins

Stores system administrators.

Fields:

- admin_id
- email
- full_name
- created_at

Admin accounts are responsible for creating tournaments.

---

### Tournaments

Stores tournament information.

Fields:

- title
- photo_url
- registration_deadline
- status (ACTIVE / CLOSED / COMPLETED)
- created_by (admin)

---

### Tournament Games

Each tournament contains multiple games.

Fields:

- game_name
- category (Male / Female / Mix)
- game_type (Solo / Duo / Custom)
- fee_per_person

---

### Game Registrations

Stores student participation in games.

Fields:

- user_id
- game_id
- registration_date
- payment_status (PENDING / PAID / FAILED)

---

# Prerequisites

Before running the project install:

- Node.js (v16 or higher)
- npm
- Git
- Windows OS
- Oracle 10g XE

---

# Step 1: Clone the Repository

```bash
git clone https://github.com/mrxvaau/AIUB-SPORTS-PORTAL
cd aiub-sports-portal
Step 2: Backend Environment Configuration (.env)

⚠️ Do NOT commit the .env file to GitHub

Create .env inside backend folder:

cd backend
type nul > .env
.env Example Configuration
PORT=3000
NODE_ENV=development

DB_USER=webuser
DB_PASSWORD=webpassword
DB_CONNECTION_STRING=localhost:1521/XE

JWT_SECRET=change_me

SESSION_TIMEOUT=3600000
CORS_ORIGIN=http://localhost:3001

APP_NAME=AIUB Sports Portal
APP_VERSION=1.1

AZURE_TENANT_ID=YOUR_TENANT_ID
AZURE_CLIENT_ID=YOUR_CLIENT_ID
AZURE_CLIENT_SECRET=YOUR_CLIENT_SECRET
AZURE_REDIRECT_URI=http://localhost:3001/callback

ALLOWED_EMAIL_DOMAIN=@student.aiub.edu
Azure OAuth Setup

Go to Azure Portal

Open Azure Active Directory

Click App registrations

Select New Registration

Copy:

Tenant ID

Client ID

Go to Certificates & Secrets

Create Client Secret

Add Redirect URI:

http://localhost:3001/callback
Step 3: Install Oracle 10g (Manual Download)

GitHub does not allow .exe files.

Download Oracle 10g XE:

https://www.dropbox.com/scl/fo/japz568rim4cc9y48xhze/AHUjHYykGFIsMpW-W5kfPes

Installation steps:

Extract archive

Run setup.exe

Install using default XE settings

Restart system after installation

Step 4: Install Oracle Instant Client

Download from Oracle:

https://download.oracle.com/otn_software/nt/instantclient/2326000/instantclient-basic-windows.x64-23.26.0.0.0.zip

Steps:

Extract ZIP

Move folder to:

C:\oraclexe\instantclient_23_0
Step 5: Configure Environment Variables

Add to PATH:

C:\oraclexe\instantclient_23_0

Create system variables:

Variable	Value
ORACLE_HOME	C:\oraclexe
TNS_ADMIN	C:\oraclexe\instantclient_23_0

Restart your system.

Step 6: Database Setup

Open SQLPlus:

sqlplus / as sysdba

Create database user:

CREATE USER webuser IDENTIFIED BY webpassword;
GRANT CONNECT, RESOURCE, DBA TO webuser;

Import database dump:

cd database
imp webuser/webpassword@XE file=webuser_backup.dmp full=y
Step 7: Run Backend
cd backend
npm install
npm run start

Backend will run at:

http://localhost:3000
Step 8: Run Frontend
cd frontend
npx http-server -p 3001

Frontend will run at:

http://localhost:3001
```
