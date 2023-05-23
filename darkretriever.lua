-- Function to display a loading animation
local function displayLoadingAnimation()
  local animationFrames = {"/", "-", "\\", "|"} -- Frames for the animation
  local frameIndex = 1 -- Current frame index

  -- Clear the terminal
  term.clear()
  term.setCursorPos(1, 1)

  -- Display the animation
  while true do
    -- Print the current frame
    term.write(animationFrames[frameIndex])
    term.setCursorPos(1, 1)

    -- Wait for a short duration
    os.sleep(0.1)

    -- Move to the next frame
    frameIndex = frameIndex + 1
    if frameIndex > #animationFrames then
      frameIndex = 1
    end
  end
end

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

local function fetchData()
  write("-> Grabbing file...")
  displayLoadingAnimation() -- Display the loading animation
  cat = getUrlFile("https://raw.github.com/darkrising/darkprograms/darkprograms/programVersions")
  cat = textutils.unserialize(cat)
  write(" Done.")
  sleep(1)
  cs()
end

fetchData()

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
  term.write("By OutragedMetro")
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
    if key == keys.q then
      return
    elseif key == keys.h then
      cs()
      term.setTextColor(colors.yellow)
      writeC("Herp Derp Retrieval Program v2.12",5)
      writeC("Author: OutragedMetro",7)
      term.setTextColor(colors.white)
      writeC("To navigate the menu:",9)
      writeC("Use arrow keys or 'w', 's' to navigate up and down.",11)
      writeC("Press 'a' to enter a menu level or go back.",13)
      writeC("Press 'd' to download a program or file.",15)
      writeC("Press 'q' to quit the program.",17)
      term.setTextColor(colors.yellow)
      writeC("Press any key to continue...",y)
      term.setTextColor(colors.white)
      os.pullEvent("key")
      level = 1
    elseif key == keys.a then
      if level == 1 then
        return
      elseif level == 2 then
        level = 1
        csel = osel[#osel - 1]
        table.remove(osel,#osel)
      elseif level == 3 then
        level = 2
        csel = osel[#osel - 1]
        table.remove(osel,#osel)
      elseif level == 4 then
        level = 3
        csel = osel[#osel - 1]
        table.remove(osel,#osel)
      end
    elseif key == keys.s or key == keys.down then
      if level == 1 then
        if csel ~= #list then
          csel = csel + 1
        else
          csel = 1
        end
      elseif level == 2 then
        if csel ~= #list then
          csel = csel + 1
        else
          csel = 1
        end
      elseif level == 3 then
        if csel ~= #list then
          csel = csel + 1
        else
          csel = 1
        end
      elseif level == 4 then
        if csel ~= #list then
          csel = csel + 1
        else
          csel = 1
        end
      end
    elseif key == keys.w or key == keys.up then
      if level == 1 then
        if csel ~= 1 then
          csel = csel - 1
        else
          csel = #list
        end
      elseif level == 2 then
        if csel ~= 1 then
          csel = csel - 1
        else
          csel = #list
        end
      elseif level == 3 then
        if csel ~= 1 then
          csel = csel - 1
        else
          csel = #list
        end
      elseif level == 4 then
        if csel ~= 1 then
          csel = csel - 1
        else
          csel = #list
        end
      end
    elseif key == keys.d then
      if level == 4 then
        fetchString = fetchData(rawName[list[csel]].URL)
        if fs.exists(rawName[list[csel]]) then
          if fs.isDir(rawName[list[csel]]) then
            print("Program exists as a directory.")
          else
            print("Program exists, overwriting.")
          end
        else
          print("Program does not exist, creating new.")
        end
        if type(fetchString) ~= "string" then
          print("Failed to get file.")
          print("Error: ".. fetchString)
        else
          print("Downloading program.")
          writeFile(rawName[list[csel]], fetchString)
          print("Download complete.")
        end
        sleep(2)
      end
    elseif key == keys.enter then
      if level == 1 then
        level = 2
        auna = list[csel]
        table.insert(osel,csel)
        csel = 1
      elseif level == 2 then
        level = 3
        pkg = list[csel]
        table.insert(osel,csel)
        csel = 1
      elseif level == 3 then
        level = 4
        pro = list[csel]
        table.insert(osel,csel)
        csel = 1
      elseif level == 4 then
        fetchString = fetchData(menu[auna][pkg][pro].URL)
        if fs.exists(rawName[list[csel]]) then
          if fs.isDir(rawName[list[csel]]) then
            print("Program exists as a directory.")
          else
            print("Program exists, overwriting.")
          end
        else
          print("Program does not exist, creating new.")
        end
        if type(fetchString) ~= "string" then
          print("Failed to get file.")
          print("Error: ".. fetchString)
        else
          print("Downloading program.")
          writeFile(rawName[list[csel]], fetchString)
          print("Download complete.")
        end
        sleep(2)
      end
    end
  end
end

runMenu()
