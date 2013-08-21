m = peripheral.wrap("right")
m.setAutoCollect(true)
local currLevel = 0

function enchantBook()
   turtle.select(1)
   turtle.suck()
   if turtle.getItemCount(1) >= 1 then
    turtle.drop(turtle.getItemCount(1)-1)
    m.enchant(30)
    while turtle.dropDown() == false do
     turtle.dropDown()
     print("Enderchest is full!")
     sleep(10)
    end
   else
   print("I need books!")
   sleep(10)
   end
end

function clearInv()
  turtle.select(1)
  while turtle.getItemCount(1) >= 1 do
   turtle.dropDown()
   print("Clearing Inventory...")
   sleep(5)
  end
end

--print(m.getLevels())
--enchantBook()

clearInv()
while true do
   currLevel = m.getLevels()
   print("Currently Level: "..currLevel)
   if currLevel >=30 then
      enchantBook()
   else
      sleep(10)
   end
end