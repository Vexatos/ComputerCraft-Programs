--Sets A Few Varibles And Opens Rednet
SecLvl = 3 --Set The Securety Level
rednet.open("left")

--Downloads The Latest Database
function getdatabase()
 code = http.get("http://pastebin.com/raw.php?i=QkuZZE5W")
  text = code.readAll()
  code.close()
  file = fs.open("perms","w")
  file.write(text)
  file.close()
end

--Gets The Database And Puts It In A Array
 function load(permfile)
 file = fs.open(permfile,"r")
 data = file.readAll()
 file.close()
 return textutils.unserialize(data)
end


--Main Code
getdatabase()
tbl = load("perms")
--Main Loop
while true do
 event,player = os.pullEvent()
  if event == "player" then
  if tbl[player] >= SecLvl then
   print(player.." Has Granted Permission")
    --rs.setOutput("front",true)
    --sleep(2)
    --rs.setOutput("front",false)
  else 
 print(player.." Didnt Get Granted Permission")
end

--Allows to Manually Update The Database
 elseif event == "key" then
  read = io.read()
  if read == "update" then
    getdatabase()
    tbl = load("perms")
  end
 else
end
end
