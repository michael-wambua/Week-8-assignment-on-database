from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from .. import models, schemas, database
from ..database import get_db

router = APIRouter(
    prefix="/tasks",
    tags=["tasks"],
    responses={404: {"description": "Not found"}},
)

@router.post("/", response_model=schemas.Task, status_code=status.HTTP_201_CREATED)
def create_task(task: schemas.TaskCreate, user_id: int, db: Session = Depends(get_db)):
    # Check if user exists
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Check if project exists if project_id is provided
    if task.project_id:
        project = db.query(models.Project).filter(models.Project.id == task.project_id).first()
        if not project:
            raise HTTPException(status_code=404, detail="Project not found")
    
    db_task = models.Task(**task.dict(), user_id=user_id)
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

@router.get("/", response_model=List[schemas.Task])
def read_tasks(
    skip: int = 0, 
    limit: int = 100, 
    status: Optional[schemas.StatusEnum] = None,
    project_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    query = db.query(models.Task)
    
    if status:
        query = query.filter(models.Task.status == status)
    
    if project_id:
        query = query.filter(models.Task.project_id == project_id)
    
    tasks = query.offset(skip).limit(limit).all()
    return tasks

@router.get("/user/{user_id}", response_model=List[schemas.Task])
def read_user_tasks(
    user_id: int, 
    status: Optional[schemas.StatusEnum] = None,
    db: Session = Depends(get_db)
):
    query = db.query(models.Task).filter(models.Task.user_id == user_id)
    
    if status:
        query = query.filter(models.Task.status == status)
    
    tasks = query.all()
    return tasks

@router.get("/{task_id}", response_model=schemas.Task)
def read_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return db_task

@router.put("/{task_id}", response_model=schemas.Task)
def update_task(task_id: int, task: schemas.TaskUpdate, db: Session = Depends(get_db)):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # Check if project exists if project_id is being updated
    if task.project_id is not None:
        project = db.query(models.Project).filter(models.Project.id == task.project_id).first()
        if not project and task.project_id != None:
            raise HTTPException(status_code=404, detail="Project not found")
    
    task_data = task.dict(exclude_unset=True)
    for key, value in task_data.items():
        setattr(db_task, key, value)
    
    db.commit()
    db.refresh(db_task)
    return db_task

@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    
    db.delete(db_task)
    db.commit()
    return None