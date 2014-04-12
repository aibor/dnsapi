class Cryptokey < ActiveRecord::Base
  self.inheritance_column = :itype
  belongs_to :domain
end
