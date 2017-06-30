class Room
  include Mongoid::Document
  field :name, type: String
  field :number, type: String
  field :floor, type: String
  
  has_many :equipments
  
end
