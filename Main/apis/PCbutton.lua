--local mon = peripheral.wrap("top")
--mon.setTextScale(1)
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

function funcName()
   print("You clicked buttonText")
end
        
function fillTable()
   setTable("ButtonText", funcName, 5, 25, 4, 8)
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
     
function heading(text)
   w, h = term.getSize()
   term.setCursorPos((w-string.len(text))/2+1, 1)
   term.write(text)
end
     
function label(w, h, text)
   term.setCursorPos(w, h)
   term.write(text)
end