# coding: utf-8

module DNSValidator

  class ResourceRecord::AAAA < ResourceRecord

    def attr_uniqueness
      super << :content
    end


    def conflicting_types
      %w(CNAME)
    end


    def validate_rdata
      unless is_ipv6_address? @rdata
        @record.errors.add(:content, :invalid_ipv6_address)
      end
    end

  end

end

