import traceback
from fastapi import FastAPI, HTTPException, WebSocket, Depends
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Float, Time, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
import subprocess
import logging
import asyncio
import os

app = FastAPI()

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 환경 변수에서 DB 설정 가져오기
DATABASE_URL = os.getenv('DATABASE_URL', 'mysql+pymysql://root:test1234@database-eof.cnakai2m8xfm.ap-northeast-1.rds.amazonaws.com/api')

engine = create_engine(
    DATABASE_URL, pool_recycle=500, pool_size=5, max_overflow=20, echo=False, echo_pool=True
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# 모델 정의
class Test(Base):
    __tablename__ = "test"

    test_id = Column(Integer, primary_key=True, index=True)
    target_url = Column(String, index=True)
    test_name = Column(String, index=True)
    user_num = Column(Integer)
    user_plus_num = Column(Integer)
    interval_time = Column(Integer)
    plus_count = Column(Integer)

class Spike(Base):
    __tablename__ = "spike"

    test_id = Column(Integer, primary_key=True, index=True)
    Failures = Column(Integer)
    avg_response_time = Column(Float)
    num_user = Column(Integer)
    load_duration = Column(Time)

class Incremental(Base):
    __tablename__ = "incremental"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    count = Column(Integer)
    test_id = Column(Integer)
    RPS = Column(Float)
    Failures_per_second = Column(Float)
    avg_response_time = Column(Float)
    number_of_users = Column(Integer)
    recorded_time = Column(Time)

Base.metadata.create_all(bind=engine)

# 데이터를 전송하기 위한 모델 정의
class TestData(BaseModel):
    target_url: str
    test_name: str
    user_num: int
    user_plus_num: int
    interval_time: int
    plus_count: int

async def run_load_testing_script(url, initial_user_count, additional_user_count, interval_time, repeat_count, test_id):
    command = [
        "python",
        "runner.py",
        "--url", url,
        "--initial_user_count", str(initial_user_count),
        "--additional_user_count", str(additional_user_count),
        "--interval_time", str(interval_time),
        "--repeat_count", str(repeat_count),
        "--test_id", str(test_id)
    ]
    try:
        process = await asyncio.create_subprocess_exec(*command)
        await process.wait()
    except Exception as e:
        logger.error(f"Error: {e}")

# 헬스 체크
@app.get("/health")
async def health_check():
    return JSONResponse(status_code=200, content={"status": "ok"})

@app.get("/")
async def read_root():
    return {"message": "Hello World"}

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 테스트 목록 불러오기
@app.get('/testcase')
async def read_list(db: Session = Depends(get_db)):
    try:
        tests = db.query(Test).all()
        return tests
    except Exception as e:
        logger.error(f"Error fetching test cases: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")

# 테스트 생성
@app.post('/testcase')
async def create_test(data: TestData, db: Session = Depends(get_db)):
    try:
        test = Test(
            target_url=data.target_url,
            test_name=data.test_name,
            user_num=data.user_num,
            user_plus_num=data.user_plus_num,
            interval_time=data.interval_time,
            plus_count=data.plus_count
        )
        db.add(test)
        db.commit()
        db.refresh(test)
        return {"test_id": test.test_id, "test_name": test.test_name}
    except Exception as e:
        logger.error(f"Error creating test: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")

# 테스트 삭제
@app.delete("/testcase/{test_id}")
async def delete_test(test_id: int, db: Session = Depends(get_db)):
    try:
        test = db.query(Test).filter(Test.test_id == test_id).first()
        if test is None:
            raise HTTPException(status_code=404, detail="Test not found")
        db.delete(test)
        db.commit()
        return {"message": "Test deleted successfully"}
    except Exception as e:
        logger.error(f"Error deleting test: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")

# 테스트 실행
@app.get("/testcase/{test_id}/execute/")
async def execute_test(test_id: int, db: Session = Depends(get_db)):
    try:
        test = db.query(Test).filter(Test.test_id == test_id).first()
        if test:
            await run_load_testing_script(test.target_url, test.user_num, test.user_plus_num, test.interval_time, test.plus_count, test.test_id)
            return {
                "test_id": test.test_id,
                "target_url": test.target_url,
                "test_name": test.test_name,
                "user_num": test.user_num,
                "user_plus_num": test.user_plus_num,
                "interval_time": test.interval_time,
                "plus_count": test.plus_count,
            }
        else:
            raise HTTPException(status_code=404, detail="Testcase not found")
    except Exception as e:
        logger.error(f"Error executing test: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    
# 테스트 결과값 반환 (예제 테이블과 컬럼 설정 필요)
@app.get("/testcase/{test_id}/stats/")
async def stats(test_id: int, db: Session = Depends(get_db)):
    try:
        # 여기에 결과값을 가져오는 쿼리를 추가
        # 예제에서는 임의의 쿼리 사용
        results = db.execute("SELECT MAX(count) FROM incremental WHERE test_id = :test_id", {'test_id': test_id}).fetchone()
        count = results[0] if results else None
        if count:
            updated_stats = db.execute("SELECT * FROM incremental WHERE test_id = :test_id AND count = :count", {'test_id': test_id, 'count': count}).fetchall()
            return updated_stats
        else:
            raise HTTPException(status_code=404, detail="No updated stats found for this test_id")
    except Exception as e:
        logger.error(f"Error fetching stats: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")

# 테스트 결과값 반환 (예제 테이블과 컬럼 설정 필요)
@app.get("/testcase/{test_id}/spike-stats/")
async def pre_stats(test_id: int, db: Session = Depends(get_db)):
    try:
        # 여기에 결과값을 가져오는 쿼리를 추가
        # 예제에서는 임의의 쿼리 사용
        updated_stats = db.execute("SELECT * FROM spike WHERE test_id = :test_id", {'test_id': test_id}).fetchall()
        if updated_stats:
            return updated_stats
        else:
            raise HTTPException(status_code=404, detail="No updated stats found for this test_id")
    except Exception as e:
        logger.error(f"Error fetching spike stats: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")

@app.get("/testcase/{id}/results")
async def get_id_list(id: int, db: Session = Depends(get_db)):
    try:
        results = db.execute("SELECT count FROM incremental WHERE test_id = :test_id", {'test_id': id}).fetchall()
        id_list = {result[0] for result in results}
        id_list = sorted(id_list)
        return id_list if id_list else []
    except Exception as e:
        logger.error(f"Error fetching results list: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")

# 비교할 테스트 결과값 반환 (예제 테이블과 컬럼 설정 필요)
@app.get("/testcase/{test_id}/stats/{selectedResult}")
async def stats(test_id: int, selectedResult: int, db: Session = Depends(get_db)):
    try:
        test_cases = db.execute("SELECT * FROM incremental WHERE test_id = :test_id AND count = :selectedResult", {'test_id': test_id, 'selectedResult': selectedResult}).fetchall()
        return test_cases
    except Exception as e:
        logger.error(f"Error fetching stats for selected result: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
