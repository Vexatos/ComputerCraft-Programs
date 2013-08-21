local file = fs.open("log","a")
for i=1,#chattbl do
file.writeLine(chattbl[i])
end
file.close()