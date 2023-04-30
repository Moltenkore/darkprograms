--Title: Outraged Security Client
Version = 4.26
--Author: Darkrising (minecraft name djhannz)
--Platform: ComputerCraft Lua Virtual Machine
term.clear()
term.setCursorPos(1,1)
AutoUpdate = true
x,y = term.getSize()
oldEvent = os.pullEvent
os.pullEvent = os.pullEventRaw
if fs.exists("dark") == false then -- load darkAPI
  print("Missing OSI API")
  sleep(2)
  print("Attempting to download...")
  status, getGit = pcall(http.get,"https://raw.githubusercontent.com/rservices/darkprograms/darkprograms/api/dark.lua")
  if not status then
    print("\nFailed to get OSI API")
    print("Error: ".. getGit)
    return exit
  end
  getGit = getGit.readAll()
  file = fs.open("dark", "w")
  file.write(getGit)
  file.close() 
end
if not dark then
  os.loadAPI("dark")
end
function rednetSendE(ID, Message)
  if not config.enCode then
    Message = dark.repCrypt(Message, 1)
  else
    Message = dark.repCrypt(Message, config.enCode)
  end
  rednet.send(ID, Message)
end
function rednetReceiveE(TimeA)
  local Se,Me,Di = rednet.receive(TimeA)
  if Me then
    if not config.enCode then
      Me = dark.repdeCrypt(Me, 1)
    else
      Me = dark.repdeCrypt(Me, config.enCode)
    end
    return Se,Me,Di
  end
end
function header(text, lText, rText)
  dark.printL("-", 1, nil, "blue", "blue")
  dark.printA("|", x, 2, nil, "blue", "blue")
  dark.printA("|", 1, 2, nil, "blue", "blue")
  dark.printC(string.rep(" ", x), 2, nil, "white", "blue")
  if lText then dark.printA(lText, 1, 2, nil, "white", "blue") end
  if rText then dark.printA(rText, x - #rText, 2, nil, "white", "blue") end
  dark.printC(text, 2, nil, "white", "blue")
  dark.printL("-", 3, 5, "blue", "blue")
end
function footer()
  dark.printL("-", y, nil, "blue", "blue")
  dark.printA("by OutragedMetro", x-13, y, nil, "red", "blue")
end
function keycard_mainProgram()
  while true do
    event, eventinfo, extrainfo = os.pullEventRaw("disk")
    if event == "disk" then
      com2 = {}
      com2.computerid = os.getComputerID()
      com2.area = tonumber(config.securityLevel)
    
      if disk.hasData(eventinfo) == true then
        com2.diskQuery = disk.getID(eventinfo) 
        SendString = textutils.serialize(com2)
        rednetSendE(config.serverID, SendString)
      
        S, M = rednetReceiveE(2)
        
        if M == "#granted" then
          disk.eject(eventinfo)
          rs.setOutput(config.doorside, true)
          sleep(config.pulseTime)
          rs.setOutput(config.doorside, false)
        end
        disk.eject(eventinfo)
      else
        disk.eject(eventinfo)
      end
    end
  end
end
function userandpassword_mainProgram()
  while true do
    com = {}
    com.computerid = os.getComputerID()
    com.area = tonumber(config.securityLevel)
    
    term.clear() term.setCursorPos(1,1)
    footer()
    header(config.tLabel)
    print("") print("")
    
    write(">  Username: ") 
    status, User = pcall(read)
    com.userQuery = string.lower(User)
    
    write(">  Password: ") 
    status, password = pcall(read, "*")
    com.passQuery = password
    
    SendString = textutils.serialize(com)
    
    if ((User ~= nil) and (password ~= nil)) then
      rednetSendE(config.serverID, SendString)
      ID, MES = rednetReceiveE(2)
      if MES == nil then
      print("\nWrong or no response from server.")
      sleep(2)
      else
        if MES == "#granted" then
          dark.printC("Correct", 5, 5)
          rs.setOutput(config.doorside, true)
          sleep(config.pulseTime)
          rs.setOutput(config.doorside, false)
        end
      end
    end
  end
end

S = dark.findPeripheral("modem")
if S == false then
  print("Please attach Modem") 
  return exit
else
  rednet.open(S)  
end
function stealthUpdate()
  if AutoUpdate == true then 
    if ((dark.gitUpdate("client", shell.getRunningProgram(), Version) == true) or (dark.gitUpdate("dark", "dark", dark.DARKversion) == true)) then
      os.reboot()
    end
  end
end
if fs.exists(".DarkC_conf") == false then
  config = {}
  SideList = rs.getSides()
  
  term.clear()
  term.setCursorPos(1,1)
  header("Outraged Security Client Setup")
  
  print("Computer's id is ".. os.getComputerID())
  while true do
    write("\nPlease type the server's computer id: ")
    config.serverID = tonumber(io.read())
    print("\nPinging server...")
    sleep(1)
    com = {}
    com.ping = true
    rednetSendE(config.serverID, textutils.serialize(com))
    s,m,d = rednetReceiveE(2)
    if m and m == "#pong" then
      print("Server responded, test complete.")
      break
    else
      print("\nNo response, this could be down to a number of things...")
      print("\nTry again?")
      write("y / n: ")
      ans = read()
    end
    if ans == "n" then
      break
    end
  end
  
  repeat
    write("\nTerminal Security Level: ")
    config.securityLevel = io.read()
  until tonumber(config.securityLevel)
  config.securityLevel = tonumber(config.securityLevel)
  
  repeat
    write("\nRedstone output side: ")
    doorside = io.read()
  until dark.db.search(doorside, SideList) > 0
  config.doorside = doorside
  
  write("\nRedstone pulse time (in seconds): ")
  pulseTime = tonumber(io.read())
  config.pulseTime = pulseTime
  
  write("\nTerminal label: ")
  config.tLabel = io.read()
  
  print("\nWhat type of terminal is this?")
  print("options: 'keycard', 'password' or 'both'")
  repeat
    write(": ")
    tType = read()
  until ((tType == "keycard") or (tType == "password") or (tType == "both"))
  config.tType = tType
    
  print("\nShall I try and add myself automatically to the server?")
  print("options: y / n")
  repeat
    write(": ")
    encKey = read()
  until (encKey == "y") or (encKey == "n")
  if encKey == "n" then
    repeat
      write("Encryption key: ")
      encKey = read()
    until tonumber(encKey)
  else
    while true do
      print("\nWe will now try and add this client to the server using an admin account.")
      print("Please type your server Admin username and password.")
      com = {}
      write("\nUsername: ")
      com.userQuery = read()
      write("Password: ")
      com.passQuery = read("*")    
      com.area = tonumber(config.securityLevel)
      com.computerid = os.getComputerID()
      com.super = true
      com.addMe = true
      message = textutils.serialize(com)
      rednetSendE(config.serverID, message)
      s,m,d = rednetReceiveE(2)
      if s then
        print("Success!")
        config.enCode = tonumber(m)
        break
      else
        print("Failed, Press enter to try again.")
        read()        
      end    
    end
  end
  
  dark.db.save(".DarkC_conf", config)
  
  print("\nsetup complete!")
  sleep(1.5)
end

config = dark.db.load(".DarkC_conf")

if config.tType == "keycard" then
  parallel.waitForAll(keycard_mainProgram, stealthUpdate)
elseif config.tType == "password" then
  parallel.waitForAll(userandpassword_mainProgram, stealthUpdate)
elseif config.tType == "both" then
  parallel.waitForAll(userandpassword_mainProgram, keycard_mainProgram, stealthUpdate)
end
os.pullEvent = oldEvent
