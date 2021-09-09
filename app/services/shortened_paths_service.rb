# frozen_string_literal: true

class ShortenedPathsService
  REDIS_KEY = 'unique_shortened_paths'
  THRESHOLD = 5_000

  def generate(limit = THRESHOLD)
    REDIS_POOL.with do |conn|
      existing_keys = conn.scard(REDIS_KEY)
      next if existing_keys > limit

      (THRESHOLD - existing_keys).times.each_slice(50) do |slice|
        conn.sadd(REDIS_KEY, slice.map { SecureRandom.alphanumeric(10) })
      end
    end
  end

  def lookup
    REDIS_POOL.with do |conn|
      conn.spop(REDIS_KEY)
    end
  end
end
