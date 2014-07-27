class Domainmetadatum < ActiveRecord::Base
  Kinds = %w( ALLOW-AXFR-FROM ALLOW-2136-FROM TSIG-ALLOW-2136 FORWARD-2136
              SOA-EDIT-2136 ALSO-NOTIFY AXFR-MASTER-TSIG LUA-AXFR-SCRIPT
              NSEC3NARROW NSEC3PARAM PRESIGNED SOA-EDIT TSIG-ALLOW-AXFR
            ).freeze

  SOAEdits = %w( INCREMENT-WEEKS INCEPTION-EPOCH INCEPTION-INCREMENT INCEPTION
                 INCEPTION-WEEK EPOCH ).freeze

  belongs_to :domain
  has_many :users, through: :domain

  validates :domain_id, presence: true
  validates :domain, associated: true
  validates :kind, presence: true
  validates :kind, inclusion: { in: Kinds,
    message: "%{value} is not a valid kind" }
  validates :content, inclusion: { in: SOAEdits,
    message: "%{value} is not a valid SOA-EDIT mode" },
    allow_nil: true, if: :is_soa_edit?
      
  def is_soa_edit?
    self.kind == "SOA-EDIT"
  end

end
