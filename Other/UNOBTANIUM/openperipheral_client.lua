--0.2.0 by UNOBTANIUM
local site = {}
local alarm = {}
local selected = 1
local selectedObj = 1
local selectedFrame = 100
local z = 1
local mode = "mainmenu"
local w,h = term.getSize()
local delay = os.startTimer(1)
local colorName = {colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black}
local colorHex = {0xFFFFFF,0xFF8800,0xFF8CFF,0x00FFFF,0xFFF700,0x00FF11,0xF7B5DE,0xBFBFBF,0x65A1D6,0xAF56B3,0x0000FF,0x754302,0x004000,0xFF0000,0x000000}
local b = peripheral.wrap("left")
local net = peripheral.wrap("back")

-- type text x y c
-- type x y text unit method maxNumber c cMax
-- type x y w h cBorder tBorder cBack tBack cOne tOne cTwo tTwo unit method maxNumber
-- type x y w h minNumber maxNumber c t fadeout unit method var

for i=1, 198 do
 site[i] = {}
end

function save()
 local file = fs.open("openPeripheralClient","w")
  for i=1,198 do			-- SITE
   file.writeLine(countArray(site[i]))
   for k,v in pairs(site[i]) do	-- OBJECT
    file.writeLine(countArray(site[i][k]))
    for m,n in pairs(site[i][k]) do	-- VARIABLES
     if (site[i][k][1] == "graphPillar" or site[i][k][1] == "graphPoint") and m == 13 then
      file.writeLine(countArray(site[i][k][m]))
      for a,b in pairs(site[i][k][m]) do
       file.writeLine(site[i][k][m][a])
      end
     else
      file.writeLine(n)
     end
    end
   end
  end
 -- ALARM
 file.close()
end

function load()
 if not fs.exists("openPeripheralClient") then return end
 local file = fs.open("openPeripheralClient","r")
  for i=1,198 do
   local amountObj = tonumber(file.readLine())
   for k=1,amountObj do
    local amountVars = tonumber(file.readLine())
    local typ = file.readLine()
    site[i][k] = {}
    site[i][k][1] = typ
    for m=2,amountVars do
     if typ == "text" then
      if m == 2 then
       site[i][k][m] = file.readLine()
      else
       site[i][k][m] = tonumber(file.readLine())
      end
     elseif typ == "box" then
       site[i][k][m] = tonumber(file.readLine())
     elseif typ == "number" then
      if m == 2 or m == 3 or m >= 7 then
       site[i][k][m] = tonumber(file.readLine())
      else
       site[i][k][m] = file.readLine()
      end
     elseif typ == "bar" then
      if (m >= 2 and m <=13) or m == 16 then
       site[i][k][m] = tonumber(file.readLine())
      else
       site[i][k][m] = file.readLine()
      end
     elseif typ == "graphPillar" or typ == "graphPoint" then
      if m >= 2 and m <= 9 then
       site[i][k][m] = tonumber(file.readLine())
      elseif m == 10 then
       if file.readLine() == "true" then
        site[i][k][m] = true
       else
        site[i][k][m] = false        
       end
      elseif m == 11 or m == 12 then
       site[i][k][m] = file.readLine()
      else
       local amount = tonumber(file.readLine())
       site[i][k][m] = {}
       for a=1,amount do
        site[i][k][m][a] = tonumber(file.readLine())
       end
      end
     elseif typ == "frame" then
       site[i][k][m] = tonumber(file.readLine())
     end
    end
   end
  end

 -- ALARM
 file.close()
end

function clear(color)
 color = color or colors.black
 term.setBackgroundColor(color)
 term.clear()
 term.setCursorPos(1,1)
end

function countArray(a)
 local amount = 0
 for k,v in pairs(a) do
  amount = amount + 1
 end
 return amount
end

function write(text,x,y,c)
 c = c or colors.white
 term.setCursorPos(x,y)
 term.setTextColor(c)
 term.write(text)
end

