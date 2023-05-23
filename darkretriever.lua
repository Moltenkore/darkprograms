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
osel =
