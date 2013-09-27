local scanSide = "right"
local projSide = "left"
local modemSide = "back"
local doorSec = 3
local masterSec = 41
local scanPath = "z"

p = peripheral.wrap(scanSide)
rednet.open(modemSide)
redstone.setOutput(projSide, true)

function playerInRange(name)
   data = p.getPlayerData(name)
   if data then
      return(math.abs(tonumber(data["position"][scanPath])) <2.5)
   end
   return false
end

function openDoor(name)
   redstone.setOutput(projSide, false)
   while playerInRange(name) do
     sleep(0.5)
   end
   redstone.setOutput(projSide, true)
end   

function getAccess(player)
   rednet.send(masterSec, player)
   local id, msg, dist = rednet.receive(5)
--   print(msg)
   return(msg)
end

function checkAccess(secLevel)
   if secLevel ~= nil then
      return(secLevel >= doorSec)
   end
   return(false)
end

function scan()
   local players = p.getPlayerNames()
   local playerAccess
   for num,name in pairs(players) do
    playerAccess = getAccess(name)
    if checkAccess(playerAccess) then
       if playerInRange(name) then
         openDoor(name)
       end
     end
   end
end

while true do
  scan()
  sleep(0.025)
end