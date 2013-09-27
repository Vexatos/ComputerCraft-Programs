local scanSide = "right"
local projSide = "left"
--local modemSide = "back"
local doorSec = 3
local masterSec = 41
local scanPath = "z"
local pasteLink = "http://pastebin.com/raw.php?i=QkuZZE5W"
local permFile = "perms"

p = peripheral.wrap(scanSide)
--rednet.open(modemSide)
redstone.setOutput(projSide, true)

--Downloads The Latest Database
function getDatabase(pasteLink2,fileName)
 code = http.get(pasteLink2)
  text = code.readAll()
  code.close()
  filee = fs.open(fileName,"w")
  filee.write(text)
  filee.close()
end

--Gets The Database And Puts It In A Array
 function load(permsFile)
 file = fs.open(permsFile,"r")
 dat = file.readAll()
 file.close()
 return textutils.unserialize(dat)
end

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

function getAccess(player,tablName)
--   rednet.send(masterSec, player)
--   local id, msg, dist = rednet.receive(5)
--   print(msg)
    if tablName[player] == nil then
      reply = 1
    else
      reply = tablName[player]
    end
  return(reply)
end

function checkAccess(secLevel)
   if secLevel ~= nil then
      return(secLevel >= doorSec)
   end
   return(false)
end

function scan(tblName)
   local players = p.getPlayerNames()
   local playerAccess
   for num,name in pairs(players) do
    playerAccess = getAccess(name,tblName)
    if checkAccess(playerAccess) then
       if playerInRange(name) then
         openDoor(name)
       end
     end
   end
end

getDatabase(pasteLink,permFile)
loadTbl = load(permFile)

while true do
  scan(loadTbl)
  sleep(0.025)
end