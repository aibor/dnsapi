# coding: utf-8

module DNSValidator

  class ResourceRecord::MX < ResourceRecord

    def initialize(record)
      super
      @rdata.preference = @record.prio
    end


    def conflicting_types
      %w(CNAME)
    end


    def attr_uniqueness
      super << :prio
    end


    def rdata_fields
      [:exchange, :preference]
    end


    def rdata_field_count
      1
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

end

