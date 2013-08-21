os.loadAPI("/rom/apis/miscperipheralsutil")
chattbl = {}

chat, chatSide = miscperipheralsutil.getPeripheral("chat")
if chat == nil then
  print("No Chat peripheral found")
  return
end

print("Using Chat peripheral on "..chatSide)
print("Reading chat...")
print("")

local file = fs.open("/liveLog","a")

function read()
 while true do
  event,player,message = os.pullEvent("chat")
  write("[d".. os.day() .. "," .. textutils.formatTime(os.time(),true) .. "]")
  print(player .. "> " .. message)
  file.writeLine("[d".. os.day() .. "," .. textutils.formatTime(os.time(),true).. "]" .. player .. "> " .. message)
  chattbl[#chattbl+1] = "[d".. os.day() .. "," .. textutils.formatTime(os.time(),true).. "]" .. player .. "> " .. message
 end
end

function stop()
 event2,key = os.pullEvent("key")
 if key == 54 then
  file.close()
  shell.run("save")
  print("Terminated!")
  return
 end
end

parallel.waitForAny(read,stop)