class Resource < ActiveRecord::Base
  belongs_to :user
  has_many :attachments

  cattr_reader :per_page
  @@per_page = 10

  validates_presence_of :selling_price
  validates_presence_of :title
  validates_numericality_of :selling_price

  def self.create_resource resource_data
    resource = resource_data
    resource.save
  end
end
