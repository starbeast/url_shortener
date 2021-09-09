class GenerateShortenedUrlsWorker < BaseWorker
  include Sidekiq::Throttled::Worker
  sidekiq_throttle concurrency: { limit: 1 }

  def perform
    ShortenedPathsService.new.generate
  end
end
