# since most of the operations are rather similar we're delegating common login to a mixin
# all the business logic should happen in the services
module GenericCrud
  extend ActiveSupport::Concern

  def create
    result = service.new(create_params).create
    return fail_json(result.errors, result.error_code || :unprocessable_entity) unless result.success?

    render json: { object_key => serialize_data(result.object, create_options) }.to_json, status: :created
  end

  def show
    result = service.new(id: params[:id]).fetch
    return fail_json(result.errors, result.error_code || :unprocessable_entity) unless result.success?

    render json: {
      object_key => serialize_data(result.object, show_options.reverse_merge(with_id: true))
    }.to_json, status: 200
  end

  def index
    result = service.new(index_params).fetch_all(page, per_page)
    return fail_json(result.errors, result.error_code || :unprocessable_entity) unless result.success?

    render json: {
      objects_key => serialize_data(result.objects, index_options.reverse_merge(with_id: true)),
      :pagination => pagination_data(result.objects)
    }.to_json, status: 200
  end

  def destroy
    result = service.new(destroy_params).destroy
    return fail_json(result.errors, result.error_code || :unprocessable_entity) unless result.success?

    head :ok
  end

  def update; end

  private

  def show_options
    {}
  end

  alias create_options show_options
  alias index_options show_options
  alias index_params show_options

  def destroy_params
    { id: params[:id] }
  end

  def object_key
    controller_name.singularize
  end

  def objects_key
    controller_name
  end

  def service
    klass = "#{controller_name.camelize}Service".safe_constantize
    raise StandardError "Service class for #{controller_name} was not found" if klass.nil?

    klass
  end
end
