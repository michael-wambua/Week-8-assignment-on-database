```markdown
# Task Management API

A RESTful CRUD API built with FastAPI and MySQL for managing tasks, organizing them into projects, and assigning them to users.

## Features

- User management (create, read, delete)
- Project management (create, read, update, delete)
- Task management with priorities and status tracking (create, read, update, delete)
- Filter tasks by status, project, and user
- Relationships between users, projects, and tasks

## Database Schema

The application uses three main tables:
- `users`: Stores user information
- `projects`: Organizes tasks into logical groups
- `tasks`: Contains task details with priority and status

## Setup Instructions

### Prerequisites
- Python 3.8+
- MySQL Server
- pip (Python package manager)

### Setup Database
1. Create a MySQL database:
```bash
mysql -u your_username -p < setup.sql
```

### Install Requirements
1. Clone this repository
2. Navigate to the project directory
3. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```
4. Install dependencies:
```bash
pip install -r requirements.txt
```

### Configure Environment
Create a `.env` file in the root directory with the following content:
```
DATABASE_URL=mysql+pymysql://username:password@localhost/task_manager
```

### Run the Application
```bash
uvicorn app.main:app --reload
```

The API will be available at http://localhost:8000

API documentation is available at:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API Endpoints

### Users
- `POST /users/` - Create a new user
- `GET /users/` - List all users
- `GET /users/{user_id}` - Get a specific user
- `DELETE /users/{user_id}` - Delete a user

### Projects
- `POST /projects/?user_id={user_id}` - Create a new project
- `GET /projects/` - List all projects
- `GET /projects/user/{user_id}` - List projects for a specific user
- `GET /projects/{project_id}` - Get a specific project with its tasks
- `PUT /projects/{project_id}` - Update a project
- `DELETE /projects/{project_id}` - Delete a project

### Tasks
- `POST /tasks/?user_id={user_id}` - Create a new task
- `GET /tasks/` - List all tasks
- `GET /tasks/?status={status}&project_id={project_id}` - Filter tasks
- `GET /tasks/user/{user_id}` - List tasks for a specific user
- `GET /tasks/{task_id}` - Get a specific task
- `PUT /tasks/{task_id}` - Update a task
- `DELETE /tasks/{task_id}` - Delete a task
```