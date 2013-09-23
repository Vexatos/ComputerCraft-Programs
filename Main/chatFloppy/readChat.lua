os.loadAPI(direct .. "/apis/util")
chattbl = {}

chat, chatSide = util.getPeripheral("chat")
if chat == nil then
  print("No Chat peripheral found")
  return
end

print("Using Chat peripheral on "..chatSide)
print("Reading chat...")
print("")

while true do
event,player,message = os.pullEvent("chat")
write("[d".. os.day() .. "," .. textutils.formatTime(os.time(),true) .. "]")
print(player .. "> " .. message)
chattbl[#chattbl+1] = "[d".. os.day() .. "," .. textutils.formatTime(os.time(),true).. "]" .. player .. "> " .. message
end