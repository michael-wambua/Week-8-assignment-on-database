from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import tasks, projects, users
from . import models
from .database import engine

# Create tables in the database
models.Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Task Manager API",
    description="A simple task management API built with FastAPI and MySQL",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For production, specify the exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(users.router)
app.include_router(projects.router)
app.include_router(tasks.router)

@app.get("/")
def read_root():
    return {
        "message": "Welcome to Task Manager API",
        "docs": "/docs",
        "endpoints": {
            "users": "/users",
            "projects": "/projects",
            "tasks": "/tasks"
        }
    }