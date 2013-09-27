local scanSide = "left"
local projSide = "right"
local doorSec = 1
local scanPath = "z"
local pasteLink = "https://raw.github.com/matthewsmeets/ComputerCraft/master/AwesomeSauce/Doors/perms/"
local permFile = "perms"

--Not yet implemented
--local password = "secretpassword"
--local passkey = 183

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

--Gets The Database And Puts It In A Array
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

function clearAll()
  term.clear()
  term.setCursorPos(0,0)
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
os.queueEvent("terminate")
sleep(0)
end

clearAll()
if fs.exists(permFile) == true then
  heading("Do you want to update the permission file?")
  setTable("Yes",RelYes,nil,10,20,6,10)
  setTable("No",RelNo,nil,30,40,6,10)
  setTable("Exit",RelExit,nil,0,8,17,19)
  clearAll()
  clicked = 0
  repeat
    screen()
    repeat
    event,but,xPos,yPos = os.pullEvent("mouse_click")
    until but == 1
      checkxy(xPos,yPos)
  until clicked == 1
else
  RelYes()
end

loadTbl = load(permFile)
print("Scanning...")
--function mainProg()
  while true do
    scan(loadTbl)
    sleep(0.025)
  end
--end

--This does not work yet
--function shut()
--  local shutV = 0
--  repeat
--    repeat
--      event,key = os.pullEventRaw("key")
--    until key == passkey
--      clearAll()
--      write("Enter Password: ")
--      passV = io.read()
--      if passV == password then
--        clicked = 1
--        shutV = 1
--        error()
--        return
--      end
--  until shutV == 1
--end

--parallel.waitForAny(mainProg,shut)
