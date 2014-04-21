--Args
args = {...}
--[[
  optional arguments
  1: username
  2: channel (default will be 10)
  3: autoupdate (false to disable)
]]--
--changeable
HistoryNum = 200 --how many lines of history to keep
if args[3] and args[3] == "false" then
  autoupdate = false
else
  autoupdate = true -- turn on or off auto update
end
--Non changeable!
chat = {}
lineCount = 1
modifier = 0
X, Y = term.getSize()
Version = 1.51
BottomText = "Message: "
KeyCount = 0
user = ""
Header = "Welcome to darkchat "..Version.."!"
function findPeripheral(Perihp) 
  for _,s in ipairs(rs.getSides()) do
    if peripheral.isPresent(s) and peripheral.getType(s) == Perihp then
      return s
    end
  end
  return false
end
function gitUpdate(ProgramName, Filename, ProgramVersion)
  if http then
    status, getGit = pcall(http.get, "https://raw.github.com/darkrising/darkprograms/darkprograms/programVersions")
    if not status then 
      return(getGit)
    end    
    local getGit = getGit.readAll()
    NVersion = textutils.unserialize(getGit)
    if NVersion[ProgramName].Version > ProgramVersion then
      getGit = http.get(NVersion[ProgramName].GitURL)
      getGit = getGit.readAll()
      local file = fs.open(Filename, "w")
      file.write(getGit)
      file.close()
      return true
    end
  else
    return false
  end
