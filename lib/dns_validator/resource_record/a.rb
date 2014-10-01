# coding: utf-8

module DNSValidator

  class ResourceRecord::A < ResourceRecord

    def attr_uniqueness
      super << :content
    end


    def conflicting_types
      %w(CNAME)
    end


    def validate_rdata
      unless is_ipv4_address? @rdata
        @record.errors.add(:content, :invalid_ipv4_address)
      end
    end

  end

end

