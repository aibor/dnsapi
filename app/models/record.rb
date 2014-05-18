require 'ipaddr'

class Record < ActiveRecord::Base
  self.inheritance_column = :itype

  Types = %w(A AAAA AFSDB CERT CNAME DLV DNAME DNSKEY DS EUI48 EUI64
             HINFO KEY LOC MINFO MX NAPTR NS NSEC NSEC3 NSEC3PARAM OPT
             PTR RKEY RP RRSIG SOA SPF SSHFP SRV TLSA TXT).freeze

  belongs_to :domain

  validates_inclusion_of :type, in: Types
  validate do |record|
    if RecordValidator.constants.include? self.type.to_sym
      klass = RecordValidator.class_eval self.type
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

class RecordValidator
  # validate types according to RFC 1035
  # https://tools.ietf.org/html/rfc1035
  # DNSSEC related types according to RFC 4034
  # http://www.rfc-archive.org/getrfc.php?rfc=4034

  class RDATAValidationError < StandardError; end

  class Base
    RE_label = '[[:alpha:]](?:(?:[[:alnum:]-]{0,61})?[[:alnum:]])?'
    RE_domain = /(?=\A.{,255}\z)(?:#{RE_label}\.)*#{RE_label}/

      def initialize(record)
        @record = record
      end

    def validate
      validate_name
      validate_ttl if @record.ttl
      validate_prio if @record.prio
      validate_content_length
      validate_content
    end

    private

    def validate_name
      unless is_hostname?(@record.name)
        @record.errors.add(:name, :invalid_host_name)
      end
    end

    def validate_ttl
      unless is_ttl?(@record.ttl)
        @record.errors.add(:ttl, :invalid_ttl)
      end
    end

    def validate_prio
      unless (0...2**16).include? @record.prio 
        @record.errors.add(:prio, :invalid_prio)
      end
    end

    def validate_content_length
      if @record.content
        unless @record.content.length <= 2**16
          @record.errors.add(:content, :too_long)
        end
      else
        @record.errors.add(:content, :blank)
      end
    end

    def validate_content
    end

    def is_ip_address?(ip_addr, family = Socket::AF_INET)
      !!(IPAddr.new(ip_addr, family) rescue false)
    end

    def is_domain_name?(string = nil)
      !!(string =~ /\A#{RE_domain}\.?\z/)
    end

    def is_hostname?(string = nil)
      !!(string =~ /\A#{RE_domain}?\z/)
    end

    def is_ttl?(number)
      (1...2**31).include? number
    end
  end

  class A < Base
    def validate_content
      super
      unless is_ip_address? @record.content
        @record.errors.add(:content, :invalid_ip_address)
      end
    end
  end

  class AAAA < Base
    def validate_content
      super
      unless is_ip_address? @record.content, Socket::AF_INET6
        @record.errors.add(:content, :invalid_ip_address)
      end
    end
  end

  class CNAME < Base
    def validate_content
      super
      unless is_domain_name? @record.content
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class HINFO < Base
    def validate_content
      super
      fields = @record.content.split

      unless fields.count == 2
        @record.errors.add(:content, :wrong_number_of_fields)
      end
    end
  end

  class MINFO < Base
    def validate_content
      super
      fields = @record.content.split

      unless fields.count == 2
        @record.errors.add(:content, :wrong_number_of_fields)
      end

      fields.each do |f|
        unless is_domain_name? f
          @record.errors.add(:content, :invalid_domain_name, domain: f)
        end
      end
    end
  end

  class MX < Base
    def validate_content
      super
      unless is_domain_name? @record.content
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class NS < Base
    def validate_content
      super
      unless is_domain_name? @record.content
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class PTR < Base
    def validate_content
      super
      unless is_domain_name? @record.content
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class SOA < Base
    def validate_content
      fields = @record.content.split
      unless fields.count == 7
        @record.errors.add(:content, :wrong_number_of_fields)
      end

      fields.values_at(0,1).each do |f|
        unless is_domain_name? f
          @record.errors.add(:content, :invalid_domain_name, domain: f)
        end
      end

      fields.values_at(2..6).each do |f|
        unless f =~ /\A\d+\z/
          @record.errors.add(:content, :not_a_number, string: f)
        end

        n = f.to_i
        if n == 0
          @record.errors.add(:content, :TTL_may_not_be_zero, ttl: f)
        end

        unless is_ttl? n
          @record.errors.add(:content, :invalid_TTL, ttl: f)
        end
      end
    end
  end

  class SSHFP < Base
    def validate_content
      fields = @record.content.split
      unless fields.count == 3
        @record.errors.add(:content, :wrong_number_of_fields)
      end

      unless fields[0] =~ /\A[123]\z/
        @record.errors.add(:content, :invalid_algorithm_number)
      end

      must_length = case fields[1]
                    when '1' then 40
                    when '2' then 64
                    else nil
                    end

      unless must_length
        @record.errors.add(:content, :invalid_fingerprint_type)
      else
        is_length = fields[2].length
        unless  is_length == must_length
          @record.errors.add(:content, :invalid_fingerprint_length,
                             is_length: is_length, must_length: must_length)
        end

        unless fields[2] =~ /\A\h{#{must_length}}\z/
          @record.errors.add(:content, :invalid_fingerprint)
        end
      end

    end
  end

  class TXT < Base
    def validate_content
      super
      # count occurence of non-escaped double quotes
      # will fail in cases like 'string \\"more" string'
      unless rdata.match(/((?<!\\)")/).size.even?
        @record.errors.add(:content, :odd_number_of_double_quotes)
      end
    end
  end
end
