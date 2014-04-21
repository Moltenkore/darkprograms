--Written by darkrising
DARKversion = 3.25

db = {}
db.__index = db

function db.delete(Filename)
  if fs.exists(Filename) then
    fs.delete(Filename)
    return true
  end
  return false
end
function db.load(Filename) 
  if not fs.exists(Filename) then
    local F = fs.open(Filename, "w")
    F.write("{}")
    F.close()
  end
  local F = fs.open(Filename, "r")
  local Data = F.readAll()
  F.close()
  Data = textutils.unserialize(Data)
  return Data
end
function db.save(Filename, ATable) 
  local Data = textutils.serialize(ATable)
  local F = fs.open(Filename, "w")
  F.write(Data)
  F.close()
  return true
end
function db.search(searchstring, ATable)
  for i, V in pairs(ATable) do
    if tostring(ATable[i]) == tostring(searchstring) then
      return i
    end
  end 
  return 0
end

function db.removeString(Filename, AString)
  local TempT = db.load(Filename)
  if type(TempT) ~= "table" then return false end
  local Pos = db.search(AString, TempT)
  if Pos > 0 then
    table.remove(TempT, Pos)
    db.save(Filename, TempT)
    return true
  else
    return false
  end
end
function db.insertString(Filename, AString)
  local TempT = db.load(Filename)
  if type(TempT) ~= "table" then TempT = {} end
  table.insert(TempT, AString)
  db.save(Filename, TempT)
  return true
end

--Fix buggy write function
if not term.oldWrite then
  term.oldWrite = term.write
  function term.write(text)
    if not text then
      text = ""
    end
    term.oldWrite(text)
  end
end

--Generalised functions
function findPeripheral(Perihp) -- returns side of first peripheral matching passed string
  for _,s in ipairs(rs.getSides()) do
    if peripheral.isPresent(s) and peripheral.getType(s) == Perihp then
      return s
    end
  end
  return false
end
function listPeripheral() -- returns a table of peripherals names, false if nothing found
  local typers = {}
  for _,s in ipairs(rs.getSides()) do
    if peripheral.isPresent(s) then 
      table.insert(typers,peripheral.getType(s))
    end
  end
  if #typers > 0 then
    return typers
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
function getPBFile(PBCode, uPath) -- pastebin code of the file, and path to save /turkey
  local PBfile = http.get("http://pastebin.com/raw.php?i="..textutils.urlEncode(PBCode))
  if PBfile then
  	local PBfileToWrite = PBfile.readAll()
	  PBfile.close()
		  
	  local file = fs.open( uPath, "w" )
  	file.write(PBfileToWrite)
	  file.close()
    return true
  else
    return false
  end
end
function gitUpdate(ProgramName, Filename, ProgramVersion)
  if http then
    local status, getGit = pcall(http.get,"https://raw.github.com/darkrising/darkprograms/darkprograms/programVersions")
    if not status then
      return false
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

--Common Draw functions I use
function cs() -- lazy man's screen clear
  term.clear()
  term.setCursorPos(1,1)
  return
end
function setCol(Color, BkgColor)
  if ((term.isColor) and (term.isColor() == true)) then
    if Color then term.setTextColor(colors[Color]) end
    if BkgColor then term.setBackgroundColor(colors[BkgColor]) end
  else
    return
  end
end
function resetCol(Color, BkgColor)
  if ((term.isColor) and (term.isColor() == true)) then
    if Color then term.setTextColor(colors.white) end
    if BkgColor then term.setBackgroundColor(colors.black) end
    return
  else
    return
  end
end
function printC(Text, Line, NextLine, Color, BkgColor) -- print centered
  local x, y = term.getSize()
  x = x/2 - #Text/2
  term.setCursorPos(x, Line)
  if Color then setCol(Color, BkgColor) end
  term.write(Text) 
  if NextLine then
    term.setCursorPos(1, NextLine) 
  end
  if Color then resetCol(Color, BkgColor) end
  return true  
end
function printL(Text, Line, NextLine, Color, BkgColor) -- print line
  local x, y = term.getSize()
  if ((term.isColor) and (term.isColor() == false) and (Text == " ")) then Text = "-" end
  for i = 1, x do
    term.setCursorPos(i, Line)
    if Color then setCol(Color, BkgColor) end
    term.write(Text)
  end
  if NextLine then  
    term.setCursorPos(1, NextLine) 
  end
  if Color then resetCol(Color, BkgColor) end
  return true  
end
function printA(Text, xx, yy, NextLine, Color, BkgColor) -- print anywhere
  term.setCursorPos(xx,yy)
  if Color then setCol(Color, BkgColor) end
  term.write(Text)
  if NextLine then  
    term.setCursorPos(1, NextLine) 
  end
  if Color then resetCol(Color, BkgColor) end
  return true  
end
function clearLine(Line, NextLine) -- May seem a bit odd, but it may be usefull sometimes
  local x, y = term.getSize()
  for i = 1, x do
    term.setCursorPos(i, Line)
    term.write(" ")
  end  
  if not NextLine then  
    x, y = term.getCursorPos()
    term.setCursorPos(1, y+1) 
  end
  return true  
