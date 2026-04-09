-- UtsavLink Complete Database Schema
-- Compatible with MySQL / PostgreSQL (minor tweaks may be needed)

-- ==============================
-- 1. USERS
-- ==============================
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    phone VARCHAR(15) UNIQUE NOT NULL,
    name VARCHAR(100),
    state VARCHAR(50),
    district VARCHAR(50),
    role VARCHAR(20) DEFAULT 'customer',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- 2. OTP VERIFICATION
-- ==============================
CREATE TABLE otp_verification (
    id BIGSERIAL PRIMARY KEY,
    phone VARCHAR(15) NOT NULL,
    otp VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE
);

-- ==============================
-- 3. VENDORS
-- ==============================
CREATE TABLE vendors (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    description TEXT,
    state VARCHAR(50),
    district VARCHAR(50),
    base_price DECIMAL(10,2),
    rating FLOAT DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- 4. VENDOR IMAGES
-- ==============================
CREATE TABLE vendor_images (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES vendors(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL
);

-- ==============================
-- 5. VENDOR AVAILABILITY
-- ==============================
CREATE TABLE vendor_availability (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES vendors(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'available'
);

-- ==============================
-- 6. SERVICES / PACKAGES
-- ==============================
CREATE TABLE services (
    id BIGSERIAL PRIMARY KEY,
    vendor_id BIGINT REFERENCES vendors(id) ON DELETE CASCADE,
    title VARCHAR(150),
    description TEXT,
    price DECIMAL(10,2),
    is_best BOOLEAN DEFAULT FALSE
);

-- ==============================
-- 7. BOOKINGS
-- ==============================
CREATE TABLE bookings (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    vendor_id BIGINT REFERENCES vendors(id) ON DELETE CASCADE,
    service_id BIGINT REFERENCES services(id) ON DELETE SET NULL,
    event_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- 8. PAYMENTS
-- ==============================
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    booking_id BIGINT REFERENCES bookings(id) ON DELETE CASCADE,
    amount DECIMAL(10,2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(20),
    transaction_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- 9. REVIEWS
-- ==============================
CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    vendor_id BIGINT REFERENCES vendors(id) ON DELETE CASCADE,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- 10. FAVORITES
-- ==============================
CREATE TABLE favorites (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    vendor_id BIGINT REFERENCES vendors(id) ON DELETE CASCADE,
    UNIQUE(user_id, vendor_id)
);

-- ==============================
-- 11. NOTIFICATIONS
-- ==============================
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150),
    message TEXT,
    type VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- 12. ADMIN LOGS
-- ==============================
CREATE TABLE admin_logs (
    id BIGSERIAL PRIMARY KEY,
    admin_id BIGINT,
    action VARCHAR(255),
    entity_type VARCHAR(50),
    entity_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- 13. ANALYTICS EVENTS
-- ==============================
CREATE TABLE analytics_events (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT,
    event_name VARCHAR(100),
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==============================
-- INDEXES (IMPORTANT FOR PERFORMANCE)
-- ==============================
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_vendors_location ON vendors(state, district);
CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_vendor ON bookings(vendor_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);

-- ==============================
-- SAMPLE DATA (OPTIONAL)
-- ==============================
-- INSERT INTO users (phone, name) VALUES ('9876543210', 'Test User');
