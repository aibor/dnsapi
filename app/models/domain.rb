class Domain < ActiveRecord::Base
  self.inheritance_column = :itype

  has_many :records
  has_many :domainmetadata
  has_many :comments
  has_many :cryptokeys

  def soa
    self.records.where(type: 'SOA').first
  end

  def secure_zone
    pdnssec 'secure-zone', self.name
    pdnssec 'set-nsec3', self.name
    pdnssec 'rectify-zone', self.name
  end

  private

  def pdnssec(cmd, args = nil)
    raise "pdnssec error" unless system("pdnssec #{cmd} #{args}")
  end

end
