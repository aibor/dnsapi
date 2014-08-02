require 'dns_validator'

class Record < ActiveRecord::Base
  self.inheritance_column = :itype

  attr_accessor :no_type_validation

  Types = %w(A AAAA AFSDB CERT CNAME DLV DNAME DNSKEY DS EUI48 EUI64
             HINFO KEY LOC MINFO MX NAPTR NS NSEC NSEC3 NSEC3PARAM OPT
             PTR RKEY RP RRSIG SOA SPF SSHFP SRV TLSA TXT).freeze


  belongs_to :domain
  has_many :users, through: :domain


  before_validation do
    self.name = self.name.blank? ? self.domain.name : self.name.sub(/\.\z/,'')
    unless self.name =~ /#{self.domain.name.gsub('.','\.')}\.?\z/
      self.name += self.name[-1] == '.' ? '' : '.' + self.domain.name
    end
  end

  before_save do
    self.hash_zone_record if self.domain.cryptokeys.any?
    self.ttl ||= 86400
  end


  validates :name, presence: true
  validates :domain_id, presence: true
  validates :domain, associated: true
  validates :type, presence: true
  validates :token, length: {minimum: 64, maximum: 255}, allow_blank: true
  validates_inclusion_of :type, in: Types
  validate :unique_record
  validate do |record|
    if has_dns_validator? and record.no_type_validation.to_i.zero?
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
          %w(name content).each do |attr|
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
          if x.name == y.name
            throw :sorted, x.type <=> y.type
          else
            throw :sorted, x.name <=> y.name 
          end
        end
      end
    end
  end


  def has_dns_validator?
    !!(self.type and DNSValidator.constants.include? self.type.to_sym)
  end


  def generate_token
    input_string = (Time.now.tv_sec + Random.rand(2**32)).to_s
    self.token = Digest::SHA384.base64digest(input_string).gsub(/[+\/]/,"-")
  end


  private

  def unique_record
    if Record.where(name: self.name, type: self.type, prio: self.prio, content: self.content).where.not(id: self.id).any?
      errors.add(:base, :record_exists)
    end
  end

end
