require 'dns_validator'

class Record < ActiveRecord::Base
  self.inheritance_column = :itype

  Types = %w(A AAAA AFSDB CERT CNAME DLV DNAME DNSKEY DS EUI48 EUI64
             HINFO KEY LOC MINFO MX NAPTR NS NSEC NSEC3 NSEC3PARAM OPT
             PTR RKEY RP RRSIG SOA SPF SSHFP SRV TLSA TXT).freeze

  belongs_to :domain, inverse_of: :records

  before_validation do
    self.name = self.domain.name if self.domain && self.name.blank?
    self.name = self.name.sub(/\.\z/,'') if self.name
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

  def self.type_sort(array = self.all)
    array.sort do |x,y|
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
