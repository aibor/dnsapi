class Comment < ActiveRecord::Base
  belongs_to :domain, inverse_of: :comments

  validates :domain_id, presence: true
  validates :domain, associated: true
end
