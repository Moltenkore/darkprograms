arg = { ... }
--Title: Dark Screen
Version = 3.361
--Author: Darkrising (minecraft name djhannz)
--Platform: ComputerCraft Lua Virtual Machine
AutoUpdate = true
if not fs.exists("dark") then -- load darkAPI
  print("Missing DarkAPI")
  if not http then
	error("Enable the HTTP API to download DarkAPI")
  end
  sleep(2)
  print("Attempting to download...")
  getGit = http.get("https://raw.github.com/darkrising/darkprograms/darkprograms/api/dark.lua")
  getGit = getGit.readAll()
  file = fs.open("dark", "w")
  file.write(getGit)
  file.close()
  os.reboot()
else
  os.loadAPI("dark")
end
ProgramName = shell.getRunningProgram()
if #arg == 0 then
  print("Usage: ")
  print(ProgramName.." -s <scale> <filename> ")
  print(ProgramName.." -sc <scale> <filename> ")
  print(ProgramName.." -m <scale> <frame delay> <filenames>...")
  print(ProgramName.." -mc <scale> <frame delay> <filenames>...")
  print("Note: 'c'entred, 's'ingle, 'm'ultiple.")
  print(ProgramName.." wizard --Automatic startup creation")
  print(ProgramName.." update --checks for updates")
  print(ProgramName.." version --displays screen version")
  print("Example: "..ProgramName.." -mc 2 5 frame1 frame2")
  return exit
end
function FindMonitors(Perihp) 
  local Sides = {}
  for _,s in ipairs(rs.getSides()) do
    if peripheral.isPresent(s) and peripheral.getType(s) == Perihp then
      table.insert(Sides, s)
    end
  end
  if #Sides > 0 then
    return Sides
  else
    return nil
  end
end
Side = FindMonitors("monitor")
if not Side then print("no monitors found.") return exit end
function Mear()
  for i=1, #Side do
    Mtwo = peripheral.wrap(Side[i])
    Mtwo.clear()
  end  
end
function MsetTextCol(Coloa)
  for i=1, #Side do
    Mtwo = peripheral.wrap(Side[i])
    if Mtwo.isColor() == true then
      Mtwo.setTextColor(Coloa)     
    end
  end  
end
DefaultC = "white"
Mear()
DisplayTable = {}
ColorNames = {
"white",
"orange",
"magenta",
"lightBlue",
"yellow",
"lime",
"pink",
"gray",
"lightGray",
"cyan",
"purple",
"blue",
"brown",
"green",
"red",
"black"
}
function searchTable(searchstring, ATable)
  for i, V in pairs(ATable) do
    if ATable[i] == tostring(searchstring) then
      return i
    end
  end 
  return 0
end
function split(str, pattern)
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
function printC(Text, Line, centered) -- print centered
local x, y
  if centered == true then
    for i = 1, #Side do
      Mtwo = peripheral.wrap(Side[i])
      Mtwo.setTextScale(TextScale)
      x, y = Mtwo.getSize()
      x = x/2 - #Text/2
      Mtwo.setCursorPos(x, Line)
      Mtwo.write(Text)
    end
  else
    for i = 1, #Side do
      Mtwo = peripheral.wrap(Side[i])
      Mtwo.setTextScale(TextScale)
      x, y = Mtwo.getSize()
      Mtwo.setCursorPos(1, Line)
      Mtwo.write(Text)
    end
  end
  return true  
end
function GenerateTable(Filename)
  local Counter = 0
  local text = {}
  local TextC = {}
  local TextF = {}
  local h = fs.open(Filename, "r")
  while true do
    local Line = h.readLine()
    if Line == nil then break end
    Counter = Counter + 1
    text[Counter] = Line
  end
  h.close()
  for i = 1, #text do
    if text[i] == "" then
      TextF[i] = text[i]
      TextC[i] = DefaultC
    else
      C = split(text[i], "#")
      if searchTable(C[1], ColorNames) > 0 then
        TextC[i] = C[1]
        TextF[i] = C[2]
      else
        TextC[i] = DefaultC
        TextF[i] = C[1]
      end
    end
  end
  local FinTable = {Text = TextF, Color = TextC}
  return FinTable
end
function printS(TextTable, ColorTable, centered)
  for i = 1, #TextTable do
    MsetTextCol(colors[ColorTable[i]])
    printC(TextTable[i], i, centered)
  end
