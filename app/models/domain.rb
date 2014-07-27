require 'dns_validator'

class Domain < ActiveRecord::Base
  self.inheritance_column = :itype

  has_many :records
  has_many :domainmetadata
  has_many :comments
  has_many :cryptokeys
  has_and_belongs_to_many :users

  before_validation do
    self.name = self.name.sub(/\.\z/,'') if self.name
    self.type = 'MASTER' if self.type.blank?
  end

  after_save do
    rectify_zone
  end

  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
  validates_inclusion_of :type, in: %w(NATIVE MASTER SLAVE)
  validate do |record|
    DNSValidator::Domain.new(record).validate
  end

  def soa
    self.records.where(type: 'SOA').first
  end

  def secure_zone
    if self.cryptokeys.empty?
      pdnssec 'secure-zone', self.name
      pdnssec 'set-nsec3', self.name
      rectify_zone if self.soa
    else
      self.errors[:base] << "Zone already secured"
      false
    end
  end

  def dskeys
    arr = []
    IO.popen("pdnssec show-zone #{self.name}") do |res|
      res.each do |line|
        arr << $1 if line =~ /\ADS = (.+)/
      end
    end
    arr
  end


  def rectify_zone
    pdnssec 'rectify-zone', self.name
  end

  private

  def pdnssec(cmd, *args)
    unless system("pdnssec #{cmd} #{args.join(' ')} >/dev/null 2>&1")
      self.errors[:base] << "pdnssec error while executing: #{cmd} #{args.join(' ')}"
    end
  end

end
