-- Create and set up the database
CREATE DATABASE IF NOT EXISTS task_manager;
USE task_manager;

-- Create tables
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    status ENUM('pending', 'in_progress', 'completed') DEFAULT 'pending',
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    due_date DATE,
    project_id INT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Add sample data
INSERT INTO users (username, email, hashed_password) VALUES 
('testuser', 'test@example.com', '$2b$12$test_hashed_password');

INSERT INTO projects (name, description, user_id) VALUES 
('Work Tasks', 'Professional tasks and deadlines', 1),
('Personal', 'Personal errands and goals', 1);

INSERT INTO tasks (title, description, status, priority, due_date, project_id, user_id) VALUES 
('Complete project proposal', 'Draft the Q3 project proposal', 'pending', 'high', '2025-04-25', 1, 1),
('Schedule doctor appointment', 'Annual checkup', 'pending', 'medium', '2025-05-10', 2, 1),
('Review code PR', 'Review pull request #1234', 'in_progress', 'high', '2025-04-17', 1, 1);
```