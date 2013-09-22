function load(permfile)
file = fs.open(permfile,"r")
data = file.readAll()
file.close()
return textutils.unserialize(data)
end
 
tbl = load("perms")
for i,j in pairs(tbl) do
print(i.." has permission level "..j)
end