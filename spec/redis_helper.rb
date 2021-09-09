module RedisHelper
  def with_clean_redis
    REDIS_POOL.with(&:flushall)
    begin
      yield
    ensure
      REDIS_POOL.with do |conn|
        conn.flushall
        conn.quit
      end
    end
  end
end
