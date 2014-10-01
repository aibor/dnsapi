# coding: utf-8

module DNSValidator

  class ResourceRecord::SSHFP < ResourceRecord

    def conflicting_types
      %w(CNAME)
    end


    def rdata_fields
      [:algorithm, :fp_type, :fingerprint]
    end


    def validate_rdata
      unless @rdata.algorithm =~ /\A[123]\z/
        @record.errors.add(:content, :invalid_algorithm_number)
      end

      must_length = case @rdata.fp_type
                    when '1' then 40
                    when '2' then 64
                    else nil
                    end

      unless must_length
        @record.errors.add(:content, :invalid_fingerprint_type)
      else
        is_length = @rdata.fingerprint.length
        unless  is_length == must_length
          @record.errors.add(:content, :invalid_fingerprint_length,
                             is_length: is_length, must_length: must_length)
        end

        unless @rdata.fingerprint =~ /\A\h{#{must_length}}\z/
          @record.errors.add(:content, :invalid_fingerprint)
        end
      end
    end

  end

end

