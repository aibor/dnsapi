# coding: utf-8

require 'ipaddr'

##
# Validates 
# * basic types according to {https://tools.ietf.org/html/rfc1035
#   RFC 1035}
# * DNSSEC related types according to
#   {http://www.rfc-archive.org/getrfc.php?rfc=4034 RFC 4034}
# * SSHFP according to {https://tools.ietf.org/html/rfc4255 RFC 4255}
#   and {http://www.rfc-archive.org/getrfc.php?rfc=6594 RFC 6594}
# * TLSA according to {https://tools.ietf.org/html/rfc6698 RFC 6698}

module DNSValidator
end

require 'dns_validator/domain.rb'
require 'dns_validator/resource_record.rb'
