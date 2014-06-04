require 'dns_validator'

class Record < ActiveRecord::Base
  self.inheritance_column = :itype

  Types = %w(A AAAA AFSDB CERT CNAME DLV DNAME DNSKEY DS EUI48 EUI64
             HINFO KEY LOC MINFO MX NAPTR NS NSEC NSEC3 NSEC3PARAM OPT
             PTR RKEY RP RRSIG SOA SPF SSHFP SRV TLSA TXT).freeze

  belongs_to :domain, inverse_of: :records

  before_validation do
    unless self.name =~ /#{self.domain.name.gsub('.','\.')}\.?\z/
      self.name += self.name[-1] == '.' ? '' : '.' + self.domain.name
    end
    self.name = self.name.sub(/\.\z/,'') if self.name
  end

  before_save do
    self.hash_zone_record if self.domain.cryptokeys.any?
    self.ttl ||= 86400
  end

  validates :name, presence: true
  validates :domain_id, presence: true
  validates :domain, associated: true
  validates :type, presence: true
  validates_inclusion_of :type, in: Types
  validate do |record|
    if self.type and DNSValidator.constants.include? self.type.to_sym
      klass = DNSValidator.class_eval self.type
      klass.new(record).validate
    end
  end

  def hash_zone_record
    IO.popen("pdnssec hash-zone-record #{self.domain.name} #{self.name}") do |res|
      res.each do |line|
        self.ordername = line
      end
    end
  end

  def self.type_sort
    all.sort do |x,y|
      catch :sorted do
        if x.type == y.type
          %w(name ordername content).each do |attr|
            if x.send(attr).nil? and y.send(attr)
              throw :sorted, -1
            elsif y.send(attr).nil? and x.send(attr)
              throw :sorted, 1
            end

            comp = x.send(attr) <=> y.send(attr)
            throw :sorted, comp unless comp == 0
          end
          throw :sorted, 0
        else
          %w(SOA NS MX).each do |rtype|
            case rtype
            when x.type then throw :sorted, -1
            when y.type then throw :sorted, 1
            end
          end
          throw :sorted, x.type <=> y.type
        end
      end
    end
  end

end
