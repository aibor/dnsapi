class Record < ActiveRecord::Base
  self.inheritance_column = :itype

  Types = %w( A AAAA AFSDB CERT CNAME DNSKEY DS HINFO KEY LOC MX NAPTR NS NSEC
              PTR RP RRSIG SOA SPF SSHFP SRV TXT ).freeze

  belongs_to :domain

  validates_inclusion_of :type, in: Types

end
