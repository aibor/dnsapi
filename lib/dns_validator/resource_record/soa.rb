# coding: utf-8

module DNSValidator

  class ResourceRecord::SOA < ResourceRecord

    def conflicting_types
      %w(CNAME)
    end


    def rdata_fields
      [:mname, :rname, :serial, :refresh, :retry, :expire, :minimum]
    end


    def validate_rdata
			unless is_domain_name? @rdata.mname
				@record.errors.add(:content, :invalid_domain_name_, domain: @rdata.mname)
        return
			end

			unless is_rname? @rdata.rname
				@record.errors.add(:content, :invalid_rname, rname: @rdata.rname)
        return
			end

      [:serial, :refresh, :retry, :expire, :minimum].each do |key|
        f = @rdata[key]

        unless f =~ /\A\d+\z/
          @record.errors.add(:content, :not_a_number, string: key)
          break
        end

        n = f.to_i
        if n == 0
          @record.errors.add(:content, :may_not_be_zero, key: key)
          break
        end

        unless is_ttl? n
          @record.errors.add(:content, :too_high, key: key)
          break
        end
      end
    end

  end

end

