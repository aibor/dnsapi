# coding: utf-8

require 'ipaddr'


module DNSValidator

  module StringValidations

    RE_char_string  = '[[:print:]]{,255}'

    # RFC1035 wants a label to start with a letter.
    # The real world also allows digits and needs underscores for service records.
    RE_label = '(?!.*--.*)[[:alnum:]_](?:(?:[[:alnum:]-]{0,61})?[[:alnum:]])?'

    # In order to work around the rfc ignoring domain_names, which causes IPv4 address
    # to be valid domain names, check the last label to be rfc conform.
    RE_label_rfc = '(?!.*--.*)[[:alpha:]](?:(?:[[:alnum:]-]{0,61})?[[:alnum:]])?'
    RE_domain = /(?=\A.{,255}\z)(?:#{RE_label}\.)*#{RE_label_rfc}/


    def is_ip_address?(ip_addr, family = nil)
      !!(IPAddr.new(ip_addr, family) rescue false)
    end


    def is_ipv4_address?(ip_addr)
      is_ip_address?(ip_addr, Socket::AF_INET)
    end


    def is_ipv6_address?(ip_addr)
      is_ip_address?(ip_addr, Socket::AF_INET6)
    end


    def is_domain_name?(string = nil)
      !!(string =~ /\A#{RE_domain}\.?\z/)
    end


    def is_rname?(string = nil)
      is_domain_name?(string) and string.split('.').count > 2
    end


    def is_ttl?(number)
      (1...2**31).include? number
    end

  end

end

