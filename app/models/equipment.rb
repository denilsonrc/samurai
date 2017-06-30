class Equipment
  include Mongoid::Document
  field :name, type: String
  field :ip, type: String
  field :status, type: String
  field :description, type: String
  
  embeds_many :equipment_histories, validate: true
  belongs_to :room
  
  def make_history(new_status,tmp_resp)
    self.update(:status=>new_status)
    EquipmentHistory.create(:equipment_id=>self.id,:status=>new_status, :room_id=>self.room_id, :response_time=>tmp_resp, :created_at=>DateTime.now)
  end
end
