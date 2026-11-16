-- ==============================================================
-- VEHICLE SERVICE CENTER MANAGEMENT SYSTEM
-- Database: vehicle_service_center
-- MySQL 8.0+ / H2 MySQL Mode Compatible Schema
-- ==============================================================

CREATE DATABASE IF NOT EXISTS vehicle_service_center;
USE vehicle_service_center;

-- Drop tables in reverse dependency order if resetting
-- DROP TABLE IF EXISTS payments;
-- DROP TABLE IF EXISTS invoice_items;
-- DROP TABLE IF EXISTS invoices;
-- DROP TABLE IF EXISTS inventory_transactions;
-- DROP TABLE IF EXISTS spare_parts;
-- DROP TABLE IF EXISTS service_order_items;
-- DROP TABLE IF EXISTS service_orders;
-- DROP TABLE IF EXISTS bookings;
-- DROP TABLE IF EXISTS employees;
-- DROP TABLE IF EXISTS services;
-- DROP TABLE IF EXISTS vehicles;
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS users;

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(256) NOT NULL,
    salt VARCHAR(64) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL, -- ADMIN, RECEPTIONIST, MECHANIC
    email VARCHAR(100),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. CUSTOMERS TABLE
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100),
    address VARCHAR(255),
    registration_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. VEHICLES TABLE
CREATE TABLE IF NOT EXISTS vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    registration_number VARCHAR(30) NOT NULL UNIQUE,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    manufacturing_year INT NOT NULL,
    vehicle_type VARCHAR(30) NOT NULL, -- Sedan, SUV, Hatchback, Motorcycle, Commercial
    fuel_type VARCHAR(20) NOT NULL,    -- Petrol, Diesel, Electric, Hybrid, CNG
    current_km INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vehicle_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- 4. SERVICES CATALOG TABLE
CREATE TABLE IF NOT EXISTS services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    estimated_cost DECIMAL(10,2) NOT NULL,
    estimated_duration_mins INT DEFAULT 60,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. EMPLOYEES & MECHANICS TABLE
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    name VARCHAR(100) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    specialization VARCHAR(100),
    salary DECIMAL(10,2) NOT NULL,
    availability_status VARCHAR(20) DEFAULT 'Available', -- Available, Busy, On Leave
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- 6. SERVICE BOOKINGS TABLE
CREATE TABLE IF NOT EXISTS bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    service_id INT NOT NULL,
    employee_id INT NULL,
    booking_date DATE NOT NULL,
    booking_time VARCHAR(20) NOT NULL,
    complaints TEXT,
    status VARCHAR(20) DEFAULT 'Pending', -- Pending, Confirmed, In Progress, Completed, Cancelled
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_service FOREIGN KEY (service_id) REFERENCES services(service_id),
    CONSTRAINT fk_booking_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL
);

-- 7. SERVICE ORDERS (WORK IN PROGRESS) TABLE
CREATE TABLE IF NOT EXISTS service_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NULL,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    employee_id INT NULL,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completion_date TIMESTAMP NULL,
    labor_charges DECIMAL(10,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'In Progress', -- In Progress, Completed, Cancelled
    notes TEXT,
    CONSTRAINT fk_order_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE SET NULL,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_order_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id),
    CONSTRAINT fk_order_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL
);

-- 8. SERVICE ORDER ITEMS
CREATE TABLE IF NOT EXISTS service_order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_type VARCHAR(20) NOT NULL, -- SERVICE, PART, LABOUR, OTHER
    item_ref_id INT NULL,
    item_name VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES service_orders(order_id) ON DELETE CASCADE
);

-- 9. SPARE PARTS & INVENTORY TABLE
CREATE TABLE IF NOT EXISTS spare_parts (
    part_id INT AUTO_INCREMENT PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    min_threshold INT NOT NULL DEFAULT 5,
    purchase_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    supplier_name VARCHAR(100),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. INVENTORY TRANSACTIONS AUDIT TABLE
CREATE TABLE IF NOT EXISTS inventory_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    part_id INT NOT NULL,
    order_id INT NULL,
    transaction_type VARCHAR(20) NOT NULL, -- IN, OUT, ADJUSTMENT
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    CONSTRAINT fk_inv_part FOREIGN KEY (part_id) REFERENCES spare_parts(part_id) ON DELETE CASCADE,
    CONSTRAINT fk_inv_order FOREIGN KEY (order_id) REFERENCES service_orders(order_id) ON DELETE SET NULL
);

