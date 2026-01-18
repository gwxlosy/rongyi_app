import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import logging

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 从 .env 文件加载环境变量 (主要用于本地开发)
load_dotenv()

# 从环境变量中获取数据库连接URL
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    logger.error("错误：DATABASE_URL 环境变量未设置。")
    raise ValueError("请设置 DATABASE_URL 环境变量")

# 检查是否是PostgreSQL的URL
if not DATABASE_URL.startswith("postgresql://") and not DATABASE_URL.startswith("postgres://"):
    logger.warning(f"提供的DATABASE_URL '{DATABASE_URL[:20]}...' 可能不是一个标准的PostgreSQL连接字符串。")

engine = None
SessionLocal = None

try:
    # 创建数据库引擎
    engine = create_engine(DATABASE_URL)
    
    # 创建一个SessionLocal类，用于创建数据库会话
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    
    logger.info("数据库连接成功建立。")

except Exception as e:
    logger.error(f"数据库连接失败: {e}")
    # 在实际生产中，你可能希望程序在这里退出或进入重试逻辑

# 创建一个Base类，我们的ORM模型将继承这个类
Base = declarative_base()

# 依赖注入函数：获取数据库会话
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
