require 'dns_validator'
require 'open3'

class Domain < ActiveRecord::Base
  self.inheritance_column = :itype

  attr_accessor :create_soa

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

  def create_default_soa(user)
    primary     = user.default_primary
    primary     = primary.blank? ? 'ns.inwx.de.' : primary
    postmaster  = user.default_postmaster
    postmaster  = postmaster.blank? ? 'hostmaster.inwx.de.' : postmaster
    serial      = Time.new.strftime('%Y%m%d01')

   Record.create(
     domain_id: self.id,
     ttl: 86400,
     type: 'SOA',
     content: "#{primary} #{postmaster} #{serial} 86400 3600 3600000 86400"
   )
  end


  def import_zone_file(import)
    cmd = "zone2json --zone-name=#{self.name} --zone=/dev/stdin"

    stdout, stderr, status = Open3.capture3(cmd, stdin_data: import)

    zone_file = stdout

    unless status.to_i.zero?
      self.errors.add(:base, stderr)
      return false
    end


    begin
      zone_file = JSON.parse zone_file
    rescue JSON::ParserError => e
      self.errors.add(:base, e.message)
      return false
    end

    zone_file['records'].each do |record|
      new_record = Record.new(record)
      new_record.domain = self
      new_record.save
    end
  end

  private

  def pdnssec(cmd, *args)
    unless system("pdnssec #{cmd} #{args.join(' ')} >/dev/null 2>&1")
      self.errors[:base] << "pdnssec error while executing: #{cmd} #{args.join(' ')}"
    end
  end

end