end
function split(str, pattern) -- Splits string by pattern, returns table
  local t = { }
  local fpat = "(.-)" .. pattern
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end
function cWrite(Text, bgcolor, tecolor, solid)
  if term.isColor() == true then
    term.setBackgroundColor(colors[bgcolor])
    term.setTextColor(colors[tecolor])
    if solid then
      term.write(string.rep(" ", #Text))
    else
      term.write(Text)
    end
  else
    term.write(Text)
  end
end
function bgReset()
  if term.isColor() == true then
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
  end
end
function rSend(message, special, hidden)
  local messaget = {}
  messaget.user = user
  messaget.message = message
  messaget.darkchat = true
  messaget.id = os.getComputerID()
  if special then messaget.special = true end
  messaget = textutils.serialize(messaget)
  modem.transmit(channelN,channelN,messaget)
  if not hidden then
    if special then
      os.queueEvent("tableInsert", "yellow#* "..user.." "..message)
    else
      os.queueEvent("tableInsert", "white#"..user..": "..message)
    end
  end
end
function rReceive()
  local darkchat = false
  repeat
    _,_,C,rC,M,D = os.pullEvent("modem_message")
    M = textutils.unserialize(M)
    if type(M) == "table" and M.darkchat then
      darkchat = true
    elseif type(M) == "table" and M.list then
      local list = {}
      list.user = user
      list.reply = true
      list = textutils.serialize(list)
      modem.transmit(channelN,channelN,list)
    elseif type(M) == "table" and M.reply then
      os.queueEvent("user",M.user)
    end
  until darkchat == true
  return M
end
function modiferMod(operation, amount) -- if operation is true, number will be added else subtacted
  if operation == true then
    if lineCount - modifier > 1 then
      modifier = modifier + 1
    end
  else
    if modifier > 0 then
      modifier = modifier - 1
    end
  end
end
function clears()
  for i = 1, Y - 2 do
    term.setCursorPos(1,i)
    term.write(string.rep(" ", X))
  end
end
function getChat()
  draw()
  while true do
    m = rReceive()
    if m.id ~= os.getComputerID() and m.user ~= user and m.message then
      if m.special then
        os.queueEvent("tableInsert", "yellow#* ".. m.user .. " " .. m.message)
      else
        os.queueEvent("tableInsert", "white#" .. m.user ..": ".. m.message)
      end
    end
  end
end
function draw() 
  bgReset() clears()
  if #chat > HistoryNum then table.remove(chat, 1) end
  if #chat > Y - 2 then 
    lineCount = ((#chat) - (Y - 3))
  end
  for i = lineCount - modifier, #chat - modifier do
    chatN = split(chat[i], "#")
    term.setCursorPos(1,i - lineCount+1+modifier)
    cWrite(chatN[2],"black",chatN[1])
  end
  term.setCursorPos(1, Y - 1)
  cWrite(string.rep("-", X), "blue","blue", true) 
  term.setTextColor(colors.white)
  local Text = "<User: "..user.."> <Channel: "..channelN..">"
  term.setCursorPos(X/2 - #Text/2, Y - 1)
  write(Text)
  if modifier > 0 and term.isColor() == true then
    paintutils.drawPixel(1, Y - 1, colors.yellow)
    paintutils.drawPixel(X, Y - 1, colors.yellow)
  end
  bgReset()
  term.setCursorPos(#BottomText + KeyCount + 1, Y)
  return true
end
function sendChat()
  while true do
    term.setCursorPos(1, Y)
    term.write(BottomText)
    message = read()
    if string.sub(message,1,1) == "/" then
      commandS = string.sub(message,2,#message)
      commandS = split(commandS, " ")
      if comD[commandS[1]] then
        comD[commandS[1]].run(commandS)
      else
        os.queueEvent("tableInsert", "red#Unknown Command")
      end
    elseif message == "" then
      draw()
    elseif message then
      rSend(message)
      draw()
    end
  end
end
function keyListen()
  while true do
    Type, KEY = os.pullEvent("key")
    if KEY == 28 then 
      KeyCount = 0
    elseif KEY == 14 then
      if KeyCount ~= 0 then
        KeyCount = KeyCount - 1
      end
    elseif KEY then
      if KEY ~= 54 then
        KeyCount = KeyCount + 1
      end
    end
  end
end
function startUp()
  term.clear() term.setCursorPos(1,1)
  if autoupdate == true then
  print("Checking for updates...")
  local updateStatus = gitUpdate("chat", shell.getRunningProgram(), Version)
    if type(updateStatus) == "string" then
      print("Cannot check for updates:")
      print(updateStatus)
      sleep(1)
    elseif updateStatus == true then
      print("Downloaded new version, restarting...")
      sleep(1.5)
      os.reboot()
    else
      print("You're running the latest version")
      sleep(1)
    end
  end
  Side = findPeripheral("modem")
  if not Side then
    print("no modem.")
    return exit
  end
  modem = peripheral.wrap(Side)
  term.clear() term.setCursorPos(1,1)
  cWrite(string.rep("-", X), "blue","blue", true) bgReset()
  term.setCursorPos(X/2 - string.len(Header)/2,2)
  print(Header)
  cWrite(string.rep("-", X), "blue","blue", true) bgReset()
end
function privateMode()
  user = config.user
  channelN = config.channel
end
function publicMode()
  repeat
    write("Nickname: ")
    user = read()
    if user == "" then
      print("\nInvalid Name")
    end
  until user ~= ""
  print("\nDefault channel is 10")
  write("Channel: ")
  channelN = read()
  if not tonumber(channelN) then
    channelN = "10"
  end
end
function getOnlineList()
  while true do
    os.pullEvent("grabList")
    local com = {}
    local Users = ""
    com.list = true
    com = textutils.serialize(com)
    modem.transmit(channelN,channelN,com)
    os.startTimer(2)
    repeat
      local e, u = os.pullEvent()
      if e == "user" then
        Users = Users..u..", "
      end
    until e == "timer"
    Users = string.sub(Users, 1, #Users - 2) -- remove extra comma
    os.queueEvent("tableInsert", "yellow#Users in channel: "..Users)
  end
end
function scrollingEventListen()
  while true do
    local _,direction = os.pullEvent("mouse_scroll")
    if direction == -1 then
      modiferMod(true, 1) 
      draw()
    else
      modiferMod(false, 1) 
      draw()  
    end
  end
end
function tableEventListen()
  while true do
    local e, mess = os.pullEvent("tableInsert")
    if modifier > 0 and HistoryNum ~= #chat then
      modifier = modifier + 1
    end
    table.insert(chat, mess)
    draw()
  end
end
function exitEventListen()
  while true do
    os.pullEvent("exit")
    term.clear()
    term.setCursorPos(1,1)
    modem.closeAll()
    return exit
  end
end
function helpGen()
  os.queueEvent("tableInsert", "lime#".. string.rep("-", X / 2 - 4) .. "  help  " .. string.rep("-", X / 2 - 3))
  for i, v in pairs(comD) do
    if v.help then
      os.queueEvent("tableInsert", "lime#/"..i.." ".. v.help)
    end
  end
  os.queueEvent("tableInsert", "lime#".. string.rep("-", X))
end
comD = {
  ["exit"] = {
    run = function()
      rSend("has quit.", true)
      os.queueEvent("exit")
    end,
    help = ""
  },
  ["quit"] = {
    run = function()
      rSend("has quit.", true)
      os.queueEvent("exit")
    end,
    help = ""
  },
  ["me"] = {
    run = function(Words)
      local StringRe = ""
      for i = 2, #Words do
        StringRe = StringRe..Words[i].." "
      end
      rSend(StringRe, true)
    end,
    help = "<text>"
  },
  ["channel"] = {
    run = function(Channels)
      local SetChan = Channels[2]
      if not tonumber(SetChan) then
        os.queueEvent("tableInsert", "red#Error: Must be a number.")
      else
        rSend("has changed channel.", true)
        channelN = tonumber(SetChan)
        modem.closeAll()
        modem.open(channelN)
        rSend("has entered the channel!", true, true)
      end
    end,
    help = "<number>"
  },
  ["list"] = {
    run = function()
      os.queueEvent("grabList")
      os.queueEvent("tableInsert", "lime#Gathering list...")
    end,
    help = ""
  },
  ["clear"] = {
    run = function()
      chat = {}
      lineCount = 1
      modifier = 0
      draw()
    end,
    help = ""
  },
  ["help"] = {
    run = helpGen,
    help = ""
  },
  ["nick"] = {
    run = function(Nickname)
      rSend("is now known as "..Nickname[2], true)
      user = Nickname[2]
      if config.private == true then
        config.user = Nickname[2]
        local F = fs.open(".darkChatConf", "w")
        local configString = textutils.serialize(config)
        F.write(configString)
        F.close()
      end
      draw()
    end,
    help = "<nickname>"
  },
}
--[[
28: enter
14: backspace
]]--
term.clear() term.setCursorPos(1,1)
if (fs.exists(".darkChatConf") == true) and (#args == 0) then
  F = fs.open(".darkChatConf", "r")
  Data = F.readAll()
  F.close()
  config = textutils.unserialize(Data)
elseif #args == 0 then
  config = {}
  repeat
    print("Do you want your username to be stored? (Private Mode)")
    write("y / n : ")
    Qprivate = read()
  until Qprivate == "y" or Qprivate == "n"
  if Qprivate == "y" then
    config.private = true
    write("\nUsername: ")
    config.user = read()
    repeat
      write("Default channel number: ")
      Qchannel = read()
    until tonumber(Qchannel)
    config.channel = tonumber(Qchannel)
  else
    config.private = false
  end
  configString = textutils.serialize(config)
  F = fs.open(".darkChatConf", "w")
  F.write(configString)
  F.close()
  print("Setup Complete!")
  sleep(1)
end
if args[1] then
  config = {}
  config.private = true
  config.user = args[1]
  config.channel = 10  
end
if args[2] and tonumber(args[2]) then
  config.channel = tonumber(args[2])
end

startUp()
if config.private == true then
  privateMode()
else
  publicMode()
end
channelN = tonumber(channelN)
modem.closeAll()
modem.open(channelN)
term.clear()
term.setCursorPos(1,1)
rSend("has joined the chat!", true, true)
parallel.waitForAny(getChat, sendChat, keyListen, getOnlineList, scrollingEventListen, tableEventListen, exitEventListen)