Version = 2.12
x, y = term.getSize()

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
  term.setCursorPos(1, 1)
end

local function tc(tcolor, bcolor)
  if term.isColor() then
    if tcolor then
      term.setTextColor(colors[tcolor])
    end
    if bcolor then
      term.setBackgroundColor(colors[bcolor])
    end
  end
end

local function writeC(text, line)
  term.setCursorPos((x / 2) - (#text / 2), line)
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
  tc("white", "blue")
  writeC(string.rep("  ", x), 1)
  writeC(string.rep("  ", x), y)
  writeC(text, 1)
  tc("white", "black")
end

local function gitUpdate(ProgramName, Filename, ProgramVersion)
  if http then
    local status, getGit = pcall(http.get, "https://raw.githubusercontent.com/rservices/darkprograms/darkprograms/programVersions")
    if not status then
      print("\nFailed to get Program Versions file.")
      print("Error: " .. getGit)
      return exit
    end
    getGit = getGit.readAll()
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
  print("\nPlease run " .. shell.getRunningProgram() .. " again.")
  return exit
else
  print("Program up-to-date.")
end
sleep(1)

x, y = term.getSize()
cs()
write("-> Grabbing file...")
cat = getUrlFile("https://raw.githubusercontent.com/rservices/darkprograms/darkprograms/programVersions")
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

for name, data in pairs(cat) do
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
osel = 1 --Option selected
pro = 1 --Selected program

selections = {}

while true do
  if state == "top" then
    selections = {}
    for author, packages in pairs(menu) do
      table.insert(selections, author)
    end
    header("Authors")
    for i, v in pairs(selections) do
      if i == csel then
        tc("white", "black")
      else
        tc("black", "white")
      end
      writeC(v, i + 1)
    end
    event, button = os.pullEvent("key")
    if button == 200 then
      csel = csel - 1
      if csel < 1 then
        csel = #selections
      end
    elseif button == 208 then
      csel = csel + 1
      if csel > #selections then
        csel = 1
      end
    elseif button == 28 then
      state = "packages"
      psel = 1
    elseif button == 14 then
      state = "menu"
    end
  elseif state == "packages" then
    selections = {}
    for packages, programs in pairs(menu[selections[csel]]) do
      table.insert(selections, packages)
    end
    header("Packages")
    for i, v in pairs(selections) do
      if i == psel then
        tc("white", "black")
      else
        tc("black", "white")
      end
      writeC(v, i + 1)
    end
    event, button = os.pullEvent("key")
    if button == 200 then
      psel = psel - 1
      if psel < 1 then
        psel = #selections
      end
    elseif button == 208 then
      psel = psel + 1
      if psel > #selections then
        psel = 1
      end
    elseif button == 28 then
      state = "programs"
      pro = 1
    elseif button == 14 then
      state = "top"
    end
  elseif state == "programs" then
    selections = {}
    for program, data in pairs(menu[selections[csel]][selections[psel]]) do
      table.insert(selections, program)
    end
    header("Programs")
    for i, v in pairs(selections) do
      if i == pro then
        tc("white", "black")
      else
        tc("black", "white")
      end
      writeC(v, i + 1)
    end
    event, button = os.pullEvent("key")
    if button == 200 then
      pro = pro - 1
      if pro < 1 then
        pro = #selections
      end
    elseif button == 208 then
      pro = pro + 1
      if pro > #selections then
        pro = 1
      end
    elseif button == 28 then
      state = "menu"
      osel = 1
    elseif button == 14 then
      state = "packages"
    end
  elseif state == "menu" then
    header("Options")
    if osel == 1 then
      tc("white", "black")
    else
      tc("black", "white")
    end
    writeC("Run", 1)
    if osel == 2 then
      tc("white", "black")
    else
      tc("black", "white")
    end
    writeC("Install", 2)
    event, button = os.pullEvent("key")
    if button == 200 then
      osel = osel - 1
      if osel < 1 then
        osel = 2
      end
    elseif button == 208 then
      osel = osel + 1
      if osel > 2 then
        osel = 1
      end
    elseif button == 28 then
      if osel == 1 then
        term.clear()
        term.setCursorPos(1, 1)
        shell.run(menu[selections[csel]][selections[psel]][selections[pro]].Run)
      elseif osel == 2 then
        cs()
        write("-> Downloading " .. menu[selections[csel]][selections[psel]][selections[pro]].Name .. "...")
        writeFile(menu[selections[csel]][selections[psel]][selections[pro]].Name, getUrlFile(menu[selections[csel]][selections[psel]][selections[pro]].URL))
        write(" Done.")
        sleep(1)
        state = "top"
      end
    elseif button == 14 then
      state = "programs"
    end
  end
end
