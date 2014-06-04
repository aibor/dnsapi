class Domain < ActiveRecord::Base
  self.inheritance_column = :itype

  has_many :records, inverse_of: :domain
  has_many :domainmetadata, inverse_of: :domain
  has_many :comments, inverse_of: :domain
  has_many :cryptokeys, inverse_of: :domain

  before_validation do
    self.name = self.name.sub(/\.\z/,'') if self.name
    self.type = 'MASTER' if self.type.blank?
  end

  after_save do
    rectify_zone
  end

  validates :name, presence: true
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
        puts line
        puts "--------------"
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
    unless system("pdnssec #{cmd} #{args}")
      self.errors[:base] << "pdnssec error while executing: #{cmd} #{args}"
    end
  end

end
