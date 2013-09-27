--edit of the pastebin program, edited by Vexatos
local function printUsage()
    print( "Usages:" )
    print( "github get <username> <reponame> <branch> <path> <filename>" )
    print( "github run <username> <reponame> <branch> <path> <arguments>" )
end
 
local tArgs = { ... }
if #tArgs < 6 then
    printUsage()
    return
end
 
if not http then
    printError( "Github requires http API" )
    printError( "Set enableAPI_http to true in ComputerCraft.cfg" )
    return
end
 
local function get(name,reponame,branch,path)
    write( "Connecting to github.com... " )
    local response = http.get(
        "https://raw.github.com/"..textutils.urlEncode( name ).."/"..textutils.urlEncode( reponame ).."/"..textutils.urlEncode( branch ).."/"..textutils.urlEncode( path )
    )
        
    if response then
        print( "Success." )
        
        local sResponse = response.readAll()
        response.close()
        return sResponse
    else
        printError( "Failed." )
    end
end
 
local sCommand = tArgs[1]
if sCommand == "get" then
    -- Download a file from github.com
    if #tArgs < 6 then
        printUsage()
        return
    end
 
    -- Determine file to download
    local sName = tArgs[2]
    local sRepo = tArgs[3]
    local sBranch = tArgs[4]
    local sPath = tArgs[5]
    local sFile = tArgs[6]
    local sPathN = shell.resolve( sFile )
    if fs.exists( sPathN ) then
        print( "File already exists" )
        return
    end
    
    -- GET the contents from github
    local res = get(sName,sRepo,sBranch,sPath)
    if res then        
        local file = fs.open( sPathN, "w" )
        file.write( res )
        file.close()
        
        print( "Downloaded as "..sFile )
    end 
elseif sCommand == "run" then
    local sName = tArgs[2]
    local sRepo = tArgs[3]
    local sBranch = tArgs[4]
    local sPath = tArgs[5]
 
    local res = get(sName,sRepo,sBranch,sPath)
    if res then
        local func, err = loadstring(res)
        if not func then
            printError( err )
            return
        end
        setfenv(func, getfenv())
        local success, msg = pcall(func, unpack(tArgs, 6))
        if not success then
            printError( msg )
        end
    end
else
    printUsage()
    return
end