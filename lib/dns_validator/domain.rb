# coding: utf-8

require 'dns_validator/base.rb'


module DNSValidator

  class Domain < Base

    def initialize(record)
      super
      @name   = @record.name
      @masters = @record.master ? @record.master.split(',') : []
      @type   = @record.type
    end


    def validate
      validate_name
      validate_master
    end


    def validate_name
      unless is_domain_name?(@name)
        @record.errors.add(:name, :invalid_domain_name)
      end
    end


    def validate_master
      @masters.each do |master|
        unless is_domain_name?(master) or is_ip_address?(master)
          @record.errors.add(:master, :invalid_master, master: master)
        end
      end
    end

  end

end
