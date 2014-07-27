class Comment < ActiveRecord::Base
  belongs_to :domain
  has_many :users, through: :domain

  validates :domain_id, presence: true
  validates :domain, associated: true
end