end
function drawBox(StartX, lengthX, StartY, lengthY, Text, Color, BkgColor) -- does what is says on the tin.
  local x, y = term.getSize()
  if Color then setCol(Color, BkgColor) end
  if not Text then Text = "*" end
  lengthX = lengthX - 1 
  lengthY = lengthY - 1
  EndX = StartX + lengthX  
  EndY = StartY + lengthY
  term.setCursorPos(StartX, StartY)
  term.write(string.rep(Text, lengthX))
  term.setCursorPos(StartX, EndY)
  term.write(string.rep(Text, lengthX)) 
  for i = StartY, EndY do
    term.setCursorPos(StartX, i)
    term.write(Text)
    term.setCursorPos(EndX, i)    
    term.write(Text)
  end
  resetCol(Color, BkgColor)
  return true  
end

-- special functions
function splash(duration, Text) -- displays dark programs splash (coloured monitors only)
  local x, y = term.getSize()
  if ((term.isColor) and (term.isColor() == true)) then
    term.clear() term.setCursorPos(1,1)
    splash = {
      [1]={2,2,2,2,2,2,2,2,2,2,2,2,2},
      [2]={2,16,16,16,16,16,16,16,16,16,16,16,2},
      [3]={2,16,2,16,2,16,2,16,2,16,2,16,2},
      [4]={2,16,2,2,2,2,2,2,2,2,2,16,2},
      [5]={2,16,2,1,1,2048,8192,16384,1,1,2,16,2,},
      [6]={2,16,2,2,2,2,2,2,2,2,2,16,2,},
      [7]={2,16,16,16,16,16,16,16,16,16,16,16,2,},
      [8]={2,2,2,2,2,2,2,2,2,2,2,2,2,},
    }
    paintutils.drawImage(splash, (x/2) - 7, (y/2) - 4)
    term.setCursorPos(x/2 - string.len(Text)/2, y/2 + 5)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)  
    textutils.slowWrite(Text)
    sleep(duration)
  else
    term.clear() term.setCursorPos(1,1)
    term.setCursorPos(x/2 - string.len(Text)/2, y/2)
    textutils.slowWrite(Text)
    sleep(duration)    
  end
  return
end
function hashSplit(Hash) -- transfers a long hash number into a table
  local HashTable = {}
  for i = 1, #tostring(Hash) do
    local set = i
    local b = string.sub(Hash, set, set)
    table.insert(HashTable, b)
  end
  return HashTable
end
function encrypt(Input, keyN) -- takes a string and returns an encrypted version, if keyN 1 - 9 returns encrypted string with solid number hash
  local inType = type(Input)
  local keystore = {}
  local i = 1
  local dec = ""
  local key
  if inType == "number" then
    Input = tostring(Input)
  end
  repeat
    if keyN then 
      key = keyN
    else
      key = math.random(9)
    end
    table.insert(keystore, key)  
    local tstr = string.char(Input:byte(i) + key)
    dec = dec .. tstr
    i = i + 1
  until Input:byte(i) == nil
  local cin = ""
  for i = 1, #keystore do
    cin = cin..keystore[i]
  end
  if keyN then
    return dec
  else
    return dec, cin
  end
end
function decrypt(Input, Hash, keyY) -- takes encrypted string with either hash (or solid hash if keyY is true) and converts it back to readable text
  local keystore, tstr, i, dec
  if keyY then
    keystore = {Hash}
  else
    keystore = hashSplit(Hash)
  end
  i = 1
  dec = ""
  repeat
    if keyY then
      tstr = string.char(Input:byte(i) - keystore[1])
    else
      tstr = string.char(Input:byte(i) - keystore[i])
    end
    dec = dec .. tstr
    i = i + 1
  until Input:byte(i) == nil
  return dec
end
function serialGen(digits) -- seems to become unstable above 18 digits long
  local serial
  for i = 1, digits do
    if i == 1 then
      serial = math.random(9)
    else
      serial = serial.. math.random(9)
    end
  end
  serial = tonumber(serial)
  return serial
end
function repCrypt(Input, numHash)
  local keystore = {}
  local i = 1
  local dec = ""
  local keyLength = #tostring(numHash)
  numHash = tonumber(numHash)
  local posCou = 1
  repeat
    if posCou > keyLength then posCou = 1 end
    key = tonumber(string.sub(numHash, posCou, posCou))
    posCou = posCou + 1
    table.insert(keystore, key)
    local tstr = string.char(Input:byte(i) - key)
    dec = dec .. tstr
    i = i + 1    
  until Input:byte(i) == nil
  return dec
end
function repdeCrypt(Input, numHash)
  local i = 1
  local dec = ""
  local keyLength = #tostring(numHash)
  numHash = tonumber(numHash)
  local posCou = 1
  repeat
    if posCou > keyLength then posCou = 1 end
    key = tonumber(string.sub(numHash, posCou, posCou))
    posCou = posCou + 1
    tstr = string.sub(Input, i, i)
    tstr = string.char(Input:byte(i) + key)
    dec = dec .. tstr
    i = i + 1
  until Input:byte(i) == nil
  return dec
end