--Title: Dark Server
Version = 6.3
--Author: Darkrising (minecraft name djhannz)
--Platform: ComputerCraft Lua Virtual Machine
if fs.exists("dark") == false then
  print("Missing DarkAPI")
  print("Attempting to download...")
  getGit = http.get("https://github.com/darkrising/darkprograms/raw/darkprograms/darksecurity/dark.lua")
  getGit = getGit.readAll()
  file = fs.open("dark", "w")
  file.write(getGit)
  file.close()
  print("Done!")
  sleep(0.5)
end
os.loadAPI("dark")
--Search for a modem
S = dark.findPeripheral("modem")
if S == false then
  print("Please attach Modem") 
  return exit
else
  rednet.open(S)  
end
--Some Vars
x, y = term.getSize()
AutoUpdate = true
globalWait = 1
slevel = 1
cliVent = {}
co = "blue"
mLog = {}
--Communication
function logDat(Message)
  table.insert(mLog, Message)
end
function sendE(ID, Message)
  if debugMode and (debugMode == true) then
    logDat("Sending to ID: "..ID)
    logDat("Message: "..Message)
    logDat("--------------------")
  end
  if masterdb.pc[tostring(S)] and masterdb.pc[tostring(S)].enCode then
    Message = dark.repCrypt(Message, masterdb.pc[tostring(ID)].enCode)
  else
    Message = dark.repCrypt(Message, 1)
  end
  rednet.send(ID, Message)
end
function recDec(S,M,D)
  if masterdb.pc[tostring(S)] and masterdb.pc[tostring(S)].enCode then
    M = dark.repdeCrypt(M, masterdb.pc[tostring(S)].enCode)
  else
    M = dark.repdeCrypt(M, 1, true)
  end
  if debugMode and (debugMode == true) then
    logDat("Sender: "..S)
    logDat("Message: "..M)
    logDat("Distance: "..D)
    logDat("--------------------")
  end
  return S,M,D
end
--User Management
function decUser(user)
  local encText, pash, out
  encText = masterdb.user[user].password
  pash = masterdb.user[user].pash
  out = dark.decrypt(encText, pash)
  return out
end
function newUser(slevel, Username, Password, isadmin)
  local encText, Hash = dark.encrypt(Password)
  masterdb.user[Username] = {}
  masterdb.user[Username].password = encText
  masterdb.user[Username].pash = Hash
  masterdb.user[Username].admin = isadmin
  masterdb.user[Username].area = slevel
  databaseSave()
end
function delUser(Username)
  masterdb.user[Username] = nil
  databaseSave()
end
--Database Control
function databaseNew()
  local db = {}
  db.ids = {}
  db.user = {}
  db.pc = {}
  return db
end
function databaseSave()
  dark.db.save(".DarkDB", masterdb)
  dark.db.save(".DarkS_conf", config)
end
function databaseLoad()
  masterdb = dark.db.load(".DarkDB")
  config = dark.db.load(".DarkS_conf")  
