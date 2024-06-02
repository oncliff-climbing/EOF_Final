import time
from collections import defaultdict

class StatsEntry:
    """개별 요청 통계를 관리하는 클래스입니다."""

    def __init__(self, name, method):
        self.name = name
        self.method = method
        self.num_requests = 0
        self.num_failures = 0
        self.total_response_time = 0
        self.min_response_time = None
        self.max_response_time = 0
        self.response_times = defaultdict(int)  # 응답 시간 분포

    def log_request(self, response_time):
        """요청을 로깅하고 통계를 업데이트합니다."""
        self.num_requests += 1
        self.total_response_time += response_time
        if self.min_response_time is None or response_time < self.min_response_time:
            self.min_response_time = response_time
        if response_time > self.max_response_time:
            self.max_response_time = response_time
        # 응답 시간을 특정 구간으로 라운딩하여 카운트합니다.
        rounded_response_time = self.round_response_time(response_time)
        self.response_times[rounded_response_time] += 1

    def log_failure(self):
        """실패를 로깅합니다."""
        self.num_failures += 1

    def round_response_time(self, response_time):
        """응답 시간을 라운딩합니다."""
        if response_time < 100:
            return round(response_time)
        elif response_time < 1000:
            return round(response_time, -1)
        elif response_time < 10000:
            return round(response_time, -2)
        else:
            return round(response_time, -3)

class RequestStats:
    """모든 요청의 통계를 관리하는 클래스입니다."""

    def __init__(self):
        self.entries = {}

    def get_entry(self, name, method):
        """주어진 이름과 메소드에 해당하는 StatsEntry 인스턴스를 반환합니다."""
        if (name, method) not in self.entries:
            self.entries[(name, method)] = StatsEntry(name, method)
        return self.entries[(name, method)]

    def log_request(self, method, name, response_time, content_length):
        """요청을 로깅하고 관련 통계를 업데이트합니다."""
        entry = self.get_entry(name, method)
        entry.log_request(response_time)

    def log_failure(self, method, name):
        """요청 실패를 로깅합니다."""
        entry = self.get_entry(name, method)
        entry.log_failure()

    def serialize_stats(self):
        """모든 통계 데이터를 직렬화합니다."""
        return {key: vars(entry) for key, entry in self.entries.items()}

# 사용 예
# stats = RequestStats()
# stats.log_request("GET", "test_request", 120, 500)
# stats.log_failure("GET", "test_request")
# print(stats.serialize_stats())
