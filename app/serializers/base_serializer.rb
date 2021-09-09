class BaseSerializer < ActiveModel::Serializer
  attribute :id, if: ->{ @instance_options[:with_id] }
end
