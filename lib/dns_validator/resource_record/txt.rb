# coding: utf-8

module DNSValidator

  class ResourceRecord::TXT < ResourceRecord

    def conflicting_types
      %w(CNAME)
    end


    def validate_rdata

    end

  end

end

