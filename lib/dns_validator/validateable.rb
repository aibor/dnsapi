# coding: utf-8

require 'dns_validator/string_validations'


module DNSValidator

  module Validatable

    include StringValidations


    def initialize(record)
      @record = record
    end


    def attr_uniqueness
       [:name, :type]
    end


    def record_exists?(search_data)
      @record.class.where(search_data).where.not(id: @record.id).any? 
    end

  end

end

