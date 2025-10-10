-- Y0 Task Manager Database Schema
-- Created: 2024-10-10
-- Version: 1.0.0

CREATE DATABASE IF NOT EXISTS y0_task_manager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE y0_task_manager;

-- Users Table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    avatar_url VARCHAR(255),
    timezone VARCHAR(50) DEFAULT 'UTC',
    language VARCHAR(10) DEFAULT 'ar',
    theme VARCHAR(20) DEFAULT 'light',
    total_xp INT DEFAULT 0,
    level INT DEFAULT 1,
    streak_days INT DEFAULT 0,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_username (username),
    INDEX idx_active (is_active)
);

-- Categories Table
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(7) DEFAULT '#3B82F6',
    icon VARCHAR(50) DEFAULT 'folder',
    description TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_categories (user_id)
);

-- Tasks Table
CREATE TABLE tasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    category_id INT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    due_date DATETIME,
    reminder_date DATETIME,
    estimated_duration INT, -- in minutes
    actual_duration INT, -- in minutes
    xp_reward INT DEFAULT 10,
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_pattern VARCHAR(50), -- daily, weekly, monthly, etc.
    tags JSON,
    attachments JSON,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_user_tasks (user_id),
    INDEX idx_due_date (due_date),
    INDEX idx_status (status),
    INDEX idx_priority (priority)
);

-- Subtasks Table
CREATE TABLE subtasks (
    id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    order_index INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    INDEX idx_task_subtasks (task_id)
);

-- Achievements Table
CREATE TABLE achievements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    xp_reward INT DEFAULT 0,
    condition_type VARCHAR(50), -- tasks_completed, streak_days, etc.
    condition_value INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Achievements Table
CREATE TABLE user_achievements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    achievement_id INT NOT NULL,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_achievement (user_id, achievement_id),
    INDEX idx_user_achievements (user_id)
);

-- Daily Quotes Table
CREATE TABLE daily_quotes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    quote_ar TEXT NOT NULL,
    quote_en TEXT,
    author VARCHAR(100),
    category VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Sessions Table (for JWT refresh tokens)
CREATE TABLE user_sessions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    refresh_token VARCHAR(255) NOT NULL,
    device_info VARCHAR(255),
    ip_address VARCHAR(45),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_sessions (user_id),
    INDEX idx_refresh_token (refresh_token)
);

-- Notifications Table
CREATE TABLE notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    task_id INT,
    type VARCHAR(50) NOT NULL, -- reminder, achievement, etc.
    title VARCHAR(255) NOT NULL,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    scheduled_at TIMESTAMP,
    sent_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
    INDEX idx_user_notifications (user_id),
    INDEX idx_scheduled (scheduled_at)
);

-- Insert Default Categories
INSERT INTO categories (user_id, name, color, icon, description, is_default) VALUES
(0, 'العمل', '#EF4444', 'briefcase', 'مهام متعلقة بالعمل والوظيفة', TRUE),
(0, 'الدراسة', '#3B82F6', 'book', 'مهام تعليمية ودراسية', TRUE),
(0, 'الصحة', '#10B981', 'heart', 'مهام متعلقة بالصحة واللياقة', TRUE),
(0, 'الأسرة', '#F59E0B', 'users', 'مهام عائلية واجتماعية', TRUE),
(0, 'شخصي', '#8B5CF6', 'user', 'مهام شخصية متنوعة', TRUE);

-- Insert Sample Achievements
INSERT INTO achievements (name, description, icon, xp_reward, condition_type, condition_value) VALUES
('المبتدئ', 'أكمل أول مهمة لك', 'star', 50, 'tasks_completed', 1),
('المثابر', 'أكمل 10 مهام', 'trophy', 100, 'tasks_completed', 10),
('البطل', 'أكمل 50 مهمة', 'medal', 250, 'tasks_completed', 50),
('الأسطورة', 'أكمل 100 مهمة', 'crown', 500, 'tasks_completed', 100),
('المنتظم', 'حافظ على streak لمدة 7 أيام', 'fire', 200, 'streak_days', 7),
('الملتزم', 'حافظ على streak لمدة 30 يوم', 'calendar', 500, 'streak_days', 30);

-- Insert Sample Daily Quotes
INSERT INTO daily_quotes (quote_ar, quote_en, author, category) VALUES
('النجاح هو الانتقال من فشل إلى فشل دون فقدان الحماس', 'Success is going from failure to failure without losing your enthusiasm', 'Winston Churchill', 'motivation'),
('الطريق إلى النجاح دائماً تحت الإنشاء', 'The road to success is always under construction', 'Lily Tomlin', 'success'),
('لا تؤجل عمل اليوم إلى الغد', 'Don\'t put off until tomorrow what you can do today', 'Benjamin Franklin', 'productivity'),
('الوقت أثمن ما نملك', 'Time is the most valuable thing we have', 'Theophrastus', 'time'),
('الإنجاز الصغير أفضل من الخطة الكبيرة', 'A small accomplishment is better than a big plan', 'Unknown', 'action');
