# Vehicle Service Center Management System (Apex Auto Service & Care)

![Java](https://img.shields.io/badge/Java-17%2B-blue.svg)
![Swing](https://img.shields.io/badge/GUI-Java%20Swing%20(FlatLaf)-navy.svg)
![Database](https://img.shields.io/badge/Database-MySQL%20%2F%20JDBC-orange.svg)
![Build](https://img.shields.io/badge/Build-Maven-red.svg)
![Architecture](https://img.shields.io/badge/Architecture-MVC%20%2B%20DAO%20%2B%20Service-green.svg)

An enterprise-grade, commercial-quality **Vehicle Service Center Management System** developed in Java. The project strictly adheres to **Object-Oriented Programming (OOP)** principles, the **Model-View-Controller (MVC)** architectural pattern, and clean coding best practices. It features a modern automotive dark navy and white user interface styled with FlatLaf, real-time database persistence with MySQL via JDBC (with seamless zero-config local storage fallback), OpenPDF tax invoice and report generation, JFreeChart graphical analytics, and role-based access control.

---

## Table of Contents
1. [Core Features](#core-features)
2. [Strict OOP Implementation](#strict-oop-implementation)
3. [Technology Stack](#technology-stack)
4. [System Architecture](#system-architecture)
5. [Database Schema & Normalization](#database-schema--normalization)
6. [Demo User Credentials](#demo-user-credentials)
7. [Installation & Setup Guide](#installation--setup-guide)
8. [Billing & Tax Calculation Formula](#billing--tax-calculation-formula)
9. [Project Structure](#project-structure)
10. [Application Preview Screenshots](#application-preview-screenshots)

---

## 1. Core Features

### 🔐 User Authentication & Role-Based Access Control (RBAC)
- Multi-role support with strictly enforced permissions:
  - **Admin**: Complete system control, employee/payroll management, financial statements, and full system configuration.
  - **Receptionist**: Customer registration, vehicle onboarding, appointment scheduling, work order creation, and billing.
  - **Mechanic**: Assigned job tracking, repair progress updates, and inspection notes.
- Cryptographic password hashing using **SHA-256 with dynamic salt**.
- One-click instant demo login buttons for seamless evaluation.

### 📊 Modern Executive Dashboard
- 7 Key Performance Indicator (KPI) metric cards:
  - Total Registered Customers
  - Total Vehicles in Fleet
  - Total Service Bookings
  - Pending / In-Progress Jobs
  - Completed Services
  - Available Certified Mechanics
  - Total Settled Revenue (INR ₹)
- Interactive **Monthly Revenue Bar Chart** powered by JFreeChart.
- Live **Service Status Breakdown Pie Chart**.
- Recent Service Bookings table with color-coded status badges.
- Quick shortcut buttons for new booking, customer registration, and billing.

### 👥 Customer Relationship Management (CRM)
- Complete CRUD operations (Add, Edit, View, Delete with referential safety).
- Instant multi-field search by Customer Name, Phone Number, Email, or Customer ID.
- Detailed **Customer Service History Viewer** modal tracking all registered vehicles and historical repair bookings.

### 🚗 Vehicle Fleet Management
- Multi-vehicle registration per customer.
- Tracks: Registration Plate, Brand/Make, Model, Manufacturing Year, Body Type (Sedan, SUV, Hatchback, Bike, etc.), Fuel Type (Petrol, Diesel, EV, Hybrid, CNG), and Odometer (KM).
- Search by Registration Plate, Brand, or Owner Name.
- Dedicated **Vehicle Service Log Drilldown** showing all service visits, assigned mechanics, and repair logs.

### 📅 Service Booking & Appointment Scheduling
- Interactive appointment scheduler with cascading dropdowns:
  - Selecting a Customer automatically filters and populates their registered vehicles.
- Preventive Conflict Detection: Validates that mechanics are not double-booked for the same date and time slot.
- Status Lifecycle: `Pending` ➔ `Confirmed` ➔ `In Progress` ➔ `Completed` ➔ `Cancelled`.
- Automatic mechanic availability updates (toggles to `Busy` during work and returns to `Available` upon completion).
- Direct "Generate Invoice" trigger from completed appointments.

### 🛠️ Service Catalog Management
- Standardized package definitions (General Periodic Servicing, Engine Overhaul, Synthetic Oil Change, Brake Inspection, Wheel Alignment, AC Repair, Detailing, etc.).
- Admin controls for adding, editing, pricing, and setting estimated labor duration in minutes.

### 👨‍🔧 Mechanic & Employee Roster
- Full staff directory with contact numbers, technical specializations, certifications, and monthly salaries.
- Mechanic availability status toggle (`Available`, `Busy`, `On Leave`).

### 📦 Spare Parts & Inventory Control
- Comprehensive stock management with Selling Price, Purchase Cost, and Supplier information.
- **Low-Stock Visual Alert Banner**: Automatically warns administrators when inventory drops below safety thresholds.
- Manual restock / adjustment dialog.
- **Automated Stock Deduction**: Deducts parts and logs audit transactions when parts are billed in work orders/invoices.

### 💳 Invoicing, Tax & Billing Engine
- Professional GST-compliant tax invoices with unique automatic numbering (`INV-YYYY-XXXX`).
- Automatic formula calculations:
  $$\text{Subtotal} = \text{Service Charges} + \text{Spare Parts Cost} + \text{Labour Charges}$$
  $$\text{Taxable Amount} = \text{Subtotal} - \text{Discount}$$
  $$\text{GST Amount} = \text{Taxable Amount} \times 18\%$$
  $$\text{Final Amount} = \text{Taxable Amount} + \text{GST Amount}$$
- Itemized bill generator supporting multi-service and multi-part line items.
- Commercial-grade **PDF Tax Invoice Export** using OpenPDF.

### 💵 Polymorphic Payment Settlements
- Polymorphic payment processing supporting:
  - **Cash Payment**: Enters tendered cash, automatically calculates change due.
  - **Card / POS Payment**: Validates card network (Visa, MasterCard, RuPay), last 4 digits, and auth code.
  - **UPI Instant Payment**: Validates Virtual Payment Address (VPA) and NPCI transaction reference ID.
- Automatically marks invoices as `Paid` upon successful settlement.

### 📈 Reports & Business Intelligence
- Comprehensive analytics:
  - 1. Revenue & Settlement Statement (Daily, Weekly, Monthly with Date Range Filter)
  - 2. Service Demand & Popularity Analysis
  - 3. Mechanic & Technician Efficiency Metrics
  - 4. Spare Parts Inventory Valuation & Stock Alerts
  - 5. Most Serviced Vehicles & Fleet Frequency
- One-click export to **CSV Spreadsheet** and **High-Resolution PDF Reports**.

---

## 2. Strict OOP Implementation

This project was architected as an exemplary showcase of all four fundamental OOP pillars:

| OOP Pillar | Real-World Implementation in Project |
| :--- | :--- |
| **Encapsulation** | All model attributes (`User`, `Customer`, `Vehicle`, `Invoice`, etc.) are declared `private`. Access is strictly governed via public getters, setters, and constructors with comprehensive boundary and regex validations. |
| **Inheritance** | Base class `User` is extended by `Admin`, `Receptionist`, and `Mechanic`. Common attributes (`username`, `passwordHash`, `email`) are reused, while specialized attributes and role permissions are modularized in subclasses. |
| **Polymorphism** | Role-specific behavior: Overridden methods like `canManageUsers()`, `canManageFinances()`, and `canPerformRepairs()`.<br>Payment hierarchy: Abstract class `Payment` is polymorphically implemented by `CashPayment`, `CardPayment`, and `UpiPayment` through overridden `processPayment()`, `getPaymentDetails()`, and `getFormattedReceipt()` methods. |
| **Abstraction** | Abstract base classes (`User`, `Payment`) define clean contracts. Decoupled Service and DAO layers isolate SQL persistence details from the UI layer. |

---

## 3. Technology Stack

- **Core Programming Language**: Java (JDK 17 or higher; tested on OpenJDK 25)
- **GUI Framework**: Java Swing with modern **FlatLaf** (FlatLightLaf)
- **Database Engine**: **MySQL 8.0+** with official MySQL Connector/J JDBC driver
- **Fallback Database**: Embedded persistent H2 database in MySQL compatibility mode (ensures zero-config immediate execution on machines where MySQL server isn't running)
- **PDF Generation**: **OpenPDF 1.3.39** (clean, open-source PDF engine)
- **Charting & Visual Analytics**: **JFreeChart 1.5.4**
- **Build & Dependency Management**: Apache Maven

---

## 4. System Architecture

The project follows a clean **Model-View-Controller (MVC)** layered architecture:

```
src/main/java/com/vehicleservice/
├── Main.java                        # Application bootstrap & entry point
├── model/                           # Domain Entities & OOP Hierarchies
│   ├── User.java                    # [Abstract] User entity
│   ├── Admin.java                   # [Subclass] System Administrator
│   ├── Receptionist.java            # [Subclass] Front Desk Operator
│   ├── Mechanic.java                # [Subclass] Garage Technician
│   ├── Customer.java                # Customer entity
│   ├── Vehicle.java                 # Automobile / Asset entity
│   ├── Service.java                 # Service catalog item
│   ├── Employee.java                # Technician / Staff entity
│   ├── Booking.java                 # Appointment booking entity
│   ├── ServiceOrder.java            # Active garage work order
│   ├── ServiceOrderItem.java        # Work order item (service/part)
│   ├── SparePart.java               # Inventory item
│   ├── Invoice.java                 # Tax invoice entity
│   ├── InvoiceItem.java             # Invoice line item
│   ├── Payment.java                 # [Abstract] Polymorphic base payment
│   ├── CashPayment.java             # [Subclass] Cash payment
│   ├── CardPayment.java             # [Subclass] Debit/Credit payment
│   └── UpiPayment.java              # [Subclass] UPI instant payment
├── dao/                             # Data Access Objects (JDBC & PreparedStatements)
│   ├── UserDAO.java
│   ├── CustomerDAO.java
│   ├── VehicleDAO.java
│   ├── ServiceDAO.java
│   ├── EmployeeDAO.java
│   ├── BookingDAO.java
│   ├── ServiceOrderDAO.java
│   ├── SparePartDAO.java
│   ├── InvoiceDAO.java
│   └── PaymentDAO.java
├── service/                         # Business Logic Layer
│   ├── AuthenticationService.java
│   ├── CustomerService.java
│   ├── VehicleService.java
│   ├── BookingService.java
│   ├── BillingService.java
│   └── ReportService.java
├── controller/                      # MVC Controllers
│   ├── LoginController.java
│   ├── CustomerController.java
│   ├── VehicleController.java
│   ├── BookingController.java
│   └── BillingController.java
├── view/                            # Swing UI Frames & Views
│   ├── LoginFrame.java              # Professional sign-in screen
│   ├── DashboardFrame.java          # Main window with sidebar navigation
│   ├── DashboardPanel.java          # KPI cards, charts & recent queue
│   ├── CustomerPanel.java           # Customer CRUD & history
│   ├── VehiclePanel.java            # Vehicle fleet management
│   ├── BookingPanel.java            # Appointment booking & conflict check
│   ├── ServicePanel.java            # Service catalog management
│   ├── EmployeePanel.java           # Staff roster & availability
│   ├── InventoryPanel.java          # Spare parts & low-stock alerts
│   ├── BillingPanel.java            # Invoice generator & payment dialog
│   └── ReportsPanel.java            # Business intelligence & PDF/CSV exports
├── database/                        # Database Connection & Initialization
│   └── DatabaseConnection.java      # Singleton manager with auto-bootstrap
└── util/                            # Cross-Cutting Utilities
    ├── UITheme.java                 # FlatLaf styling, palette & badge renderers
    ├── PasswordUtil.java            # SHA-256 cryptographic hashing
    ├── ValidationUtil.java          # Input validation helpers
    └── PDFGenerator.java            # OpenPDF invoice & report builder
```

---

## 5. Database Schema & Normalization

The database named `vehicle_service_center` is fully normalized into 13 relational tables with foreign keys and indexes:

1. `users`: System login credentials, SHA-256 password hash, salt, and role.
2. `customers`: Customer personal information, phone, email, address, registration date.
3. `vehicles`: Vehicle registration number, customer ID, make, model, year, body type, fuel type, odometer.
4. `services`: Standard repair packages, descriptions, estimated duration, labor cost.
5. `employees`: Technicians, specializations, contact numbers, salaries, availability status.
6. `bookings`: Appointment scheduling, customer ID, vehicle ID, service ID, assigned technician, date, time slot, status, customer complaints.
7. `service_orders`: Active workshop orders, start date, completion date, labor charges, status.
8. `service_order_items`: Line items attached to work orders (services, replacement parts).
9. `spare_parts`: Inventory catalog, categories, in-stock quantity, reorder threshold, purchase cost, selling price.
10. `inventory_transactions`: Audit log tracking stock movement (`IN`, `OUT`, `ADJUSTMENT`).
11. `invoices`: Tax invoices, customer/vehicle reference, subtotal, discount, taxable amount, GST 18%, final amount, payment status.
12. `invoice_items`: Itemized line items billed on each invoice.
13. `payments`: Payment records, amount, payment method (`CASH`, `CARD`, `UPI`), reference number, timestamp.

The complete SQL initialization script is available in:
- `src/main/resources/database.sql`
- `database.sql` (in project root)

---

## 6. Demo User Credentials

The application is pre-seeded with sample users for each role:

| Role | Username | Password | Access Privileges |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin` | `admin123` | Full system control: Analytics, Staff, Inventory, Billing, CRM |
| **Receptionist** | `receptionist` | `recep123` | Front desk: Register customers, add vehicles, book services, generate invoices |
| **Mechanic** | `mechanic` | `mech123` | Workshop floor: View assigned jobs, update repair progress, add notes |

*Quick tip: The login screen also features 1-click demo login buttons for each role.*

---

## 7. Installation & Setup Guide

### Prerequisites
- **Java Development Kit (JDK 17 or higher)** installed (`java -version`).
- **Apache Maven 3.8+** (or use the included wrapper).
- *(Optional)* **MySQL Server 8.0+** running on `localhost:3306` with user `root` / password `root`.
  *Note: If MySQL is not running, the application automatically uses its local embedded storage fallback seamlessly.*

### Option A: Running via Maven
1. Open a terminal in the project directory:
   ```bash
   cd C:\Users\manis\.gemini\antigravity\scratch\vehicle-service-center
   ```
2. Compile and execute the application:
   ```powershell
   .\mvnw.cmd compile exec:java
   ```

### Option B: Building and Running the Executable Fat JAR
1. Package the shaded executable JAR:
   ```powershell
   .\mvnw.cmd package -DskipTests
   ```
2. Launch the application with Java:
   ```bash
   java -jar target/vehicle-service-center-1.0.0.jar
   ```

### Option C: Configuring MySQL
Edit `src/main/resources/config.properties`:
```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/vehicle_service_center?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
db.user=root
db.password=your_mysql_password
```
When launched, `DatabaseConnection` will automatically create the `vehicle_service_center` database, create all 13 tables, and seed initial demo data!

---

## 8. Billing & Tax Calculation Formula

The system calculates bills automatically using Indian GST standards:

$$\text{Subtotal} = \text{Service Charges} + \text{Spare Parts Cost} + \text{Labour Charges}$$
$$\text{Taxable Amount} = \text{Subtotal} - \text{Discount}$$
$$\text{GST Amount} = \text{Taxable Amount} \times 18\%$$
$$\text{Final Amount} = \text{Taxable Amount} + \text{GST Amount}$$

### Example Calculation:
- **Service Charges**: ₹2,500.00 (General Periodic Servicing)
- **Spare Parts**: ₹1,500.00 (Castrol Edge 5W-40 Synthetic Oil)
- **Labour Charges**: ₹500.00 (Caliper Overhaul)
- **Subtotal**: ₹4,500.00
- **Discount**: ₹200.00
- **Taxable Amount**: ₹4,300.00
- **GST @ 18%**: ₹774.00
- **Final Billed Amount**: ₹5,074.00

---

## 9. Verification & Automated Test Suite

A complete integration test suite verifies the database bootstrap, OOP inheritance and polymorphism, CRUD operations, billing formulas, and PDF generation:

```powershell
java -cp "target\test-classes;target\vehicle-service-center-1.0.0.jar" com.vehicleservice.SystemIntegrationTest
```

**Results:**
```
=================================================================
    VEHICLE SERVICE CENTER MANAGEMENT SYSTEM - TEST SUITE        
=================================================================
[TEST 1] Database Initialization & Connection ... PASSED ✓
[TEST 2] OOP Pillars: User Hierarchy & Polymorphism ... PASSED ✓
[TEST 3] Authentication Service & Password Hashing ... PASSED ✓
[TEST 4] Customer CRUD Operations ... PASSED ✓
[TEST 5] Vehicle Management & Fleet Ownership ... PASSED ✓
[TEST 6] Service Catalog & Diagnostics ... PASSED ✓
[TEST 7] Employee & Mechanic Availability Roster ... PASSED ✓
[TEST 8] Service Booking & Conflict Prevention ... PASSED ✓
[TEST 9] Inventory Stock & Audit Tracking ... PASSED ✓
[TEST 10] Billing Formulas & Tax Invoicing ... PASSED ✓
[TEST 11] OOP Polymorphism: Payment Methods (Cash, Card, UPI) ... PASSED ✓
[TEST 12] Report Generation & CSV / PDF Export ... PASSED ✓
=================================================================
  TEST EXECUTION SUMMARY: 12 / 12 PASSED (100.0%)
=================================================================
```

---

## 10. Application Preview Screens

High-resolution screenshots are located in the `screenshots/` directory:
- `login_screen.png`: Secure sign-in portal with quick demo buttons and database engine indicator.
- `dashboard_screen.png`: Executive dashboard with 7 KPI metric cards, revenue trend bar chart, and service status pie chart.
- `customers_screen.png`: Customer table, search bar, and service history viewer.
- `vehicles_screen.png`: Vehicle fleet registry with owner association and service log dialog.
- `bookings_screen.png`: Service appointment queue with conflict prevention.
- `inventory_screen.png`: Spare parts stock with low-stock warning alert banner.
- `billing_screen.png`: Tax invoice management, itemized billing, and polymorphic payment settlements.
- `reports_screen.png`: Business intelligence analytics with PDF and CSV export options.
