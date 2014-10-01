# coding: utf-8

module DNSValidator

  class ResourceRecord::PTR < ResourceRecord

    def validate_rdata
      unless is_domain_name? @rdata
        @record.errors.add(:content, :invalid_domain_name)
      end

      re_octet = /(?:25[0-5]|(?:2[0-4]|(?:1?\d))?\d)/
      unless @rdata =~ /\A(?:#{re_octet}\.){1,4}IN-ADDR\.ARPA\.\z/i
        @record.errors.add(:content, :invalid_ptr_name)
      end
    end

  end

end

