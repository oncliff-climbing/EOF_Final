import traceback
from fastapi import FastAPI, HTTPException, WebSocket
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import mysql.connector
from mysql.connector import pooling
import subprocess
import logging
import asyncio

app = FastAPI()

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# DB 연결 풀 설정
db_config = {
    'user': 'root',
    'password': 'test1234',
    'host': 'database-eof.cnakai2m8xfm.ap-northeast-1.rds.amazonaws.com',
    'database': 'api'
}

connection_pool = mysql.connector.pooling.MySQLConnectionPool(
    pool_name="mypool",
    pool_size=10,
    **db_config
)

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
        print(f"Error: {e}")
        
        
#헬스 체크
@app.get("/health")
async def health_check():
    return JSONResponse(status_code=200, content={"status": "ok"})

@app.get("/")
async def read_root():
    return {"message": "Hello World"}

# 테스트 목록 불러오기
@app.get('/testcase')
async def read_list():
    try:
        conn = connection_pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM test")
        result = cursor.fetchall()
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    finally:
        cursor.close()
        conn.close()

# 테스트 생성
@app.post('/testcase')
async def create_test(data: TestData):
    try:
        conn = connection_pool.get_connection()
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO test (target_url, test_name, user_num, user_plus_num, interval_time, plus_count)
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            (data.target_url, data.test_name, data.user_num, data.user_plus_num, data.interval_time, data.plus_count)
        )
        conn.commit()
        test_id = cursor.lastrowid
        return {"test_id": test_id, "test_name": data.test_name}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    finally:
        cursor.close()
        conn.close()

# 테스트 삭제
@app.delete("/testcase/{test_id}")
async def delete_test(test_id: int):
    try:
        conn = connection_pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM test WHERE test_id = %s", (test_id,))
        conn.commit()
        return {"message": "Test deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    finally:
        cursor.close()
        conn.close()

# 테스트 실행
@app.get("/testcase/{test_id}/execute/")
async def execute_test(test_id: int):
    try:
        conn = connection_pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM test WHERE test_id = %s", (test_id,))
        test_data = cursor.fetchone()
        if test_data:
            test_id, target_url, test_name, user_num, user_plus_num, interval_time, plus_count = test_data
            await run_load_testing_script(target_url, user_num, user_plus_num, interval_time, plus_count, test_id)
            return {
                "test_id": test_id,
                "target_url": target_url,
                "test_name": test_name,
                "user_num": user_num,
                "user_plus_num": user_plus_num,
                "interval_time": interval_time,
                "plus_count": plus_count,
            }
        else:
            raise HTTPException(status_code=404, detail="Testcase not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    finally:
        cursor.close()
        conn.close()
    
# 테스트 결과값 반환
@app.get("/testcase/{test_id}/stats/")
async def stats(test_id: int):
    try:
        conn = connection_pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT MAX(count) FROM incremental WHERE test_id = %s", (test_id,))
        count = cursor.fetchone()[0]
        cursor.execute("SELECT * FROM incremental WHERE test_id = %s and count = %s", (test_id, count))
        updated_stats = cursor.fetchall()
        if updated_stats:
            return updated_stats
        else:
            raise HTTPException(status_code=404, detail="No updated stats found for this test_id")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    finally:
        cursor.close()
        conn.close()

# 테스트 결과값 반환
@app.get("/testcase/{test_id}/spike-stats/")
async def pre_stats(test_id: int):
    try:
        conn = connection_pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM spike WHERE test_id = %s", (test_id,))
        updated_stats = cursor.fetchall()
        if updated_stats:
            return updated_stats
        else:
            raise HTTPException(status_code=404, detail="No updated stats found for this test_id")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    finally:
        cursor.close()
        conn.close()

@app.get("/testcase/{id}/results")
async def get_id_list(id: int):
    try:
        conn = connection_pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT count FROM incremental WHERE test_id = %s", (id,))
        idList = cursor.fetchall()
        idList = set(idList)
        idList = [t[0] for t in idList]
        idList.sort()
        if idList:
            return idList
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    finally:
        cursor.close()
        conn.close()

# 비교할 테스트 결과값 반환
@app.get("/testcase/{test_id}/stats/{selectedResult}")
async def stats(test_id: int, selectedResult: int):
    try:
        conn = connection_pool.get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM incremental WHERE test_id = %s AND count = %s", (test_id, selectedResult,))
        test_cases = cursor.fetchall()
        return test_cases
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {str(e)}")
    finally:
        cursor.close()
        conn.close()