-- 11. INVOICES TABLE
CREATE TABLE IF NOT EXISTS invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(30) NOT NULL UNIQUE,
    order_id INT NULL,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    service_charges DECIMAL(10,2) DEFAULT 0.00,
    spare_parts_cost DECIMAL(10,2) DEFAULT 0.00,
    labor_charges DECIMAL(10,2) DEFAULT 0.00,
    subtotal DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0.00,
    taxable_amount DECIMAL(10,2) NOT NULL,
    gst_rate DECIMAL(5,2) DEFAULT 18.00,
    gst_amount DECIMAL(10,2) NOT NULL,
    final_amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'Unpaid', -- Unpaid, Partially Paid, Paid
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoice_order FOREIGN KEY (order_id) REFERENCES service_orders(order_id) ON DELETE SET NULL,
    CONSTRAINT fk_invoice_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_invoice_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

-- 12. INVOICE LINE ITEMS TABLE
CREATE TABLE IF NOT EXISTS invoice_items (
    invoice_item_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    item_description VARCHAR(150) NOT NULL,
    item_type VARCHAR(20) NOT NULL, -- SERVICE, PART, LABOUR, OTHER
    quantity INT DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_inv_items_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE
);

-- 13. PAYMENTS TABLE
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL, -- CASH, CARD, UPI
    transaction_reference VARCHAR(100),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id) ON DELETE CASCADE
);

-- ==============================================================
-- INDEXES FOR PERFORMANCE
-- ==============================================================
CREATE INDEX idx_customers_phone ON customers(phone_number);
CREATE INDEX idx_vehicles_reg ON vehicles(registration_number);
CREATE INDEX idx_bookings_date ON bookings(booking_date);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_invoices_status ON invoices(payment_status);
CREATE INDEX idx_invoices_num ON invoices(invoice_number);

-- ==============================================================
-- SEED DATA FOR DEMO & TESTING
-- ==============================================================

-- 1. Default Users (passwords hashed using SHA-256 with static salt 'APEX_SALT_2026')
-- admin123 => hash of 'APEX_SALT_2026admin123'
-- recep123 => hash of 'APEX_SALT_2026recep123'
-- mech123  => hash of 'APEX_SALT_2026mech123'
INSERT INTO users (username, password_hash, salt, full_name, role, email, phone) VALUES
('admin', 'ad10ad98b7ec7b1982082a92a6785d6fbbc5e7fe1dd56e43b97a7421c1b231cf', 'APEX_SALT_2026', 'Vikramaditya Roy (Admin)', 'ADMIN', 'admin@apexautoservice.com', '+91 98888 11111'),
('receptionist', '20e92bdc485cc76f722f783e2c4bd4546f35348bbc7fdaba196a25ee970fe22a', 'APEX_SALT_2026', 'Priya Sharma (Receptionist)', 'RECEPTIONIST', 'priya@apexautoservice.com', '+91 98888 22222'),
('mechanic', 'e66411e041627a67419208ffd542f692d33b59a1e96d1a167ef3f354a34ea625', 'APEX_SALT_2026', 'Rajesh Kumar (Senior Mechanic)', 'MECHANIC', 'rajesh@apexautoservice.com', '+91 98888 33333');

-- 2. Employees / Mechanics
INSERT INTO employees (user_id, name, contact_number, specialization, salary, availability_status) VALUES
(3, 'Rajesh Kumar', '+91 98888 33333', 'Engine & Transmission Specialist', 45000.00, 'Available'),
(NULL, 'Arun Verma', '+91 98765 11001', 'Electrical, ECU & Diagnostics', 42000.00, 'Available'),
(NULL, 'Kiran Nair', '+91 98765 11002', 'Brakes, Suspension & Alignment', 38000.00, 'Busy'),
(NULL, 'Suresh Gowda', '+91 98765 11003', 'HVAC / AC & Detailing Specialist', 36000.00, 'Available');

