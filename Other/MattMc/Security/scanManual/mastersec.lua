local sec = {}
local reply
rednet.open("left")

function fillSec()
   sec["direwolf20"] = 3
   sec["Soaryn"] = 3
   sec["Rorax"] = 2
   sec["cpw11"] = 2
end


fillSec()
while true do
  local id, msg, dist = rednet.receive()
  if sec[msg] == nil then
     reply = 1
  else
     reply = sec[msg]
  end
  rednet.send(id, reply)
end