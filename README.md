This repository contains two projects that showcase MySQL database design and API implementation skills:

## Project 1: Library Management System Database
A comprehensive MySQL database for managing library operations.

## Project 2: Task Management API
A RESTful API built with FastAPI and MySQL for task management.

---

## Project 1: Library Management System Database

### Overview
A complete relational database system that manages books, members, borrowing records, staff, and library branch operations.

### Features
- **Member Management**: Track member details, contact information, and membership status
- **Book Catalog**: Organize books by title, author, genre, and availability
- **Borrowing System**: Monitor book checkouts, returns, and due dates
- **Staff Records**: Manage employee information and roles
- **Multi-branch Support**: Handle operations across different library locations

### Database Schema
The database includes the following interconnected tables:
- `members`
- `books`
- `authors`
- `genres`
- `borrowing_records`
- `staff`
- `branches`

### Entity Relationships
- One book can have multiple authors (M:M)
- One book can belong to multiple genres (M:M)
- A member can borrow multiple books (1:M)
- Each branch has multiple staff members (1:M)
- Each borrowing record links one book to one member (M:M with attributes)

### Implementation Details
- Primary and foreign key constraints for data integrity
- Proper indexing for performance optimization
- Check constraints for data validation
- Triggers for automated date management
- Sample data for testing and demonstration

### How to Use
1. Import the SQL file into your MySQL server:
```bash
mysql -u username -p < library_management.sql
```
2. Explore the database structure and sample data
3. Run queries to test functionality

---

## Project 2: Task Management API

### Overview
A RESTful CRUD API built with FastAPI and MySQL for managing tasks, organizing them into projects, and assigning them to users.

### Features
- User management (create, read, delete)
- Project management (create, read, update, delete)
- Task management with priorities and status tracking
- Filter tasks by status, project, and user
- Relationships between users, projects, and tasks

### Database Schema
The application uses three main tables:
- `users`: Stores user information
- `projects`: Organizes tasks into logical groups
- `tasks`: Contains task details with priority and status

### API Endpoints

#### Users
- `POST /users/` - Create a new user
- `GET /users/` - List all users
- `GET /users/{user_id}` - Get a specific user
- `DELETE /users/{user_id}` - Delete a user

#### Projects
- `POST /projects/?user_id={user_id}` - Create a new project
- `GET /projects/` - List all projects
- `GET /projects/user/{user_id}` - List projects for a specific user
- `GET /projects/{project_id}` - Get a specific project with its tasks
- `PUT /projects/{project_id}` - Update a project
- `DELETE /projects/{project_id}` - Delete a project

#### Tasks
- `POST /tasks/?user_id={user_id}` - Create a new task
- `GET /tasks/` - List all tasks
- `GET /tasks/?status={status}&project_id={project_id}` - Filter tasks
- `GET /tasks/user/{user_id}` - List tasks for a specific user
- `GET /tasks/{task_id}` - Get a specific task
- `PUT /tasks/{task_id}` - Update a task
- `DELETE /tasks/{task_id}` - Delete a task

### Technologies Used
- **Backend**: FastAPI (Python)
- **Database**: MySQL
- **ORM**: SQLAlchemy
- **API Documentation**: Swagger UI / ReDoc (built into FastAPI)

### Setup Instructions

#### Prerequisites
- Python 3.8+
- MySQL Server
- pip (Python package manager)

#### Database Setup
1. Create a MySQL database:
```bash
mysql -u your_username -p < setup.sql
```

#### Application Setup
1. Navigate to the task-manager-api directory
2. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```
3. Install dependencies:
```bash
pip install -r requirements.txt
```
4. Configure database connection in `.env` file
5. Run the application:
```bash
uvicorn app.main:app --reload
```

The API will be available at http://localhost:8000 with documentation at http://localhost:8000/docs

---

## Learning Outcomes

Through these projects, the following skills are demonstrated:

1. **Database Design**:
   - Normalization principles
   - Relationship modeling
   - Constraint implementation

2. **SQL Programming**:
   - Table creation with proper constraints
   - Data insertion and manipulation
   - Advanced SQL features (views, indexes, triggers)

3. **API Development**:
   - RESTful endpoint design
   - Request/response handling
   - Input validation

4. **Backend Programming**:
   - Python with FastAPI
   - ORM implementation with SQLAlchemy
   - Error handling and status codes

5. **Software Architecture**:
   - Modular code organization
   - Separation of concerns
   - API documentation