-- 3. Service Catalog
INSERT INTO services (service_name, category, description, estimated_cost, estimated_duration_mins) VALUES
('General Periodic Servicing', 'Maintenance', 'Comprehensive multi-point inspection, fluid top-up, filter clean, brake check', 2499.00, 180),
('Engine Repair & Overhaul', 'Engine', 'Engine diagnostics, valve clearance adjustment, gasket replacement & tuning', 7500.00, 360),
('Full Synthetic Oil Change', 'Fluids', 'Drain old oil, flush engine, refill 5W-40 fully synthetic oil with OEM filter', 3200.00, 45),
('Complete Brake Inspection & Overhaul', 'Braking', 'Brake pad inspection, rotor resurfacing/cleaning, brake fluid flush & bleeding', 1850.00, 90),
('Tyre Replacement & Balancing', 'Tyres', 'Tire dismount, mount new tire, computer wheel balancing & pressure calibration', 800.00, 60),
('Heavy Duty Battery Replacement', 'Electrical', 'Battery load test, terminal cleaning, brand new maintenance-free AGM battery install', 4999.00, 30),
('Automotive AC Servicing & Gas Refill', 'AC & Climate', 'AC leak test, condenser cleaning, compressor oil refill and R134a refrigerant charge', 2750.00, 120),
('3D Computerised Wheel Alignment', 'Alignment', 'Digital 4-wheel alignment check, camber, caster, toe adjustment for tire longevity', 950.00, 45),
('Premium Foam Wash & Detailing', 'Detailing', 'Snow foam exterior wash, underbody pressure blast, interior deep vacuum, dash polish', 1499.00, 90),
('Auto Electrical Diagnostic Scan', 'Diagnostics', 'OBD-II computer fault code scanning, alternator testing, wiring integrity diagnostic', 1200.00, 60);

-- 4. Spare Parts Inventory
INSERT INTO spare_parts (part_name, category, quantity, min_threshold, purchase_price, selling_price, supplier_name) VALUES
('Castrol EDGE 5W-40 Synthetic Oil 4L', 'Fluids & Oils', 28, 6, 2100.00, 3100.00, 'Castrol Lubricants India'),
('Bosch Premium Engine Oil Filter', 'Filters', 45, 10, 220.00, 450.00, 'Bosch Auto Parts'),
('Brembo Ceramic Front Brake Pads', 'Braking', 18, 5, 1400.00, 2400.00, 'Brembo Brake Systems'),
('NGK Laser Iridium Spark Plug (Pack of 4)', 'Engine', 22, 8, 1200.00, 2100.00, 'NGK Spark Plugs'),
('Exide Matrix 65Ah AGM Car Battery', 'Electrical', 9, 3, 4200.00, 5800.00, 'Exide Industries Ltd'),
('Mann-Filter High Performance Air Filter', 'Filters', 32, 10, 350.00, 650.00, 'Mann+Hummel India'),
('Active Carbon AC Cabin Air Filter', 'AC & Climate', 24, 8, 400.00, 800.00, 'Denso Auto Parts'),
('Prestone Heavy Duty Coolant 1L', 'Fluids & Oils', 50, 12, 180.00, 350.00, 'Prestone Chemical Co'),
('Front Vented Brake Disc Rotors (Pair)', 'Braking', 4, 5, 2800.00, 4500.00, 'TVS Girling Parts'),
('Bosch Aerotwin Frameless Wiper Blades Pair', 'Accessories', 16, 5, 650.00, 1200.00, 'Bosch Auto Parts');

-- 5. Customers
INSERT INTO customers (full_name, phone_number, email, address, registration_date) VALUES
('Rohan Mehra', '+91 98450 12345', 'rohan.mehra@gmail.com', '124 Indiranagar, 100ft Road, Bengaluru', '2026-01-15'),
('Ananya Deshmukh', '+91 98450 54321', 'ananya.d@outlook.com', '45 Koramangala 4th Block, Bengaluru', '2026-02-10'),
('Karthik Subbaraj', '+91 98450 67890', 'karthik.sub@yahoo.com', '88 Whitefield Main Road, Bengaluru', '2026-03-05'),
('Sunita Patel', '+91 98450 99887', 'sunita.patel@rediffmail.com', '77 Jayanagar 7th Block, Bengaluru', '2026-03-22');

