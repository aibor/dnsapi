# coding: utf-8

module DNSValidator

  class ResourceRecord::HINFO < ResourceRecord

    def conflicting_types
      %w(CNAME)
    end


    def rdata_fields
      [:cpu, :os]
    end


    def validate_rdata
      @rdata.each_pair do |name,value|
        unless value =~ /\A#{RE_char_string}\z/
          @record.errors.add(:content, :invalid_char_string, char_string: value)
        end
      end
    end

  end

end

