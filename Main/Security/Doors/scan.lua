--scan program, adapted from the scan program by direwolf20
--gets permission file from a website like pastebin or github
--edited by Vexatos

--The side of the OpenPeripheral sensor
local scanSide = "left"
--The side where Redstone will be sent to
local projSide = "right"
--The security level of the door
local doorSec = 1
--The axis in which the Sensor shall 'look' for players
local scanPath = "z"
-- The remote file in which the permissions are set
local pasteLink = "https://raw.github.com/matthewsmeets/ComputerCraft/master/AwesomeSauce/Doors/perms/"
--How the file with the permissions shall be called
local permFile = "perms"
--The time when the program starts without a button click, default 10
local autoStart = 10
--The time between each check for players, default 0.025
local checkTime = 0.025


--The code, nothing else to edit from here on.

p = peripheral.wrap(scanSide)
redstone.setOutput(projSide, true)

--Downloads The Latest Database
function getDatabase(pasteLink2,fileName)
  Dcode = http.get(pasteLink2)
  text = Dcode.readAll()
  Dfile = fs.open(fileName,"w")
  Dfile.write(text)
  Dcode.close()
  Dfile.close()
end

--Gets The Database And Puts It Into an Array
 function load(permsFile)
 file = fs.open(permsFile,"r")
 dat = file.readAll()
 file.close()
 return textutils.unserialize(dat)
end

--included button stuff, credits to direwolf20

term.setTextColor(colors.white)
local button={}
term.setBackgroundColor(colors.black)

function clearTable()
   button = {}
end
               
function setTable(name, func, param, xmin, xmax, ymin, ymax)
   button[name] = {}
   button[name]["func"] = func
   button[name]["active"] = false
   button[name]["param"] = param
   button[name]["xmin"] = xmin
   button[name]["ymin"] = ymin
   button[name]["xmax"] = xmax
   button[name]["ymax"] = ymax
end

function getActive(name)
   return button[name]["active"]
end   

function fill(text, color, bData)
   term.setBackgroundColor(color)
   local yspot = math.floor((bData["ymin"] + bData["ymax"]) /2)
   local xspot = math.floor((bData["xmax"] - bData["xmin"] - string.len(text)) /2) +1
   for j = bData["ymin"], bData["ymax"] do
      term.setCursorPos(bData["xmin"], j)
      if j == yspot then
         for k = 0, bData["xmax"] - bData["xmin"] - string.len(text) +1 do
            if k == xspot then
               term.write(text)
            else
               term.write(" ")
            end
         end
      else
         for i = bData["xmin"], bData["xmax"] do
            term.write(" ")
         end
      end
   end
   term.setBackgroundColor(colors.black)
end
     
function screen()
   local currColor
   for name,data in pairs(button) do
      local on = data["active"]
      if on == true then currColor = colors.lime else currColor = colors.red end
      fill(name, currColor, data)
   end
end

function toggleButton(name)
   button[name]["active"] = not button[name]["active"]
   screen()
end     

function flash(name)
   toggleButton(name)
   screen()
   sleep(0.15)
   toggleButton(name)
   screen()
end
                                             
function checkxy(x, y)
   for name, data in pairs(button) do
      if y>=data["ymin"] and  y <= data["ymax"] then
         if x>=data["xmin"] and x<= data["xmax"] then
            if data["param"] == "" then
              data["func"]()
            else
              data["func"](data["param"])
            end
            return true
            --data["active"] = not data["active"]
            --print(name)
         end
      end
   end
   return false
end
     
function heading(headText)
   term.setCursorPos(1,1)
   w, h = term.getSize()
   term.setCursorPos((w-string.len(headText))/2+1, 1)
   term.write(headText)
   term.setCursorPos(0,0)
end

--end button stuff

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
    if tablName[player] == nil then
      reply = 1
    else
      reply = tablName[player]
--    print(player.." has access level "..reply)
    end
  return(reply)
end

function checkAccess(secLevel)
   if secLevel ~= nil then
      return(secLevel >= doorSec)
   end
   return(false)
end

function clearAll()
  term.clear()
  term.setCursorPos(0,0)
end

function scan(tblName)
   term.clear()
   term.setCursorPos(1,1)
   print("Scanning...")
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

function RelYes()
  flash("Yes")
  clicked = 1
  clearAll()
  getDatabase(pasteLink,permFile)
--  print("Latest Permission File received")
  sleep(1)
end

function RelNo()
  flash("No")
  clicked = 1
  clearAll()
--  print("No new Permission File received")
  sleep(1)
end

function RelExit()
flash("Exit")
clicked = 1
clearAll()
redstone.setOutput(projSide, true)
os.queueEvent("terminate")
sleep(0)
end

clearAll()
if fs.exists(permFile) == true then
  setTable("Yes",RelYes,nil,10,20,6,10)
  setTable("No",RelNo,nil,30,40,6,10)
  setTable("Exit",RelExit,nil,0,8,17,19)
  clearAll()
  clicked = 0
  timer1 = os.startTimer(autoStart)
  repeat
    heading("Do you want to update the permission file?")
    screen()
    local Bbut = 0
    local Bclicked = 0
    repeat
    event,but,xPos,yPos = os.pullEventRaw()
    if event == "mouse_click" then
      if but == 1 then
        Bbut = 1
      end
    elseif event == "timer" then
      if but == timer1 then
        RelNo()
        Bbut = 2
        Bclicked = 1
      end
    end
    until Bbut ~= 0
    if Bbut == 1 then
      checkxy(xPos,yPos)
      if clicked == 1 then
        Bclicked = 1
      end
    end
  until Bclicked == 1
else
  RelYes()
end

loadTbl = load(permFile)
print("Scanning...")
  while true do
    scan(loadTbl)
    sleep(checkTime)
  end
