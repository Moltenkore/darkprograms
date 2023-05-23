local Version = 2.12
local x, y = term.getSize()
if not http then
  print("Herp derp, forgot to enable HTTP?")
  return
end

local function getUrlFile(url)
  local response = http.get(url)
  if response then
    local fileContent = response.readAll()
    response.close()
    return fileContent
  else
    error("Failed to retrieve URL: " .. url)
  end
end

local function writeFile(filename, data)
  local file = fs.open(filename, "w")
  file.write(data)
  file.close()
end

local function clearScreen()
  term.clear()
  term.setCursorPos(1, 1)
end

local function setTextColor(textColor, backgroundColor)
  if term.isColor() then
    if textColor then
      term.setTextColor(colors[textColor])
    end
    if backgroundColor then
      term.setBackgroundColor(colors[backgroundColor])
    end
  end
end

local function centeredWrite(text, line)
  local xPos = math.floor((x - #text) / 2) + 1
  term.setCursorPos(xPos, line)
  term.write(text)
end

term.oldWrite = term.write
function term.write(text)
  if not text then
    text = ""
  end
  term.oldWrite(text)
end

local function printHeader(text)
  setTextColor("white", "blue")
  centeredWrite(string.rep("  ", x), 1)
  centeredWrite(string.rep("  ", x), y)
  centeredWrite(text, 1)
  setTextColor("white", "black")
end

local function gitUpdate(programName, filename, programVersion)
  if http then
    local status, getGit = pcall(http.get, "https://raw.githubusercontent.com/rservices/darkprograms/darkprograms/programVersions")
    if not status then
      print("\nFailed to get Program Versions file.")
      print("Error: " .. getGit)
      return false
    end
    getGit = getGit.readAll()
    local newVersion = textutils.unserialize(getGit)
    if newVersion[programName].Version > programVersion then
      getGit = http.get(newVersion[programName].GitURL)
      getGit = getGit.readAll()
      writeFile(filename, getGit)
      return true
    end
  end
  return false
end

clearScreen()
print("Checking for updates...")
if gitUpdate("darkretriever", shell.getRunningProgram(), Version) then
  print("Update found and downloaded.")
  print("\nPlease run " .. shell.getRunningProgram() .. " again.")
  return
else
  print("Program up-to-date.")
end
sleep(1)

x, y = term.getSize()
clearScreen()
write("-> Grabbing file...")
local cat = getUrlFile("https://raw.githubusercontent.com/rservices/darkprograms/darkprograms/programVersions")
cat = textutils.unserialize(cat)
write(" Done.")
sleep(1)
clearScreen()

local menu = {}
local rawName = {}

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

local state = "top"
local csel = 1 -- Current selected
local osel = {1} -- Breadcrumb
local page = 0
local ind = 3 -- Y indent
local ava = y - ind -- Available space
local level = 1

local function selection(no, list, totpage)
  term.setCursorPos(1, (no - mod) + (ind - 1))
  setTextColor("white")
  term.write("[" .. list[no] .. "]")
  setTextColor("white", "black")
  term.setCursorPos(1, y)
  setTextColor("white", "blue")
  term.write("Page: " .. page + 1 .. "/" .. totpage)
  term.setCursorPos(x - 8, y)
  term.write("By OutragedMetro .INC")
  setTextColor("white", "black")
end

local function draw(tbl)
  local c = 1
  local sdat = {}
  local odat = {}
  for n, d in pairs(tbl) do
    table.insert(sdat, n)
    table.insert(odat, d)
    c = c + 1
  end
  if level ~= 4 then
    table.sort(sdat)
  end

  local tpages = math.ceil(c / (y - ind))
  local mod = page * (y - ind)

  for i = 1, y - ind do
    term.setCursorPos(2, i + ind - 1)
    term.write(sdat[i + mod])

    if level == 4 then
      term.setCursorPos(15, i + ind - 1)
      if type(odat[i + mod]) == "string" and #odat[i + mod] + 14 > x then
        term.write(string.sub(odat[i + mod], 1, x - 14 - 2) .. "..")
      else
        term.write(odat[i + mod])
      end
    end
  end

  if level == 4 then
    term.setCursorPos(1, y - 2)
    centeredWrite("Press enter to download.", y - 2)
  end

  return sdat, tpages, mod
end

local function runMenu()
  while true do
    clearScreen()
    if level == 1 then
      local list, totpage, mod = draw(menu)
      printHeader("Authors")
      setTextColor("white", "black")
      centeredWrite("Press 'h' for help, 'q' to quit.", 2)
      setTextColor("white", "black")

    elseif level == 2 then
      local list, totpage, mod = draw(menu[auna])
      printHeader("Packages")
    elseif level == 3 then
      local list, totpage, mod = draw(menu[auna][pkg])
      printHeader("Programs")
    elseif level == 4 then
      printHeader("Program Data")
      local list, totpage, mod = draw(menu[auna][pkg][pro])
    end

    selection(csel, list, totpage)

    local event, key = os.pullEvent("key")

    if key == keys.h then
      clearScreen()
      printHeader("Help")
      term.setCursorPos(1, ind)
      print("Use the up and down arrows to move through the list.")
      print("Use the right arrow to enter a menu item and the left arrow to exit.")
      print("https://outraged-metro.com")
      setTextColor("white", "black")
      centeredWrite("Press enter to continue.", y - 2)
      os.pullEvent("key")
      level = osel[#osel]
    end

    if key == keys.q then
      clearScreen()
      printHeader("Exit")
      term.setCursorPos(1, ind)
      print("Are you sure you want to exit?")
      print("Press enter to confirm or any other key to cancel.")
      local event, key = os.pullEvent("key")
      if key == keys.enter then
        clearScreen()
        return
      else
        level = osel[#osel]
      end
    end

    if key == keys.enter then
      if level == 1 then
        auna = list[csel + mod]
        osel = {csel + mod}
        level = 2
      elseif level == 2 then
        pkg = list[csel + mod]
        osel[#osel + 1] = csel + mod
        level = 3
      elseif level == 3 then
        pro = rawName[list[csel + mod]]
        osel[#osel + 1] = csel + mod
        level = 4
      elseif level == 4 then
        local rname = rawName[list[csel + mod]]
        clearScreen()
        printHeader("Download")
        term.setCursorPos(1, ind)
        print("Are you sure you want to download " .. rname .. "?")
        print("Press enter to confirm or any other key to cancel.")
        local event, key = os.pullEvent("key")
        if key == keys.enter then
          clearScreen()
          write("-> Grabbing file...")
          local file = getUrlFile(cat[rname].DownloadURL)
          writeFile(rname, file)
          print(" Done.")
          sleep(1)
          clearScreen()
          print("File " .. rname .. " downloaded successfully!")
          print("Press any key to continue.")
          os.pullEvent("key")
        end
        level = osel[#osel]
      end
    end

    if key == keys.right then
      if level ~= 4 then
        osel[#osel + 1] = csel + mod
      end
      level = level + 1
    end

    if key == keys.left then
      if level == 1 then
        clearScreen()
        printHeader("Exit")
        term.setCursorPos(1, ind)
        print("Are you sure you want to exit?")
        print("Press enter to confirm or any other key to cancel.")
        local event, key = os.pullEvent("key")
        if key == keys.enter then
          clearScreen()
          return
        end
      else
        level = osel[#osel]
        table.remove(osel, #osel)
      end
    end

    if key == keys.down then
      if csel < ava then
        csel = csel + 1
      else
        if page + 1 < totpage then
          page = page + 1
          csel = 1
        end
      end
    end

    if key == keys.up then
      if csel > 1 then
        csel = csel - 1
      else
        if page - 1 >= 0 then
          page = page - 1
          csel = ava
        end
      end
    end
  end
end

runMenu()
