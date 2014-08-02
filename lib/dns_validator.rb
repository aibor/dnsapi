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
    RE_char_string  = '[[:graph:]]{,255}'
    # RFC1035 wants a label to start with a letter. The real world also allows digits
    RE_label = '(?!.*--.*)[[:alnum:]](?:(?:[[:alnum:]-]{0,61})?[[:alnum:]])?'
    # In order to work around the rfc ignoring domain_names, which causes IPv4 address
    # to be valid domain names, check the last label to be rfc conform.
    RE_label_rfc = '(?!.*--.*)[[:alpha:]](?:(?:[[:alnum:]-]{0,61})?[[:alnum:]])?'
    RE_domain = /(?=\A.{,255}\z)(?:#{RE_label}\.)*#{RE_label_rfc}/


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

    def is_rname?(string = nil)
      is_domain_name?(string) and string.split('.').count > 2
    end

    def is_ttl?(number)
      (1...2**31).include? number
    end

    def attr_uniqueness
       [:name, :type]
    end

    def record_exists?(search_data)
      @record.class.where(search_data).where.not(id: @record.id).any? 
    end

  end

  class Domain < Base
    def initialize(record)
      super
      @name   = @record.name
      @masters = @record.master ? @record.master.split(',') : []
      @type   = @record.type
    end

    def validate
      validate_name
      validate_master
    end

    def validate_name
      unless is_domain_name?(@name)
        @record.errors.add(:name, :invalid_domain_name)
      end
    end

    def validate_master
      @masters.each do |master|
        unless is_domain_name?(master) or is_ip_address?(master)
          @record.errors.add(:master, :invalid_master, master: master)
        end
      end
    end

  end

  class ResourceRecord < Base
    def initialize(record)
      super
      @name         = @record.name
      @type         = @record.type
      @ttl          = @record.ttl
      @rdlength     = @record.content ? @record.content.length : 0
      @rdata_fields = rdata_fields
      @rdata        = parse_rdata
    end

    def validate
      validate_type
      validate_uniqueness_of_record
      validate_name
      validate_ttl if @ttl
      validate_rdlength and
        validate_rdata_fields and
        validate_rdata
    end

    private

    def conflicting_types
      []
    end

    def rdata_fields
      # dummy method
    end

    def parse_rdata
      return @record.content unless @rdata_fields.is_a? Array
      return @record.content if @rdata_fields.empty?
      return @record.content if @rdata_fields.bsearch {|e| !e.is_a? Symbol}

      rdata_struct = Struct.new(*@rdata_fields)

      rdata = @record.content ? @record.content.split : []

      rdata_struct.new(*rdata)
    end

    def validate_type
      conflicting_types.each do |ctype| 
        if record_exists?({name: @record.name, type: ctype})
          @record.errors.add(:base, :conflicting_record, type: ctype)
        end
      end
    end


    def validate_uniqueness_of_record
      search_data = @record.attributes.keep_if do |k,v|
        attr_uniqueness.include? k.to_sym
      end

      if record_exists?(search_data)
        @record.errors.add(:base, :record_with_name_and_type_exists)
      end
    end

    def validate_name
      unless is_domain_name?(@name)
        @record.errors.add(:name, :invalid_domain_name)
      end
    end

    def validate_ttl
      unless is_ttl?(@ttl)
        @record.errors.add(:ttl, :invalid_ttl)
      end
    end

    def validate_rdlength
      if @rdlength <= 2**16
        true
      else
        @record.errors.add(:content, :too_long)
        false
      end
    end

    def validate_rdata_fields
      return true unless @rdata_fields

      if @rdata.class.superclass.name == "Struct" && !@rdata.all?
        @record.errors.add(:content, :wrong_number_of_fields)
        false
      else
        true
      end
    end

    def validate_rdata
      false
    end
  end

  class A < ResourceRecord
    def conflicting_types
      %w(CNAME)
    end

    def validate_rdata
      unless is_ipv4_address? @rdata
        @record.errors.add(:content, :invalid_ipv4_address)
      end
    end
  end

  class AAAA < ResourceRecord
    def conflicting_types
      %w(CNAME)
    end

    def validate_rdata
      unless is_ipv6_address? @rdata
        @record.errors.add(:content, :invalid_ipv6_address)
      end
    end
  end

  class CNAME < ResourceRecord
    def conflicting_types
      %w(A AAAA)
    end

    def validate_rdata
      unless is_domain_name? @rdata
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class HINFO < ResourceRecord
    def rdata_fields
      [:cpu, :os]
    end

    def validate_rdata
      @rdata.each do |name,value|
        unless value =~ /\A#{RE_char_string}\z/
          @record.errors.add(:content, :invalid_char_string, char_string: value)
        end
      end
    end
  end

  class MINFO < ResourceRecord
    def rdata_fields
      [:rmailbx, :emailbx]
    end

    def validate_rdata
      @rdata.each do |name,value|
        unless is_domain_name? f
          @record.errors.add(:content, :invalid_domain_name_, domain: value)
        end
      end
    end
  end

  class MX < ResourceRecord
    def attr_uniqueness
      super << :prio
    end

    def rdata_fields
      [:exchange, :preference]
    end

    def initialize(record)
      super
      @rdata.preference = @record.prio
    end

    def validate_rdata_fields
      bool = true
      unless @rdata.preference
        @record.errors.add(:prio, :preference_missing)
        bool = false
      end

      unless @rdata.exchange
        @record.errors.add(:content, :exchange_missing)
        bool = false
      end
      bool
    end

    def validate_rdata
      unless is_domain_name? @rdata.exchange
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class NS < ResourceRecord
    def attr_uniqueness
      super << :content
    end

    def validate_rdata
      unless is_domain_name? @rdata
        @record.errors.add(:content, :invalid_domain_name)
      end
    end
  end

  class PTR < ResourceRecord
    def validate_rdata
      unless is_domain_name? @rdata
        @record.errors.add(:content, :invalid_domain_name)
      end

      re_octet = "(?:25[0-5]|(?:2[0-4]|(?:1?\d))?\d)"
      unless @rdata =~ /\A(?:#{re_octet}\.){1,4}IN-ADDR\.ARPA\.\z/i
        @record.errors.add(:content, :invalid_ptr_name)
      end
    end
  end

  class SOA < ResourceRecord
    def rdata_fields
      [:mname, :rname, :serial, :refresh, :retry, :expire, :minimum]
    end

    def validate_rdata
			unless is_domain_name? @rdata.mname
				@record.errors.add(:content, :invalid_domain_name_, domain: @rdata.mname)
			end

			unless is_rname? @rdata.rname
				@record.errors.add(:content, :invalid_rname, rname: @rdata.rname)
			end

      [:serial, :refresh, :retry, :expire, :minimum].each do |key|
        f = @rdata[key]

        unless f =~ /\A\d+\z/
          @record.errors.add(:content, :not_a_number, string: key)
        end

        n = f.to_i
        if n == 0
          @record.errors.add(:content, :may_not_be_zero, key: key)
        end

        unless is_ttl? n
          @record.errors.add(:content, :too_high, key: key)
        end
      end
    end
  end

  class SSHFP < ResourceRecord
    def rdata_fields
      [:algorithm, :fp_type, :fingerprint]
    end

    def validate_rdata
      unless @rdata.algorithm =~ /\A[123]\z/
        @record.errors.add(:content, :invalid_algorithm_number)
      end

      must_length = case @rdata.fp_type
                    when '1' then 40
                    when '2' then 64
                    else nil
                    end

      unless must_length
        @record.errors.add(:content, :invalid_fingerprint_type)
      else
        is_length = @rdata.fingerprint.length
        unless  is_length == must_length
          @record.errors.add(:content, :invalid_fingerprint_length,
                             is_length: is_length, must_length: must_length)
        end

        unless @rdata.fingerprint =~ /\A\h{#{must_length}}\z/
          @record.errors.add(:content, :invalid_fingerprint)
        end
      end

    end
  end

  class TXT < ResourceRecord
    def validate_rdata
      # count occurence of non-escaped double quotes
      # will fail in cases like 'string \\"more" string'
      unless rdata.match(/((?<!\\)")/).size.even?
        @record.errors.add(:content, :odd_number_of_double_quotes)
      end
    end
  end
end