end

if arg[1] == "wizard" then
  framename = {}
  StartupScri = ""
  term.clear()
  term.setCursorPos(1,1)
  print("This wizard will setup a startup file for you!")
  print("----------------------------------------------")
  print("Note: this wizard will override your startup.\n")
  repeat
    write("How many frames do you have? ")
    framecount = read()
    if not tonumber(framecount) then
      print("Please type a number.")
    end
  until tonumber(framecount)
  framecount = tonumber(framecount)
  for i = 1, framecount do
    write("Frame "..i.." filename: ")
    table.insert(framename, read())
  end  
  repeat
    write("Do you want the text to be centered? (y/n) ")
    Centered = read()
    if ((Centered ~= "y") and (Centered ~= "n")) then
      print("Please type 'y' or 'n'")
    end
  until ((Centered == "y") or (Centered == "n"))
  if Centered == "y" then Centered = "c" end
  if Centered == "n" then Centered = "" end
  
  repeat
    write("Monitor Text Scale: ")
    TextSca = tonumber(read())
    if not ((TextSca >= 0.5) and (TextSca <= 5)) then
      print("Must be a number between 0.5 and 5")
    end
  until ((TextSca >= 0.5) and (TextSca <= 5))  
  
  if #framename == 1 then
    StartupScri = "shell.run(\""..ProgramName.."\",\"-s"..Centered.."\","..TextSca..",\""..framename[1].."\")"
  else
    for i = 1, #framename do
      if i == 1 then
        framenameC = "\""..framename[i].."\","
      elseif i == #framename then
        framenameC = framenameC.."\""..framename[i].."\""
      else
        framenameC = framenameC.."\""..framename[i].."\","
      end
    end
    repeat
    write("How many seconds between each frame? ")
    Seco = read()
    until tonumber(Seco)
    Seco = tonumber(Seco)
    StartupScri = "shell.run(\""..ProgramName.."\",\"-m"..Centered.."\","..TextSca..","..Seco..","..framenameC..")"
  end
  File = fs.open("startup", "w")
  File.write(StartupScri)
  File.close()
  print("\nChanges Written to startup.")
  print("Wizard Complete!")
  return exit
end
if arg[1] == "update" then
  print("Checking for updates...")
  if ((dark.gitUpdate("screen", ProgramName, Version) == true) or (dark.gitUpdate("dark", "dark", dark.DARKversion) == true)) then 
    print("Update Complete")
    sleep(1)
    os.reboot()
  else
    print("Everything is up-to-date.")
  end
end
if arg[1] == "version" then
  print("Screen version is: "..Version)
end

TextScale = tonumber(arg[2])

if arg[1] == "-s" then
  print(ProgramName.." has run.")
  ToPrint = GenerateTable(arg[3])
  printS(ToPrint.Text, ToPrint.Color, false)
end
if arg[1] == "-sc" then
  print(ProgramName.." has run.")
  ToPrint = GenerateTable(arg[3])
  printS(ToPrint.Text, ToPrint.Color, true)
end
if arg[1] == "-m" then
  print(ProgramName.." is currently running.")
  print("Hold [ctrl] + T to exit.")
  Sarg = {}
  for i = 4, #arg do
    table.insert(Sarg, arg[i])
  end
  for i = 1, #Sarg do
    DisplayTable[i] = GenerateTable(Sarg[i])
  end
  Cou = 1
  while true do
    Mear()
    printS(DisplayTable[Cou].Text, DisplayTable[Cou].Color, false)
    sleep(tonumber(arg[3]))
    Cou = Cou + 1
    if Cou > #Sarg then
      Cou = 1
    end
  end
end
if arg[1] == "-mc" then
  print(ProgramName.." is currently running.")
  print("Hold [ctrl] + T to exit.")
  Sarg = {}
  for i = 4, #arg do
    table.insert(Sarg, arg[i])
  end
  for i = 1, #Sarg do
    DisplayTable[i] = GenerateTable(Sarg[i])
  end
  Cou = 1
  while true do
    Mear()
    printS(DisplayTable[Cou].Text, DisplayTable[Cou].Color, true)
    sleep(tonumber(arg[3]))
    Cou = Cou + 1
    if Cou > #Sarg then
      Cou = 1
    end
  end
end