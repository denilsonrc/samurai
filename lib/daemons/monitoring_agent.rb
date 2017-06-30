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

def ping(host)
  begin
    Timeout.timeout(5) do 
      s = TCPSocket.new(host, 'echo')
      s.close
      return true
    end
  rescue Errno::ECONNREFUSED 
    return true
  rescue Timeout::Error, Errno::ENETUNREACH, Errno::EHOSTUNREACH
    return false
  end
end


while($running) do
  
  Equipment.where(:equipment_id=>nil).map { |e|
    if e.protocol.name == "PING"
      tmp = Time.now
      if ping(e.ip)
        status="ligado"
      else
        status="desligado"
      end
      tmp_resp = ((Time.now - tmp) * 1000).round(4)
      equipment.make_history(status,tmp_resp)
      #EquipmentHistory.create(:equipment_id=>e.id,:status=>status, :room_id=>e.room_id, :time=>tmp_resp)
    elsif e.protocol.name == "SNMP"
      ifTableColumns = ["1.3.6.1.2.1.99.1.1.1.9", "1.3.6.1.2.1.99.1.1.1.5", "1.3.6.1.2.1.99.1.1.1.4"]
      tmp = Time.now
      SNMP::Manager.open(:host => e.ip) do |manager|
        manager.walk(ifTableColumns) do |dados|
          aux = []
          dados.each { |vb| 
            aux << "#{vb.value}" 
          }
          equipment = Equipment.where(ip: aux[0]).first
          unless equipment.nil?
            if aux[1] == "0"
              status = "Desligado"
            elsif aux[1] == "1"
              status = "Ativo"
            else
              status = "Sem registro"
            end
            tmp_resp = ((Time.now - tmp) * 1000).round(4)
            equipment.make_history(status,tmp_resp)
            #equipment.change_status(:status=>status)
            #EquipmentHistory.create(:equipment_id=>equipment.id,:status=>status,:room_id=>equipment.room_id,:dado=>aux[2],:time=>tmp_resp)
          end
        end
        tmp_resp = ((Time.now - tmp) * 1000).round(4)
        e.make_history("Ativo",tmp_resp)
        #EquipmentHistory.create(:equipment_id=>e.id,:status=>"Ativo",:room_id=>e.sala_id,:time=>tmp_resp)
      end
    end 
  }
  sleep 10
end
