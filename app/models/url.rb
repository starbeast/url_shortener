class Url < ApplicationRecord
  belongs_to :user, optional: true
  self.primary_key = :shortened_url

  validates :url, :shortened_url, presence: true
end
