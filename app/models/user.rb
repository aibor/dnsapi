require 'dns_validator'

class User < ActiveRecord::Base
  has_secure_password

  has_and_belongs_to_many :domains
  has_many :records, through: :domains
  has_many :comments, through: :domains
  has_many :domainmetadata, through: :domains
  has_many :cryptokeys, through: :domains

  validates_uniqueness_of :username
  validates_presence_of :username
  validates :password, length: { minimum: 16 }, if: :password
  validate :defaults_format

  class NotAuthorized < StandardError; end

  private

  def defaults_format
    dns_validator = DNSValidator::Base.new(self)

    unless default_primary.blank? or dns_validator.is_domain_name?(default_primary)
      errors.add(:default_primary, :invalid_domain_name)
    end

    unless default_postmaster.blank? or dns_validator.is_rname?(default_postmaster)
      errors.add(:default_postmaster, :invalid_rname)
    end

  end
end
