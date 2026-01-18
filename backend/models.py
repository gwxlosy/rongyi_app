from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

from database import Base

# ================================================
# SQLAlchemy ORM Models (数据库表模型)
# ================================================

class SignWord(Base):
    __tablename__ = "sign_words"

    id = Column(Integer, primary_key=True, index=True)
    word = Column(String, nullable=False)
    category = Column(String, nullable=False, index=True)
    description = Column(String, nullable=False)
    video_path = Column(String, nullable=False)

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    account = Column(String, unique=True, index=True, nullable=False)
    password = Column(String, nullable=False) # 在实际应用中，密码应该被哈希处理
    create_time = Column(DateTime(timezone=True), server_default=func.now())

    feedbacks = relationship("Feedback", back_populates="owner")

class Feedback(Base):
    __tablename__ = "feedbacks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    type = Column(String, nullable=False)
    content = Column(String, nullable=False)
    create_time = Column(DateTime(timezone=True), server_default=func.now())

    owner = relationship("User", back_populates="feedbacks")


# ================================================
# Pydantic Models (API数据验证模型)
# ================================================

# --- SignWord Schemas ---
class SignWordBase(BaseModel):
    word: str
    category: str
    description: str
    video_path: str

class SignWordCreate(SignWordBase):
    pass

class SignWord(SignWordBase):
    id: int

    class Config:
        orm_mode = True

# --- User Schemas ---
class UserBase(BaseModel):
    account: str

class UserCreate(UserBase):
    password: str # 创建时需要密码

class User(UserBase):
    id: int
    create_time: datetime

    class Config:
        orm_mode = True

# --- Feedback Schemas ---
class FeedbackBase(BaseModel):
    type: str
    content: str

class FeedbackCreate(FeedbackBase):
    user_id: int

class Feedback(FeedbackBase):
    id: int
    user_id: int
    create_time: datetime

    class Config:
        orm_mode = True