function centered(text,y,c)
 c = c or colors.white
 term.setCursorPos(w/2-math.ceil(#tostring(text)/2),y)
 term.setTextColor(c)
 term.write(tostring(text))
end

function fill(text,y)
 centered(string.rep(tostring(text), w), y)
end

function setColors(text,background)
 background = background or colors.lightGray
 term.setTextColor(text)
 term.setBackgroundColor(background)
end

function drawArrows(y)
  write("<",15,y)
  write(">",34,y)
end

-- UNIT AND METHOD

function getUnit(pos)
 clear()
 local list = net.getNamesRemote()
 if countArray(list) == 0 then
  write("NOTHING ATTACHED TO THE NETWORK!",25,9)
  sleep(1.5)
  return "NONE"
 end
 local unit = 1
 centered("SELECT A UNIT",1)
 fill("-",2)
 centered("SELECT",14)
 while true do
  fill(" ",9)
  drawArrows(9)
  centered(list[unit],9)
  local event, button, x, y = os.pullEvent()
  if event == "mouse_click" then
   if y >= 8 and y <= 10 then
    if x <= 25 then
     unit = unit - 1
    else
      unit = unit + 1
    end
    if unit == 0 then
     unit = countArray(list)
    elseif unit > countArray(list) then
     unit = 1
    end
   elseif y == 14 then
    site[selected][selectedObj][pos] = list[unit]
    site[selected][selectedObj][pos+1] = "NONE"
    break
   end
  elseif event == "timer" and button == delay then
   drawSite(false)
   delay = os.startTimer(2)
  end
 end
end

function getMethod(pos,unit)
 clear()
 if not net.isPresentRemote(unit) then
  return "NONE"
 end
 local list = net.getMethodsRemote(unit)
-- local list = {}
-- for k,v in pairs(tempList) do
--  print(v)
--  if type(net.callRemote(unit, v)) == "number" then
--   table.insert(list,1,v)
--  end
-- end
 if countArray(list) == 0 then
  centered("NO METHOD FOUND!",9)
  sleep(1.5)
  return "NONE"
 end
 local method = 1
 centered("SELECT A METHOD FROM " .. unit ,1)
 fill("-",2)
 centered("SELECT",14)
 while true do
  fill(" ",9)
  drawArrows(9)
  centered(list[method],9)
  local event, button, x, y = os.pullEvent()
  if event == "mouse_click" then
   if y >= 8 and y <= 10 then
    if x <= 25 then
     method = method - 1
    else
     method = method + 1
    end
    if method == 0 then
     method = countArray(list)
    elseif method > countArray(list) then
     method = 1
    end
   elseif y == 14 then
    site[selected][selectedObj][pos] = list[method]
    break
   end
  elseif event == "timer" and button == delay then
   drawSite(false)
   delay = os.startTimer(2)
  end
 end
end


-- DRAW

-- type text x y c
function drawText(text,x,y,c)
 local var = b.addText(x,y,text,colorHex[c])
 var.setZIndex(z)
end

-- type x y w h cOne tOne cTwo tTwo
function drawBox(x,y,w,h,cOne,tOne,cTwo,tTwo)
 cOne = colorHex[cOne]
 cTwo = colorHex[cTwo]
 local var1 = b.addBox(x,y,w,2,cTwo,tTwo)
 var1.setZIndex(z)
 local var2 = b.addBox(x,y+2,2,h-4,cTwo,tTwo)
 var2.setZIndex(z)
 local var3 = b.addBox(x,y+h-2,w,2,cTwo,tTwo)
 var3.setZIndex(z)
 local var4 = b.addBox(x+w-2,y+2,2,h-4,cTwo,tTwo)
 var4.setZIndex(z)
 local var5 = b.addBox(x+2,y+2,w-4,h-4,cOne,tOne)
 var5.setZIndex(z)
end

-- type x y text unit method maxNumber c cMax
function drawNumber(x,y,text,unit,method,maxNumber,c,cMax)
 c = colorHex[c]
 cMax = colorHex[cMax]
 local number = "NONE"
 if net.isPresentRemote(unit) and not (method == "NONE") then
  number = tonumber(net.callRemote(unit,method))
 end
 local lengthText = ((#text) + 2)*6
 local lengthNumber = (#(tostring(number)))*6
 local maxLength = (#(tostring(maxNumber)))*6
 if type(number) == "string" or (type(number) == "number" and number == maxNumber) then
  local var1 = b.addText(x,y,text .. ":",c)
  var1.setZIndex(z)
  local var2 = b.addText(x+lengthText,y,tostring(number),cMax)
  var2.setZIndex(z)
  local var3 = b.addText(x+lengthText+maxLength,y, " / " .. maxNumber, c)
  var3.setZIndex(z)
 else
  local var1 =  b.addText(x,y, text .. ":", c )
  var1.setZIndex(z)
  local var2 =  b.addText(x+lengthText+(maxLength-lengthNumber),y, number .. " / " .. maxNumber,c)
  var2.setZIndex(z)
 end
end

-- type x y w h cBorder tBorder cBack tBack cOne tOne cTwo tTwo unit method maxNumber
function drawBar(x,y,w,h,cBorder,tBorder,cBack,tBack,cOne,tOne,cTwo,tTwo,unit,method,maxNumber)
 cBorder = colorHex[cBorder]
 cBack = colorHex[cBack]
 cOne = colorHex[cOne]
 cTwo = colorHex[cTwo]
 local var1 = b.addBox(x+2,y+2,w-4,h-4,cBack,tBack)
 var1.setZIndex(z)
 local var2 = b.addBox(x,y,w,2,cBorder,tBorder)
 var2.setZIndex(z)
 local var3 = b.addBox(x,y+h-2,w,2,cBorder,tBorder)
 var3.setZIndex(z)
 local var4 = b.addBox(x,y+2,2,h-4,cBorder,tBorder)
 var4.setZIndex(z)
 local var5 = b.addBox(x+w-2,y+2,2,h-4,cBorder,tBorder)
 var5.setZIndex(z)
 if net.isPresentRemote(unit) and method ~= "NONE" and net.callRemote(unit,method) <= maxNumber then
  local number = net.callRemote(unit,method)
  local box = b.addBox(x+2,y+2,math.ceil((number/maxNumber)*(w-4)),h-4,cOne,tOne)
  box.setColor2(cTwo)
  box.setOpacity(tTwo)
  box.setGradient(2)
  z = z + 1
  box.setZIndex(z)
 end
end

-- type x y w h minNumber maxNumber c t fadeout unit method var
function drawGraph(typ,x,y,w,h,minNumber,maxNumber,c,t,fadeout,var)
 local decrease = t/20
 c = colorHex[c]
 for relX=2,w,2 do
  if fadeout and relX >= w-20 and t > 0.05 then
   t = t - decrease
  end
  if typ == "graphPillar" then
   if type(var[relX/2]) == "number" then
    if var[relX/2] > minNumber then
     local box = b.addBox(x+relX-2,y+(h-(math.ceil((var[relX/2]/(maxNumber))*h))),2,(math.ceil((var[relX/2]/(maxNumber))*h)),c,t)
     box.setZIndex(z)
    else
     local box = b.addBox(x+relX-2,y+h-1,2,1,c,t)
     box.setZIndex(z)
    end
   else
    local box = b.addBox(x+relX-2,y+h-1,2,1,c,t)
    box.setZIndex(z)
   end
  else
   if type(var[relX/2]) == "number" then
    if var[relX/2] > minNumber then
     local box = b.addBox(x+relX-2,y+(h-1-((math.ceil((var[relX/2]/(maxNumber))*h)))),2,2,c,t)
     box.setZIndex(z)
     local box = b.addBox(x+relX-2,y+h-1,2,1,c,t)
     box.setZIndex(z)
    else
     local box = b.addBox(x+relX-2,y+h-1,2,1,c,t)
     box.setZIndex(z)
    end
   else
    local box = b.addBox(x+relX-2,y+h-1,2,1,c,t)
    box.setZIndex(z)
   end
  end
 end
end

function innerDraw(relX,relY,s) 
 for k,v in pairs(site[s]) do
  if site[s][k][1] == "frame" then
   innerDraw(site[s][k][3],site[s][k][4],site[s][k][2])
  elseif site[s][k][1] == "box" then
   drawBox(site[s][k][2]+relX,site[s][k][3]+relY,site[s][k][4],site[s][k][5],site[s][k][6],site[s][k][7],site[s][k][8],site[s][k][9])
   z = z + 1
  end
 end

 for k,v in pairs(site[s]) do
  if site[s][k][1] == "number" then
   drawNumber(site[s][k][2]+relX,site[s][k][3]+relY,site[s][k][4],site[s][k][5],site[s][k][6],site[s][k][7],site[s][k][8],site[s][k][9])
   z = z + 1
  elseif site[selected][k][1] == "bar" then
   drawBar(site[s][k][2]+relX,site[s][k][3]+relY,site[s][k][4],site[s][k][5],site[s][k][6],site[s][k][7],site[s][k][8],site[s][k][9],site[s][k][10],site[s][k][11],site[s][k][12],site[s][k][13],site[s][k][14],site[s][k][15],site[s][k][16])
   z = z + 1
  elseif site[s][k][1] == "graphPillar" or site[s][k][1] == "graphPoint" then
   drawGraph(site[s][k][1],site[s][k][2]+relX,site[s][k][3]+relY,site[s][k][4],site[s][k][5],site[s][k][6],site[s][k][7],site[s][k][8],site[s][k][9],site[s][k][10],site[s][k][13])
   z = z + 1
  end
 end

 for k,v in pairs(site[s]) do
  if site[s][k][1] == "text" then
   drawText(site[s][k][2],site[s][k][3]+relX,site[s][k][4]+relY,site[s][k][5])
   z = z + 1
  end
 end
end

function drawSite(doRefresh)
 z = 1
 if doRefresh then
  refresh()
 end
 b.clear()
 if selected == 0 then return end
 innerDraw(0,0,selected)
 save()
end

function refresh()
 for k,v in pairs(site) do
  for m,n in pairs(site[k]) do
   if (site[k][m][1] == "graphPillar" or site[k][m][1] == "graphPoint") and net.isPresentRemote(site[k][m][11]) and site[k][m][12] ~= "NONE" then
    table.insert(site[k][m][13],1,net.callRemote(site[k][m][11],site[k][m][12]))
    if type(site[k][m][13][math.ceil(site[k][m][4]/2)+1]) ~= nil then
     site[k][m][13][math.ceil(site[k][m][4]/2)+1] = nil
    end
   elseif site[k][m][1] == "graphPillar" or site[k][m][1] == "graphPoint" then
    table.insert(site[k][m][13], 1, 0)
    if type(site[k][m][13][math.ceil(site[k][m][4]/2)+1]) ~= nil then
     site[k][m][13][math.ceil(site[k][m][4]/2)+1] = nil
    end
   end
  end
 end
end

function drawColor(i,y)
 drawArrows(y)
 term.setBackgroundColor(colorName[site[selected][selectedObj][i]])
 centered("   ",y)
 term.setBackgroundColor(colors.black)
end

function drawTransparent(i,y)
 drawArrows(y)
 centered(site[selected][selectedObj][i],y)
end




function draw()
 clear()
 if mode == "mainmenu" then
  write("Site",20,6)
  write("Frame",20,8)
  write("Alarm",20,10)
  write("Quit",20,12)
 elseif mode == "selectSite" then
  centered("Select Site",1)
  centered(selected, 8)
  drawArrows(8)
  centered("SELECT",11)
  centered("BACK",13)
 elseif mode == "selectFrame" then
  centered("Select Frame",1)
  centered(selected-99, 8)
  drawArrows(8)
  centered("SELECT",11)
  centered("BACK",13)
 elseif mode == "selectAlarm" then
  
 elseif mode == "individualizeSite" or mode == "individualizeFrame" then
  if mode == "individualizeSite" then
   centered("INDIVIDUALIZE SITE " .. selected ,1)
  elseif mode == "individualizeFrame" then
   centered("INDIVIDUALIZE FRAME " .. selected-99 ,1)
  end
  fill("-",2)
  if type(site[selected][selectedObj]) == "table" then
   centered(selectedObj.. " - " .. site[selected][selectedObj][1] , 3)
  else
   centered(selectedObj , 3)
  end
  drawArrows(3)
  fill("-",4)
  write("BACK",48,1)
  if type(site[selected][selectedObj]) == "table" then		-- object exists
   write("DELETE",1,1)
   if site[selected][selectedObj][1] == "text" then		-- TEXT
    write("TEXT: " .. site[selected][selectedObj][2],10,7)
    write("X:    " .. site[selected][selectedObj][3],10,9)
    write("Y:    " .. site[selected][selectedObj][4],10,11)
    drawColor(5,13)
   elseif site[selected][selectedObj][1] == "box" then		-- BOX
    write("X:      " .. site[selected][selectedObj][2],10,5)
    write("Y:      " .. site[selected][selectedObj][3],10,6)
    write("WIDTH:  " .. site[selected][selectedObj][4],10,7)
    write("HEIGHT: " .. site[selected][selectedObj][5],10,8)
    drawColor(6,9)
    drawTransparent(7,10)
    drawColor(8,11)
    drawTransparent(9,12)
   elseif site[selected][selectedObj][1] == "number" then	-- NUMBER
    write("X:      "..site[selected][selectedObj][2],10,5)
    write("Y:      "..site[selected][selectedObj][3],10,6)
    write("TEXT:   "..site[selected][selectedObj][4],10,7)
    write("UNIT:   "..site[selected][selectedObj][5],10,8)
    write("METHOD: "..site[selected][selectedObj][6],10,9)
    write("MAX:    "..site[selected][selectedObj][7],10,10)
    drawColor(8,11)
    drawColor(9,12)
   elseif site[selected][selectedObj][1] == "bar" then		-- BAR
    write("X:      "..site[selected][selectedObj][2],10,5)
    write("Y:      "..site[selected][selectedObj][3],10,6)
    write("WIDTH:  "..site[selected][selectedObj][4],10,7)
    write("HEIGHT: "..site[selected][selectedObj][5],10,8)
    write("UNIT:   "..site[selected][selectedObj][14],10,9)
    write("METHOD: "..site[selected][selectedObj][15],10,10)
    write("MAX:    "..site[selected][selectedObj][16],10,11)
    drawColor(6,12)
    drawTransparent(7,13)
    drawColor(8,14)
    drawTransparent(9,15)
    drawColor(10,16)
    drawTransparent(11,17)
    drawColor(12,18)
    drawTransparent(13,19)
   elseif site[selected][selectedObj][1] == "graphPillar" or site[selected][selectedObj][1] == "graphPoint" then			
		-- GRAPHS
    write("X:       "..site[selected][selectedObj][2],10,5)
    write("Y:       "..site[selected][selectedObj][3],10,6)
    write("WIDTH:   "..site[selected][selectedObj][4],10,7)
    write("HEIGHT:  "..site[selected][selectedObj][5],10,8)
    write("UNIT:    "..site[selected][selectedObj][11],10,9)
    write("METHOD:  "..site[selected][selectedObj][12],10,10)
    write("MIN:     "..site[selected][selectedObj][6],10,11)
    write("MAX:     "..site[selected][selectedObj][7],10,12)
    drawColor(8,13)
    drawTransparent(9,14)
    write("FADEOUT: "..tostring(site[selected][selectedObj][10]),10,15)
    write("TYPE:   " ..site[selected][selectedObj][1],10,16)
   elseif site[selected][selectedObj][1] == "frame" then	-- FRAME
    centered(selectedFrame-99,5)
    drawArrows(5)
    fill("-",6)
    write("X: "..site[selected][selectedObj][3],10,8)
    write("Y: "..site[selected][selectedObj][4],10,10)
   end
  else	--create new object
   write("TEXT",20,6)
   write("BOX",20,7)
   write("NUMBER",20,8)
   write("BAR",20,9)
   write("GRAPH (PILLAR)",20,10)
   write("GRAPH (POINT)",20,11)
   if mode == "individualizeSite" then
    write("FRAME",20,12)
   end
  end
 end
end



function changeColor(x,pos)
 if x < 25 then
  site[selected][selectedObj][pos] = site[selected][selectedObj][pos] - 1
 else
  site[selected][selectedObj][pos] = site[selected][selectedObj][pos] + 1
 end
 if site[selected][selectedObj][pos] <= 0 then
  site[selected][selectedObj][pos] = 15
 elseif site[selected][selectedObj][pos] >= 16 then
  site[selected][selectedObj][pos] = 1
 end
end

function changeTransparence(x,pos)
 if x < 25 then
  site[selected][selectedObj][pos] = site[selected][selectedObj][pos] - 0.1
 else
  site[selected][selectedObj][pos] = site[selected][selectedObj][pos] + 0.1
 end
 if site[selected][selectedObj][pos] < 0 then
  site[selected][selectedObj][pos] = 1
 elseif site[selected][selectedObj][pos] > 1 then
  site[selected][selectedObj][pos] = 0
 end
end

function betterRead(x,y,numberOnly,pos,clickX)
 term.setTextColor(colors.lightGray)
 term.setCursorBlink(true)
 local s
 if clickX < x then
  s = ""
 else
  s = tostring(site[selected][selectedObj][pos])
 end


 while true do
  term.setCursorPos(x,y)
  term.write( string.rep(' ', w - x + 1) )
  term.setCursorPos(x,y)
  if s:len()+x < w then
   term.write(s)
  else
   term.write(s:sub( s:len() - (w-x-2)))
  end
  local e = { os.pullEvent() }
  if e[1] == "timer" and e[2] == delay then
   drawSite(false)
   delay = os.startTimer( 2 )
  elseif e[1] == "char" then
   s = s .. e[2]
  elseif e[1] == "key" then
   if e[2] == keys.enter then
    break
   elseif e[2] == keys.backspace then
    s = s:sub( 1, s:len() - 1 )
   end
  end
 end
 term.setTextColor(colors.white)
 if numberOnly then
  s = tonumber(s)
  if s then
   site[selected][selectedObj][pos] = s
  end
 else
  site[selected][selectedObj][pos] = s
 end
 term.setCursorBlink(false)
end





function mouseInteraction(x,y)
 if mode == "mainmenu" then
  if y == 6 then
   mode = "selectSite"
   selected = 1
   elseif y == 8 then
   mode = "selectFrame"
   selected = 100
  elseif y == 10 then
   --mode = "selectAlarm"
  elseif y == 12 then
   save()
   b.clear()
   os.reboot()
  end
 elseif mode == "individualizeSite" then
  checkIndividualization(x,y)
 elseif mode == "individualizeFrame" then
  checkIndividualization(x,y)
 elseif mode == "individualizeAlarm" then

 elseif mode == "selectSite" or mode == "selectFrame" or mode == "selectAlarm" then	-- SELECT
  if y == 8 then
   if x < 25 then
    selected = selected - 1
   else
    selected = selected + 1
   end
   if mode == "selectSite" then
    if selected == 0 then
     selected = 99
    elseif selected == 100 then
     selected = 1
    end
   elseif mode == "selectFrame" then
    if selected == 99 then
     selected = 198
    elseif selected == 199 then
     selected = 100
    end
   end
  elseif y == 11 then
   if mode == "selectSite" then
    mode = "individualizeSite"
    selectedObj = 1
   elseif mode == "selectFrame" then
    mode = "individualizeFrame"
    selectedObj = 1
    selectedFrame = 100
   elseif mode == "selectAlarm" then
    mode = "individualizeAlarm"
    selectedObj = 1
   end
   return
  elseif y == 13 then
   mode = "mainmenu"
  end
 end
end


function checkIndividualization(x,y)
 if y == 3 then
  if x < 25 then
   selectedObj = selectedObj - 1
  else
   selectedObj = selectedObj + 1
  end
  if selectedObj == 0 then
   selectedObj = 1
  end
 elseif y == 1 and x >= w-3 then
  mode = "mainmenu"
  return
 end
 if type(site[selected][selectedObj]) == "table" then
  if y == 1 and x <=6 then
   site[selected][selectedObj] = nil
  elseif site[selected][selectedObj][1] == "text" then
   if y == 7 then
    betterRead(16,y,false,2,x)
   elseif y == 9 then
    betterRead(16,y,true,3,x)
   elseif y == 11 then
    betterRead(16,y,true,4,x)
   elseif y == 13 then
    changeColor(x,5)
   end
  elseif site[selected][selectedObj][1] == "box" then
   if y == 5 then
    betterRead(18,y,true,2,x)
   elseif y == 6 then
    betterRead(18,y,true,3,x)
   elseif y == 7 then
    betterRead(18,y,true,4,x)
   elseif y == 8 then
    betterRead(18,y,true,5,x)
   elseif y == 9 then
    changeColor(x,6)
   elseif y == 10 then
    changeTransparence(x,7)
   elseif y == 11 then
    changeColor(x,8)
   elseif y == 12 then
    changeTransparence(x,9)
   end
  elseif site[selected][selectedObj][1] == "number" then
   if y == 5 then
    betterRead(18,y,true,2,x)
   elseif y == 6 then
    betterRead(18,y,true,3,x)
   elseif y == 7 then
    betterRead(18,y,false,4,x)
   elseif y == 8 then
    getUnit(5)
   elseif y == 9 then
    getMethod(6,site[selected][selectedObj][5])
   elseif y == 10 then
    betterRead(18,y,true,7,x)
   elseif y == 11 then
    changeColor(x,8)
   elseif y == 12 then
    changeColor(x,9)
   elseif y == 13 then
   end
  elseif site[selected][selectedObj][1] == "bar" then
   if y == 5 then
    betterRead(18,y,true,2,x)
   elseif y == 6 then
    betterRead(18,y,true,3,x)
   elseif y == 7 then
    betterRead(18,y,true,4,x)
   elseif y == 8 then
    betterRead(18,y,true,5,x)
   elseif y == 9 then
    getUnit(14)
   elseif y == 10 then
    getMethod(15,site[selected][selectedObj][14])
   elseif y == 11 then
    betterRead(18,y,true,16,x)
   elseif y == 12 then
    changeColor(x,6)
   elseif y == 13 then
    changeTransparence(x,7)
   elseif y == 14 then
    changeColor(x,8)
   elseif y == 15 then
    changeTransparence(x,9)
   elseif y == 16 then
    changeColor(x,10)
   elseif y == 17 then
    changeTransparence(x,11)
   elseif y == 18 then
    changeColor(x,12)
   elseif y == 19 then
    changeTransparence(x,13)
   end
  elseif site[selected][selectedObj][1] == "graphPillar" or site[selected][selectedObj][1] == "graphPoint" then
   if y == 5 then
    betterRead(19,y,true,2,x)
   elseif y == 6 then
    betterRead(19,y,true,3,x)
   elseif y == 7 then
    betterRead(19,y,true,4,x)
   elseif y == 8 then
    betterRead(19,y,true,5,x)
   elseif y == 9 then
    getUnit(11)
   elseif y == 10 then
    getMethod(12,site[selected][selectedObj][11])
   elseif y == 11 then
    betterRead(19,y,true,6,x)
   elseif y == 12 then
    betterRead(19,y,true,7,x)
   elseif y == 13 then
    changeColor(x,8)
   elseif y == 14 then
    changeTransparence(x,9)
   elseif y == 15 then
    site[selected][selectedObj][10] = not site[selected][selectedObj][10]
   elseif y == 16 then
    if site[selected][selectedObj][1] == "graphPoint" then
     site[selected][selectedObj][1] = "graphPillar"
    elseif site[selected][selectedObj][1] == "graphPillar" then
     site[selected][selectedObj][1] = "graphPoint"
    end
   end
  elseif site[selected][selectedObj][1] == "frame" then
   if y == 5 then
    if x < 25 then
     selectedFrame = selectedFrame - 1
    else
     selectedFrame = selectedFrame + 1
    end
    if selectedFrame == 99 then
     selectedFrame = 198
    elseif selectedFrame == 199 then
     selectedFrame = 100
    end
    site[selected][selectedObj][2] = selectedFrame
   elseif y == 8 then
    betterRead(13,y,true,3,x)
   elseif y == 10 then
    betterRead(13,y,true,4,x)
   end
  end
 else				-- CREATE
  if y == 6 then
   site[selected][selectedObj] = {"text","UNOBTANIUM",1,1,1}
  elseif y == 7 then
   site[selected][selectedObj] = {"box",1,1,10,10,1,1,1,1}
  elseif y == 8 then
   site[selected][selectedObj] = {"number",1,1,"UNOBTANIUM","NONE","NONE",1337,1,1}
  elseif y == 9 then
   site[selected][selectedObj] = {"bar",1,1,40,15,1,1,1,1,1,1,1,1,"NONE","NONE",1337}
  elseif y == 10 then
   site[selected][selectedObj] = {"graphPillar",1,1,100,40,0,1337,1,1,false,"NONE","NONE",{}}
  elseif y == 11 then
   site[selected][selectedObj] = {"graphPoint",1,1,100,40,0,1337,1,1,false,"NONE","NONE",{}}
  elseif y == 12 and mode == "individualizeSite" then
   site[selected][selectedObj] = {"frame",100,1,1}
  end
 end
 save()
end

function run()
 -- draw
 draw()
 drawSite(false)

 -- interactions
 local event = {os.pullEvent()}
 
 if event[1] == "timer" and event[2] == delay then
  drawSite(true)
  delay = os.startTimer(2)
 elseif event[1] == "mouse_click" then
  mouseInteraction(event[3],event[4])
 elseif event[1] == "chat_command" then
  if event[2] == "clear" then
   selected = 0
   mode = "mainmenu"
  end
  for i=1,99 do
   if event[2] == "site"..i then
    selected = i
    selectedObj = 1
    selectedFrame = 1
    break
   end
  end
 end
end


load()
while true do
 run()
end