# coding: utf-8

module DNSValidator

  class ResourceRecord::MINFO < ResourceRecord

    def conflicting_types
      %w(CNAME)
    end


    def rdata_fields
      [:rmailbx, :emailbx]
    end


    def validate_rdata
      @rdata.each_pair do |name,value|
        unless is_domain_name? value
          @record.errors.add(:content, :invalid_domain_name_, domain: value)
        end
      end
    end

  end

end
