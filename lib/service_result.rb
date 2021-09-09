class ServiceResult
  attr_accessor :success, :errors, :error_code, :object, :objects

  def initialize(success = true)
    @success = success
    @errors = []
    @error_code = nil
  end

  def fail(messages, error_code = nil)
    @success = false
    formatted_messages = messages.is_a?(Array) ? messages : [messages]
    @errors += formatted_messages
    @error_code = error_code if error_code.present?
    self
  end

  def success?
    @success
  end

  def failed?
    !success?
  end
end
