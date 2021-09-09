class BaseService
  attr_reader :result

  def initialize(params = {})
    @params = params.to_h
    @result = ServiceResult.new
  end
end
