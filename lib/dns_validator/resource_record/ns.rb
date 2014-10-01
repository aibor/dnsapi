# coding: utf-8

module DNSValidator


  class ResourceRecord::NS < ResourceRecord

    def conflicting_types
      %w(CNAME)
    end


    def attr_uniqueness
      super << :content
    end


    def validate_rdata
      unless is_domain_name? @rdata
        @record.errors.add(:content, :invalid_domain_name)
      end
    end

  end

end

