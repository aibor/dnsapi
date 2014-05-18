require 'ipaddr'

class DNSValidator
  # validate types according to RFC 1035
  # https://tools.ietf.org/html/rfc1035
  # DNSSEC related types according to RFC 4034
  # http://www.rfc-archive.org/getrfc.php?rfc=4034
  # SSHFP according to RFC 4255 nd RFC 6594
  # https://tools.ietf.org/html/rfc4255
  # http://www.rfc-archive.org/getrfc.php?rfc=6594
  # TLSA according to RFC 6698
  # https://tools.ietf.org/html/rfc6698

  class Base
    RE_label = '[[:alpha:]](?:(?:[[:alnum:]-]{0,61})?[[:alnum:]])?'
    RE_domain = /(?=\A.{,255}\z)(?:#{RE_label}\.)*#{RE_label}/


    def initialize(record)
      @record = record
    end

    def is_ip_address?(ip_addr, family = nil)
      !!(IPAddr.new(ip_addr, family) rescue false)
    end

    def is_ipv4_address?(ip_addr)
      is_ip_address?(ip_addr, Socket::AF_INET)
    end

    def is_ipv6_address?(ip_addr)
      is_ip_address?(ip_addr, Socket::AF_INET6)
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

  class Domain < Base
    def validate
      validate_name
      validate_master if @record.master
    end

    def validate_name
      unless is_hostname?(@record.name)
        @record.errors.add(:name, :invalid_host_name)
      end
    end

    def validate_master
      masters = @record.master.split(',')

      masters.each do |master|
        unless is_hostname?(master) or is_ip_address?(master)
          @record.errors.add(:master, :invalid_master, master: master)
        end
      end
    end
  end

  class ResourceRecord < Base
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
  end

  class A < ResourceRecord
    def validate_content
      super
      unless is_ipv4_address? @record.content
        @record.errors.add(:content, :invalid_ipv4_address)
      end
    end
  end

  class AAAA < ResourceRecord
    def validate_content
      super
      unless is_ipv6_address? @record.content
        @record.errors.add(:content, :invalid_ipv6_address)
      end
    end
  end

  class CNAME < ResourceRecord
    def validate_content
      super
      unless is_domain_name? @record.content
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class HINFO < ResourceRecord
    def validate_content
      super
      fields = @record.content.split

      unless fields.count == 2
        @record.errors.add(:content, :wrong_number_of_fields)
      end
    end
  end

  class MINFO < ResourceRecord
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

  class MX < ResourceRecord
    def validate_content
      super
      unless is_domain_name? @record.content
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class NS < ResourceRecord
    def validate_content
      super
      unless is_domain_name? @record.content
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class PTR < ResourceRecord
    def validate_content
      super
      unless is_domain_name? @record.content
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class SOA < ResourceRecord
    def validate_content
      fields = @record.content.split
      unless fields.count == 7
        @record.errors.add(:content, :wrong_number_of_fields)
      end

			unless is_host_name? fields[0]
				@record.errors.add(:content, :invalid_host_name)
			end

			unless is_domain_name? fields[1]
				@record.errors.add(:content, :invalid_domain_name, domain: fields[1])
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

  class SSHFP < ResourceRecord
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

  class TXT < ResourceRecord
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
