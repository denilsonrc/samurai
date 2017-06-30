#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  Equipment.where(:equipment_id=>nil).map{|e|
    ifTableColumns = ["1.3.6.1.2.1.99.1.1.1.10", "1.3.6.1.2.1.99.1.1.1.9", "1.3.6.1.2.1.99.1.1.1.5", "1.3.6.1.2.1.99.1.1.1.13", "1.3.6.1.2.1.99.1.1.1.14", "1.3.6.1.2.1.99.1.1.1.1"]
    SNMP::Manager.open(:host => e.ip) do |manager|
      manager.walk(ifTableColumns) do |row|
        aux = []
        row.each { |vb| 
          aux << "#{vb.value}" 
        }
        begin
          room = Room.where(:name=>aux[4]).first
          if aux[2] == 0
            status = "Desligado"
          elsif aux[2] == 1
            status = "Ativo"
          else
            status = "Sem registro"
          end
          type = Type.find(aux[5])
          description = "#{tipo.nome} sensor"
          Equipment.create(:nome=>aux[0],:ip=>aux[1],:status=>status,:descricao=>description,:equipment_id=>e.id,:room_id=>room.id,:protocol_id=>2,:type_id=>type.id)
        rescue
        end
      end
    end
  }
  
  sleep 10
end
