import mysql.connector
import argparse
import logging
import requests
import gevent
from stats_management import RequestStats
from datetime import datetime, timedelta

# MySQL 데이터베이스 연결 설정
db_config = {
    'user': 'root',      
    'password': 'test1234',   
    'host': 'database-eof.cnakai2m8xfm.ap-northeast-1.rds.amazonaws.com',
    'database': 'api'    
}

def get_db_connection():
    conn = mysql.connector.connect(**db_config)
    return conn, conn.cursor()

# result 테이블 생성
conn, c = get_db_connection()
c.execute('''CREATE TABLE IF NOT EXISTS spike (
    test_id INT PRIMARY KEY,
    Failures INT,
    avg_response_time DECIMAL(10, 2),
    num_user INT,
    load_duration TIME)''')

c.execute('''CREATE TABLE IF NOT EXISTS incremental (
    count INT,
    id INT AUTO_INCREMENT PRIMARY KEY,
    test_id INT,
    RPS DECIMAL(10, 2),
    Failures_per_second DECIMAL(10, 2),
    avg_response_time DECIMAL(10, 2),
    number_of_users INT,
    recorded_time TIME)''')
conn.commit()
conn.close()

# 가상의 사용자 클래스 정의 : 각 사용자가 요청을 보내는 역할
class User:
    def __init__(self, environment, url):
        self.environment = environment
        self.url = url  

    def do_work(self):
        try:
            response = requests.get(self.url)
            response.raise_for_status()
            response_time = response.elapsed.total_seconds() * 1000
            content_length = len(response.content)
            
            if self.environment.stats:
                self.environment.stats.log_request('GET', self.url, response_time, content_length)
            self.environment.load_tester.response_times.append(response_time)  
            logging.debug(f"Request to {self.url} successful. Response time: {response_time} ms, Content length: {content_length} bytes")
        
        except requests.RequestException as e:
            self.environment.load_tester.failures += 1 
            logging.error(f"An error occurred while requesting {self.url}: {e}")

# 부하 테스트 클래스 정의
class LoadTester:
    def __init__(self, environment):
        self.environment = environment
        self.response_times = []  
        self.failures = 0 
        self.request_count = 0
        self.start_time = datetime.now()
        self.last_recorded_time = self.start_time

    def spawn_users(self, user_count, url):
        users = [] 
        greenlets = [] 
        for _ in range(user_count):
            user = User(self.environment, url)
            users.append(user)
            greenlets.append(gevent.spawn(user.do_work)) 
        gevent.joinall(greenlets) 
        self.request_count += user_count
        return users 

    def add_users_periodically(self, initial_users, additional_users, interval_time, repeat_count, url, test_id, count):
        self.spawn_users(initial_users, url)
        for i in range(repeat_count + 1):
            for _ in range(interval_time):
                gevent.sleep(1)
                self.record_incremental_stats(test_id, count)
            self.spawn_users(additional_users, url)

    def calculate_average_response_time(self):
        if self.response_times:
            return sum(self.response_times) / len(self.response_times)
        else:
            return 0

    def calculate_failure_rate(self):
        total_requests = len(self.response_times) + self.failures
        if total_requests > 0:
            return (self.failures / total_requests) * 100
        else:
            return 0
    
    def record_incremental_stats(self, test_id, count):
        conn, c = get_db_connection()
        current_time = datetime.now()
        average_response_time = self.calculate_average_response_time()
        failures_per_second = self.failures / len(self.response_times) if self.response_times else 0
        elapsed_time = (current_time - self.last_recorded_time).total_seconds()
        rps = self.request_count / elapsed_time if elapsed_time > 0 else 0
        self.last_recorded_time = current_time

        c.execute('''INSERT INTO incremental (count, test_id, RPS, Failures_per_second, avg_response_time, number_of_users, recorded_time)
                     VALUES (%s, %s, %s, %s, %s, %s, %s)''',
                  (count, test_id, rps, failures_per_second, average_response_time, len(self.response_times), current_time))
        conn.commit()
        conn.close()

    def record_final_stats_spike(self, test_id, load_duration):
        conn, c = get_db_connection()
        average_response_time = self.calculate_average_response_time()
        failure_rate = self.calculate_failure_rate()
        num_users = len(self.response_times)

        c.execute('SELECT * FROM spike WHERE test_id = %s', (test_id,))
        exists = c.fetchone()
        c.execute('SELECT load_duration FROM spike WHERE test_id = %s', (test_id,))
        beforeLoadDuration = c.fetchone()
        
        if exists:
            c.execute('UPDATE spike SET load_duration = %s WHERE test_id = %s', (str(load_duration), test_id,))
            conn.commit()
            c.execute('SELECT load_duration FROM spike WHERE test_id = %s', (test_id,))
            newLoadDuration = c.fetchone()
        else:
            c.execute('''INSERT INTO spike (test_id, Failures, avg_response_time, num_user, load_duration)
                         VALUES (%s, %s, %s, %s, %s)''',
                      (test_id, failure_rate, average_response_time, num_users, str(load_duration)))
            conn.commit()
        conn.close()

class TestEnvironment:
    def __init__(self):
        self.stats = RequestStats()
        self.load_tester = LoadTester(self)

def setup_test():
    logging.basicConfig(level=logging.DEBUG)
    environment = TestEnvironment()
    return environment.load_tester

def get_count(test_id):
    conn, c = get_db_connection()
    c.execute("SELECT MAX(count) FROM incremental WHERE test_id=%s", (test_id,))
    result = c.fetchone()
    conn.close()
    if result[0] is None:
        return 1
    else:
        return result[0] + 1
        
def main(url, initial_user_count, additional_user_count, interval_time, repeat_count, test_id):
    load_tester = setup_test()
    count = get_count(test_id)
    start_time = datetime.now() 
    
    if additional_user_count == 0 or interval_time == 0 or repeat_count == 0:
        load_tester.spawn_users(initial_user_count, url)
        end_time = datetime.now() 
        load_duration = end_time - start_time 
        load_tester.record_final_stats_spike(test_id, load_duration)
    else:
        load_tester.add_users_periodically(initial_user_count, additional_user_count, interval_time, repeat_count, url, test_id, count)
    
    average_response_time = load_tester.calculate_average_response_time()
    failure_rate = load_tester.calculate_failure_rate()
    load_duration = datetime.now() - start_time
    
    print(f"######## Average Response Time: {average_response_time} ms ########")
    print(f"######## Failure Rate: {failure_rate}% ########")
    print(f"######## Load Duration: {load_duration} ########")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Load testing script parameters.')
    parser.add_argument('--url', type=str, required=True, help='Target URL for load testing')
    parser.add_argument('--initial_user_count', type=int, required=True, help='Initial number of users')
    parser.add_argument('--additional_user_count', type=int, required=True, help='Number of additional users to add periodically')
    parser.add_argument('--interval_time', type=int, required=True, help='Interval in seconds between adding additional users')
    parser.add_argument('--repeat_count', type=int, required=True, help='Number of times to add additional users')
    parser.add_argument('--test_id', type=int, required=True, help='Test ID')

    args = parser.parse_args()

    main(
        url=args.url,
        initial_user_count=args.initial_user_count,
        additional_user_count=args.additional_user_count,
        interval_time=args.interval_time,
        repeat_count=args.repeat_count,
        test_id=args.test_id
    )
