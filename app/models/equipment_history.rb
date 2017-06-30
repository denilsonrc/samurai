class EquipmentHistory
  include Mongoid::Document
  field :status, type: String
  field :response_time, type: Float
  field :create_at, type: DateTime
  
  embedded_in :equipment
end
