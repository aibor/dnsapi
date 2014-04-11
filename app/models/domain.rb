class Domain < ActiveRecord::Base
  self.inheritance_column = :itype
  has_many :records
  has_many :domainmetadata
end
