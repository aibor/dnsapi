# coding: utf-8

require 'dns_validator/validateable'


module DNSValidator

  class ResourceRecord

    include Validatable


    def initialize(record)
      @record       = record
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


    def rdata_field_count
      @rdata_fields.count
    end


    def parse_rdata
      return @record.content unless @rdata_fields.is_a? Array
      return @record.content if @rdata_fields.empty?
      return @record.content if @rdata_fields.bsearch {|e| !e.is_a? Symbol}

      rdata_struct = Struct.new(*@rdata_fields)

      rdata = @record.content ? Shellwords.shellwords(@record.content) : []

      if rdata.count != rdata_field_count
        @record.errors.add(:content, :wrong_number_of_fields)
      end

      rdata_struct.new(*rdata.take(@rdata_fields.count))
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
        @record.errors.add(:base, :record_with_attrs_exists,
                           attrs: attr_uniqueness.join(', '))
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


  Dir.glob("#{__dir__}/resource_record/*.rb").each { |f| require f }

end

