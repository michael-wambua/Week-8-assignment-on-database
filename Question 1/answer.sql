-- Library Management System Database
-- Created: April 15, 2025

-- -----------------------------------------------------
-- Database Creation
-- -----------------------------------------------------
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- -----------------------------------------------------
-- Table `authors`
-- -----------------------------------------------------
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    death_date DATE,
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT check_dates CHECK (death_date IS NULL OR death_date > birth_date)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `publishers`
-- -----------------------------------------------------
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_publisher_name (publisher_name)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `categories`
-- -----------------------------------------------------
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    parent_category_id INT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_category_name (category_name),
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_category_id)
        REFERENCES categories (category_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `books`
-- -----------------------------------------------------
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publication_date DATE,
    language VARCHAR(30) DEFAULT 'English',
    page_count INT UNSIGNED,
    publisher_id INT,
    category_id INT,
    summary TEXT,
    cover_image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id)
        REFERENCES publishers (publisher_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_book_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `book_authors` (Many-to-Many relationship)
-- -----------------------------------------------------
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_role ENUM('Primary', 'Co-author', 'Editor', 'Translator') DEFAULT 'Primary',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_bookauthors_book FOREIGN KEY (book_id)
        REFERENCES books (book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_bookauthors_author FOREIGN KEY (author_id)
        REFERENCES authors (author_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `book_copies`
-- -----------------------------------------------------
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    acquisition_date DATE NOT NULL,
    status ENUM('Available', 'Checked Out', 'Reserved', 'Under Repair', 'Lost', 'Discarded') DEFAULT 'Available',
    condition ENUM('New', 'Good', 'Fair', 'Poor') DEFAULT 'Good',
    location VARCHAR(50),
    barcode VARCHAR(30) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_copy_book FOREIGN KEY (book_id)
        REFERENCES books (book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `patrons`
-- -----------------------------------------------------
CREATE TABLE patrons (
    patron_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    membership_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_expiry DATE,
    status ENUM('Active', 'Expired', 'Suspended', 'Cancelled') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT check_membership_dates CHECK (membership_expiry > membership_date)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `staff`
-- -----------------------------------------------------
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role ENUM('Librarian', 'Assistant', 'Admin', 'IT Support', 'Manager') NOT NULL,
    hire_date DATE NOT NULL,
    end_date DATE,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT check_staff_dates CHECK (end_date IS NULL OR end_date > hire_date)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `loans`
-- -----------------------------------------------------
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    patron_id INT NOT NULL,
    checkout_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATETIME NOT NULL,
    return_date DATETIME,
    renewed_times TINYINT UNSIGNED DEFAULT 0,
    staff_id_checkout INT,
    staff_id_return INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_loan_copy FOREIGN KEY (copy_id)
        REFERENCES book_copies (copy_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_loan_patron FOREIGN KEY (patron_id)
        REFERENCES patrons (patron_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_loan_staff_checkout FOREIGN KEY (staff_id_checkout)
        REFERENCES staff (staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_loan_staff_return FOREIGN KEY (staff_id_return)
        REFERENCES staff (staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT check_loan_dates CHECK (return_date IS NULL OR return_date >= checkout_date)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `fines`
-- -----------------------------------------------------
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL,
    fine_reason ENUM('Late Return', 'Damaged Item', 'Lost Item') NOT NULL,
    fine_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    payment_date DATETIME,
    staff_id INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_fine_loan FOREIGN KEY (loan_id)
        REFERENCES loans (loan_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_fine_staff FOREIGN KEY (staff_id)
        REFERENCES staff (staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `reservations`
-- -----------------------------------------------------
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    patron_id INT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATETIME NOT NULL,
    status ENUM('Active', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Active',
    fulfillment_date DATETIME,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_reservation_book FOREIGN KEY (book_id)
        REFERENCES books (book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_reservation_patron FOREIGN KEY (patron_id)
        REFERENCES patrons (patron_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `events`
-- -----------------------------------------------------
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    event_date DATETIME NOT NULL,
    duration INT NOT NULL COMMENT 'Duration in minutes',
    location VARCHAR(100),
    max_attendees INT,
    staff_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_event_staff FOREIGN KEY (staff_id)
        REFERENCES staff (staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `event_attendees` (Many-to-Many relationship)
-- -----------------------------------------------------
CREATE TABLE event_attendees (
    event_id INT NOT NULL,
    patron_id INT NOT NULL,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered', 'Attended', 'No-Show', 'Cancelled') DEFAULT 'Registered',
    PRIMARY KEY (event_id, patron_id),
    CONSTRAINT fk_eventattendees_event FOREIGN KEY (event_id)
        REFERENCES events (event_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_eventattendees_patron FOREIGN KEY (patron_id)
        REFERENCES patrons (patron_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `reviews`
-- -----------------------------------------------------
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    patron_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    moderated_by INT,
    moderation_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_book FOREIGN KEY (book_id)
        REFERENCES books (book_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_review_patron FOREIGN KEY (patron_id)
        REFERENCES patrons (patron_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_review_staff FOREIGN KEY (moderated_by)
        REFERENCES staff (staff_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    UNIQUE KEY idx_unique_review (book_id, patron_id)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Views
-- -----------------------------------------------------

-- View to show available books
CREATE VIEW available_books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS authors,
    p.publisher_name,
    c.category_name,
    COUNT(bc.copy_id) AS available_copies
FROM 
    books b
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN categories c ON b.category_id = c.category_id
LEFT JOIN book_copies bc ON b.book_id = bc.book_id AND bc.status = 'Available'
GROUP BY 
    b.book_id, b.title, b.isbn, p.publisher_name, c.category_name
HAVING 
    COUNT(bc.copy_id) > 0;

-- View for overdue books
CREATE VIEW overdue_loans AS
SELECT 
    l.loan_id,
    b.title,
    b.isbn,
    CONCAT(p.first_name, ' ', p.last_name) AS patron_name,
    p.email AS patron_email,
    l.checkout_date,
    l.due_date,
    DATEDIFF(CURRENT_DATE, l.due_date) AS days_overdue
FROM 
    loans l
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id
JOIN patrons p ON l.patron_id = p.patron_id
WHERE 
    l.return_date IS NULL 
    AND l.due_date < CURRENT_DATE
ORDER BY 
    days_overdue DESC;

-- View for patron activity
CREATE VIEW patron_activity AS
SELECT 
    p.patron_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patron_name,
    p.email,
    COUNT(DISTINCT l.loan_id) AS total_checkouts,
    SUM(CASE WHEN l.return_date IS NULL AND l.due_date < CURRENT_DATE THEN 1 ELSE 0 END) AS current_overdue,
    COUNT(DISTINCT r.reservation_id) AS total_reservations,
    SUM(CASE WHEN f.payment_status = 'Pending' THEN f.fine_amount ELSE 0 END) AS pending_fines
FROM 
    patrons p
LEFT JOIN loans l ON p.patron_id = l.patron_id
LEFT JOIN reservations r ON p.patron_id = r.patron_id
LEFT JOIN fines f ON l.loan_id = f.loan_id
GROUP BY 
    p.patron_id, patron_name, p.email;

-- -----------------------------------------------------
-- Stored Procedures
-- -----------------------------------------------------

-- Procedure to check out a book
DELIMITER //
CREATE PROCEDURE checkout_book(
    IN p_copy_id INT,
    IN p_patron_id INT,
    IN p_staff_id INT,
    IN p_loan_days INT
)
BEGIN
    DECLARE copy_status VARCHAR(20);
    DECLARE patron_status VARCHAR(20);
    DECLARE has_overdue_books BOOLEAN;
    DECLARE has_unpaid_fines BOOLEAN;
    
    -- Check if copy is available
    SELECT status INTO copy_status FROM book_copies WHERE copy_id = p_copy_id;
    
    -- Check if patron is active
    SELECT status INTO patron_status FROM patrons WHERE patron_id = p_patron_id;
    
    -- Check if patron has overdue books
    SELECT EXISTS (
        SELECT 1 FROM loans 
        WHERE patron_id = p_patron_id 
        AND return_date IS NULL 
        AND due_date < CURRENT_DATE
    ) INTO has_overdue_books;
    
    -- Check if patron has unpaid fines
    SELECT EXISTS (
        SELECT 1 FROM fines f
        JOIN loans l ON f.loan_id = l.loan_id
        WHERE l.patron_id = p_patron_id 
        AND f.payment_status = 'Pending'
    ) INTO has_unpaid_fines;
    
    -- Validate conditions
    IF copy_status != 'Available' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book copy is not available for checkout';
    ELSEIF patron_status != 'Active' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patron account is not active';
    ELSEIF has_overdue_books = TRUE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patron has overdue books';
    ELSEIF has_unpaid_fines = TRUE THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Patron has unpaid fines';
    ELSE
        -- Create loan record
        INSERT INTO loans (copy_id, patron_id, checkout_date, due_date, staff_id_checkout)
        VALUES (p_copy_id, p_patron_id, CURRENT_TIMESTAMP, DATE_ADD(CURRENT_DATE, INTERVAL p_loan_days DAY), p_staff_id);
        
        -- Update book copy status
        UPDATE book_copies SET status = 'Checked Out' WHERE copy_id = p_copy_id;
        
        SELECT 'Book checked out successfully' AS message;
    END IF;
END //
DELIMITER ;

-- Procedure to return a book
DELIMITER //
CREATE PROCEDURE return_book(
    IN p_copy_id INT,
    IN p_staff_id INT
)
BEGIN
    DECLARE loan_id_var INT;
    DECLARE due_date_var DATETIME;
    DECLARE is_overdue BOOLEAN;
    
    -- Find active loan for this copy
    SELECT l.loan_id, l.due_date INTO loan_id_var, due_date_var
    FROM loans l
    WHERE l.copy_id = p_copy_id AND l.return_date IS NULL
    LIMIT 1;
    
    -- Check if loan exists
    IF loan_id_var IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No active loan found for this book copy';
    ELSE
        -- Check if book is overdue
        SET is_overdue = (due_date_var < CURRENT_TIMESTAMP);
        
        -- Update loan record
        UPDATE loans 
        SET return_date = CURRENT_TIMESTAMP, 
            staff_id_return = p_staff_id
        WHERE loan_id = loan_id_var;
        
        -- Update book copy status
        UPDATE book_copies SET status = 'Available' WHERE copy_id = p_copy_id;
        
        -- Create fine if overdue
        IF is_overdue THEN
            INSERT INTO fines (loan_id, fine_amount, fine_reason, fine_date)
            VALUES (
                loan_id_var, 
                DATEDIFF(CURRENT_TIMESTAMP, due_date_var) * 0.50, -- $0.50 per day
                'Late Return',
                CURRENT_TIMESTAMP
            );
            
            SELECT 'Book returned successfully, but it was overdue. Fine has been applied.' AS message;
        ELSE
            SELECT 'Book returned successfully' AS message;
        END IF;
    END IF;
END //
DELIMITER ;

-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------

-- Trigger to check if reservation can be fulfilled when book becomes available
DELIMITER //
CREATE TRIGGER after_book_copy_update
AFTER UPDATE ON book_copies
FOR EACH ROW
BEGIN
    -- If status changed to Available, check reservations
    IF NEW.status = 'Available' AND OLD.status != 'Available' THEN
        -- Get the book_id for this copy
        DECLARE book_id_var INT;
        SELECT book_id INTO book_id_var FROM book_copies WHERE copy_id = NEW.copy_id;
        
        -- Find oldest active reservation for this book
        UPDATE reservations
        SET status = 'Fulfilled', fulfillment_date = CURRENT_TIMESTAMP
        WHERE book_id = book_id_var
        AND status = 'Active'
        ORDER BY reservation_date ASC
        LIMIT 1;
    END IF;
END //
DELIMITER ;

-- -----------------------------------------------------
-- Sample Data
-- -----------------------------------------------------

-- Insert sample authors
INSERT INTO authors (first_name, last_name, birth_date, biography) VALUES
('J.K.', 'Rowling', '1965-07-31', 'British author best known for the Harry Potter series'),
('George', 'Orwell', '1903-06-25', 'English novelist, essayist, and critic'),
('Jane', 'Austen', '1775-12-16', 'English novelist known for her six major novels'),
('Stephen', 'King', '1947-09-21', 'American author of horror, supernatural fiction, suspense, and fantasy novels'),
('Agatha', 'Christie', '1890-09-15', 'English writer known for her detective novels');

-- Insert sample publishers
INSERT INTO publishers (publisher_name, address, phone, email, website) VALUES
('Penguin Random House', '1745 Broadway, New York, NY 10019', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000', 'info@harpercollins.com', 'www.harpercollins.com'),
('Simon & Schuster', '1230 Avenue of the Americas, New York, NY 10020', '212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com'),
('Macmillan Publishers', '120 Broadway, New York, NY 10271', '646-307-5151', 'info@macmillan.com', 'www.macmillan.com'),
('Scholastic', '557 Broadway, New York, NY 10012', '212-343-6100', 'info@scholastic.com', 'www.scholastic.com');

-- Insert sample categories
INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Literary works created from the imagination'),
('Non-Fiction', 'Literary works based on facts'),
('Science Fiction', 'Fiction based on imagined future scientific advances'),
('Mystery', 'Fiction dealing with the solution of a crime or puzzle'),
('Romance', 'Fiction that focuses on the romantic relationship between characters');

-- Insert child categories
INSERT INTO categories (category_name, parent_category_id, description) VALUES
('Fantasy', 1, 'Fiction with magical or supernatural elements'),
('Historical Fiction', 1, 'Fiction set in the past'),
('Biography', 2, 'Non-fiction account of a person\'s life'),
('Science', 2, 'Non-fiction work about scientific topics'),
('Young Adult', 1, 'Fiction targeted at teenagers');

-- Insert sample books
INSERT INTO books (title, isbn, publication_date, language, page_count, publisher_id, category_id, summary) VALUES
('Harry Potter and the Philosopher\'s Stone', '9780747532743', '1997-06-26', 'English', 223, 5, 6, 'The first novel in the Harry Potter series, following Harry Potter, a young wizard who discovers his magical heritage.'),
('1984', '9780451524935', '1949-06-08', 'English', 328, 1, 1, 'A dystopian novel by George Orwell published in 1949, which follows the life of Winston Smith in a totalitarian state.'),
('Pride and Prejudice', '9780141439518', '1813-01-28', 'English', 432, 1, 5, 'A romantic novel following the character development of Elizabeth Bennet who learns about the repercussions of hasty judgments.'),
('The Shining', '9780307743657', '1977-01-28', 'English', 447, 2, 1, 'A horror novel by Stephen King about a family that becomes the caretakers of an isolated hotel with a dark past.'),
('Murder on the Orient Express', '9780062073501', '1934-01-01', 'English', 256, 2, 4, 'A detective novel featuring Hercule Poirot investigating a murder that occurred on the Orient Express train.');

-- Connect books with authors
INSERT INTO book_authors (book_id, author_id, author_role) VALUES
(1, 1, 'Primary'),
(2, 2, 'Primary'),
(3, 3, 'Primary'),
(4, 4, 'Primary'),
(5, 5, 'Primary');

-- Insert sample book copies
INSERT INTO book_copies (book_id, acquisition_date, status, condition, location, barcode) VALUES
(1, '2020-01-15', 'Available', 'Good', 'Floor 1, Section A', 'LIB-HP-001'),
(1, '2020-01-15', 'Available', 'Good', 'Floor 1, Section A', 'LIB-HP-002'),
(1, '2020-01-15', 'Checked Out', 'Good', 'Floor 1, Section A', 'LIB-HP-003'),
(2, '2019-05-20', 'Available', 'Fair', 'Floor 2, Section B', 'LIB-1984-001'),
(2, '2019-05-20', 'Available', 'Good', 'Floor 2, Section B', 'LIB-1984-002'),
(3, '2018-11-10', 'Available', 'Good', 'Floor 1, Section C', 'LIB-PP-001'),
(3, '2018-11-10', 'Under Repair', 'Poor', 'Floor 1, Section C', 'LIB-PP-002'),
(4, '2021-03-25', 'Available', 'New', 'Floor 3, Section A', 'LIB-SH-001'),
(5, '2020-07-12', 'Available', 'Good', 'Floor 2, Section C', 'LIB-ME-001'),
(5, '2020-07-12', 'Lost', 'Fair', 'Floor 2, Section C', 'LIB-ME-002');

-- Insert sample patrons
INSERT INTO patrons (first_name, last_name, email, phone, address, date_of_birth, membership_date, membership_expiry, status) VALUES
('michael', 'Smith', 'michael.smith@email.com', '555-123-4567', '123 Main St, Anytown, AN 12345', '1985-03-15', '2022-01-01', '2026-01-01', 'Active'),
('Sarah', 'michaelson', 'sarah.j@email.com', '555-234-5678', '456 Oak Ave, Sometown, ST 23456', '1990-07-22', '2022-02-15', '2026-02-15', 'Active'),
('Michael', 'Brown', 'mbrown@email.com', '555-345-6789', '789 Pine Rd, Othertown, OT 34567', '1978-11-30', '2022-03-10', '2023-03-10', 'Expired'),
('Emily', 'Davis', 'emily.davis@email.com', '555-456-7890', '101 Elm St, Yourtown, YT 45678', '1995-05-05', '2022-04-20', '2026-04-20', 'Active'),
('Robert', 'Wilson', 'rwilson@email.com', '555-567-8901', '202 Maple Dr, Theirtown, TT 56789', '1982-09-12', '2022-05-05', '2026-05-05', 'Active');

-- Insert sample staff
INSERT INTO staff (first_name, last_name, email, phone, role, hire_date, username, password_hash) VALUES
('Alice', 'Anderson', 'alice.a@library.org', '555-987-6543', 'Librarian', '2018-06-01', 'aanderson', '$2y$10$Hb8DÖfgT5RTyUIO92ADFdsf42efsGDFADO9'),
('Bob', 'Baker', 'bob.b@library.org', '555-876-5432', 'Assistant', '2019-03-15', 'bbaker', '$2y$10$JKcvBn8eJNfDSF9dGHJKsDFG234fdgDFS'),
('Carol', 'Cooper', 'carol.c@library.org', '555-765-4321', 'Manager', '2015-09-20', 'ccooper', '$2y$10$JHSLKDFhsDFBKJHBAJHSDF234dDFGSdfg'),
('David', 'Douglas', 'david.d@library.org', '555-654-3210', 'IT Support', '2020-01-10', 'ddouglas', '$2y$10$SDFGH45gdfgDFGH56dfgDFG45Ddfg'),
('Eva', 'Edwards', 'eva.e@library.org', '555-543-2109', 'Admin', '2021-11-05', 'eedwards', '$2y$10$DFG34dfgDFG34DFG45dfgDF34Gdfg');

-- Insert sample loans
INSERT INTO loans (copy_id, patron_id, checkout_date, due_date, return_date, staff_id_checkout, staff_id_return) VALUES
(3, 1, '2023-03-01', '2023-03-15', NULL, 1, NULL),
(7, 2, '2023-02-15', '2023-03-01', '2023-02-28', 2, 1),
(10, 3, '2022-12-01', '2022-12-15', NULL, 1, NULL),
(4, 4, '2023-03-05', '2023-03-19', '2023-03-25', 2, 2),
(9, 5, '2023-03-10', '2023-03-24', NULL, 1, NULL);

-- Insert sample fines
INSERT INTO fines (loan_id, fine_amount, fine_reason, fine_date, payment_status, payment_date, staff_id) VALUES
(4, 3.00, 'Late Return', '2023-03-26', 'Paid', '2023-03-26', 1),
(3, 75.00, 'Lost Item', '2023-04-01', 'Pending', NULL, NULL);

-- Insert sample reservations
INSERT INTO reservations (book_id, patron_id, reservation_date, expiry_date, status) VALUES
(1, 3, '2023-03-02', '2023-04-02', 'Active'),
(2, 4, '2023-03-05', '2023-04-05', 'Active'),
(5, 1, '2023-02-10', '2023-03-10', 'Expired');

-- Continuing from the previous section...

-- Complete the insert for events
INSERT INTO events (title, description, event_date, duration, location, max_attendees, staff_id) VALUES
('Book Club: 1984', 'Discussion of George Orwell\'s 1984', '2023-04-15 18:00:00', 120, 'Meeting Room A', 20, 1),
('Children\'s Story Time', 'Weekly story time for children ages 4-8', '2023-04-10 10:00:00', 60, 'Children\'s Area', 15, 2),
('Author Visit: Local Writers', 'Q&A session with local authors', '2023-04-20 19:00:00', 180, 'Auditorium', 50, 3),
('Introduction to Research Databases', 'Workshop on using the library\'s research resources', '2023-04-25 14:00:00', 90, 'Computer Lab', 12, 4),
('Poetry Reading Night', 'Open mic poetry reading session', '2023-04-30 18:30:00', 120, 'Reading Room', 30, 1);

-- Insert sample event attendees
INSERT INTO event_attendees (event_id, patron_id, attendance_status) VALUES
(1, 1, 'Registered'),
(1, 2, 'Registered'),
(1, 4, 'Registered'),
(2, 5, 'Registered'),
(3, 1, 'Registered'),
(3, 3, 'Registered'),
(3, 4, 'Registered'),
(4, 2, 'Registered'),
(5, 1, 'Registered'),
(5, 5, 'Registered');

-- Insert sample reviews
INSERT INTO reviews (book_id, patron_id, rating, review_text, status, moderated_by, moderation_date) VALUES
(1, 2, 5, 'An absolute classic that truly deserves its status in literature. The magical world-building is exceptional.', 'Approved', 1, '2023-01-15'),
(1, 4, 4, 'Great introduction to the series. Engaging characters and storyline.', 'Approved', 1, '2023-01-20'),
(2, 1, 5, 'A prophetic and chilling masterpiece that remains relevant today.', 'Approved', 1, '2023-02-05'),
(3, 2, 4, 'Beautifully written with witty dialogue and memorable characters.', 'Approved', 1, '2023-02-10');

-- -----------------------------------------------------
-- Indexes for improved performance
-- -----------------------------------------------------

-- Index for faster patron searches
CREATE INDEX idx_patron_name ON patrons (last_name, first_name);

-- Index for book searches
CREATE INDEX idx_book_title ON books (title);

-- Index for loan date searches
CREATE INDEX idx_loan_dates ON loans (checkout_date, due_date, return_date);

-- Index for event searches
CREATE INDEX idx_event_date ON events (event_date);

-- -----------------------------------------------------
-- Additional Stored Procedures
-- -----------------------------------------------------

-- Add a new book with a single author
DELIMITER //
CREATE PROCEDURE add_new_book(
    IN p_title VARCHAR(255),
    IN p_isbn VARCHAR(20),
    IN p_publication_date DATE,
    IN p_language VARCHAR(30),
    IN p_page_count INT,
    IN p_publisher_id INT,
    IN p_category_id INT,
    IN p_summary TEXT,
    IN p_author_id INT,
    IN p_num_copies INT,
    OUT p_book_id INT
)
BEGIN
    -- Insert the book
    INSERT INTO books (
        title, isbn, publication_date, language, 
        page_count, publisher_id, category_id, summary
    ) VALUES (
        p_title, p_isbn, p_publication_date, p_language, 
        p_page_count, p_publisher_id, p_category_id, p_summary
    );
    
    -- Get the inserted book ID
    SET p_book_id = LAST_INSERT_ID();
    
    -- Connect the book with the author
    INSERT INTO book_authors (book_id, author_id, author_role)
    VALUES (p_book_id, p_author_id, 'Primary');
    
    -- Add specified number of copies
    SET @i = 1;
    WHILE @i <= p_num_copies DO
        INSERT INTO book_copies (
            book_id, acquisition_date, status, 
            condition, barcode
        ) VALUES (
            p_book_id, CURRENT_DATE, 'Available', 
            'New', CONCAT('LIB-', REPLACE(p_isbn, '-', ''), '-', LPAD(@i, 3, '0'))
        );
        SET @i = @i + 1;
    END WHILE;
    
    SELECT CONCAT('Added ', p_title, ' with ', p_num_copies, ' copies') AS result;
END //
DELIMITER ;

-- Register a new patron
DELIMITER //
CREATE PROCEDURE register_patron(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_phone VARCHAR(20),
    IN p_address TEXT,
    IN p_date_of_birth DATE,
    IN p_membership_years INT
)
BEGIN
    DECLARE exists_count INT;
    
    -- Check if email already exists
    SELECT COUNT(*) INTO exists_count FROM patrons WHERE email = p_email;
    
    IF exists_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A patron with this email already exists';
    ELSE
        -- Insert new patron
        INSERT INTO patrons (
            first_name, last_name, email, phone, address, 
            date_of_birth, membership_date, membership_expiry, status
        ) VALUES (
            p_first_name, p_last_name, p_email, p_phone, p_address, 
            p_date_of_birth, CURRENT_DATE, 
            DATE_ADD(CURRENT_DATE, INTERVAL p_membership_years YEAR), 
            'Active'
        );
        
        SELECT CONCAT('Patron ', p_first_name, ' ', p_last_name, ' successfully registered') AS result;
    END IF;
END //
DELIMITER ;

-- Procedure to renew a loan
DELIMITER //
CREATE PROCEDURE renew_loan(
    IN p_loan_id INT,
    IN p_renewal_days INT
)
BEGIN
    DECLARE current_due_date DATE;
    DECLARE current_renewals INT;
    DECLARE max_renewals INT DEFAULT 2;
    
    -- Get current due date and renewals
    SELECT due_date, renewed_times 
    INTO current_due_date, current_renewals
    FROM loans 
    WHERE loan_id = p_loan_id AND return_date IS NULL;
    
    -- Check if loan exists and is active
    IF current_due_date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No active loan found with this ID';
    -- Check if maximum renewals reached
    ELSEIF current_renewals >= max_renewals THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Maximum number of renewals reached for this loan';
    ELSE
        -- Update due date and increment renewals
        UPDATE loans 
        SET due_date = DATE_ADD(current_due_date, INTERVAL p_renewal_days DAY),
            renewed_times = current_renewals + 1
        WHERE loan_id = p_loan_id;
        
        SELECT CONCAT('Loan renewed successfully. New due date: ', 
                     DATE_FORMAT(DATE_ADD(current_due_date, INTERVAL p_renewal_days DAY), '%Y-%m-%d')) AS result;
    END IF;
END //
DELIMITER ;

-- Generate monthly report procedure
DELIMITER //
CREATE PROCEDURE generate_monthly_report(
    IN p_year INT,
    IN p_month INT
)
BEGIN
    DECLARE start_date DATE;
    DECLARE end_date DATE;
    
    SET start_date = CONCAT(p_year, '-', LPAD(p_month, 2, '0'), '-01');
    SET end_date = LAST_DAY(start_date);
    
    -- New memberships
    SELECT COUNT(*) AS new_members 
    FROM patrons 
    WHERE membership_date BETWEEN start_date AND end_date;
    
    -- Books checked out
    SELECT COUNT(*) AS total_checkouts
    FROM loans
    WHERE checkout_date BETWEEN start_date AND end_date;
    
    -- Books returned
    SELECT COUNT(*) AS total_returns
    FROM loans
    WHERE return_date BETWEEN start_date AND end_date;
    
    -- Fines collected
    SELECT SUM(fine_amount) AS total_fines_collected
    FROM fines
    WHERE payment_status = 'Paid' 
    AND payment_date BETWEEN start_date AND end_date;
    
    -- Most popular books
    SELECT b.title, COUNT(l.loan_id) AS checkout_count
    FROM loans l
    JOIN book_copies bc ON l.copy_id = bc.copy_id
    JOIN books b ON bc.book_id = b.book_id
    WHERE l.checkout_date BETWEEN start_date AND end_date
    GROUP BY b.book_id, b.title
    ORDER BY checkout_count DESC
    LIMIT 5;
    
    -- Most active patrons
    SELECT CONCAT(p.first_name, ' ', p.last_name) AS patron_name, 
           COUNT(l.loan_id) AS activity_count
    FROM loans l
    JOIN patrons p ON l.patron_id = p.patron_id
    WHERE l.checkout_date BETWEEN start_date AND end_date
    GROUP BY p.patron_id, patron_name
    ORDER BY activity_count DESC
    LIMIT 5;
END //
DELIMITER ;

-- -----------------------------------------------------
-- Functions
-- -----------------------------------------------------

-- Calculate fine for overdue book
DELIMITER //
CREATE FUNCTION calculate_overdue_fine(
    p_due_date DATETIME,
    p_return_date DATETIME,
    p_daily_rate DECIMAL(10,2)
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE days_overdue INT;
    DECLARE fine_amount DECIMAL(10,2);
    
    IF p_return_date <= p_due_date THEN
        RETURN 0.00;
    END IF;
    
    SET days_overdue = DATEDIFF(p_return_date, p_due_date);
    SET fine_amount = days_overdue * p_daily_rate;
    
    RETURN fine_amount;
END //
DELIMITER ;

-- Function to check if a patron can borrow more books
DELIMITER //
CREATE FUNCTION can_borrow_more(
    p_patron_id INT,
    p_max_loans INT
) RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE current_loans INT;
    
    SELECT COUNT(*) INTO current_loans
    FROM loans
    WHERE patron_id = p_patron_id AND return_date IS NULL;
    
    IF current_loans < p_max_loans THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END //
DELIMITER ;

-- -----------------------------------------------------
-- Additional Views
-- -----------------------------------------------------

-- Popular books view
CREATE VIEW popular_books AS
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    COUNT(l.loan_id) AS checkout_count,
    AVG(r.rating) AS avg_rating,
    COUNT(DISTINCT r.review_id) AS review_count
FROM 
    books b
LEFT JOIN book_copies bc ON b.book_id = bc.book_id
LEFT JOIN loans l ON bc.copy_id = l.copy_id
LEFT JOIN reviews r ON b.book_id = r.book_id AND r.status = 'Approved'
GROUP BY 
    b.book_id, b.title, b.isbn
ORDER BY 
    checkout_count DESC;

-- Staff activity view
CREATE VIEW staff_activity AS
SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    s.role,
    COUNT(DISTINCT l_checkout.loan_id) AS checkouts_processed,
    COUNT(DISTINCT l_return.loan_id) AS returns_processed,
    COUNT(DISTINCT f.fine_id) AS fines_processed,
    COUNT(DISTINCT e.event_id) AS events_managed
FROM 
    staff s
LEFT JOIN loans l_checkout ON s.staff_id = l_checkout.staff_id_checkout
LEFT JOIN loans l_return ON s.staff_id = l_return.staff_id_return
LEFT JOIN fines f ON s.staff_id = f.staff_id
LEFT JOIN events e ON s.staff_id = e.staff_id
GROUP BY 
    s.staff_id, staff_name, s.role;

-- Category distribution view
CREATE VIEW category_distribution AS
SELECT 
    c.category_id,
    c.category_name,
    COUNT(b.book_id) AS book_count,
    COUNT(DISTINCT bc.copy_id) AS copy_count,
    COUNT(DISTINCT l.loan_id) AS loan_count
FROM 
    categories c
LEFT JOIN books b ON c.category_id = b.category_id
LEFT JOIN book_copies bc ON b.book_id = bc.book_id
LEFT JOIN loans l ON bc.copy_id = l.copy_id
GROUP BY 
    c.category_id, c.category_name;

-- -----------------------------------------------------
-- Ending message
-- -----------------------------------------------------

-- Display completion message
SELECT 'Library Management System Database Setup Complete' AS 'Status';