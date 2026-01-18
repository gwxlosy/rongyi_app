from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

import models
import database

# 检查数据库引擎是否成功初始化
if database.engine is None:
    print("数据库引擎未初始化，应用无法启动。")
    exit(1)

# 创建FastAPI应用实例
app = FastAPI(
    title="Rongyi App Backend",
    description="为融易手语App提供数据服务的API",
    version="1.0.0"
)

# 应用启动事件：创建数据库表
@app.on_event("startup")
def on_startup():
    print("正在尝试创建数据库表...")
    try:
        models.Base.metadata.create_all(bind=database.engine)
        print("数据库表创建成功（如果不存在）。")
    except Exception as e:
        print(f"创建数据库表时出错: {e}")

# ========== API Endpoints ===================================================

@app.get("/", tags=["Root"])
def read_root():
    return {"message": "欢迎使用融易手语App后端API"}

# --- SignWords Endpoints ---

@app.post("/words/", response_model=models.SignWord, status_code=status.HTTP_201_CREATED, tags=["SignWords"])
def create_word(word: models.SignWordCreate, db: Session = Depends(database.get_db)):
    db_word = models.SignWord(**word.dict())
    db.add(db_word)
    db.commit()
    db.refresh(db_word)
    return db_word

@app.get("/words/", response_model=List[models.SignWord], tags=["SignWords"])
def read_words_by_category(category: str, db: Session = Depends(database.get_db)):
    words = db.query(models.SignWord).filter(models.SignWord.category == category).order_by(models.SignWord.word).all()
    return words

@app.get("/words/search/", response_model=List[models.SignWord], tags=["SignWords"])
def search_words(keyword: str, db: Session = Depends(database.get_db)):
    words = db.query(models.SignWord).filter(models.SignWord.word.like(f"%{keyword}%")).all()
    return words

@app.get("/categories/", response_model=List[str], tags=["SignWords"])
def read_all_categories(db: Session = Depends(database.get_db)):
    categories = db.query(models.SignWord.category).distinct().order_by(models.SignWord.category).all()
    return [c[0] for c in categories]

@app.get("/words/{word_id}", response_model=models.SignWord, tags=["SignWords"])
def read_word_by_id(word_id: int, db: Session = Depends(database.get_db)):
    db_word = db.query(models.SignWord).filter(models.SignWord.id == word_id).first()
    if db_word is None:
        raise HTTPException(status_code=404, detail="Word not found")
    return db_word

# --- Users Endpoints ---

@app.post("/users/", response_model=models.User, status_code=status.HTTP_201_CREATED, tags=["Users"])
def register_user(user: models.UserCreate, db: Session = Depends(database.get_db)):
    db_user = db.query(models.User).filter(models.User.account == user.account).first()
    if db_user:
        raise HTTPException(status_code=400, detail="账号已存在")
    # 注意：生产环境中密码应该被哈希
    new_user = models.User(account=user.account, password=user.password)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@app.post("/users/login", response_model=models.User, tags=["Users"])
def login_user(user: models.UserCreate, db: Session = Depends(database.get_db)):
    db_user = db.query(models.User).filter(models.User.account == user.account, models.User.password == user.password).first()
    if db_user is None:
        raise HTTPException(status_code=401, detail="账号或密码错误")
    return db_user

@app.get("/users/{user_id}", response_model=models.User, tags=["Users"])
def read_user_by_id(user_id: int, db: Session = Depends(database.get_db)):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

# --- Feedbacks Endpoints ---

@app.post("/feedbacks/", response_model=models.Feedback, status_code=status.HTTP_201_CREATED, tags=["Feedbacks"])
def save_feedback(feedback: models.FeedbackCreate, db: Session = Depends(database.get_db)):
    # 检查用户是否存在
    db_user = db.query(models.User).filter(models.User.id == feedback.user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail=f"User with id {feedback.user_id} not found")
    
    db_feedback = models.Feedback(**feedback.dict())
    db.add(db_feedback)
    db.commit()
    db.refresh(db_feedback)
    return db_feedback

@app.get("/users/{user_id}/feedbacks/", response_model=List[models.Feedback], tags=["Feedbacks"])
def read_user_feedbacks(user_id: int, db: Session = Depends(database.get_db)):
    feedbacks = db.query(models.Feedback).filter(models.Feedback.user_id == user_id).order_by(models.Feedback.create_time.desc()).all()
    return feedbacks

@app.delete("/feedbacks/{feedback_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Feedbacks"])
def delete_feedback(feedback_id: int, db: Session = Depends(database.get_db)):
    db_feedback = db.query(models.Feedback).filter(models.Feedback.id == feedback_id).first()
    if db_feedback is None:
        raise HTTPException(status_code=404, detail="Feedback not found")
    db.delete(db_feedback)
    db.commit()
    return

@app.delete("/users/{user_id}/feedbacks/", status_code=status.HTTP_204_NO_CONTENT, tags=["Feedbacks"])
def clear_user_feedbacks(user_id: int, db: Session = Depends(database.get_db)):
    num_deleted = db.query(models.Feedback).filter(models.Feedback.user_id == user_id).delete()
    db.commit()
    if num_deleted == 0:
        # 即使没有反馈被删除，操作也是成功的
        pass
    return
