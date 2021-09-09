# frozen_string_literal: true

class BaseWorker
  include Sidekiq::Worker
  sidekiq_options retry: 0, queue: :default

  sidekiq_retries_exhausted do |msg, _e|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end
end