-- 6. Vehicles
INSERT INTO vehicles (customer_id, registration_number, brand, model, manufacturing_year, vehicle_type, fuel_type, current_km) VALUES
(1, 'KA-01-MJ-2024', 'Hyundai', 'Creta SX (O)', 2022, 'SUV', 'Diesel', 34200),
(1, 'KA-01-EQ-8812', 'Royal Enfield', 'Classic 350', 2021, 'Motorcycle', 'Petrol', 18450),
(2, 'KA-05-NB-5544', 'Honda', 'City ZX CVT', 2023, 'Sedan', 'Petrol', 16200),
(3, 'KA-03-MR-9012', 'Tata', 'Nexon EV Empowered', 2023, 'SUV', 'Electric', 28900),
(4, 'KA-51-AB-4321', 'Maruti Suzuki', 'Swift ZXi+', 2020, 'Hatchback', 'Petrol', 48500);

-- 7. Bookings
INSERT INTO bookings (customer_id, vehicle_id, service_id, employee_id, booking_date, booking_time, complaints, status) VALUES
(1, 1, 1, 1, '2026-11-04', '09:30 AM', '30,000 km periodic maintenance, slight squeak in front brakes', 'In Progress'),
(2, 3, 3, 2, '2026-11-04', '11:00 AM', 'Scheduled oil change and general fluid levels check', 'Confirmed'),
(3, 4, 10, 2, '2026-11-05', '02:00 PM', 'EV system firmware scan, tire rotation and wiper chatter', 'Pending'),
(4, 5, 4, 3, '2026-11-03', '10:00 AM', 'Brake pedal feels soft during high speed stops', 'Completed');

-- 8. Completed Service Order & Invoice for History & Reports Demo
INSERT INTO service_orders (booking_id, customer_id, vehicle_id, employee_id, start_date, completion_date, labor_charges, status, notes) VALUES
(4, 4, 5, 3, '2026-11-03 10:00:00', '2026-11-03 14:30:00', 800.00, 'Completed', 'Front brake pads replaced with Brembo ceramics. Rotors cleaned and brake fluid flushed.');

INSERT INTO service_order_items (order_id, item_type, item_ref_id, item_name, quantity, unit_price, total_price) VALUES
(1, 'SERVICE', 4, 'Complete Brake Inspection & Overhaul', 1, 1850.00, 1850.00),
(1, 'PART', 3, 'Brembo Ceramic Front Brake Pads', 1, 2400.00, 2400.00),
(1, 'LABOUR', NULL, 'Brake Caliper Servicing & Bleeding Labour', 1, 800.00, 800.00);

-- Deduct from inventory transaction
INSERT INTO inventory_transactions (part_id, order_id, transaction_type, quantity, unit_price, notes) VALUES
(3, 1, 'OUT', 1, 2400.00, 'Fitted to KA-51-AB-4321 during Order #1');

-- Invoice
-- Subtotal = 1850 + 2400 + 800 = 5050.00
-- Discount = 250.00
-- Taxable = 4800.00
-- GST 18% = 864.00
-- Final = 5664.00
INSERT INTO invoices (invoice_number, order_id, customer_id, vehicle_id, service_charges, spare_parts_cost, labor_charges, subtotal, discount, taxable_amount, gst_rate, gst_amount, final_amount, payment_status, invoice_date, due_date) VALUES
('INV-2026-0001', 1, 4, 5, 1850.00, 2400.00, 800.00, 5050.00, 250.00, 4800.00, 18.00, 864.00, 5664.00, 'Paid', '2026-11-03', '2026-11-03');

INSERT INTO invoice_items (invoice_id, item_description, item_type, quantity, unit_price, total_price) VALUES
(1, 'Complete Brake Inspection & Overhaul', 'SERVICE', 1, 1850.00, 1850.00),
(1, 'Brembo Ceramic Front Brake Pads', 'PART', 1, 2400.00, 2400.00),
(1, 'Brake Caliper Servicing & Bleeding Labour', 'LABOUR', 1, 800.00, 800.00);

INSERT INTO payments (invoice_id, amount, payment_method, transaction_reference, payment_date, notes) VALUES
(1, 5664.00, 'UPI', 'UPI/20261103/9845099887@okaxis/10293847', '2026-11-03 15:15:00', 'Full payment received via Google Pay UPI');