end
--Gui Elements
function header(text, lText, rText)
  if debugMode and (debugMode == true) then
    co = "red"
  else
    co = "blue"
  end
  dark.printL("-", 1, nil, co, co)
  dark.printA("|", x, 2, nil, co, co)
  dark.printA("|", 1, 2, nil, co, co)
  dark.printC(string.rep(" ", x), 2, nil, "white", co)
  if lText then dark.printA(lText, 1, 2, nil, "white", co) end
  if rText then dark.printA(rText, x - #rText, 2, nil, "white", co) end
  dark.printC(text, 2, nil, "yellow", co)
  dark.printL("-", 3, 5, co, co)
end
function footer()
  if debugMode and (debugMode == true) then
    co = "red"
  else
    co = "blue"
  end
  dark.printL("-", y, nil, co, co)
  dark.printA("by darkrising", x-13, y, nil, "yellow", co)
end
function displayTNameColumn(TName, Page, Extrater, Admin)
  if Extrater then
    local TName2 = {}
    for i,v in pairs(TName) do
      if Admin then
        if v.admin == true then
          table.insert(TName2, i)
        end
      else
        table.insert(TName2, i)
      end
    end
    TName = TName2
  end
  Mod = 42 * Page
  gPage = math.floor(#TName / 42)
  for i = 1, 14 do
    dark.printA(TName[i+Mod], 1, i + 3)
  end
  for i = 1, 14 do
    dark.printA(TName[(i+14)+Mod], 17, i + 3)
  end
  for i = 1, 14 do
    dark.printA(TName[(i+28)+Mod], 34, i + 3)
  end
end
function prevPage()
  if Page ~= 0 then
    Page = Page - 1
  end
end
function nextPage()
 if Page < gPage then
   Page = Page + 1
 end
end
function resetCli()
  cliVent = {}
end
function printR(text, option, bx, line, bgCol)
  if not bx then
    bx, line = term.getCursorPos()
  end
  local clindex = #cliVent + 1
  cliVent[clindex] = {}
  cliVent[clindex].startx = bx
  cliVent[clindex].endx = bx + #text
  cliVent[clindex].starty = line
  cliVent[clindex].endy = line
  cliVent[clindex].option = option
  cliVent[clindex].draw = function()
    term.setCursorPos(bx, line)
    if term.isColor() == true then
      if bgCol then term.setBackgroundColor(colors[bgCol]) end
      term.setTextColor(colors.yellow)
      term.write(text)
      dark.resetCol("white", "black")
    end
  end
  write(text)
  term.setCursorPos(1, line + 1)
end
function regBut(text, startx, line, option, bgCol)
  local clindex = #cliVent + 1
  cliVent[clindex] = {}
  cliVent[clindex].startx = startx
  cliVent[clindex].endx = startx + #text
  cliVent[clindex].starty = line
  cliVent[clindex].endy = line
  cliVent[clindex].option = option
  cliVent[clindex].draw = function()
    term.setCursorPos(startx, line)
    if term.isColor() == true then
      if bgCol then term.setBackgroundColor(colors[bgCol]) end
      term.setTextColor(colors.yellow)
      term.write(text)
      dark.resetCol("white", "black")
    end
  end  
end
function checkArea(tx,ty)
  for _, data in pairs(cliVent) do
    if ty >= data.starty and ty <= data.endy then
      if tx >= data.startx and tx <= data.endx then
        state = Co[state].options[data.option]
        data.draw()
        sleep(0.1)
      end
    end
  end
end
--Server Loops
function listen()
  local cou = 1
  while true do
    os.pullEvent("D")
    cou = cou + 1
    if cou == 5 then
      debugMode = not debugMode
      cou = 1
    end
  end
end
function runServerGui()
  term.clear() 
  term.setCursorPos(1,1)
  dark.splash(1.5, "Powered by DarkGui")  
  state = "main"
  Page = 0  
  while true do
    term.clear()
    term.setCursorPos(1,1)
    resetCli()
    if Co[state].draw then    
      Co[state].draw()
      Event, key, mx, my = os.pullEvent()
      if Event == "char" then
        if tonumber(key) then
          key = tonumber(key)
        end
        if Co[Co[state].options[key]] then
          state = Co[state].options[key]
        end
        if key == "d" then 
          os.queueEvent("D")
        end
        if key == "l" then
          Co["secLev_select"].run()
        end
      elseif Event == "mouse_click" then
        checkArea(mx,my)
      end
    else
      Co[state].run()
      state = Co[state].parent
    end
  end
end
function runServerBackend()
  while true do
	  serverstatus = "running"
    T,S,M,D = os.pullEvent()
    if T == "rednet_message" then
      S,M,D = recDec(S,M,D)
      com = textutils.unserialize(M)
      if (type(com) == "table") and com.area and com.computerid and tonumber(com.area) and tonumber(com.computerid) then
        if (not com.super) and masterdb.pc[tostring(com.computerid)] and (masterdb.pc[tostring(com.computerid)].area == com.area) then
          if com.diskQuery and tonumber(com.diskQuery) and masterdb.ids[tostring(com.diskQuery)] and (masterdb.ids[tostring(com.diskQuery)].area <= tonumber(com.area)) then
            sendE(S, "#granted")
          end
          if com.userQuery and com.passQuery and masterdb.user[com.userQuery] and (decUser(com.userQuery) == com.passQuery) then
            if masterdb.user[com.userQuery].area <= tonumber(com.area) then
              sendE(S, "#granted")
            elseif (masterdb.user[com.userQuery].admin == true) then
              sendE(S, "#granted")
            end
          end
        else
          if com.super and com.userQuery and com.passQuery and masterdb.user[com.userQuery] and (decUser(com.userQuery) == com.passQuery) and (masterdb.user[com.userQuery].admin == true) then
            if com.addMe then
              local genCode = dark.serialGen(18)
              sendE(S, tostring(genCode))
              masterdb.pc[tostring(com.computerid)] = {}
              masterdb.pc[tostring(com.computerid)].enCode = genCode
              masterdb.pc[tostring(com.computerid)].area = tonumber(com.area)
              databaseSave()
            end
          end
        end
      elseif (type(com) == "table") and com.ping then
        sendE(S, "#pong")
      end
    end
  end
end
function stealthUpdate()
  if AutoUpdate == true then 
    if ((dark.gitUpdate("server", shell.getRunningProgram(), Version) == true) or (dark.gitUpdate("dark", "dark", dark.DARKversion) == true)) then
      os.reboot()
    end
  end
  return
end
--Gui Table
Co = {
  ["help"] = {
    draw = function()
      term.clear()
      term.setCursorPos(1,1)
      header("Help")
      dark.printA("Press [1] to return to the main menu", 1, y)
      print("\nHelp comming soon!")
      os.pullEvent("key")
    end,
    options = {"main"}
  },
  ["main"] = {
    draw = function()
      Page = 0
      if debugMode and debugMode == true then
        header("Debug mode enabled!", "V"..Version, "ID:".. os.getComputerID())
        Co.main.options = {"ids", "user_main", "pc_general", "secLev", "help", "log", "lua", "shell"}
      else
        header("Welcome to the Server Control Panel", "V"..Version, "ID:".. os.getComputerID())
        Co.main.options = {"ids", "user_main", "pc_general", "secLev", "help"}
      end
      printR("[1] Disk ID managment", 1)
      printR("[2] User managment", 2)
      printR("[3] Pc managment", 3)
      printR("[4] Security Level Manager", 4)
	    printR("[5] Help", 5)
      print("")
      if debugMode and debugMode == true then 
        printR("[6] Log", 6) 
        printR("[7] Lua Command Prompt", 7) 
        printR("[8] Shell", 8) 
      end
      dark.printL("-", y, nil, co, co)
      dark.printA("by darkrising", x-13, y, nil, "yellow", co)
	    dark.printA("                 ", 1, y, nil, co, co)
      dark.printA("Current Security Level: "..slevel, 1, y, nil, "white", co)
    end,
  },
  ["log"] = {
    draw = function()
      term.setCursorPos(1,4)
      for name, stuff in pairs(mLog) do
        print(stuff)
      end
      header("Communications Log - [1]Go Back, [2]Dump Log")
    end,
    options = {"main", "dump"}
  },
  ["dump"] = {
    run = function()
      header("Log Dump")
      write("log filename: ")
      local filename = "/"..read()
      local file = fs.open(filename, "w")
      for name, stuff in pairs(mLog) do
        file.writeLine(stuff)
      end
      file.close()
      print("\nDone!")
      sleep(2)
    end,
    parent = "log"
  },
  ["lua"] = {
    run = function()
      print("Opened direct Lua input, the program is still running.")
      print("")
      shell.run("lua")
    end,
    parent = "main"
  },
  ["shell"] = {
    run = function()
      print("Dropped to shell, type 'exit' to exit.")
      print("")
      shell.run("shell")
    end,
    parent = "main"
  },
  
  -- disk ids menu
  ["ids"] = {
    draw = function()
      databaseLoad()
      header("ID managment","[4]prevPage","[5]nextPage")
      regBut("[4]prevPage",1,2,4, co)
      regBut("[5]nextPage",x - 7,2,5, co)
      dark.printL("-", y-1, nil, co, co)
      local tempList = {}
      for name, data in pairs(masterdb.ids) do
        if data.area == slevel then
          table.insert(tempList, name)
        end
      end
      displayTNameColumn(tempList, Page)
      dark.printL("-", y, nil, co, co)
      dark.printA("[1]ADD, [2]Delete, [3]Back, P:"..Page + 1 .."/"..gPage + 1 .." Level:"..slevel, 1, y, nil, "white", co)
      regBut("[1]ADD,",1,y,1,co)
      regBut("[2]Delete,",9,y,2,co)
      regBut("[3]Back,",20,y,3,co)
    end,
    options = {"ids_add", "ids_delete", "main", "ids_prevPage", "ids_nextPage"}
  },
  ["ids_add"] = {
    run = function()
      dark.cs()
      header("Disk IDs - add")
      
      print("Do you want to add the id manually?")
      repeat
        write("y / n : ")
        answer1 = read()
      until ((answer1 == "y") or (answer1 == "n"))
      
      if answer1 == "y" then
        repeat
          write("Disk ID to add: ")
          answer = read()
        until tonumber(answer)
      else
        repeat
          print("\nPlease insert a disk into the drive.")
          _,DSide = os.pullEvent("disk")
          if disk.hasData(DSide) == true then
            answer = disk.getID(DSide)
          else
            print("\nNot a disk!")
          end
        until disk.hasData(DSide) == true
        disk.eject(DSide)
        answer = tostring(answer)
      end
      
      if not masterdb.ids[answer] then
        masterdb.ids[answer] = {}
        masterdb.ids[answer].area = slevel
        print("\nAdded!")
        databaseSave()
      else
        print("\nDisk id already exists.")
      end
      write("\nPress enter to continue.")
      read()
    end,
    parent = "ids"
  },
  ["ids_delete"] = {
    run = function()
      dark.cs()
      header("Disk IDs - remove")
      write("Disk ID to remove: ")
      repeat
        answer = read()
      until tonumber(answer)
      if masterdb.ids[answer] then
        masterdb.ids[answer] = nil
        databaseSave()
        print("\nRemoved!")
      else
        print("\nID not found!")
      end
      sleep(globalWait)      
    end,
    parent = "ids"    
  },
  ["ids_prevPage"] = {
    run = prevPage,
    parent = "ids"
  },
  ["ids_nextPage"] = {
    run = nextPage,
    parent = "ids"
  }, 
  
  -- user menus
  ["user_main"] = {
    draw = function()
      Page = 0
      header("User Management")
      printR("[1] Main Menu", 1)
      print("")
      printR("[2] User Manager", 2)
      printR("[3] Admin Manager", 3)
      footer()
    end,
    options = {"main", "user_general", "user_admin"}
  },
  
  ["user_general"] = {
    draw = function()
      Page = 0
      databaseLoad()
      header("General User Managment","[4]prevPage","[5]nextPage")
      regBut("[4]prevPage",1,2,4, co)
      regBut("[5]nextPage",x - 7,2,5, co)
      dark.printL("-", y-1, nil, co, co)
      tempList = {}
      for name, data in pairs(masterdb.user) do
        if (data.area == slevel) and (data.admin == false) then
          table.insert(tempList, name)
        end
      end
      displayTNameColumn(tempList, Page)
      dark.printL("-", y, nil, co, co)
      dark.printA("[1]ADD, [2]Delete, [3]Back, P:"..Page + 1 .."/"..gPage + 1 .." Level:"..slevel, 1, y, nil, "white", co)
      regBut("[1]ADD,",1,y,1,co)
      regBut("[2]Delete,",9,y,2,co)
      regBut("[3]Back,",20,y,3,co)
    end,
    options = {"user_general_add","user_general_remove","user_main","user_general_prevPage","user_general_nextPage"}
  },
  ["user_general_add"] = {
    run = function()
      dark.cs()
      header("Add User")
      write("Username: ")
      local username = read()
      repeat
        write("Password: ")
        pass1 = read("*")
        write("Confirm Password: ")
        pass2 = read("*")
      until pass1 == pass2
      pass1 = tostring(pass1)
      username = string.lower(username)
      newUser(tonumber(slevel), username, pass1, false)
      print("\nUser Added!")
      sleep(globalWait)
    end,
    parent = "user_general"
  },
  ["user_general_remove"] = {
    run = function()
      dark.cs()
      header("Remove User")
      write("User to remove: ")
      local username = read()
      if masterdb.user[username] then
        delUser(username)
        print("\nUser deleted!")
      else
        print("\nUser doesn't exist.")
      end
      sleep(globalWait)
    end,
    parent = "user_general"
  },
  ["user_general_prevPage"] = {
    run = prevPage,
    parent = "user_general"
  },
  ["user_general_nextPage"] = {
    run = nextPage,
    parent = "user_general"  
  },
  
  ["user_admin"] = {
    draw = function()
      Page = 0
      databaseLoad()
      header("Admin Managment","[4]prevPage","[5]nextPage")
      regBut("[4]prevPage",1,2,4, co)
      regBut("[5]nextPage",x - 7,2,5, co)
      dark.printL("-", y-1, nil, co, co)
      displayTNameColumn(masterdb.user, Page, true, true)
      dark.printL("-", y, nil, co, co)
      dark.printA("[1]Promote, [2]Demote, [3]Back, P:"..Page + 1 .."/"..gPage + 1, 1, y, nil, "white", co)
      regBut("[1]Promote,",1,y,1,co)
      regBut("[2]Demote,",13,y,2,co)
      regBut("[3]Back,",24,y,3,co)
    end,
    options = {"user_admin_promote","user_admin_demote","user_main","user_admin_prevPage","user_admin_nextPage"}  
  },
  ["user_admin_promote"] = {
    run = function()
      dark.cs()
      header("Promote User")
      write("User to promote to admin: ")
      username = read()
      if masterdb.user[username] then
        masterdb.user[username].admin = true
        databaseSave()
        print("\nUser promoted")
      else
        print("\nUser doesn't exist")
      end
      sleep(globalWait)
    end,
    parent = "user_admin"
  },
  ["user_admin_demote"] = {
    run = function()
      dark.cs()
      header("Demote User")
      write("User to demote from admin: ")
      username = read()
      if masterdb.user[username] then
        masterdb.user[username].admin = false
        databaseSave()
        print("\nUser demoted")
      else
        print("\nUser doesn't exist")
      end  
      sleep(globalWait)
    end,
    parent = "user_admin"  
  },
  ["user_admin_prevPage"] = {
    run = prevPage,
    parent = "user_admin"
  },
  ["user_admin_nextPage"] = {
    run = nextPage,
    parent = "user_admin"  
  },
  
  -- pc menus  
  ["pc_general"] = {
    draw = function()
      Page = 0
      databaseLoad()
      header("Pc Whitelist","[4]prevPage","[5]nextPage")
      regBut("[4]prevPage",1,2,4, co)
      regBut("[5]nextPage",x - 7,2,5, co)
      dark.printL("-", y-1, nil, co, co)
      tempList = {}
      for name, data in pairs(masterdb.pc) do
        if data.area == slevel then
          table.insert(tempList, name)
        end
      end
      displayTNameColumn(tempList, Page)
      dark.printL("-", y, nil, co, co)
      dark.printA("[1]ADD, [2]Delete, [3]Back, P:"..Page + 1 .."/"..gPage + 1 .." Level:"..slevel, 1, y, nil, "white", co)
      regBut("[1]ADD,",1,y,1,co)
      regBut("[2]Delete,",9,y,2,co)
      regBut("[3]Back,",20,y,3,co)
    end,
    options = {"pc_general_add","pc_general_remove","main","pc_general_prevPage","pc_general_nextPage"}
  },
  ["pc_general_add"] = {
    run = function()
      dark.cs()
      header("Pc whitelist - add")
      write("PC ID to add to the whitelist: ")
      repeat
        answer = read()
      until tonumber(answer)
      if not masterdb.pc[answer] then
        masterdb.pc[answer] = {}
        masterdb.pc[answer].enCode = dark.serialGen(5)
        masterdb.pc[answer].area = slevel
        databaseSave()
        print("\nAdded!")
        dark.setCol("yellow", "black")
        print("\nEncryption Code for the new Client is: ".. masterdb.pc[answer].enCode)
        dark.resetCol(true, true)
        print("\nMake sure to take a note of this number!")
        write("\nPress enter to continue.")
        read()
      else
        print("\nPc id exists.")
        sleep(globalWait)
      end
    end,
    parent = "pc_general"
  },
  ["pc_general_remove"] = {
    run = function()
      dark.cs()
      header("Pc whitelist - remove")
      write("ID to remove from whitelist: ")
      repeat
        answer = read()
      until tonumber(answer)
      if masterdb.pc[answer] then
        masterdb.pc[answer] = nil
        databaseSave()
        print("\nRemoved!")
      else
        print("\nID not found!")
      end
      sleep(globalWait)
    end,
    parent = "pc_general"    
  },
  ["pc_general_prevPage"] = {
    run = prevPage,
    parent = "pc_general"   
  },
  ["pc_general_nextPage"] = {
    run = nextPage,
    parent = "pc_general"    
  },

  -- security level menu
  ["secLev"] = {
    draw = function()
      databaseLoad()
      header("Security Level Manager")
      printR("[1] Main Menu", 1)
      print("")
      print("Security Levels: ".. config.secLevels)
      print("")
      printR("[2] Select Level", 2)
      printR("[3] Modify Level Amount", 3)
      footer()
      dark.printA("Current Security Level: "..slevel, 1, y, nil, "white", co)
    end,
    options = {"main","secLev_select","secLev_modify"}
  },
  ["secLev_select"] = {
    run = function()
      dark.cs()
      header("Security Level - Select")
      print("Currently Selected Security Level: "..slevel)
      print("Security Levels: ".. config.secLevels)
      repeat
        write("\nSecurity Level to switch too: ")        
        answer = read()
      until tonumber(answer)
      answer = tonumber(answer)
      if ((answer < 0) or (answer > config.secLevels)) then
        print("\nInvalid number entered.")
      else
        slevel = answer
        print("Switched to level: "..slevel)
      end
      sleep(globalWait)
    end,
    parent = "secLev"
  },
  ["secLev_modify"] = {
    run = function()
      dark.cs()
      header("Security Level - Modify")
      print("\nSecurity Level Amount: ".. config.secLevels)
      write("New security level amount: ")
      repeat
        answer = read()
      until tonumber(answer)
      config.secLevels = tonumber(answer)
      databaseSave()
      print("Changed!")
      sleep(globalWait)
    end,
    parent = "secLev"
  },
}
--Config file
if fs.exists(".DarkS_conf") == false then 
  dark.cs()
  config = {}
  masterdb = databaseNew()
  header("Dark Server Setup")
  print("Computer's id is ".. os.getComputerID())
  repeat
    write("security level amount (must be a number): ")
    securityLevelNumber = io.read()
  until tonumber(securityLevelNumber)
  config.secLevels = tonumber(securityLevelNumber)
  
  dark.db.save(".DarkDB", masterdb)
  dark.db.save(".DarkS_conf", config)
end
--Finale Stuff
databaseLoad()
parallel.waitForAll(runServerBackend, runServerGui, stealthUpdate, listen)