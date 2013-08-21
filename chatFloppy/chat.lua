os.loadAPI("rom/apis/miscperipheralsutil")

chat, chatSide = miscperipheralsutil.getPeripheral("chat")
if chat == nil then
  print("No Chat peripheral found")
  return
end

print("Using Chat peripheral on "..chatSide)
print("Press ENTER (empty line) to exit")
print("")

while true do
  line = io.read()
  if line == "" then break end
  chat.say(line)
end