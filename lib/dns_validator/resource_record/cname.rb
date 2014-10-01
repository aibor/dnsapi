# coding: utf-8

module DNSValidator

  class ResourceRecord::CNAME < ResourceRecord

    def conflicting_types
      %w(A AAAA HINFO MINFO MX NS SOA SSHFP TXT)
    end


    def validate_rdata
      unless is_domain_name? @rdata
        @record.errors.add(:content, :invalid_domain_name)
      end
    end

  end

end
