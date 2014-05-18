class Cryptokey < ActiveRecord::Base
  self.inheritance_column = :itype

  enum flags: {
    ZSK: 256,
    KSK: 257
  }

  belongs_to :domain

end
