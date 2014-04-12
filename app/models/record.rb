class Record < ActiveRecord::Base
  self.inheritance_column = :itype

  Types = %w( A AAAA AFSDB CERT CNAME DNSKEY DS HINFO KEY LOC MX NAPTR NS NSEC
              PTR RP RRSIG SOA SPF SSHFP SRV TXT ).freeze

  belongs_to :domain

  validates_inclusion_of :type, in: Types

  def self.type_sort( array = self.all )
    array.sort do |x,y|
      out = 0
      if x.type.nil?
        out = 1
      elsif y.type.nil?
        out = -1
      elsif x.type == y.type
        %w( name ordername content ).each do |attr|
          if x.send(attr).nil? and y.send(attr)
            out = -1
          elsif y.send(attr).nil? and x.send(attr)
            out = 1
          elsif x.send(attr) == y.send(attr)
            next
          else
            out = x.send(attr) <=> y.send(attr)
          end
          break
        end
        out
      else
        out = x.type <=> y.type
        %w( SOA NS MX ).each do |rtype|
          if x.type == rtype
            out = -1
            break
          elsif y.type == rtype
            out = 1
            break
          end
        end
      end
      out
    end

  end

end
