Version = 2.12
x,y = term.getSize()
if not http then
  print("Herp derp, forget to enable http?")
  return exit
end
local function getUrlFile(url)
  local mrHttpFile = http.get(url)
  mrHttpFile = mrHttpFile.readAll()
  return mrHttpFile
end
local function writeFile(filename, data)
  local file = fs.open(filename, "w")
  file.write(data)
  file.close()
end
local function cs()
  term.clear()
  term.setCursorPos(1,1)
end
local function tc(tcolor,bcolor)
  if term.isColor() then
    if tcolor then
      term.setTextColor(colors[tcolor])
    end
    if bcolor then
      term.setBackgroundColor(colors[bcolor])  
    end
  end
end
local function writeC(text,line)
  term.setCursorPos((x / 2) - (#text / 2),line)
  term.write(text)
end
term.oldWrite = term.write
function term.write(text)
  if not text then
    text = ""
  end
  term.oldWrite(text)
end
local function header(text)
  tc("white","blue")
  writeC(string.rep("  ",x),1)
  writeC(string.rep("  ",x),y)
  writeC(text,1)
  tc("white","black")
end
local function gitUpdate(ProgramName, Filename, ProgramVersion)
  if http then
    local status, getGit = pcall(http.get, "https://raw.github.com/darkrising/darkprograms/darkprograms/programVersions")
    if not status then
      print("\nFailed to get Program Versions file.")
      print("Error: ".. getGit)
      return exit
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

cs()
print("Checking for updates...")
if gitUpdate("darkretriever", shell.getRunningProgram(), Version) == true then
  print("Update found and downloaded.")
  print("\nPlease run ".. shell.getRunningProgram() .. " again.")
  return exit
else
  print("Program up-to-date.")
end
sleep(1)

x,y = term.getSize()
cs()
write("-> Grabbing file...")
cat = getUrlFile("https://raw.github.com/darkrising/darkprograms/darkprograms/programVersions")
cat = textutils.unserialize(cat)
write(" Done.")
sleep(1)
cs()

menu = {}
rawName = {}

--[[

-Author
--Package
---Program

]]--

for name,data in pairs(cat) do
  if not menu[data.Author] then
    menu[data.Author] = {}
  end
  if not menu[data.Author][data.Package] then
    menu[data.Author][data.Package] = {}
  end
  if not menu[data.Author][data.Package][name] then
    menu[data.Author][data.Package][data.Name] = data
    rawName[data.Name] = name
  end
end

state = "top"
csel = 1 --Current selected
osel = {1} --breadcrumb

page = 0
ind = 3 --Y indent
ava = y - ind --Available space
level = 1

function selection(no,list,totpage)
  term.setCursorPos(1, (no - mod) + (ind - 1))
  tc("yellow")
  term.write("[".. list[no] .. "]")
  tc("white","black")
  term.setCursorPos(1,y)
  tc("white","blue")
  term.write("Page: ".. page + 1 .. "/" .. totpage)
  term.setCursorPos(x - 14, y)
  term.write("By Darkrising")
  tc("white","black")
end
function draw(tbl)
  local c = 1
  local sdat = {}
  local odat = {}
  for n,d in pairs(tbl) do
    table.insert(sdat, n)
    table.insert(odat, d)
    c = c + 1
  end
  if level ~= 4 then
    table.sort(sdat)
  end
    
  tpages = math.ceil(c / (y - ind))
  mod = page * (y - ind)
  
  for i = 1, y - ind do 
    term.setCursorPos(2, i + ind - 1)
    term.write(sdat[i + mod])
    
    if level == 4 then
      term.setCursorPos(15, i + ind - 1)
      if type(odat[i + mod]) == "string" and #odat[i + mod] + 14 > x then
        term.write(string.sub(odat[i + mod],1,x-14-2).."..")
      else
        term.write(odat[i + mod])
      end
    end   
  end
  
  if level == 4 then
    term.setCursorPos(1, y-2)
    writeC("Press enter to download.",y-2)
  end
  
  return sdat, tpages, mod
end
function runMenu()
  while true do
    cs()
    if level == 1 then
      list,totpage,mod = draw(menu)
      header("Authors")
      
      tc("yellow","black")
      writeC("Press 'h' for help, 'q' to quit.",2)
      tc("white","black")
      
    elseif level == 2 then
      list,totpage,mod = draw(menu[auna])
      header("Packages")
    elseif level == 3 then
      list,totpage,mod = draw(menu[auna][pkg])
      header("Programs")
    elseif level == 4 then
      header("Program Data")
      list,totpage,mod = draw(menu[auna][pkg][pro])
    end
    
    selection(csel, list, totpage)
    
    e,key = os.pullEvent("key")  
    
    if key == keys.h then
      cs()
      header("Help")
      term.setCursorPos(1,ind)
      print("Use the up and down arrows to move through the list.")
      print("use the right arrow to enter a menu item and the left arrow to exit")
      print("")
      _,cy = term.getCursorPos()
      tc("yellow","black")
      writeC("Press enter to continue.",cy)
      tc("white","black")
      read(" ")
    end
    
    if key == keys.up then
      csel = csel - 1
    end
    if key == keys.down then
      csel = csel + 1
    end
    if key == keys.enter then
      
    end
    if key == keys.right then
      osel[level] = csel
      level = level + 1
       
      if level == 2 then
        auna = list[csel]       
      elseif level == 3 then
        pkg = list[csel]
      elseif level == 4 then
        pro = list[csel]
      end
      
      if level > 4 then level = 4 end
      
      csel = 1
      osel[level] = 1
    end  
    if key == keys.q then
      cs()
      return exit
    end
    if key == keys.rightBracket then
      csel = csel + ava
    end
    if key == keys.leftBracket then
      csel = csel - ava
    end
    
    if key == keys.enter and level == 4 then
      cs()
      p = cat[pro]
      writeC("Downloading ".. cat[rawName[pro]].Name .. " to /" .. rawName[pro], y/2)
      status = getUrlFile(cat[rawName[pro]].GitURL)
      sleep(1)
      if status then
        writeFile("/".. rawName[pro], status)
      end
      
      cs()
      writeC("Success!", y/2)
      sleep(1)
      
      repeat
        cs()
        writeC("Would you like to generate a startup script? ", y/2)
        writeC("Y / N : ",y/2 + 1)
        answer = string.lower(read())
      until answer == "y" or answer == "n"
      
      if answer == "y" then
        cs()
        writeC("Writing startup script...", y/2)
        
        star = fs.open("/startup","w")
        star.write("shell.run('".. rawName[pro] .. "')")
        star.close()
        
        cs()
        writeC("Success! Hold [Ctrl] + R to reboot.", y/2)
        sleep(2)
      end
    end
    
    if csel < 1 then --Can't go below beginning of the list
      csel = 1
    end
    if csel > #list then --Can't go above length of the list
      csel = #list
    end
    
    if key == keys.left then      
      level = level - 1
      if level < 1 then level = 1 end
      csel = osel[level]
    end
    
    page = math.floor((csel - 1) / ava)
    
  end
end

runMenu()